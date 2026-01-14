package com.ruoyi.appointment.controller;

import java.util.List;
import java.util.Arrays;
import java.util.Map;
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

    @GetMapping("/list")
    public TableDataInfo list(Appointment appointment)
    {
        startPage();
        startOrderBy();
        List<Appointment> list = appointmentService.selectAppointmentList(appointment);
        return getDataTable(list);
    }

    @GetMapping("/stats")
    public ResultVO<Map<String, Object>> stats()
    {
        return ResultVO.success(appointmentService.selectAppointmentStats());
    }

    @GetMapping(value = "/{id}")
    public ResultVO<Appointment> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(appointmentService.selectAppointmentById(id));
    }

    @PostMapping("/create")
    public ResultVO<Boolean> create(@RequestBody Appointment appointment)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        return ResultVO.success(appointmentService.createAppointment(appointment));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Appointment appointment)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        return ResultVO.success(appointmentService.updateById(appointment));
    }

    @PostMapping("/cancel/{id}")
    public ResultVO<Boolean> cancel(@PathVariable Long id)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        return ResultVO.success(appointmentService.cancelAppointment(id));
    }

    @PostMapping("/request-cancel/{id}")
    public ResultVO<Boolean> requestCancel(@PathVariable Long id)
    {
        // 申请取消通常由患者或医生发起，不需要管理员权限
        return ResultVO.success(appointmentService.requestCancel(id));
    }

    @PostMapping("/cancel-request/{id}")
    public ResultVO<Boolean> cancelRequest(@PathVariable Long id)
    {
        // 取消申请通常由患者或医生发起，不需要管理员权限
        return ResultVO.success(appointmentService.cancelRequest(id));
    }

    @PutMapping("/status")
    public ResultVO<Boolean> updateStatus(@RequestParam("id") Long id, @RequestParam("status") String status)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        Appointment appointment = new Appointment();
        appointment.setId(id);
        appointment.setStatus(status);
        return ResultVO.success(appointmentService.updateById(appointment));
    }

    /**
     * 根据排班ID取消所有预约
     */
    @PutMapping("/cancelByScheduleId")
    public ResultVO<Boolean> cancelByScheduleId(@RequestParam("scheduleId") Long scheduleId)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
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
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        return ResultVO.success(appointmentService.reassign(oldScheduleId, newScheduleId, count));
    }

    /**
     * 同步排班班次变更导致的预约时间调整
     */
    @PutMapping("/syncTimeChange")
    public ResultVO<Boolean> syncTimeChange(@RequestParam("scheduleId") Long scheduleId,
                                          @RequestParam("oldTimeSlot") String oldTimeSlot,
                                          @RequestParam("newTimeSlot") String newTimeSlot) {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        return ResultVO.success(appointmentService.syncTimeChange(scheduleId, oldTimeSlot, newTimeSlot));
    }

    /**
     * 批量删除预约
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        return ResultVO.success(appointmentService.deleteAppointmentByIds(ids));
    }

    /**
     * 批量恢复预约
     */
    @PutMapping("/recover/{ids}")
    public ResultVO<Boolean> recover(@PathVariable Long[] ids)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_BOOKING);
        return ResultVO.success(appointmentService.recoverAppointmentByIds(ids));
    }
}
