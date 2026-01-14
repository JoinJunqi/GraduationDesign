package com.ruoyi.system.service.impl;

import java.util.HashSet;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.api.domain.SysUser;
import com.ruoyi.system.service.ISysMenuService;
import com.ruoyi.system.service.ISysPermissionService;

/**
 * 用户权限处理
 * 
 * @author ruoyi
 */
@Service
public class SysPermissionServiceImpl implements ISysPermissionService
{
    @Autowired
    private ISysMenuService menuService;

    /**
     * 获取角色数据权限
     * 
     * @param user 用户信息
     * @return 角色权限信息
     */
    @Override
    public Set<String> getRolePermission(SysUser user)
    {
        Set<String> roles = new HashSet<String>();
        // 管理员拥有所有权限
        if (user.isAdmin())
        {
            roles.add("admin");
        }
        else
        {
            roles.add("common");
        }
        return roles;
    }

    /**
     * 获取菜单数据权限
     * 
     * @param user 用户信息
     * @return 菜单权限信息
     */
    @Override
    public Set<String> getMenuPermission(SysUser user)
    {
        Set<String> perms = new HashSet<String>();
        // 管理员（包括超级管理员和普通管理员）都赋予全部权限字符串
        // 这样可以绕过前端 v-hasPermi 的通用校验，具体的业务权限由 bitmask (permissions 字段) 控制
        if (user.getAdminLevel() != null)
        {
            perms.add("*:*:*");
        }
        else
        {
            // 非管理员用户（如以后扩展的患者、医生通过该接口查询时）赋予基础权限
            perms.add("common"); 
        }
        return perms;
    }
}
