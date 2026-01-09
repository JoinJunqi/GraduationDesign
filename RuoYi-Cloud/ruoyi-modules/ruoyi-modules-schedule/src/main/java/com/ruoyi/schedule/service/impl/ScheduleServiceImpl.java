package com.ruoyi.schedule.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.schedule.domain.Schedule;
import com.ruoyi.schedule.mapper.ScheduleMapper;
import com.ruoyi.schedule.service.IScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ScheduleServiceImpl extends ServiceImpl<ScheduleMapper, Schedule> implements IScheduleService {

    @Autowired
    private ScheduleMapper scheduleMapper;

    @Override
    public boolean addSchedule(Schedule schedule) {
        // 检查排班冲突
        Long count = scheduleMapper.selectCount(new LambdaQueryWrapper<Schedule>()
                .eq(Schedule::getDoctorId, schedule.getDoctorId())
                .eq(Schedule::getWorkDate, schedule.getWorkDate())
                .eq(Schedule::getTimeSlot, schedule.getTimeSlot()));
        if (count > 0) {
            throw new RuntimeException("该时段已有排班");
        }
        
        schedule.setAvailableSlots(schedule.getTotalCapacity());
        return this.save(schedule);
    }

    @Override
    public List<Schedule> selectScheduleList(Schedule schedule) {
        return scheduleMapper.selectList(new LambdaQueryWrapper<Schedule>()
                .eq(schedule.getDoctorId() != null, Schedule::getDoctorId, schedule.getDoctorId())
                .eq(schedule.getWorkDate() != null, Schedule::getWorkDate, schedule.getWorkDate()));
    }
}
