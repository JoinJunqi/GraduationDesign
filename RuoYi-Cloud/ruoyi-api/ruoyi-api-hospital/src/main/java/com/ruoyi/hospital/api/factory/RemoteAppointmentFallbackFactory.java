package com.ruoyi.hospital.api.factory;

import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.api.RemoteAppointmentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.openfeign.FallbackFactory;
import org.springframework.stereotype.Component;

/**
 * 预约服务降级处理
 */
@Component
public class RemoteAppointmentFallbackFactory implements FallbackFactory<RemoteAppointmentService> {
    private static final Logger log = LoggerFactory.getLogger(RemoteAppointmentFallbackFactory.class);

    @Override
    public RemoteAppointmentService create(Throwable throwable) {
        log.error("预约服务调用失败:{}", throwable.getMessage());
        return new RemoteAppointmentService() {
            @Override
            public ResultVO<Boolean> updateStatus(Long id, String status) {
                return ResultVO.error("更新预约状态失败:" + throwable.getMessage());
            }

            @Override
            public ResultVO<com.ruoyi.hospital.api.domain.Appointment> getInfo(Long id) {
                return ResultVO.error("获取预约详情失败:" + throwable.getMessage());
            }
        };
    }
}
