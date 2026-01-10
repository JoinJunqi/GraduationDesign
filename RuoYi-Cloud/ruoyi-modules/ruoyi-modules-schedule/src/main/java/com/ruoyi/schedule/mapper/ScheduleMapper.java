package com.ruoyi.schedule.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.schedule.domain.Schedule;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface ScheduleMapper extends BaseMapper<Schedule> {
    /**
     * 查询排班列表
     */
    List<Schedule> selectScheduleList(Schedule schedule);
}
