package com.ruoyi.appointment.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.appointment.domain.SysOperationAudit;
import java.util.List;

/**
 * 系统操作审核Mapper接口
 */
public interface SysOperationAuditMapper extends BaseMapper<SysOperationAudit> {
    /**
     * 查询审核列表
     */
    public List<SysOperationAudit> selectAuditList(SysOperationAudit audit);
}
