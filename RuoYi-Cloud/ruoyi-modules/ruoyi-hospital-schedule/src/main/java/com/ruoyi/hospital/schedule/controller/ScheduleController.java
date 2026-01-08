package com.ruoyi.hospital.schedule.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.schedule.domain.Schedule;
import com.ruoyi.hospital.schedule.service.IScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 排班控制器
 */
@RestController
@RequestMapping("/schedule")
public class ScheduleController {

    @Autowired
    private IScheduleService scheduleService;

    /**
     * 查询排班列表
     */
    @GetMapping("/list")
    public ResultVO<List<Schedule>> list(Schedule schedule) {
        LambdaQueryWrapper<Schedule> queryWrapper = new LambdaQueryWrapper<>();
        if (schedule.getDoctorId() != null) {
            queryWrapper.eq(Schedule::getDoctorId, schedule.getDoctorId());
        }
        if (schedule.getWorkDate() != null) {
            queryWrapper.eq(Schedule::getWorkDate, schedule.getWorkDate());
        }
        return ResultVO.success(scheduleService.list(queryWrapper));
    }

    /**
     * 获取排班详细信息
     */
    @GetMapping(value = "/{id}")
    public ResultVO<Schedule> getInfo(@PathVariable("id") Long id) {
        return ResultVO.success(scheduleService.getById(id));
    }

    /**
     * 新增排班
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Schedule schedule) {
        return ResultVO.success(scheduleService.save(schedule));
    }

    /**
     * 修改排班
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Schedule schedule) {
        return ResultVO.success(scheduleService.updateById(schedule));
    }

    /**
     * 删除排班
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable List<Long> ids) {
        return ResultVO.success(scheduleService.removeByIds(ids));
    }
}
