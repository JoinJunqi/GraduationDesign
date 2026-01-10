package com.ruoyi.hospital.api;

import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.api.factory.RemoteAppointmentFallbackFactory;
import org.springframework.cloud.openfeign.FeignClient;
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
}
