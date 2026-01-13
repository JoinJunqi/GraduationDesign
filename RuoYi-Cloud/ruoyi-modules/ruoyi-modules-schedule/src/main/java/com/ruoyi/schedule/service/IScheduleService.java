package com.ruoyi.schedule.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.schedule.domain.Schedule;
import java.util.List;

public interface IScheduleService extends IService<Schedule> {
    /**
     * 查询排班列表
     */
    List<Schedule> selectScheduleList(Schedule schedule);

    /**
     * 新增排班
     */
    boolean insertSchedule(Schedule schedule);

    /**
     * 修改排班
     */
    boolean updateSchedule(Schedule schedule);

    /**
     * 批量删除排班
     */
    boolean deleteScheduleByIds(Long[] ids);

    /**
     * 批量恢复排班
     */
    boolean recoverScheduleByIds(Long[] ids);
}
