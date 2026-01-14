package com.ruoyi.appointment.controller;

import com.ruoyi.appointment.domain.SysOperationAudit;
import com.ruoyi.appointment.service.ISysOperationAuditService;
import com.ruoyi.common.core.constant.UserConstants;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.web.domain.AjaxResult;
import com.ruoyi.common.core.web.page.TableDataInfo;
import com.ruoyi.common.security.annotation.RequiresPermissions;
import com.ruoyi.common.security.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 系统操作审核Controller
 */
@RestController
@RequestMapping("/audit")
public class SysOperationAuditController extends BaseController {

    @Autowired
    private ISysOperationAuditService auditService;

    /**
     * 查询审核列表
     */
    @RequiresPermissions("appointment:audit:list")
    @GetMapping("/list")
    public TableDataInfo list(SysOperationAudit audit) {
        startPage();
        List<SysOperationAudit> list = auditService.selectAuditList(audit);
        return getDataTable(list);
    }

    /**
     * 获取审核详细信息
     */
    @RequiresPermissions("appointment:audit:query")
    @GetMapping(value = "/{id}")
    public AjaxResult getInfo(@PathVariable("id") Long id) {
        return AjaxResult.success(auditService.getById(id));
    }

    /**
     * 提交审核申请
     */
    @PostMapping("/submit")
    public AjaxResult submit(@RequestBody SysOperationAudit audit) {
        return toAjax(auditService.submitAudit(audit));
    }

    /**
     * 处理审核
     */
    @RequiresPermissions("appointment:audit:process")
    @PutMapping("/process")
    public AjaxResult process(@RequestBody SysOperationAudit audit) {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_AUDIT);
        return toAjax(auditService.processAudit(audit));
    }
}
