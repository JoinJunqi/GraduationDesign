package com.ruoyi.system.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.web.controller.BaseController;
import java.util.Map;
// import com.ruoyi.department.domain.Department;
// import com.ruoyi.doctor.domain.Doctor;
// import com.ruoyi.patient.domain.Patient;
// 假设有对应的Service接口，实际需注入DepartmentService等，这里为演示简化
// import com.ruoyi.system.service.IDepartmentService; 

import com.ruoyi.system.api.domain.SysUser;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.common.security.utils.SecurityUtils;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/admin")
public class AdminController extends BaseController
{
    @Autowired
    private ISysUserService userService;

    /**
     * 查询管理员列表
     */
    @GetMapping("/list")
    public ResultVO<List<SysUser>> list(SysUser user)
    {
        startPage();
        List<SysUser> list = userService.selectUserList(user);
        return ResultVO.success(list);
    }

    /**
     * 获取指定管理员信息
     */
    @GetMapping("/{userId}")
    public ResultVO<SysUser> getInfo(@PathVariable Long userId)
    {
        return ResultVO.success(userService.selectUserById(userId));
    }

    /**
     * 新增管理员
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody SysUser user)
    {
        if (user.getUserName() != null && !userService.checkUserNameUnique(user))
        {
            return ResultVO.error("新增管理员'" + user.getUserName() + "'失败，登录账号已存在");
        }
        user.setPassword(SecurityUtils.encryptPassword(user.getPassword()));
        return ResultVO.success(userService.insertUser(user) > 0);
    }

    /**
     * 修改管理员
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody SysUser user)
    {
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(SecurityUtils.encryptPassword(user.getPassword()));
        }
        return ResultVO.success(userService.updateUser(user) > 0);
    }

    /**
     * 删除管理员
     */
    @DeleteMapping("/{userIds}")
    public ResultVO<Boolean> remove(@PathVariable Long[] userIds)
    {
        return ResultVO.success(userService.deleteUserByIds(userIds) > 0);
    }

    @Autowired
    private com.ruoyi.system.service.ISysPermissionService permissionService;

    /**
     * 查询个人信息
     */
    @GetMapping("/profile")
    public com.ruoyi.common.core.web.domain.AjaxResult profile()
    {
        Long userId = SecurityUtils.getUserId();
        SysUser user = userService.selectUserById(userId);
        com.ruoyi.common.core.web.domain.AjaxResult ajax = com.ruoyi.common.core.web.domain.AjaxResult.success(user);
        ajax.put("roleGroup", userService.selectUserRoleGroup(user.getUserName()));
        ajax.put("postGroup", userService.selectUserPostGroup(user.getUserName()));
        return ajax;
    }

    /**
     * 修改管理员个人信息
     */
    @PutMapping("/profile")
    public ResultVO<Boolean> updateProfile(@RequestBody SysUser user)
    {
        user.setUserId(SecurityUtils.getUserId());
        // 不允许修改账号和密码
        user.setUserName(null);
        user.setPassword(null);
        return ResultVO.success(userService.updateUserProfile(user));
    }

    /**
     * 修改密码
     */
    @PutMapping("/profile/updatePwd")
    public ResultVO<Boolean> updatePwd(@RequestParam("oldPassword") String oldPassword, @RequestParam("newPassword") String newPassword)
    {
        String username = SecurityUtils.getUsername();
        SysUser user = userService.selectUserByUserName(username);
        String password = user.getPassword();
        if (!SecurityUtils.matchesPassword(oldPassword, password))
        {
            return ResultVO.error("修改密码失败，旧密码错误");
        }
        if (SecurityUtils.matchesPassword(newPassword, password))
        {
            return ResultVO.error("新密码不能与旧密码相同");
        }
        if (userService.resetUserPwd(user.getUserId(), SecurityUtils.encryptPassword(newPassword)) > 0)
        {
            return ResultVO.success(true);
        }
        return ResultVO.error("修改密码异常，请联系管理员");
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
            // String avatar = userService.updateUserAvatar(username, file);
            String avatar = "/profile/avatar/default.png"; 
            if (userService.updateUserAvatar(SecurityUtils.getUserId(), avatar))
            {
                return ResultVO.success(avatar);
            }
        }
        return ResultVO.error("上传图片异常，请联系管理员");
    }
}
