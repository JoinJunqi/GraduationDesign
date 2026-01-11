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

        // 1.1 检查该时段是否已被占用
        if (appointment.getAppointmentTime() != null) {
            Long timeCount = this.count(new LambdaQueryWrapper<Appointment>()
                    .eq(Appointment::getScheduleId, appointment.getScheduleId())
                    .eq(Appointment::getAppointmentTime, appointment.getAppointmentTime())
                    .ne(Appointment::getStatus, "已取消"));
            if (timeCount > 0) {
                throw new ServiceException("该具体时段已被预约，请选择其他时段");
            }
        }

        // 2. 检查排班是否存在及剩余号源 (Redis 优先)
        Long scheduleId = appointment.getScheduleId();
        String redisKey = getScheduleRedisKey(scheduleId);
        log.info("Checking Redis slots for key: {}", redisKey);
        
        // 获取 Redis 中的值（用于调试）
        Object redisValue = redisService.getCacheObject(redisKey);
        log.info("Current Redis value for key {}: {}", redisKey, redisValue);

        // 先检查 Redis 中是否存在该 key 或者值是否有效
        Long remaining;
        if (redisValue == null) {
            log.info("Redis key {} not found or value is null, loading from DB...", redisKey);
            // 缓存不存在，从数据库加载
            ResultVO<Schedule> scheduleResult = remoteScheduleService.getById(scheduleId);
            log.info("DB fetch result for schedule {}: {}", scheduleId, scheduleResult);
            
            if (scheduleResult != null && scheduleResult.getData() != null) {
                Schedule schedule = scheduleResult.getData();
                log.info("Schedule from DB: availableSlots={}, totalCapacity={}", 
                         schedule.getAvailableSlots(), schedule.getTotalCapacity());
                         
                if (schedule.getAvailableSlots() == null || schedule.getAvailableSlots() <= 0) {
                    log.warn("No slots available in DB for schedule {}", scheduleId);
                    throw new ServiceException("对不起，该时段号源已满");
                }
                // 初始化缓存 (设置过期时间)
                redisService.setCacheObject(redisKey, schedule.getAvailableSlots(), 24L, java.util.concurrent.TimeUnit.HOURS);
                log.info("Redis cache initialized for key {} with value {}", redisKey, schedule.getAvailableSlots());
            } else {
                log.error("Schedule {} not found in DB", scheduleId);
                throw new ServiceException("排班信息不存在");
            }
        } else {
            // 如果 redisValue 不为 null，但可能不是数字（比如之前的错误残留）
            try {
                String valStr = redisValue.toString();
                if (Integer.parseInt(valStr) <= 0) {
                    log.warn("Redis value for {} is <= 0: {}", redisKey, valStr);
                    throw new ServiceException("对不起，该时段号源已满");
                }
            } catch (NumberFormatException e) {
                log.error("Redis value for {} is not a valid number: {}", redisKey, redisValue);
                // 重新加载缓存
                redisService.deleteObject(redisKey);
                return createAppointment(appointment); // 递归重试一次
            }
        }
        
        // 执行原子递减
        try {
            remaining = redisService.redisTemplate.opsForValue().decrement(redisKey);
            log.info("Redis decrement result for key {}: {}", redisKey, remaining);
        } catch (Exception e) {
            log.error("Redis decrement failed for key {}", redisKey, e);
            // 如果 Redis 递减失败（可能是序列化问题），尝试重新加载缓存
            redisService.deleteObject(redisKey);
            throw new ServiceException("系统繁忙，请重试 (Cache Error)");
        }
        
        if (remaining != null && remaining < 0) {
            // 递减后小于 0，说明刚才那一瞬间没号了
            // 回退递减操作
            redisService.redisTemplate.opsForValue().increment(redisKey);
            log.warn("No slots available in Redis for schedule {}. Remaining was {}", scheduleId, remaining);
            throw new ServiceException("对不起，该时段号源已满");
        } else if (remaining == null) {
            log.error("Redis decrement returned null for key {}", redisKey);
            throw new ServiceException("系统繁忙，请重试");
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
        log.info("Cancelling appointment ID: {}", appointmentId);
        Appointment appointment = this.getById(appointmentId);
        if (appointment == null) {
            throw new ServiceException("预约记录不存在");
        }

        if ("已取消".equals(appointment.getStatus())) {
            throw new ServiceException("预约已取消，请勿重复操作");
        }

        // 1. 恢复 Redis 号源
        Long scheduleId = appointment.getScheduleId();
        String redisKey = getScheduleRedisKey(scheduleId);
        Long remaining = redisService.redisTemplate.opsForValue().increment(redisKey);
        log.info("Redis slots incremented for schedule {}. New remaining: {}", scheduleId, remaining);

        // 2. 更新数据库排班号源 (Feign)
        Schedule updateSchedule = new Schedule();
        updateSchedule.setId(scheduleId);
        updateSchedule.setAvailableSlots(remaining != null ? remaining.intValue() : 0);
        remoteScheduleService.update(updateSchedule);

        // 3. 更新预约状态
        appointment.setStatus("已取消");
        return this.updateById(appointment);
    }

    @Override
    public boolean requestCancel(Long appointmentId) {
        Appointment appointment = this.getById(appointmentId);
        if (appointment == null) {
            throw new ServiceException("预约记录不存在");
        }
        if (!"待就诊".equals(appointment.getStatus())) {
            throw new ServiceException("只有待就诊状态可以发起取消申请");
        }
        appointment.setStatus("取消申请中");
        return this.updateById(appointment);
    }

    @Override
    public boolean cancelRequest(Long appointmentId) {
        Appointment appointment = this.getById(appointmentId);
        if (appointment == null) {
            throw new ServiceException("预约记录不存在");
        }
        if (!"取消申请中".equals(appointment.getStatus())) {
            throw new ServiceException("当前状态不可撤回申请");
        }
        appointment.setStatus("待就诊");
        return this.updateById(appointment);
    }


}
