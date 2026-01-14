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

    /**
     * 查询近7天预约趋势
     */
    List<java.util.Map<String, Object>> selectAppointmentTrend();

    /**
     * 查询科室预约分布
     */
    List<java.util.Map<String, Object>> selectDeptAppointmentDistribution();

    /**
     * 查询预约状态分布
     */
    List<java.util.Map<String, Object>> selectStatusDistribution();

    /**
     * 查询患者总数
     */
    int selectPatientCount();

    /**
     * 查询医生总数
     */
    int selectDoctorCount();
}
