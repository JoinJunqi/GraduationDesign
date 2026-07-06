package com.ruoyi.appointment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.exception.ServiceException;
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

    /**
     * 生成排班号源缓存键。
     */
    private String getScheduleRedisKey(Long scheduleId) {
        return SCHEDULE_SLOTS_KEY + scheduleId;
    }

    /**
     * 按条件查询操作审核列表。
     */
    @Override
    public List<SysOperationAudit> selectAuditList(SysOperationAudit audit) {
        return auditMapper.selectAuditList(audit);
    }

    /**
     * 提交审核申请：初始化审核状态、去重校验并写入审核记录。
     */
    @Override
    @Transactional
    public int submitAudit(SysOperationAudit audit) {
        // 步骤1：补齐创建时间与审核初始字段（统一置为待审核）
        audit.setCreatedAt(DateUtils.getNowDate());
        
        // 修正：强制设为 0 (待审核)
        audit.setAuditStatus(0); 
        audit.setAdminId(null); 
        audit.setAuditTime(null); 
        audit.setAuditRemark(null);

        // 步骤2：检查是否存在同类型、同目标ID且未审核的记录，避免重复提审
        if (audit.getAuditType() != null && audit.getTargetId() != null) {
            Long count = auditMapper.selectCount(new LambdaQueryWrapper<SysOperationAudit>()
                    .eq(SysOperationAudit::getAuditType, audit.getAuditType())
                    .eq(SysOperationAudit::getTargetId, audit.getTargetId())
                    .eq(SysOperationAudit::getAuditStatus, 0)); // 0: 待审核
            
            if (count > 0) {
                // 如果已存在待审核记录，抛出异常阻止重复提交
                throw new ServiceException("该记录已在审核中，请勿重复提交");
            }
        }

        // 步骤3：补齐申请人信息（兼容前端未传 requesterId/requesterRole 的场景）
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
        
        // 步骤4：如果是预约取消申请，同步将预约状态置为“取消审核中”
        if ("APPOINTMENT_CANCEL".equals(audit.getAuditType())) {
            Appointment appointment = appointmentMapper.selectById(audit.getTargetId());
            if (appointment != null) {
                appointment.setStatus("取消审核中");
                appointmentMapper.updateById(appointment);
            }
        }
        
        // 步骤5：写入审核申请记录
        return auditMapper.insert(audit);
    }

    /**
     * 处理审核结果：更新审核记录，并联动预约/排班状态。
     */
    @Override
    @Transactional
    public int processAudit(SysOperationAudit audit) {
        // 步骤1：基础参数校验与审核记录读取
        if (audit.getId() == null) return 0;
        
        SysOperationAudit dbAudit = auditMapper.selectById(audit.getId());
        if (dbAudit == null) return 0;
        
        // 步骤2：先更新审核记录（状态、备注、审核人、审核时间）
        dbAudit.setAuditStatus(audit.getAuditStatus());
        dbAudit.setAuditRemark(audit.getAuditRemark());
        dbAudit.setAdminId(SecurityUtils.getUserId());
        dbAudit.setAuditTime(DateUtils.getNowDate());
        auditMapper.updateById(dbAudit); // 先保存审核记录状态

        // 步骤3：按审核类型执行联动处理
        if ("APPOINTMENT_CANCEL".equals(dbAudit.getAuditType())) {
            // 分支A：预约取消审核
             Appointment appointment = appointmentMapper.selectById(dbAudit.getTargetId());
             if (appointment != null) {
                 if (audit.getAuditStatus() == 1) { // 通过
                     // A1. 审核通过：预约置为已取消，并回补 Redis/排班号源
                     appointment.setStatus("已取消");
                     // 恢复号源逻辑...
                     Long scheduleId = appointment.getScheduleId();
                     String redisKey = getScheduleRedisKey(scheduleId);
                     Long remaining = redisService.redisTemplate.opsForValue().increment(redisKey);
                     
                     com.ruoyi.hospital.api.domain.Schedule updateSchedule = new com.ruoyi.hospital.api.domain.Schedule();
                     updateSchedule.setId(scheduleId);
                     updateSchedule.setAvailableSlots(remaining != null ? remaining.intValue() : 0);
                     remoteScheduleService.update(updateSchedule);
                 } else if (audit.getAuditStatus() == 2) { // 驳回
                     // A2. 审核驳回：预约恢复到待就诊
                     appointment.setStatus("待就诊");
                 }
                 appointmentMapper.updateById(appointment);
             }
        } else if ("SCHEDULE_CHANGE".equals(dbAudit.getAuditType())) {
           // 分支B：排班变更审核
           // 调用远程服务更新排班状态
           com.ruoyi.hospital.api.domain.Schedule schedule = new com.ruoyi.hospital.api.domain.Schedule();
           schedule.setId(dbAudit.getTargetId());
            
            if (audit.getAuditStatus() == 1) { // 审核通过
                // B1. 审核通过：按申请原因确定排班最终状态
                String reason = dbAudit.getRequestReason();
                if (reason != null && reason.contains("新增")) {
                    // 新增排班，设置状态为正常
                    schedule.setStatus(0); // 正常
                    remoteScheduleService.update(schedule);
                } else if (reason != null && reason.contains("取消")) {
                    // 取消排班，设置状态为已取消
                    schedule.setStatus(2); // 已取消
                    remoteScheduleService.update(schedule);
                } else if (reason != null && reason.contains("删除")) {
                    // 审核通过，执行删除操作（逻辑删除/进回收站）
                    // 此时不再是设为“已取消”，而是真正删除
                    remoteScheduleService.remove(new Long[]{schedule.getId()});
                } else {
                    schedule.setStatus(1); // 有调整
                    remoteScheduleService.update(schedule);
                }
            } else if (audit.getAuditStatus() == 2) { // 审核驳回
                // B2. 审核驳回：按申请原因回滚/标记对应状态
                String reason = dbAudit.getRequestReason();
                if (reason != null && reason.contains("新增")) {
                    schedule.setStatus(5); // 已驳回
                } else if (reason != null && reason.contains("取消")) {
                    schedule.setStatus(0); // 取消被驳回，恢复为正常
                } else if (reason != null && reason.contains("删除")) {
                    schedule.setStatus(0); // 删除被驳回，恢复为正常(0)
                } else {
                    schedule.setStatus(5); // 修改驳回
                }
                remoteScheduleService.update(schedule);
            }
        }
        
        // 步骤4：处理完成，返回成功标记
        return 1;
    }
}
