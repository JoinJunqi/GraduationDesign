package com.ruoyi.system.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.web.page.TableDataInfo;
import com.ruoyi.system.api.domain.SysUser;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.common.security.utils.SecurityUtils;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.common.core.utils.ServletUtils;

@RestController
@RequestMapping("/admin")
public class AdminController extends BaseController
{
    @Autowired
    private ISysUserService userService;

    /**
     * 校验当前登录用户是否为超级管理员
     */
    private void checkSuperAdmin()
    {
        SysUser currentUser = userService.selectUserById(SecurityUtils.getUserId());
        if (currentUser == null || currentUser.getAdminLevel() == null || currentUser.getAdminLevel() != 1)
        {
            throw new ServiceException("权限不足，仅超级管理员可操作");
        }
    }

    /**
     * 查询管理员列表
     */
    @GetMapping("/list")
    public TableDataInfo list(SysUser user)
    {
        checkSuperAdmin();
        startPage();
        // 显式处理排序，防止 PageHelper 将 userId 错误映射为 user_id
        String orderByColumn = ServletUtils.getParameter("orderByColumn");
        String isAsc = ServletUtils.getParameter("isAsc");
        if ("userId".equals(orderByColumn) || "id".equals(orderByColumn)) {
            com.github.pagehelper.PageHelper.orderBy("id " + ("descending".equals(isAsc) || "desc".equals(isAsc) ? "desc" : "asc"));
        } else {
            startOrderBy();
        }
        List<SysUser> list = userService.selectUserList(user);
        return getDataTable(list);
    }

    /**
     * 获取指定管理员信息
     */
    @GetMapping("/{userId}")
    public ResultVO<SysUser> getInfo(@PathVariable Long userId)
    {
        checkSuperAdmin();
        return ResultVO.success(userService.selectUserById(userId));
    }

    /**
     * 新增管理员
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody SysUser user)
    {
        checkSuperAdmin();
        return ResultVO.success(userService.insertUser(user) > 0);
    }

    /**
     * 修改管理员
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody SysUser user)
    {
        checkSuperAdmin();
        if (user.getUserId() != null && user.getUserId().equals(SecurityUtils.getUserId()))
        {
            throw new ServiceException("不允许在管理员管理界面修改自己的账号信息/权限");
        }
        return ResultVO.success(userService.updateUser(user) > 0);
    }

    /**
     * 删除管理员
     */
    @DeleteMapping("/{userIds}")
    public ResultVO<Boolean> remove(@PathVariable Long[] userIds)
    {
        checkSuperAdmin();
        for (Long userId : userIds)
        {
            if (userId.equals(SecurityUtils.getUserId()))
            {
                throw new ServiceException("不允许删除自己的账号");
            }
        }
        return ResultVO.success(userService.deleteUserByIds(userIds) > 0);
    }

    /**
     * 查询个人信息
     */
    @GetMapping("/profile")
    public ResultVO<java.util.Map<String, Object>> profile()
    {
        return ResultVO.success(userService.selectUserProfile());
    }

    /**
     * 修改管理员个人信息
     */
    @PutMapping("/profile")
    public ResultVO<Boolean> updateProfile(@RequestBody SysUser user)
    {
        return ResultVO.success(userService.updateUserProfile(user));
    }

    /**
     * 修改密码
     */
    @PutMapping("/profile/updatePwd")
    public ResultVO<Boolean> updatePwd(@RequestParam("oldPassword") String oldPassword, @RequestParam("newPassword") String newPassword)
    {
        return ResultVO.success(userService.updatePassword(oldPassword, newPassword));
    }

    /**
     * 头像上传
     */
    @PostMapping("/profile/avatar")
    public ResultVO<String> avatar(@RequestParam("avatarfile") MultipartFile file) throws Exception
    {
        if (!file.isEmpty())
        {
            // 这里应该调用文件服务上传头像，暂且模拟返回一个路径
            String avatar = "/profile/avatar/default.png"; 
            if (userService.updateUserAvatar(SecurityUtils.getUserId(), avatar))
            {
                return ResultVO.success(avatar);
            }
        }
        return ResultVO.error("上传图片异常，请联系管理员");
    }
}
