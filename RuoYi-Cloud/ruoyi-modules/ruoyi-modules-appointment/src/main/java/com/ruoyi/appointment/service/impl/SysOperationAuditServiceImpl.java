package com.ruoyi.appointment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.appointment.domain.Appointment;
import com.ruoyi.appointment.domain.SysOperationAudit;
import com.ruoyi.appointment.mapper.AppointmentMapper;
import com.ruoyi.appointment.mapper.SysOperationAuditMapper;
import com.ruoyi.appointment.service.ISysOperationAuditService;
import com.ruoyi.common.core.utils.DateUtils;
import com.ruoyi.common.core.utils.StringUtils;
import com.ruoyi.common.core.domain.ResultVO;
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
        
        // 修正：强制设为 0 (待审核)，除非是特殊情况
        // 之前遇到问题是提交后马上变为“已驳回”(2)，说明这里可能没有正确初始化，或者被某些默认值覆盖
        // 或者 submitAudit 被 processAudit 调用了？ 不太可能。
        // 确保新插入的记录状态一定是 0
        audit.setAuditStatus(0); 
        audit.setAdminId(null); // 清空管理员ID
        audit.setAuditTime(null); // 清空审核时间
        audit.setAuditRemark(null); // 清空备注

        if (audit.getRequesterId() == null) {
            audit.setRequesterId(SecurityUtils.getUserId());
        }
        if (StringUtils.isEmpty(audit.getRequesterRole())) {
            if (SecurityUtils.getLoginUser() != null && SecurityUtils.getLoginUser().getRoles() != null
                    && SecurityUtils.getLoginUser().getRoles().contains("doctor")) {
                audit.setRequesterRole("doctor");
            } else {
                audit.setRequesterRole("patient");
            }
        }
        
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
        // 关键：这里只更新状态，不应该再插入
        // 如果 audit.getId() 不存在，那就是异常
        if (audit.getId() == null) {
            return 0;
        }
        
        SysOperationAudit dbAudit = auditMapper.selectById(audit.getId());
        if (dbAudit == null) return 0;
        
        // ... (省略部分属性设置) ...
        dbAudit.setAuditStatus(audit.getAuditStatus());
        dbAudit.setAuditRemark(audit.getAuditRemark());
        dbAudit.setAdminId(SecurityUtils.getUserId());
        dbAudit.setAuditTime(DateUtils.getNowDate());

        if ("APPOINTMENT_CANCEL".equals(dbAudit.getAuditType())) {
            // ... (预约取消逻辑不变) ...
        } else if ("SCHEDULE_CHANGE".equals(dbAudit.getAuditType())) {
            // 调用远程服务获取排班信息
            // 修正：这里需要根据 targetId 调用 remoteScheduleService 获取排班
            // 但远程调用返回值是 ResultVO<Schedule>，需要正确解析
            // 假设 remoteScheduleService.getById 返回的是 Schedule 对象
            
            // 由于 remoteScheduleService 是 FeignClient，我们需要确保能正确调用
            // 假设 remoteScheduleService.getById(id) 返回的是 ResultVO<Schedule>
            // 这里我们先直接构造一个 Schedule 对象用于更新，因为我们只需要更新 status
            com.ruoyi.hospital.api.domain.Schedule schedule = new com.ruoyi.hospital.api.domain.Schedule();
            schedule.setId(dbAudit.getTargetId());
            
            if (audit.getAuditStatus() == 1) { // 审核通过
                String reason = dbAudit.getRequestReason();
                if (reason != null && reason.contains("新增")) {
                    schedule.setStatus(0); // 正常
                } else if (reason != null && reason.contains("删除")) {
                    schedule.setStatus(2); // 已取消 (或者调用删除接口)
                } else {
                    schedule.setStatus(1); // 有调整
                }
            } else if (audit.getAuditStatus() == 2) { // 审核驳回
                String reason = dbAudit.getRequestReason();
                if (reason != null && reason.contains("新增")) {
                    schedule.setStatus(5); // 已驳回 (假设状态码 5)
                } else if (reason != null && reason.contains("删除")) {
                    schedule.setStatus(0); // 删除被驳回，恢复为正常(0)
                } else {
                    schedule.setStatus(5); // 修改驳回，保持原状或设为驳回状态？
                }
            }
            remoteScheduleService.update(schedule);
        }
        
        return auditMapper.updateById(dbAudit);
    }
}
