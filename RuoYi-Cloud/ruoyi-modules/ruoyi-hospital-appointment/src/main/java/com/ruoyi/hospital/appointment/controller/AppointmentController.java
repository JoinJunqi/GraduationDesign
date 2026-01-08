package com.ruoyi.hospital.appointment.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.appointment.domain.Appointment;
import com.ruoyi.hospital.appointment.service.IAppointmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 预约控制器
 */
@RestController
@RequestMapping("/appointment")
public class AppointmentController {

    @Autowired
    private IAppointmentService appointmentService;

    /**
     * 查询预约列表
     */
    @GetMapping("/list")
    public ResultVO<List<Appointment>> list(Appointment appointment) {
        LambdaQueryWrapper<Appointment> queryWrapper = new LambdaQueryWrapper<>();
        if (appointment.getPatientId() != null) {
            queryWrapper.eq(Appointment::getPatientId, appointment.getPatientId());
        }
        if (appointment.getStatus() != null) {
            queryWrapper.eq(Appointment::getStatus, appointment.getStatus());
        }
        return ResultVO.success(appointmentService.list(queryWrapper));
    }

    /**
     * 获取预约详细信息
     */
    @GetMapping(value = "/{id}")
    public ResultVO<Appointment> getInfo(@PathVariable("id") Long id) {
        return ResultVO.success(appointmentService.getById(id));
    }

    /**
     * 新增预约
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Appointment appointment) {
        return ResultVO.success(appointmentService.save(appointment));
    }

    /**
     * 修改预约
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Appointment appointment) {
        return ResultVO.success(appointmentService.updateById(appointment));
    }

    /**
     * 删除预约
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable List<Long> ids) {
        return ResultVO.success(appointmentService.removeByIds(ids));
    }
}
