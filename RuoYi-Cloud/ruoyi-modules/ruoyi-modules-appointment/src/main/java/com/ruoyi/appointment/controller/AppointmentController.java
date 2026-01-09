package com.ruoyi.appointment.controller;

import java.util.List;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
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
        List<Appointment> list = appointmentService.selectAppointmentList(appointment);
        return getDataTable(list);
    }

    @GetMapping(value = "/{id}")
    public ResultVO<Appointment> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(appointmentService.getById(id));
    }

    @PostMapping("/create")
    public ResultVO<Boolean> create(@RequestBody Appointment appointment)
    {
        return ResultVO.success(appointmentService.createAppointment(appointment));
    }

    @PostMapping("/cancel/{id}")
    public ResultVO<Boolean> cancel(@PathVariable Long id)
    {
        return ResultVO.success(appointmentService.cancelAppointment(id));
    }

    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        return ResultVO.success(appointmentService.removeBatchByIds(Arrays.asList(ids)));
    }
}
