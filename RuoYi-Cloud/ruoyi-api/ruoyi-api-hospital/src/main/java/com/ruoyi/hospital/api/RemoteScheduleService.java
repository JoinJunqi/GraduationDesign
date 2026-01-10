package com.ruoyi.hospital.api;

import com.ruoyi.common.core.constant.ServiceNameConstants;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.api.domain.Schedule;
import com.ruoyi.hospital.api.factory.RemoteScheduleFallbackFactory;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

/**
 * 排班服务
 */
@FeignClient(contextId = "remoteScheduleService", value = "ruoyi-hospital-schedule", fallbackFactory = RemoteScheduleFallbackFactory.class)
public interface RemoteScheduleService {
    /**
     * 根据ID查询排班
     */
    @GetMapping("/schedule/{id}")
    ResultVO<Schedule> getById(@PathVariable("id") Long id);

    /**
     * 修改排班 (用于更新号源)
     */
    @PutMapping("/schedule")
    ResultVO<Boolean> update(@RequestBody Schedule schedule);
}
