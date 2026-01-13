package com.ruoyi.hospital.api.factory;

import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.api.RemoteAppointmentService;
import com.ruoyi.hospital.api.domain.Appointment;
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
            public ResultVO<Appointment> getInfo(Long id) {
                return ResultVO.error("获取预约详情失败:" + throwable.getMessage());
            }

            @Override
            public ResultVO<Boolean> cancelByScheduleId(Long scheduleId) {
                return ResultVO.error("根据排班ID取消预约失败:" + throwable.getMessage());
            }

            @Override
            public ResultVO<Boolean> reassign(Long oldScheduleId, Long newScheduleId, Integer count) {
                return ResultVO.error("预约迁移失败:" + throwable.getMessage());
            }

            @Override
            public ResultVO<Boolean> syncTimeChange(Long scheduleId, String oldTimeSlot, String newTimeSlot) {
                return ResultVO.error("同步预约时间调整失败:" + throwable.getMessage());
            }
        };
    }
}
