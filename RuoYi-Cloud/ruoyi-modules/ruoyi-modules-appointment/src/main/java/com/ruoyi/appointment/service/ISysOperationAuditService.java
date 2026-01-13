package com.ruoyi.appointment.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.appointment.domain.SysOperationAudit;
import java.util.List;

/**
 * 系统操作审核Service接口
 */
public interface ISysOperationAuditService extends IService<SysOperationAudit> {
    /**
     * 查询审核列表
     */
    public List<SysOperationAudit> selectAuditList(SysOperationAudit audit);

    /**
     * 提交审核申请
     */
    public int submitAudit(SysOperationAudit audit);

    /**
     * 处理审核(通过/驳回)
     */
    public int processAudit(SysOperationAudit audit);
}
