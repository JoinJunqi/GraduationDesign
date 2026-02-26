package com.ruoyi.schedule.controller;

import java.util.List;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.constant.UserConstants;
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
        SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
        return ResultVO.success(scheduleService.insertSchedule(schedule));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Schedule schedule)
    {
        // 1. 首先尝试按管理员权限校验
        try 
        {
            SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
            return ResultVO.success(scheduleService.updateSchedule(schedule));
        } 
        catch (Exception e) 
        {
            // 2. 如果没有管理员权限，检查是否为合法的号源同步操作（跨服务调用）
            // 准则：只要包含 id 和 availableSlots，且没有尝试修改 totalCapacity，则视为同步操作
            if (schedule.getId() != null && schedule.getAvailableSlots() != null && schedule.getTotalCapacity() == null)
            {
                // 为安全起见，创建一个仅包含同步字段的新对象进行更新
                Schedule syncSchedule = new Schedule();
                syncSchedule.setId(schedule.getId());
                syncSchedule.setAvailableSlots(schedule.getAvailableSlots());
                return ResultVO.success(scheduleService.updateSchedule(syncSchedule));
            }
            // 3. 否则，重新抛出权限异常
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
