package com.ruoyi.appointment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.appointment.domain.Appointment;
import com.ruoyi.appointment.mapper.AppointmentMapper;
import com.ruoyi.appointment.service.IAppointmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Date;
import java.util.List;

@Service
public class AppointmentServiceImpl extends ServiceImpl<AppointmentMapper, Appointment> implements IAppointmentService {

    @Autowired
    private AppointmentMapper appointmentMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean createAppointment(Appointment appointment) {
        // 1. 检查排班是否存在及剩余号源 (需通过Feign调用ScheduleService)
        // Schedule schedule = scheduleMapper.selectById(appointment.getScheduleId());
        // if (schedule == null || schedule.getAvailableSlots() <= 0) {
        //     throw new RuntimeException("号源不足或排班不存在");
        // }

        // 2. 扣减号源 (需通过Feign调用ScheduleService)
        // schedule.setAvailableSlots(schedule.getAvailableSlots() - 1);
        // scheduleMapper.updateById(schedule);

        // 3. 创建预约
        appointment.setStatus("待就诊");
        appointment.setBookedAt(new Date());
        return this.save(appointment);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean cancelAppointment(Long appointmentId) {
        Appointment appointment = this.getById(appointmentId);
        if (appointment == null) {
            throw new RuntimeException("预约不存在");
        }
        
        // 1. 恢复号源 (需通过Feign调用ScheduleService)
        // Schedule schedule = scheduleMapper.selectById(appointment.getScheduleId());
        // schedule.setAvailableSlots(schedule.getAvailableSlots() + 1);
        // scheduleMapper.updateById(schedule);

        // 2. 更新状态
        appointment.setStatus("已取消");
        return this.updateById(appointment);
    }

    @Override
    public List<Appointment> selectAppointmentList(Appointment appointment) {
        return appointmentMapper.selectList(new LambdaQueryWrapper<Appointment>()
                .eq(appointment.getPatientId() != null, Appointment::getPatientId, appointment.getPatientId())
                .eq(appointment.getScheduleId() != null, Appointment::getScheduleId, appointment.getScheduleId()));
    }
}
