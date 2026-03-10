package com.ruoyi.schedule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
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

    private String getRedisKey(Long scheduleId) {
        return SCHEDULE_SLOTS_KEY + scheduleId;
    }
    
    // 获取带有随机波动的过期时间，防止缓存雪崩
    private long getRandomExpire() {
        // 在基础过期时间上增加 0-3600 秒（1小时）的随机值
        return BASE_CACHE_EXPIRE + new Random().nextInt(3600);
    }

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

    private boolean isDoctor() {
        return hasRole("doctor");
    }

    private boolean isPatient() {
        return hasRole("patient");
    }

    @Override
    public List<Schedule> selectScheduleList(Schedule schedule) {
        if (isDoctor()) {
            Long userId = SecurityUtils.getUserId();
            log.info("Doctor role detected, filtering schedule by doctorId: {}", userId);
            schedule.setDoctorId(userId);
        } else if (isPatient()) {
            if (schedule.getParams() == null) {
                schedule.setParams(new java.util.HashMap<>());
            }
            schedule.getParams().put("forPatient", "true");
            schedule.getParams().put("daysFromToday", 7);
        }
        return scheduleMapper.selectScheduleList(schedule);
    }

    @Override
    public Schedule getById(java.io.Serializable id) {
        // 使用带有关联查询的方法获取详情
        Schedule query = new Schedule();
        query.setId((Long) id);
        
        // 1. 尝试从 Redis 获取号源 (缓存穿透与雪崩保护)
        String redisKey = getRedisKey((Long) id);
        Integer availableSlots = redisService.getCacheObject(redisKey);
        
        // 缓存穿透保护：如果缓存中是特殊标记（如-1），说明数据库也不存在，直接返回 null 或抛异常
        if (availableSlots != null && availableSlots == -1) {
             // 这里的处理取决于业务，如果 id 对应的排班真的不存在，应该返回 null
             // 但 getById 的语义通常是查对象，如果号源是 -1，可能意味着排班对象缓存也空？
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

    // 校验号源上限逻辑
    private void validateCapacityLimit(Schedule schedule) {
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
                // 这里暂不强制抛异常，除非业务要求严格禁止补录
            }
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
            java.time.LocalTime start = now.isBefore(amStart) ? amStart : now;
            long minutes = java.time.Duration.between(start, amEnd).toMinutes();
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
            pmSlots = (int) (minutes / 15);
        }

        if ("上午".equals(timeSlot)) {
            maxCapacity = amSlots;
        } else if ("下午".equals(timeSlot)) {
            maxCapacity = pmSlots;
        } else if ("全天".equals(timeSlot)) {
            maxCapacity = amSlots + pmSlots;
        }

        // 允许少量的误差或特殊情况？ 暂时严格校验
        if (schedule.getTotalCapacity() > maxCapacity) {
            throw new ServiceException("当前时间已超过部分排班时段，该班次最多只能设置 " + maxCapacity + " 个号源");
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean insertSchedule(Schedule schedule) {
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
        
        if (schedule.getDoctorId() == null) {
            throw new ServiceException("医生信息不能为空");
        }

        // 检查排班冲突 (同一天只能有一个有效排班记录)
        // 排除已取消(2)和已驳回(5)的状态，允许重新排班
        Long count = scheduleMapper.selectCount(new LambdaQueryWrapper<Schedule>()
                .eq(Schedule::getDoctorId, schedule.getDoctorId())
                .eq(Schedule::getWorkDate, schedule.getWorkDate())
                .ne(Schedule::getStatus, 2)  // 排除已取消
                .ne(Schedule::getStatus, 5)); // 排除已驳回
        if (count > 0) {
            throw new ServiceException("该医生在 " + schedule.getWorkDate() + " 已有有效排班，请勿重复操作");
        }

        schedule.setAvailableSlots(schedule.getTotalCapacity());
        if (isDoctor()) {
            schedule.setStatus(3);
        } else {
            schedule.setStatus(0);
        }
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
        Schedule current = super.getById(schedule.getId());
        if (current == null) {
            throw new ServiceException("排班不存在");
        }

        // 医生端特定逻辑：自动匹配状态
        if (isDoctor()) {
            boolean isChanged = false;
            if (schedule.getTotalCapacity() != null && !schedule.getTotalCapacity().equals(current.getTotalCapacity())) {
                isChanged = true;
            }
            if (schedule.getTimeSlot() != null && !schedule.getTimeSlot().equals(current.getTimeSlot())) {
                isChanged = true;
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

            if (isChanged) {
                schedule.setStatus(3);
            } else {
                schedule.setStatus(current.getStatus());
            }
        }

        // 1. 检查号源是否已满 (针对调整或取消操作)
        // 从 Redis 获取最新号源数进行判断
        Integer currentAvailable = redisService.getCacheObject(getRedisKey(schedule.getId()));
        if (currentAvailable == null) {
            currentAvailable = current.getAvailableSlots();
        }
        
        boolean isFull = currentAvailable <= 0;
        boolean changeCapacityOrDate = schedule.getTotalCapacity() != null || schedule.getWorkDate() != null;
        boolean changeToCancel = schedule.getStatus() != null && schedule.getStatus() == 2;
        if (isFull && (changeCapacityOrDate || changeToCancel)) {
            // 注意：如果是取消预约导致的 availableSlots 增加，不应该拦截。但这里的 updateSchedule 是管理端/医生端发起的修改
            // 如果是预约模块调用的 (schedule.getAvailableSlots() != null && schedule.getTotalCapacity() == null)，不拦截
            if (!(schedule.getAvailableSlots() != null && schedule.getTotalCapacity() == null)) {
                throw new ServiceException("患者已预约满号源，不允许调整或取消");
            }
        }

        // 2. 检查排班冲突 (仅在修改了日期时检查)
        if (schedule.getDoctorId() != null && schedule.getWorkDate() != null) {
            Schedule existingSchedule = scheduleMapper.selectOne(new LambdaQueryWrapper<Schedule>()
                    .eq(Schedule::getDoctorId, schedule.getDoctorId())
                    .eq(Schedule::getWorkDate, schedule.getWorkDate()));
            if (existingSchedule != null && !existingSchedule.getId().equals(schedule.getId())) {
                throw new ServiceException("该医生在 " + schedule.getWorkDate() + " 已有其他排班记录");
            }
        }
        
        // 3. 处理号源调整
        if (schedule.getTotalCapacity() != null) {
            int usedSlots = current.getTotalCapacity() - currentAvailable;
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
                    throw new ServiceException("当天其他排班号源不足，无法分配多出的 " + remainingToMove + " 个预约");
                }
                
                // 分配成功后，当前排班的已预约人数变为新容量，可用号源变为 0
                usedSlots = schedule.getTotalCapacity();
            }
            
            schedule.setAvailableSlots(schedule.getTotalCapacity() - usedSlots);
            // 更新 Redis
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), getRandomExpire(), TimeUnit.SECONDS);
            
            // 如果状态还是正常(0)，则改为有调整(1)
            if (current.getStatus() == 0 && schedule.getStatus() == null) {
                schedule.setStatus(1);
            }
        } else if (schedule.getAvailableSlots() != null) {
            // 如果是通过预约模块调用的 update (只更新 availableSlots)
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), getRandomExpire(), TimeUnit.SECONDS);
        }

        // 4. 处理状态变更
        if (schedule.getStatus() != null) {
            // 如果变更为已取消(2)
            if (schedule.getStatus() == 2) {
                // 级联取消所有预约
                remoteAppointmentService.cancelByScheduleId(schedule.getId());
                // 清理 Redis (或者将号源置为0，防止继续预约)
                redisService.setCacheObject(getRedisKey(schedule.getId()), 0, getRandomExpire(), TimeUnit.SECONDS);
                schedule.setAvailableSlots(0);
            }
        }
        
        return updateById(schedule);
    }

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
                
                // 2. 检查日期：小于今天的不可删除
                if (schedule.getWorkDate() != null) {
                    java.time.LocalDate workDate = schedule.getWorkDate().toInstant()
                            .atZone(java.time.ZoneId.systemDefault()).toLocalDate();
                    if (workDate.isBefore(today)) {
                        throw new ServiceException("无法删除过去日期的排班 (" + schedule.getWorkDate() + ")");
                    }
                }
            }
            
            // 3. 医生删除操作：状态改为 3 (待审核)，等待管理员审核
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
            redisService.deleteObject(getRedisKey(id));
        }
        return update(new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<Schedule>()
                .set("is_deleted", 1)
                .set("deleted_at", new Date())
                .in("id", Arrays.asList(ids)));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean recoverScheduleByIds(Long[] ids) {
        List<Schedule> list = listByIds(Arrays.asList(ids));
        for (Schedule schedule : list) {
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), getRandomExpire(), TimeUnit.SECONDS);
        }
        return update(new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<Schedule>()
                .set("is_deleted", 0)
                .set("deleted_at", null)
                .in("id", Arrays.asList(ids)));
    }
}
