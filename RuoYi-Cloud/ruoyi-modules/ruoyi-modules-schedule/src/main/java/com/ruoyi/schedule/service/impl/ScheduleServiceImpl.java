package com.ruoyi.schedule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.schedule.domain.Schedule;
import com.ruoyi.schedule.mapper.ScheduleMapper;
import com.ruoyi.schedule.service.IScheduleService;
import com.ruoyi.common.redis.service.RedisService;
import com.ruoyi.hospital.api.RemoteAppointmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.system.api.model.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.time.LocalTime;

import java.util.Random;

@Service
public class ScheduleServiceImpl extends ServiceImpl<ScheduleMapper, Schedule> implements IScheduleService {

    private static final Logger log = LoggerFactory.getLogger(ScheduleServiceImpl.class);

    @Autowired
    private ScheduleMapper scheduleMapper;

    @Autowired
    private RedisService redisService;

    @Autowired
    private RemoteAppointmentService remoteAppointmentService;

    private static final String SCHEDULE_SLOTS_KEY = "hospital:schedule:slots:";
    // 空值缓存过期时间（防止缓存穿透）
    private static final long NULL_CACHE_EXPIRE = 60L; 
    // 基础过期时间（秒）
    private static final long BASE_CACHE_EXPIRE = 24 * 60 * 60L; 

    /**
     * 生成排班号源 Redis 键。
     */
    private String getRedisKey(Long scheduleId) {
        return SCHEDULE_SLOTS_KEY + scheduleId;
    }
    
    /**
     * 获取带随机抖动的缓存过期时间。
     * 目的：让不同 key 的过期时刻分散，降低同一时刻集中失效风险。
     */
    // 获取带有随机波动的过期时间，防止缓存雪崩
    private long getRandomExpire() {
        // 在基础过期时间上增加 0-3600 秒（1小时）的随机值
        return BASE_CACHE_EXPIRE + new Random().nextInt(3600);
    }

    /**
     * 判断当前用户是否拥有指定角色。
     */
    private boolean hasRole(String role) {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null) return false;
        Set<String> roles = loginUser.getRoles();
        if (roles == null) return false;
        for (String r : roles) {
            if (role.equalsIgnoreCase(r)) return true;
        }
        return false;
    }

    /**
     * 判断当前用户是否为医生。
     */
    private boolean isDoctor() {
        return hasRole("doctor");
    }

    /**
     * 判断当前用户是否为患者。
     */
    private boolean isPatient() {
        return hasRole("patient");
    }

    /**
     * 查询排班列表：医生仅看本人，患者/匿名仅看可预约范围。
     */
    @Override
    public List<Schedule> selectScheduleList(Schedule schedule) {
        // 步骤1：按角色设置查询过滤条件
        if (isDoctor()) {
            Long userId = SecurityUtils.getUserId();
            log.info("Doctor role detected, filtering schedule by doctorId: {}", userId);
            schedule.setDoctorId(userId);
        } else if (isPatient() || SecurityUtils.getLoginUser() == null) {
            if (schedule.getParams() == null) {
                schedule.setParams(new java.util.HashMap<>());
            }
            schedule.getParams().put("forPatient", "true");
            schedule.getParams().put("daysFromToday", 7);
        }
        // 步骤2：执行查询
        return scheduleMapper.selectScheduleList(schedule);
    }

    /**
     * 查询排班详情，并进行号源缓存读写与穿透保护。
     */
    @Override
    public Schedule getById(java.io.Serializable id) {
        // 使用带有关联查询的方法获取详情
        Schedule query = new Schedule();
        query.setId((Long) id);
        
        // 1. 尝试从 Redis 获取号源 (缓存穿透与雪崩保护)
        String redisKey = getRedisKey((Long) id);
        Integer availableSlots = redisService.getCacheObject(redisKey);
        
        // 缓存穿透保护：缓存中的 -1 不是“真实号源”，而是“该排班不存在”的哨兵值
        // 命中该值时直接返回 null，避免每次都回源数据库
        if (availableSlots != null && availableSlots == -1) {
             // 这里的处理取决于业务，如果 id 对应的排班真的不存在，应该返回 null
             // 但 getById 的语义通常是查对象，如果号源是 -1，可能意味着排班对象缓存也空
             // 这里仅针对号源缓存。如果号源是-1，说明之前查过数据库不存在该排班。
             return null;
        }

        List<Schedule> list = scheduleMapper.selectScheduleList(query);
        Schedule schedule = (list != null && !list.isEmpty()) ? list.get(0) : null;
        
        if (schedule != null) {
            if (availableSlots != null) {
                schedule.setAvailableSlots(availableSlots);
            } else {
                // 缓存未命中，写入缓存（防止缓存雪崩：设置随机过期时间）
                redisService.setCacheObject(redisKey, schedule.getAvailableSlots(), getRandomExpire(), TimeUnit.SECONDS);
            }
        } else {
            // 缓存穿透保护：数据库也不存在，缓存空值（-1），设置较短过期时间
            redisService.setCacheObject(redisKey, -1, NULL_CACHE_EXPIRE, TimeUnit.SECONDS);
        }
        return schedule;
    }

    /**
     * 校验当天排班可设置的号源上限（按当前时间与班次计算）。
     */
    private void validateCapacityLimit(Schedule schedule) {
        // 前置条件不足时不校验（由上层业务决定是否强制必填）
        if (schedule.getWorkDate() == null || schedule.getTotalCapacity() == null) {
            return;
        }

        java.time.LocalDate workDate = schedule.getWorkDate().toInstant()
                .atZone(java.time.ZoneId.systemDefault()).toLocalDate();
        java.time.LocalDate today = java.time.LocalDate.now();

        // 只校验当天 (过去日期的排班通常不允许新增，未来日期不做时间限制)
        if (!workDate.equals(today)) {
            if (workDate.isBefore(today)) {
                // 过去的日期，理论上不允许新增排班，或者容量为0
            }
            // 非当天直接放行：本方法仅处理“当天动态可放号上限”
            return;
        }

        java.time.LocalTime now = java.time.LocalTime.now();
        int maxCapacity = 0;
        String timeSlot = schedule.getTimeSlot();

        // 定义时间段
        java.time.LocalTime amStart = java.time.LocalTime.of(8, 0);
        java.time.LocalTime amEnd = java.time.LocalTime.of(11, 30);
        java.time.LocalTime pmStart = java.time.LocalTime.of(14, 0);
        java.time.LocalTime pmEnd = java.time.LocalTime.of(17, 30);

        // 计算上午剩余号源
        int amSlots = 0;
        if (now.isBefore(amEnd)) {
            // 若当前时间早于开诊时间，按开诊时间算；否则从“当前时刻”开始算
            java.time.LocalTime start = now.isBefore(amStart) ? amStart : now;
            long minutes = java.time.Duration.between(start, amEnd).toMinutes();
            // 按每 15 分钟一个可预约时段折算可放号数
            amSlots = (int) (minutes / 15);
        }

        // 计算下午剩余号源
        int pmSlots = 0;
        if (now.isBefore(pmEnd)) {
            java.time.LocalTime start = now.isBefore(pmStart) ? pmStart : now;
            // 如果当前时间在中午休息时间，则从下午开始算
            if (start.isBefore(pmStart)) {
                start = pmStart;
            }
            long minutes = java.time.Duration.between(start, pmEnd).toMinutes();
            // 与上午一致，下午也按 15 分钟粒度折算
            pmSlots = (int) (minutes / 15);
        }

        if ("上午".equals(timeSlot)) {
            maxCapacity = amSlots;
        } else if ("下午".equals(timeSlot)) {
            maxCapacity = pmSlots;
        } else if ("全天".equals(timeSlot)) {
            maxCapacity = amSlots + pmSlots;
        }
        // 若班次值非法（非上午/下午/全天），maxCapacity 会保持 0，后续会触发容量超限保护

        // 允许少量的误差或特殊情况？ 暂时严格校验
        if (schedule.getTotalCapacity() > maxCapacity) {
            throw new ServiceException("当前时间已超过部分排班时段，该班次最多只能设置 " + maxCapacity + " 个号源");
        }
    }

    /**
     * 根据班次与预约时间，计算对应的时段序号。
     */
    private int calculateSlotIndexByTime(String timeSlot, String appointmentTime) {
        // 非法时间字符串直接判定为无效时段
        if (appointmentTime == null || appointmentTime.length() < 5) {
            return 0;
        }

        LocalTime time;
        try {
            time = LocalTime.parse(appointmentTime);
        } catch (Exception e) {
            return 0;
        }

        LocalTime amStart = LocalTime.of(8, 0);
        LocalTime amLast = LocalTime.of(11, 15);
        LocalTime pmStart = LocalTime.of(14, 0);
        LocalTime pmLast = LocalTime.of(17, 15);

        if ("上午".equals(timeSlot)) {
            if (time.isBefore(amStart) || time.isAfter(amLast)) {
                // 返回 0 表示该预约时间不在班次可识别范围内
                return 0;
            }
            // +1 表示槽位序号从 1 开始，而非 0
            return (int) (java.time.Duration.between(amStart, time).toMinutes() / 15) + 1;
        }

        if ("下午".equals(timeSlot)) {
            if (time.isBefore(pmStart) || time.isAfter(pmLast)) {
                return 0;
            }
            return (int) (java.time.Duration.between(pmStart, time).toMinutes() / 15) + 1;
        }

        if ("全天".equals(timeSlot)) {
            if (!time.isBefore(amStart) && !time.isAfter(amLast)) {
                return (int) (java.time.Duration.between(amStart, time).toMinutes() / 15) + 1;
            }
            if (!time.isBefore(pmStart) && !time.isAfter(pmLast)) {
                // 全天班次中，下午序号接在上午后面；14 表示上午共有 14 个 15 分钟时段
                return 14 + (int) (java.time.Duration.between(pmStart, time).toMinutes() / 15) + 1;
            }
        }

        return 0;
    }

    /**
     * 根据最晚已预约时段，计算可调整的最小号源下限。
     */
    private int getMinCapacityByLatestBookedSlot(Schedule current) {
        // 通过预约服务查询“最晚已占用时段”，作为缩容下限依据
        ResultVO<String> latestBookedResult = remoteAppointmentService.getLatestBookedTime(current.getId());
        if (latestBookedResult == null || latestBookedResult.getCode() != ResultVO.SUCCESS) {
            throw new ServiceException("查询最晚预约时段失败");
        }

        String latestBookedTime = latestBookedResult.getData();
        if (latestBookedTime == null || latestBookedTime.trim().isEmpty()) {
            // 没有任何已预约记录，则容量下限为 0
            return 0;
        }

        int minCapacity = calculateSlotIndexByTime(current.getTimeSlot(), latestBookedTime);
        if (minCapacity <= 0) {
            // 最晚预约时间无法映射到合法槽位，视为数据异常
            throw new ServiceException("预约时段数据异常，无法调整号源");
        }
        return minCapacity;
    }

    /**
     * 判断两个日期是否为同一天（忽略时分秒）。
     */
    private boolean isSameDate(Date d1, Date d2) {
        if (d1 == null || d2 == null) {
            return false;
        }
        java.time.LocalDate ld1 = d1.toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDate();
        java.time.LocalDate ld2 = d2.toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDate();
        return ld1.equals(ld2);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean insertSchedule(Schedule schedule) {
        // 步骤1：医生新增时强制绑定本人 doctorId，并进行容量时间校验
        if (isDoctor()) {
            Long userId = SecurityUtils.getUserId();
            log.info("Doctor role detected, setting doctorId to: {}", userId);
            schedule.setDoctorId(userId);
            
            if (schedule.getTotalCapacity() == null) {
                throw new ServiceException("总号源数不能为空");
            }
            // 医生新增排班时进行时间校验
            validateCapacityLimit(schedule);
        }
        
        // 步骤2：校验医生信息必须存在
        if (schedule.getDoctorId() == null) {
            throw new ServiceException("医生信息不能为空");
        }

        // 检查排班冲突：仅“正常(0)”和“有调整(1)”状态视为有效冲突
        // 已取消排班保留在列表中，但不阻止同日期新增排班
        Long count = scheduleMapper.selectCount(new LambdaQueryWrapper<Schedule>()
                .eq(Schedule::getDoctorId, schedule.getDoctorId())
                .eq(Schedule::getWorkDate, schedule.getWorkDate())
                .in(Schedule::getStatus, Arrays.asList(0, 1)));
        if (count > 0) {
            throw new ServiceException("该医生在 " + schedule.getWorkDate() + " 已有有效排班，请勿重复操作");
        }

        // 步骤3：初始化可用号源与状态（医生新增默认待审核）
        schedule.setAvailableSlots(schedule.getTotalCapacity());
        if (isDoctor()) {
            schedule.setStatus(3);
        } else {
            schedule.setStatus(0);
        }
        // 步骤4：保存并回写 Redis 缓存
        boolean saved = this.save(schedule);
        if (saved) {
            // 写入 Redis 缓存 (设置随机过期时间)
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), getRandomExpire(), TimeUnit.SECONDS);
        }
        return saved;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateSchedule(Schedule schedule) {
        // 步骤1：读取当前排班，确保目标存在
        Schedule current = super.getById(schedule.getId());
        if (current == null) {
            throw new ServiceException("排班不存在");
        }

        // 步骤2：医生端特定逻辑（识别取消申请/变更并自动映射审核状态）
        if (isDoctor()) {
            // requestCancel=true 代表医生端显式将状态改为“已取消(2)”的请求
            // 实际会先转成“待审核(3)”，由管理员审核通过后再真正变更
            boolean requestCancel = schedule.getStatus() != null && schedule.getStatus() == 2;
            boolean isChanged = false;
            // 医生端只要改了“总号源/班次”，都视为排班变更，后续通常需要管理员审核
            if (schedule.getTotalCapacity() != null && !schedule.getTotalCapacity().equals(current.getTotalCapacity())) {
                isChanged = true;
            }
            if (schedule.getTimeSlot() != null && !schedule.getTimeSlot().equals(current.getTimeSlot())) {
                isChanged = true;
                // 班次变化会影响已预约时间归属，先通知预约模块同步时段
                remoteAppointmentService.syncTimeChange(current.getId(), current.getTimeSlot(), schedule.getTimeSlot());
            }

            // 医生修改排班时进行时间校验 (仅当修改了容量或班次时)
            if (isChanged || schedule.getWorkDate() != null) {
                // 如果只改了容量，没传 workDate/timeSlot，需补全信息用于校验
                if (schedule.getWorkDate() == null) schedule.setWorkDate(current.getWorkDate());
                if (schedule.getTimeSlot() == null) schedule.setTimeSlot(current.getTimeSlot());
                if (schedule.getTotalCapacity() == null) schedule.setTotalCapacity(current.getTotalCapacity());
                validateCapacityLimit(schedule);
            }

            if (requestCancel) {
                if (current.getStatus() != null && current.getStatus() == 2) {
                    throw new ServiceException("该排班已取消，请勿重复操作");
                }
                if (current.getStatus() != null && current.getStatus() == 3) {
                    throw new ServiceException("该排班取消申请已提交，请等待管理员审核");
                }
                // 医生取消排班时仅提交审核，审核通过后由管理员完成真正取消
                schedule.setStatus(3);
            } else if (isChanged) {
                // 医生修改关键字段也进入待审核
                schedule.setStatus(3);
            } else {
                // 无关键变更时维持原状态
                schedule.setStatus(current.getStatus());
            }
        }

        // 步骤3：检查号源是否已满（已满时限制调整日期或取消）
        // 从 Redis 获取最新号源数进行判断
        Integer currentAvailable = redisService.getCacheObject(getRedisKey(schedule.getId()));
        if (currentAvailable == null) {
            currentAvailable = current.getAvailableSlots();
        }
        
        boolean isFull = currentAvailable <= 0;
        boolean changeWorkDate = schedule.getWorkDate() != null && !isSameDate(schedule.getWorkDate(), current.getWorkDate());
        boolean changeToCancel = schedule.getStatus() != null && schedule.getStatus() == 2;
        if (isFull && (changeWorkDate || changeToCancel)) {
            // 注意：如果是取消预约导致的 availableSlots 增加，不应该拦截。但这里的 updateSchedule 是管理端/医生端发起的修改
            // 如果是预约模块调用的“仅同步可用号源”更新，不属于人工调整，不拦截
            if (!(schedule.getAvailableSlots() != null && schedule.getTotalCapacity() == null)) {
                throw new ServiceException("患者已预约满号源，不允许调整或取消");
            }
        }

        // 步骤4：检查排班冲突（仅正常/有调整状态参与冲突判定）
        if (schedule.getDoctorId() != null && schedule.getWorkDate() != null) {
            Long conflictCount = scheduleMapper.selectCount(new LambdaQueryWrapper<Schedule>()
                    .eq(Schedule::getDoctorId, schedule.getDoctorId())
                    .eq(Schedule::getWorkDate, schedule.getWorkDate())
                    .ne(Schedule::getId, schedule.getId())
                    .in(Schedule::getStatus, Arrays.asList(0, 1)));
            if (conflictCount > 0) {
                throw new ServiceException("该医生在 " + schedule.getWorkDate() + " 已有其他排班记录");
            }
        }
        
        // 步骤5：处理号源调整（含最晚预约时段下限校验与必要的预约迁移）
        if (schedule.getTotalCapacity() != null) {
            int minCapacityByLatestBookedSlot = getMinCapacityByLatestBookedSlot(current);
            if (schedule.getTotalCapacity() < minCapacityByLatestBookedSlot) {
                throw new ServiceException("调整后号源数量不能低于最晚已预约时段序号(" + minCapacityByLatestBookedSlot + ")");
            }

            int usedSlots = current.getTotalCapacity() - currentAvailable;
            // usedSlots = 已占用号源数（总号源 - 可用号源）
            if (schedule.getTotalCapacity() < usedSlots) {
                // 如果新容量小于已预约人数，尝试将多出的预约分配到该医生当天的其他排班
                int toMoveCount = usedSlots - schedule.getTotalCapacity();
                log.info("Capacity reduced below booked count. Attempting to move {} appointments.", toMoveCount);
                
                // 查找该医生当天的其他可用排班
                List<Schedule> otherSchedules = this.list(new LambdaQueryWrapper<Schedule>()
                        .eq(Schedule::getDoctorId, current.getDoctorId())
                        .eq(Schedule::getWorkDate, current.getWorkDate())
                        .ne(Schedule::getId, current.getId())
                        .gt(Schedule::getAvailableSlots, 0)
                        .eq(Schedule::getStatus, 0)); // 只找正常的
                
                if (otherSchedules.isEmpty()) {
                    throw new ServiceException("总号源数不能小于已预约人数 (" + usedSlots + ")，且当天无其他可用排班进行分配");
                }
                
                // 尝试依次分配
                int remainingToMove = toMoveCount;
                for (Schedule other : otherSchedules) {
                    int moveCount = Math.min(remainingToMove, other.getAvailableSlots());
                    if (moveCount > 0) {
                        // 调预约模块执行迁移，确保预约记录与排班容量保持一致
                        remoteAppointmentService.reassign(current.getId(), other.getId(), moveCount);
                        // 更新目标排班的可用号源
                        other.setAvailableSlots(other.getAvailableSlots() - moveCount);
                        this.updateById(other);
                        // 同步更新 Redis
                        redisService.setCacheObject(getRedisKey(other.getId()), other.getAvailableSlots(), getRandomExpire(), TimeUnit.SECONDS);
                        
                        remainingToMove -= moveCount;
                        if (remainingToMove <= 0) break;
                    }
                }
                
                if (remainingToMove > 0) {
                    // 能进到这里说明“可迁移目标排班”总空位仍不够
                    throw new ServiceException("当天其他排班号源不足，无法分配多出的 " + remainingToMove + " 个预约");
                }
                
                // 分配成功后，当前排班的已预约人数变为新容量，可用号源变为 0
                usedSlots = schedule.getTotalCapacity();
            }
            
            schedule.setAvailableSlots(schedule.getTotalCapacity() - usedSlots);
            // 更新 Redis
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), getRandomExpire(), TimeUnit.SECONDS);
            
            // 如果状态还是正常(0)，则改为有调整(1)
            // 注意：仅在本次请求未显式设置 status 时，才自动改状态，避免覆盖上层明确意图
            if (current.getStatus() == 0 && schedule.getStatus() == null) {
                schedule.setStatus(1);
            }
        } else if (schedule.getAvailableSlots() != null) {
            // 如果是通过预约模块调用的 update (只更新 availableSlots)
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), getRandomExpire(), TimeUnit.SECONDS);
        }

        // 步骤6：处理状态变更（取消时级联取消预约并同步缓存）
        if (schedule.getStatus() != null) {
            // 如果变更为已取消(2)
            if (schedule.getStatus() == 2) {
                // 级联取消所有预约
                remoteAppointmentService.cancelByScheduleId(schedule.getId());
                // 清理 Redis (或者将号源置为0，防止继续预约)
                // 这里采用“置0并保留key”的方式，避免短时间内再次回源时出现不一致
                redisService.setCacheObject(getRedisKey(schedule.getId()), 0, getRandomExpire(), TimeUnit.SECONDS);
                schedule.setAvailableSlots(0);
            }
        }
        
        return updateById(schedule);
    }

    /**
     * 批量删除排班：医生提交删除申请，管理员执行逻辑删除。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteScheduleByIds(Long[] ids) {
        if (isDoctor()) {
            List<Schedule> list = listByIds(Arrays.asList(ids));
            java.time.LocalDate today = java.time.LocalDate.now();
            Long currentUserId = SecurityUtils.getUserId();
            
            for (Schedule schedule : list) {
                // 1. 只能删除自己的排班
                if (!schedule.getDoctorId().equals(currentUserId)) {
                    throw new ServiceException("无权删除其他医生的排班");
                }
                
                // 2. 仅允许申请删除日期大于今天的排班
                if (schedule.getWorkDate() != null) {
                    java.time.LocalDate workDate = schedule.getWorkDate().toInstant()
                            .atZone(java.time.ZoneId.systemDefault()).toLocalDate();
                    if (!workDate.isAfter(today)) {
                        throw new ServiceException("仅可申请删除日期大于今天的排班 (" + schedule.getWorkDate() + ")");
                    }
                }

                // 3. 仅允许申请删除状态为已取消(2)的排班
                if (schedule.getStatus() == null || schedule.getStatus() != 2) {
                    throw new ServiceException("仅可申请删除状态为“已取消”的排班");
                }
            }
            
            // 4. 医生删除操作：状态改为 3 (待审核)，等待管理员审核
            // 这里不做物理删除，保留记录供管理员审核与追踪
            boolean allUpdated = true;
            for (Schedule schedule : list) {
                // 如果已经是待审核状态，不允许重复提交
                if (schedule.getStatus() == 3) {
                    throw new ServiceException("排班 " + schedule.getWorkDate() + " 已在审核中，请勿重复申请");
                }
                
                schedule.setStatus(3); 
                // 仅更新状态为待审核
                allUpdated &= update(new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<Schedule>()
                        .set("status", 3)
                        .eq("id", schedule.getId()));
                
                // 为了防止后续预约，这里可以将可用号源暂时置为0 (如果需要的话，但恢复比较麻烦)
                // 或者依赖前端/后端在预约时检查状态
                // 假设预约逻辑会检查 status != 0 && status != 1，那么状态 3 就会阻止预约
            }
            return allUpdated;
        }

        // 管理员直接删除
        for (Long id : ids) {
            // 先删缓存，避免逻辑删除后仍读取到旧号源
            redisService.deleteObject(getRedisKey(id));
        }
        // 逻辑删除：仅打标记，便于回收站恢复
        return update(new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<Schedule>()
                .set("is_deleted", 1)
                .set("deleted_at", new Date())
                .in("id", Arrays.asList(ids)));
    }

    /**
     * 批量恢复已删除排班，并重建号源缓存。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean recoverScheduleByIds(Long[] ids) {
        int recovered = scheduleMapper.recoverScheduleByIds(ids);
        if (recovered <= 0) {
            return false;
        }

        List<Schedule> list = listByIds(Arrays.asList(ids));
        for (Schedule schedule : list) {
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), getRandomExpire(), TimeUnit.SECONDS);
        }
        return true;
    }
}
