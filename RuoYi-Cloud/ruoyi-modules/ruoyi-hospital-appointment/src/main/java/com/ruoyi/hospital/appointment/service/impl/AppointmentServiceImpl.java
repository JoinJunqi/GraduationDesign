package com.ruoyi.hospital.appointment.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.hospital.appointment.domain.Appointment;
import com.ruoyi.hospital.appointment.mapper.AppointmentMapper;
import com.ruoyi.hospital.appointment.service.IAppointmentService;
import org.springframework.stereotype.Service;

/**
 * 预约 Service 实现类
 */
@Service
public class AppointmentServiceImpl extends ServiceImpl<AppointmentMapper, Appointment> implements IAppointmentService {
}
