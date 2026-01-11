package com.ruoyi.appointment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.hospital.api.RemoteScheduleService;
import com.ruoyi.hospital.api.domain.Schedule;
import com.ruoyi.appointment.domain.Appointment;
import com.ruoyi.appointment.mapper.AppointmentMapper;
import com.ruoyi.appointment.service.IAppointmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.system.api.model.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.ruoyi.common.redis.service.RedisService;

@Service
public class AppointmentServiceImpl extends ServiceImpl<AppointmentMapper, Appointment> implements IAppointmentService {

    private static final Logger log = LoggerFactory.getLogger(AppointmentServiceImpl.class);

    @Autowired
    private AppointmentMapper appointmentMapper;

    @Autowired
    private RemoteScheduleService remoteScheduleService;

    @Autowired
    private RedisService redisService;

    private static final String SCHEDULE_SLOTS_KEY = "hospital:schedule:slots:";

    private String getScheduleRedisKey(Long scheduleId) {
        return SCHEDULE_SLOTS_KEY + scheduleId;
    }

    private boolean hasRole(String role) {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getRoles() == null) {
            return false;
        }
        return loginUser.getRoles().contains(role);
    }

    @Override
    public List<Appointment> selectAppointmentList(Appointment appointment) {
        Long userId = SecurityUtils.getUserId();
        Set<String> roles = SecurityUtils.getLoginUser().getRoles();
        log.info("selectAppointmentList - userId: {}, roles: {}, appointment: {}", userId, roles, appointment);

        if (hasRole("admin")) {
            // 管理员可以看所有
            log.info("Admin access: viewing all appointments");
        } else if (hasRole("doctor")) {
            // 医生看自己的患者预约
            log.info("Doctor access: filtering by doctorId={}", userId);
            appointment.setDoctorId(userId);
        } else if (hasRole("patient")) {
            // 患者看自己的预约
            log.info("Patient access: filtering by patientId={}", userId);
            appointment.setPatientId(userId);
        } else {
            // 默认患者视角
            log.info("Default/Other access: filtering by patientId={}", userId);
            appointment.setPatientId(userId);
        }
        
        log.info("Executing selectAppointmentList with params: patientId={}, doctorId={}, patientName={}, status={}", 
                 appointment.getPatientId(), appointment.getDoctorId(), appointment.getPatientName(), appointment.getStatus());
                 
        List<Appointment> list = appointmentMapper.selectAppointmentList(appointment);
        log.info("selectAppointmentList result size: {}", list != null ? list.size() : 0);
        return list;
    }

    @Override
    public Map<String, Object> selectAppointmentStats() {
        Map<String, Object> stats = new HashMap<>();
        
        // 总预约数
        stats.put("totalCount", this.count());
        
        // 待就诊数
        stats.put("pendingCount", this.count(new LambdaQueryWrapper<Appointment>().eq(Appointment::getStatus, "待就诊")));
        
        // 已完成数
        stats.put("completedCount", this.count(new LambdaQueryWrapper<Appointment>().eq(Appointment::getStatus, "已完成")));
        
        // 已取消数
        stats.put("cancelledCount", this.count(new LambdaQueryWrapper<Appointment>().eq(Appointment::getStatus, "已取消")));
        
        return stats;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean createAppointment(Appointment appointment) {
        log.info("Starting createAppointment for patient: {}, schedule: {}", 
                 appointment.getPatientId(), appointment.getScheduleId());
                 
        // 0. 设置患者ID (如果是患者角色，强制设置为当前登录用户)
        if (hasRole("patient")) {
            appointment.setPatientId(SecurityUtils.getUserId());
            log.info("Forced patient ID from SecurityUtils: {}", appointment.getPatientId());
        }
        
        if (appointment.getPatientId() == null) {
            throw new ServiceException("患者信息不能为空");
        }

        // 1. 检查是否重复预约 (同一个排班不能重复预约)
        Long count = this.count(new LambdaQueryWrapper<Appointment>()
                .eq(Appointment::getPatientId, appointment.getPatientId())
                .eq(Appointment::getScheduleId, appointment.getScheduleId())
                .ne(Appointment::getStatus, "已取消"));
        if (count > 0) {
            log.warn("Duplicate appointment detected for patient {} and schedule {}", 
                     appointment.getPatientId(), appointment.getScheduleId());
            throw new ServiceException("您已预约过该时段，请勿重复预约");
        }

        // 2. 检查排班是否存在及剩余号源 (Redis 优先)
        Long scheduleId = appointment.getScheduleId();
        String redisKey = getScheduleRedisKey(scheduleId);
        log.info("Checking Redis slots for key: {}", redisKey);
        
        // 使用 Redis 递减操作 (原子性)
        Long remaining = redisService.redisTemplate.opsForValue().decrement(redisKey);
        log.info("Redis decrement result for key {}: {}", redisKey, remaining);
        
        if (remaining != null && remaining < 0) {
            // 如果 decrement 返回负数，说明之前没有这个 key 或者已经没号了
            // 尝试加载一次 (防止缓存过期导致的 -1)
            ResultVO<Schedule> scheduleResult = remoteScheduleService.getById(scheduleId);
            if (scheduleResult != null && scheduleResult.getData() != null) {
                Schedule schedule = scheduleResult.getData();
                if (schedule.getAvailableSlots() > 0) {
                    // 重新设置 Redis (这里可能存在微小的并发问题，但比直接报错强)
                    int newRemaining = schedule.getAvailableSlots() - 1;
                    redisService.setCacheObject(redisKey, newRemaining, 24L, java.util.concurrent.TimeUnit.HOURS);
                    remaining = (long) newRemaining;
                } else {
                    // 确实没号了，回退递减
                    redisService.redisTemplate.opsForValue().increment(redisKey);
                    log.warn("No slots available in Redis for schedule {}", scheduleId);
                    throw new ServiceException("号源已满");
                }
            } else {
                // 排班不存在，回退递减
                redisService.redisTemplate.opsForValue().increment(redisKey);
                throw new ServiceException("排班信息不存在");
            }
        } else if (remaining == null) {
            throw new ServiceException("系统繁忙，请稍后再试");
        }

        try {
            // 3. 同步到排班服务 (异步或后续同步，这里简单处理)
            Schedule updateSchedule = new Schedule();
            updateSchedule.setId(scheduleId);
            updateSchedule.setAvailableSlots(remaining.intValue());
            log.info("Updating remote schedule {} with remaining slots: {}", scheduleId, remaining);
            
            ResultVO<Boolean> updateResult = remoteScheduleService.update(updateSchedule);
            if (updateResult == null || !updateResult.getData()) {
                throw new ServiceException("同步排班信息失败");
            }

            // 4. 创建预约
            appointment.setStatus("待就诊");
            appointment.setBookedAt(new Date());
            log.info("Saving appointment record to database...");
            boolean saved = this.save(appointment);
            log.info("Appointment saved successfully: {}", saved);
            return saved;
        } catch (Exception e) {
            log.error("Error creating appointment, rolling back Redis slots...", e);
            // 数据库更新失败，回退 Redis
            redisService.redisTemplate.opsForValue().increment(redisKey);
            throw e;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean cancelAppointment(Long appointmentId) {
        Appointment appointment = this.getById(appointmentId);
        if (appointment == null) {
            throw new ServiceException("预约记录不存在");
        }
        
        if (!"待就诊".equals(appointment.getStatus())) {
            throw new ServiceException("当前状态不可取消");
        }

        // 1. 归还号源 (Redis 优先)
        Long scheduleId = appointment.getScheduleId();
        String redisKey = getScheduleRedisKey(scheduleId);
        
        Long remaining;
        // 先检查 Redis key 是否存在
        if (Boolean.TRUE.equals(redisService.redisTemplate.hasKey(redisKey))) {
            remaining = redisService.redisTemplate.opsForValue().increment(redisKey);
        } else {
            // Redis 不存在，从数据库加载并加1
            ResultVO<Schedule> scheduleResult = remoteScheduleService.getById(scheduleId);
            if (scheduleResult != null && scheduleResult.getData() != null) {
                remaining = (long) (scheduleResult.getData().getAvailableSlots() + 1);
                redisService.setCacheObject(redisKey, remaining.intValue(), 24L, java.util.concurrent.TimeUnit.HOURS);
            } else {
                throw new ServiceException("排班信息不存在");
            }
        }

        // 2. 同步到排班服务
        Schedule updateSchedule = new Schedule();
        updateSchedule.setId(scheduleId);
        updateSchedule.setAvailableSlots(remaining != null ? remaining.intValue() : 0);
        remoteScheduleService.update(updateSchedule);

        // 3. 更新预约状态
        appointment.setStatus("已取消");
        return this.updateById(appointment);
    }


}
