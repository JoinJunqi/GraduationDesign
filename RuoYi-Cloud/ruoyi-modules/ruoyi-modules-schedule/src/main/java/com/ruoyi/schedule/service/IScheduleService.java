package com.ruoyi.schedule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.schedule.domain.Schedule;
import java.util.List;

public interface IScheduleService extends IService<Schedule> {
    boolean addSchedule(Schedule schedule);
    List<Schedule> selectScheduleList(Schedule schedule);
}
