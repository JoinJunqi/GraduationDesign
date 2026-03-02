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

    private String getRedisKey(Long scheduleId) {
        return SCHEDULE_SLOTS_KEY + scheduleId;
    }

    private boolean isDoctor() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null) return false;
        Set<String> roles = loginUser.getRoles();
        return roles != null && roles.contains("doctor");
    }

    private boolean isPatient() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null) return false;
        Set<String> roles = loginUser.getRoles();
        return roles != null && roles.contains("patient");
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
        List<Schedule> list = scheduleMapper.selectScheduleList(query);
        Schedule schedule = (list != null && !list.isEmpty()) ? list.get(0) : null;
        
        if (schedule != null) {
            // 从 Redis 获取最新号源数
            Integer availableSlots = redisService.getCacheObject(getRedisKey(schedule.getId()));
            if (availableSlots != null) {
                schedule.setAvailableSlots(availableSlots);
            } else {
                // 如果 Redis 没有，缓存一份，设置 24 小时过期
                redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), 24L, TimeUnit.HOURS);
            }
        }
        return schedule;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean insertSchedule(Schedule schedule) {
        if (isDoctor()) {
            Long userId = SecurityUtils.getUserId();
            log.info("Doctor role detected, setting doctorId to: {}", userId);
            schedule.setDoctorId(userId);
        }
        
        if (schedule.getDoctorId() == null) {
            throw new ServiceException("医生信息不能为空");
        }

        // 检查排班冲突 (同一天只能有一个排班记录)
        Long count = scheduleMapper.selectCount(new LambdaQueryWrapper<Schedule>()
                .eq(Schedule::getDoctorId, schedule.getDoctorId())
                .eq(Schedule::getWorkDate, schedule.getWorkDate()));
        if (count > 0) {
            throw new ServiceException("该医生在 " + schedule.getWorkDate() + " 已有排班，请勿重复操作");
        }

        schedule.setAvailableSlots(schedule.getTotalCapacity());
        if (isDoctor()) {
            schedule.setStatus(3);
        } else {
            schedule.setStatus(0);
        }
        boolean saved = this.save(schedule);
        if (saved) {
            // 写入 Redis 缓存
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), 24L, TimeUnit.HOURS);
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
                        redisService.setCacheObject(getRedisKey(other.getId()), other.getAvailableSlots(), 24L, TimeUnit.HOURS);
                        
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
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), 24L, TimeUnit.HOURS);
            
            // 如果状态还是正常(0)，则改为有调整(1)
            if (current.getStatus() == 0 && schedule.getStatus() == null) {
                schedule.setStatus(1);
            }
        } else if (schedule.getAvailableSlots() != null) {
            // 如果是通过预约模块调用的 update (只更新 availableSlots)
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), 24L, TimeUnit.HOURS);
        }

        // 4. 处理状态变更
        if (schedule.getStatus() != null) {
            // 如果变更为已取消(2)
            if (schedule.getStatus() == 2) {
                // 级联取消所有预约
                remoteAppointmentService.cancelByScheduleId(schedule.getId());
                // 清理 Redis (或者将号源置为0，防止继续预约)
                redisService.setCacheObject(getRedisKey(schedule.getId()), 0, 24L, TimeUnit.HOURS);
                schedule.setAvailableSlots(0);
            }
        }
        
        return updateById(schedule);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteScheduleByIds(Long[] ids) {
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
            redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), 24L, TimeUnit.HOURS);
        }
        return update(new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<Schedule>()
                .set("is_deleted", 0)
                .set("deleted_at", null)
                .in("id", Arrays.asList(ids)));
    }
}
