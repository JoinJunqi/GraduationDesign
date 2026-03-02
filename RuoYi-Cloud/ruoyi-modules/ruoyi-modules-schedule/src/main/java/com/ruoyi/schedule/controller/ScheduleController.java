package com.ruoyi.schedule.controller;

import java.util.List;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.constant.UserConstants;
import com.ruoyi.system.api.model.LoginUser;
import com.ruoyi.common.security.utils.SecurityUtils;
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

    private boolean isDoctor()
    {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null)
        {
            return false;
        }
        return loginUser.getRoles() != null && loginUser.getRoles().contains("doctor");
    }

    @GetMapping("/list")
    public TableDataInfo list(Schedule schedule)
    {
        startPage();
        startOrderBy();
        List<Schedule> list = scheduleService.selectScheduleList(schedule);
        return getDataTable(list);
    }

    @GetMapping(value = "/{id}")
    public ResultVO<Schedule> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(scheduleService.getById(id));
    }

    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Schedule schedule)
    {
        if (!isDoctor())
        {
            SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
        }
        return ResultVO.success(scheduleService.insertSchedule(schedule));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Schedule schedule)
    {
        if (isDoctor())
        {
            return ResultVO.success(scheduleService.updateSchedule(schedule));
        }
        try
        {
            SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
            return ResultVO.success(scheduleService.updateSchedule(schedule));
        }
        catch (Exception e)
        {
            boolean isSlotsSync = schedule.getId() != null
                    && schedule.getAvailableSlots() != null
                    && schedule.getTotalCapacity() == null
                    && schedule.getStatus() == null;
            boolean isStatusSync = schedule.getId() != null
                    && schedule.getStatus() != null
                    && schedule.getTotalCapacity() == null
                    && schedule.getAvailableSlots() == null;
            if (isSlotsSync || isStatusSync)
            {
                Schedule syncSchedule = new Schedule();
                syncSchedule.setId(schedule.getId());
                if (schedule.getAvailableSlots() != null)
                {
                    syncSchedule.setAvailableSlots(schedule.getAvailableSlots());
                }
                if (schedule.getStatus() != null)
                {
                    syncSchedule.setStatus(schedule.getStatus());
                }
                return ResultVO.success(scheduleService.updateSchedule(syncSchedule));
            }
            throw e;
        }
    }

    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
        return ResultVO.success(scheduleService.deleteScheduleByIds(ids));
    }

    @PutMapping("/recover/{ids}")
    public ResultVO<Boolean> recover(@PathVariable Long[] ids)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
        return ResultVO.success(scheduleService.recoverScheduleByIds(ids));
    }
}
