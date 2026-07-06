package com.ruoyi.appointment.controller;

import java.util.List;
import java.util.Arrays;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.constant.UserConstants;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.web.page.TableDataInfo;
import com.ruoyi.appointment.domain.Appointment;
import com.ruoyi.appointment.service.IAppointmentService;

@RestController
@RequestMapping("/appointment")
public class AppointmentController extends BaseController
{
    @Autowired
    private IAppointmentService appointmentService;

    /**
     * 分页查询预约列表。
     */
    @GetMapping("/list")
    public TableDataInfo list(Appointment appointment)
    {
        // 步骤1：初始化分页与排序上下文
        startPage();
        startOrderBy();
        // 步骤2：查询业务数据并封装表格结果
        List<Appointment> list = appointmentService.selectAppointmentList(appointment);
        return getDataTable(list);
    }

    /**
     * 获取仪表盘统计（支持按日期筛选）。
     */
    @GetMapping("/dashboard-stats")
    public ResultVO<Map<String, Object>> dashboard(@RequestParam(value = "date", required = false) String date)
    {
        return ResultVO.success(appointmentService.selectDashboardStats(date));
    }

    /**
     * 获取预约汇总统计信息。
     */
    @GetMapping("/summary-stats")
    public ResultVO<Map<String, Object>> stats()
    {
        return ResultVO.success(appointmentService.selectAppointmentStats());
    }

    /**
     * 根据预约ID查询详情。
     */
    @GetMapping("/{id:\\d+}")
    public ResultVO<Appointment> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(appointmentService.selectAppointmentById(id));
    }

    /**
     * 查询某排班最新已预约时间点。
     */
    @GetMapping("/latestBookedTime")
    public ResultVO<String> getLatestBookedTime(@RequestParam("scheduleId") Long scheduleId)
    {
        return ResultVO.success(appointmentService.getLatestBookedTime(scheduleId));
    }

    /**
     * 判断当前登录用户是否具备指定角色。
     */
    private boolean hasRole(String role)
    {
        Set<String> roles = SecurityUtils.getLoginUser().getRoles();
        if (roles == null) return false;
        for (String r : roles)
        {
            if (role.equalsIgnoreCase(r)) return true;
        }
        return false;
    }

    /**
     * 创建预约（患者/医生可直接创建，其他角色需管理员权限）。
     */
    @PostMapping("/create")
    public ResultVO<Boolean> create(@RequestBody Appointment appointment)
    {
        // 步骤1：患者和医生可直接创建
        if (!hasRole("patient") && !hasRole("doctor"))
        {
            // 步骤2：其他角色需具备预约管理权限
            SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        }
        // 步骤3：调用服务层完成创建
        return ResultVO.success(appointmentService.createAppointment(appointment));
    }

    /**
     * 编辑预约信息（管理员权限）。
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Appointment appointment)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        return ResultVO.success(appointmentService.updateById(appointment));
    }

    /**
     * 管理员直接取消预约。
     */
    @PostMapping("/cancel/{id}")
    public ResultVO<Boolean> cancel(@PathVariable Long id)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        return ResultVO.success(appointmentService.cancelAppointment(id));
    }

    /**
     * 提交取消预约申请（通常由患者或医生发起）。
     */
    @PostMapping("/request-cancel/{id}")
    public ResultVO<Boolean> requestCancel(@PathVariable Long id)
    {
        // 申请取消通常由患者或医生发起，不需要管理员权限
        return ResultVO.success(appointmentService.requestCancel(id));
    }

    /**
     * 撤销已提交的取消预约申请。
     */
    @PostMapping("/cancel-request/{id}")
    public ResultVO<Boolean> cancelRequest(@PathVariable Long id)
    {
        // 取消申请通常由患者或医生发起，不需要管理员权限
        return ResultVO.success(appointmentService.cancelRequest(id));
    }

    /**
     * 更新预约状态（医生可操作，其他角色需管理员权限）。
     */
    @PutMapping("/status")
    public ResultVO<Boolean> updateStatus(@RequestParam("id") Long id, @RequestParam("status") String status)
    {
        // 步骤1：医生可直接更新预约状态
        if (!hasRole("doctor"))
        {
            // 步骤2：非医生角色需要预约管理权限
            SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        }
        // 步骤3：按状态流转规则执行更新
        return ResultVO.success(appointmentService.updateStatusWithRule(id, status));
    }

    /**
     * 根据排班ID取消所有预约
     */
    @PutMapping("/cancelByScheduleId")
    public ResultVO<Boolean> cancelByScheduleId(@RequestParam("scheduleId") Long scheduleId)
    {
        // 步骤1：医生可在取消排班时直接级联取消预约
        if (!hasRole("doctor"))
        {
            // 步骤2：非医生角色需要预约管理权限
            SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        }
        // 步骤3：按排班ID执行批量取消
        return ResultVO.success(appointmentService.cancelByScheduleId(scheduleId));
    }

    /**
     * 将部分预约迁移到新排班
     */
    @PutMapping("/reassign")
    public ResultVO<Boolean> reassign(@RequestParam("oldScheduleId") Long oldScheduleId, 
                                    @RequestParam("newScheduleId") Long newScheduleId, 
                                    @RequestParam("count") Integer count)
    {
        // 步骤1：医生可在调整排班时直接迁移预约
        if (!hasRole("doctor"))
        {
            // 步骤2：非医生角色需要预约管理权限
            SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        }
        // 步骤3：将部分预约迁移到新排班
        return ResultVO.success(appointmentService.reassign(oldScheduleId, newScheduleId, count));
    }

    /**
     * 同步排班班次变更导致的预约时间调整
     */
    @PutMapping("/syncTimeChange")
    public ResultVO<Boolean> syncTimeChange(@RequestParam("scheduleId") Long scheduleId,
                                          @RequestParam("oldTimeSlot") String oldTimeSlot,
                                          @RequestParam("newTimeSlot") String newTimeSlot) {
        // 步骤1：医生可在调整排班时直接同步预约时间
        if (!hasRole("doctor"))
        {
            // 步骤2：非医生角色需要预约管理权限
            SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        }
        // 步骤3：按排班与时段变更规则执行同步
        return ResultVO.success(appointmentService.syncTimeChange(scheduleId, oldTimeSlot, newTimeSlot));
    }

    /**
     * 批量删除预约
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        // 步骤1：管理员权限校验
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        // 步骤2：批量删除预约
        return ResultVO.success(appointmentService.deleteAppointmentByIds(ids));
    }

    /**
     * 批量恢复预约
     */
    @PutMapping("/recover/{ids}")
    public ResultVO<Boolean> recover(@PathVariable Long[] ids)
    {
        // 步骤1：管理员权限校验
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        // 步骤2：批量恢复预约
        return ResultVO.success(appointmentService.recoverAppointmentByIds(ids));
    }
}
