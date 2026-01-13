package com.ruoyi.appointment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.appointment.domain.Appointment;
import com.ruoyi.appointment.domain.SysOperationAudit;
import com.ruoyi.appointment.mapper.AppointmentMapper;
import com.ruoyi.appointment.mapper.SysOperationAuditMapper;
import com.ruoyi.appointment.service.ISysOperationAuditService;
import com.ruoyi.common.core.utils.DateUtils;
import com.ruoyi.common.security.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 系统操作审核Service业务层处理
 */
@Service
public class SysOperationAuditServiceImpl extends ServiceImpl<SysOperationAuditMapper, SysOperationAudit> implements ISysOperationAuditService {

    @Autowired
    private SysOperationAuditMapper auditMapper;

    @Autowired
    private AppointmentMapper appointmentMapper;

    @Autowired
    private com.ruoyi.hospital.api.RemoteScheduleService remoteScheduleService;

    @Autowired
    private com.ruoyi.common.redis.service.RedisService redisService;

    private static final String SCHEDULE_SLOTS_KEY = "hospital:schedule:slots:";

    private String getScheduleRedisKey(Long scheduleId) {
        return SCHEDULE_SLOTS_KEY + scheduleId;
    }

    @Override
    public List<SysOperationAudit> selectAuditList(SysOperationAudit audit) {
        return auditMapper.selectAuditList(audit);
    }

    @Override
    @Transactional
    public int submitAudit(SysOperationAudit audit) {
        audit.setCreatedAt(DateUtils.getNowDate());
        audit.setAuditStatus(0); // 待审核
        
        // 如果是预约取消申请，同步更新预约状态为“取消审核中”
        if ("APPOINTMENT_CANCEL".equals(audit.getAuditType())) {
            Appointment appointment = appointmentMapper.selectById(audit.getTargetId());
            if (appointment != null) {
                appointment.setStatus("取消审核中");
                appointmentMapper.updateById(appointment);
            }
        }
        
        return auditMapper.insert(audit);
    }

    @Override
    @Transactional
    public int processAudit(SysOperationAudit audit) {
        SysOperationAudit dbAudit = auditMapper.selectById(audit.getId());
        if (dbAudit == null) return 0;

        dbAudit.setAuditStatus(audit.getAuditStatus());
        dbAudit.setAuditRemark(audit.getAuditRemark());
        dbAudit.setAdminId(SecurityUtils.getUserId());
        dbAudit.setAuditTime(DateUtils.getNowDate());

        // 处理业务逻辑
        if ("APPOINTMENT_CANCEL".equals(dbAudit.getAuditType())) {
            Appointment appointment = appointmentMapper.selectById(dbAudit.getTargetId());
            if (appointment != null) {
                if (audit.getAuditStatus() == 1) { // 通过
                    appointment.setStatus("已取消");
                    
                    // 恢复号源逻辑
                    Long scheduleId = appointment.getScheduleId();
                    String redisKey = getScheduleRedisKey(scheduleId);
                    Long remaining = redisService.redisTemplate.opsForValue().increment(redisKey);
                    
                    com.ruoyi.hospital.api.domain.Schedule updateSchedule = new com.ruoyi.hospital.api.domain.Schedule();
                    updateSchedule.setId(scheduleId);
                    updateSchedule.setAvailableSlots(remaining != null ? remaining.intValue() : 0);
                    remoteScheduleService.update(updateSchedule);
                    
                } else if (audit.getAuditStatus() == 2) { // 驳回
                    appointment.setStatus("待就诊");
                }
                appointmentMapper.updateById(appointment);
            }
        }

        return auditMapper.updateById(dbAudit);
    }
}
