package com.ruoyi.schedule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.schedule.domain.Schedule;
import com.ruoyi.schedule.mapper.ScheduleMapper;
import com.ruoyi.schedule.service.IScheduleService;
import com.ruoyi.common.redis.service.RedisService;
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

    @Override
    public List<Schedule> selectScheduleList(Schedule schedule) {
        if (isDoctor()) {
            Long userId = SecurityUtils.getUserId();
            log.info("Doctor role detected, filtering schedule by doctorId: {}", userId);
            schedule.setDoctorId(userId);
        }
        return scheduleMapper.selectScheduleList(schedule);
    }

    @Override
    public Schedule getById(java.io.Serializable id) {
        Schedule schedule = super.getById(id);
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
        // 检查排班冲突 (仅在修改了日期时检查)
        if (schedule.getDoctorId() != null && schedule.getWorkDate() != null) {
            Schedule existingSchedule = scheduleMapper.selectOne(new LambdaQueryWrapper<Schedule>()
                    .eq(Schedule::getDoctorId, schedule.getDoctorId())
                    .eq(Schedule::getWorkDate, schedule.getWorkDate()));
            if (existingSchedule != null && !existingSchedule.getId().equals(schedule.getId())) {
                throw new ServiceException("该医生在 " + schedule.getWorkDate() + " 已有其他排班记录");
            }
        }
        
        // 如果修改了总号源数，需要相应调整剩余号源数
        if (schedule.getTotalCapacity() != null || schedule.getAvailableSlots() != null) {
            Schedule current = super.getById(schedule.getId());
            if (current == null) {
                throw new ServiceException("排班不存在");
            }
            
            // 如果是通过预约模块调用的 update (只更新 availableSlots)
            if (schedule.getAvailableSlots() != null && schedule.getTotalCapacity() == null) {
                // 更新 Redis
                redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), 24L, TimeUnit.HOURS);
            } else if (schedule.getTotalCapacity() != null) {
                // 如果是管理端修改总号源
                // 注意：这里需要考虑当前 Redis 中的实际占用情况，而不是数据库中的
                Integer currentAvailable = redisService.getCacheObject(getRedisKey(schedule.getId()));
                if (currentAvailable == null) {
                    currentAvailable = current.getAvailableSlots();
                }
                
                int usedSlots = current.getTotalCapacity() - currentAvailable;
                if (schedule.getTotalCapacity() < usedSlots) {
                    throw new ServiceException("总号源数不能小于已预约人数 (" + usedSlots + ")");
                }
                schedule.setAvailableSlots(schedule.getTotalCapacity() - usedSlots);
                // 更新 Redis
                redisService.setCacheObject(getRedisKey(schedule.getId()), schedule.getAvailableSlots(), 24L, TimeUnit.HOURS);
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
        Schedule schedule = new Schedule();
        schedule.setIsDeleted(1);
        schedule.setDeletedAt(new Date());
        return update(schedule, new LambdaQueryWrapper<Schedule>().in(Schedule::getId, Arrays.asList(ids)));
    }
}
