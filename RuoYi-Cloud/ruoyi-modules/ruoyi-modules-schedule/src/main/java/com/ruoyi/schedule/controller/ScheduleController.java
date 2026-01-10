package com.ruoyi.schedule.controller;

import java.util.List;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.web.page.TableDataInfo;
import com.ruoyi.schedule.domain.Schedule;
import com.ruoyi.schedule.service.IScheduleService;

@RestController
@RequestMapping("/schedule")
public class ScheduleController extends BaseController
{
    @Autowired
    private IScheduleService scheduleService;

    @GetMapping("/list")
    public ResultVO<List<Schedule>> list(Schedule schedule)
    {
        List<Schedule> list = scheduleService.selectScheduleList(schedule);
        return ResultVO.success(list);
    }

    @GetMapping(value = "/{id}")
    public ResultVO<Schedule> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(scheduleService.getById(id));
    }

    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Schedule schedule)
    {
        return ResultVO.success(scheduleService.insertSchedule(schedule));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Schedule schedule)
    {
        return ResultVO.success(scheduleService.updateSchedule(schedule));
    }

    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        return ResultVO.success(scheduleService.deleteScheduleByIds(ids));
    }
}
