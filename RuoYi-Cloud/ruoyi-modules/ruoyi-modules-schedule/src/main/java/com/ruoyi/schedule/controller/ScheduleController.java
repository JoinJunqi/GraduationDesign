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

    /**
     * 判断当前登录用户是否为医生角色。
     */
    private boolean isDoctor()
    {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null)
        {
            return false;
        }
        if (loginUser.getRoles() != null)
        {
            for (String role : loginUser.getRoles())
            {
                if ("doctor".equalsIgnoreCase(role))
                {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * 分页查询排班列表。
     */
    @GetMapping("/list")
    public TableDataInfo list(Schedule schedule)
    {
        // 步骤1：初始化分页与排序上下文
        startPage();
        startOrderBy();
        // 步骤2：查询并封装表格数据
        List<Schedule> list = scheduleService.selectScheduleList(schedule);
        return getDataTable(list);
    }

    /**
     * 根据ID查询排班详情。
     */
    @GetMapping(value = "/{id}")
    public ResultVO<Schedule> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(scheduleService.getById(id));
    }

    /**
     * 新增排班：医生可直接提交，其他角色需管理员权限。
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Schedule schedule)
    {
        // 步骤1：非医生角色走管理员权限校验
        if (!isDoctor())
        {
            SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
        }
        // 步骤2：调用服务层新增排班
        return ResultVO.success(scheduleService.insertSchedule(schedule));
    }

    /**
     * 编辑排班：医生可直接修改；管理员路径包含兜底同步逻辑。
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Schedule schedule)
    {
        // 步骤1：医生角色可直接修改
        if (isDoctor())
        {
            return ResultVO.success(scheduleService.updateSchedule(schedule));
        }
        try
        {
            // 步骤2：管理员正常修改路径
            SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
            return ResultVO.success(scheduleService.updateSchedule(schedule));
        }
        catch (Exception e)
        {
            // 步骤3：兜底处理预约模块回写的“号源同步/状态同步”请求
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

    /**
     * 删除排班：医生可删除本人排班（细则在Service层校验），其他角色需管理员权限。
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        // 允许医生删除自己的排班 (Service层会校验日期)
        if (!isDoctor()) {
            SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
        }
        return ResultVO.success(scheduleService.deleteScheduleByIds(ids));
    }

    /**
     * 批量恢复排班（管理员权限）。
     */
    @PutMapping("/recover/{ids}")
    public ResultVO<Boolean> recover(@PathVariable Long[] ids)
    {
        // 步骤1：管理员权限校验
        SecurityUtils.checkAdminPermission(UserConstants.PERM_SCHEDULE);
        // 步骤2：调用恢复逻辑
        return ResultVO.success(scheduleService.recoverScheduleByIds(ids));
    }
}
