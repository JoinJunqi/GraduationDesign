package com.ruoyi.hospital.department.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.department.domain.Department;
import com.ruoyi.hospital.department.service.IDepartmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 科室控制器
 */
@RestController
@RequestMapping("/department")
public class DepartmentController {

    @Autowired
    private IDepartmentService departmentService;

    /**
     * 查询科室列表
     */
    @GetMapping("/list")
    public ResultVO<List<Department>> list(Department department) {
        LambdaQueryWrapper<Department> queryWrapper = new LambdaQueryWrapper<>();
        if (department.getName() != null) {
            queryWrapper.like(Department::getName, department.getName());
        }
        return ResultVO.success(departmentService.list(queryWrapper));
    }

    /**
     * 获取科室详细信息
     */
    @GetMapping(value = "/{id}")
    public ResultVO<Department> getInfo(@PathVariable("id") Long id) {
        return ResultVO.success(departmentService.getById(id));
    }

    /**
     * 新增科室
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Department department) {
        return ResultVO.success(departmentService.save(department));
    }

    /**
     * 修改科室
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Department department) {
        return ResultVO.success(departmentService.updateById(department));
    }

    /**
     * 删除科室
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable List<Long> ids) {
        return ResultVO.success(departmentService.removeByIds(ids));
    }
}
