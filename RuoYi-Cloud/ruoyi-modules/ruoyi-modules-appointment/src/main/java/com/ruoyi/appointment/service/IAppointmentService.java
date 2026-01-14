package com.ruoyi.appointment.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.appointment.domain.Appointment;
import java.util.List;
import java.util.Map;

public interface IAppointmentService extends IService<Appointment> {
    boolean createAppointment(Appointment appointment);
    boolean cancelAppointment(Long appointmentId);
    boolean requestCancel(Long appointmentId);
    boolean cancelRequest(Long appointmentId);
    List<Appointment> selectAppointmentList(Appointment appointment);
    Map<String, Object> selectAppointmentStats();
    Map<String, Object> selectDashboardStats();
    Appointment selectAppointmentById(Long id);

    /**
     * 根据排班ID取消所有预约
     */
    boolean cancelByScheduleId(Long scheduleId);

    /**
     * 批量迁移预约
     */
    boolean reassign(Long oldScheduleId, Long newScheduleId, Integer count);

    /**
     * 同步排班班次变更导致的预约时间调整
     */
    boolean syncTimeChange(Long scheduleId, String oldTimeSlot, String newTimeSlot);

    /**
     * 批量删除预约
     */
    boolean deleteAppointmentByIds(Long[] ids);

    /**
     * 批量恢复预约
     */
    boolean recoverAppointmentByIds(Long[] ids);
}
