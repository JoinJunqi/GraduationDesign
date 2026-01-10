package com.ruoyi.appointment.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.appointment.domain.Appointment;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface AppointmentMapper extends BaseMapper<Appointment> {
    /**
     * 查询预约列表
     */
    List<Appointment> selectAppointmentList(Appointment appointment);
}
