package com.ruoyi.hospital.api.factory;

import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.api.RemoteScheduleService;
import com.ruoyi.hospital.api.domain.Schedule;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.openfeign.FallbackFactory;
import org.springframework.stereotype.Component;

/**
 * 排班服务降级处理
 */
@Component
public class RemoteScheduleFallbackFactory implements FallbackFactory<RemoteScheduleService> {
    private static final Logger log = LoggerFactory.getLogger(RemoteScheduleFallbackFactory.class);

    @Override
    public RemoteScheduleService create(Throwable throwable) {
        log.error("排班服务调用失败:{}", throwable.getMessage());
        return new RemoteScheduleService() {
            @Override
            public ResultVO<Schedule> getById(Long id) {
                return ResultVO.error("查询排班失败:" + throwable.getMessage());
            }

            @Override
            public ResultVO<Boolean> update(Schedule schedule) {
                return ResultVO.error("更新排班失败:" + throwable.getMessage());
            }
        };
    }
}
