package com.ruoyi.hospital.api;

import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.api.domain.Appointment;
import com.ruoyi.hospital.api.factory.RemoteAppointmentFallbackFactory;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 预约服务
 */
@FeignClient(contextId = "remoteAppointmentService", value = "ruoyi-hospital-appointment", fallbackFactory = RemoteAppointmentFallbackFactory.class)
public interface RemoteAppointmentService {
    /**
     * 更新预约状态
     */
    @PutMapping("/appointment/status")
    ResultVO<Boolean> updateStatus(@RequestParam("id") Long id, @RequestParam("status") String status);

    @GetMapping("/appointment/{id}")
    ResultVO<Appointment> getInfo(@PathVariable("id") Long id);

    /**
     * 根据排班ID取消所有预约
     */
    @PutMapping("/appointment/cancelByScheduleId")
    ResultVO<Boolean> cancelByScheduleId(@RequestParam("scheduleId") Long scheduleId);

    /**
     * 将部分预约迁移到新排班
     */
    @PutMapping("/appointment/reassign")
    ResultVO<Boolean> reassign(@RequestParam("oldScheduleId") Long oldScheduleId, 
                             @RequestParam("newScheduleId") Long newScheduleId, 
                             @RequestParam("count") Integer count);

    /**
     * 同步排班班次变更导致的预约时间调整
     */
    @PutMapping("/appointment/syncTimeChange")
    ResultVO<Boolean> syncTimeChange(@RequestParam("scheduleId") Long scheduleId,
                                   @RequestParam("oldTimeSlot") String oldTimeSlot,
                                   @RequestParam("newTimeSlot") String newTimeSlot);
}
