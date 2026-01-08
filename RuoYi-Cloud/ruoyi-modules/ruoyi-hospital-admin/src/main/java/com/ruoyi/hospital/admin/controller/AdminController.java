package com.ruoyi.hospital.admin.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.admin.domain.Admin;
import com.ruoyi.hospital.admin.service.IAdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 管理员控制器
 */
@RestController
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private IAdminService adminService;

    /**
     * 查询管理员列表
     */
    @GetMapping("/list")
    public ResultVO<List<Admin>> list(Admin admin) {
        LambdaQueryWrapper<Admin> queryWrapper = new LambdaQueryWrapper<>();
        if (admin.getUsername() != null) {
            queryWrapper.like(Admin::getUsername, admin.getUsername());
        }
        if (admin.getName() != null) {
            queryWrapper.like(Admin::getName, admin.getName());
        }
        return ResultVO.success(adminService.list(queryWrapper));
    }

    /**
     * 获取管理员详细信息
     */
    @GetMapping(value = "/{id}")
    public ResultVO<Admin> getInfo(@PathVariable("id") Long id) {
        return ResultVO.success(adminService.getById(id));
    }

    /**
     * 新增管理员
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Admin admin) {
        return ResultVO.success(adminService.save(admin));
    }

    /**
     * 修改管理员
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Admin admin) {
        return ResultVO.success(adminService.updateById(admin));
    }

    /**
     * 删除管理员
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable List<Long> ids) {
        return ResultVO.success(adminService.removeByIds(ids));
    }
}
