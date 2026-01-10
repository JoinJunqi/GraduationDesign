package com.ruoyi.appointment.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.appointment.domain.Appointment;
import java.util.List;

public interface IAppointmentService extends IService<Appointment> {
    boolean createAppointment(Appointment appointment);
    boolean cancelAppointment(Long appointmentId);
    List<Appointment> selectAppointmentList(Appointment appointment);
    java.util.Map<String, Object> selectAppointmentStats();
}
