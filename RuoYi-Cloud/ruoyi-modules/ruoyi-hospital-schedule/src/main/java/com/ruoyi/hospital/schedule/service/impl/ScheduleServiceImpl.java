package com.ruoyi.hospital.schedule.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.hospital.schedule.domain.Schedule;
import com.ruoyi.hospital.schedule.mapper.ScheduleMapper;
import com.ruoyi.hospital.schedule.service.IScheduleService;
import org.springframework.stereotype.Service;

/**
 * 排班 Service 实现类
 */
@Service
public class ScheduleServiceImpl extends ServiceImpl<ScheduleMapper, Schedule> implements IScheduleService {
}
