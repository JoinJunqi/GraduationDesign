package com.ruoyi.department.controller;

import java.util.List;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.constant.UserConstants;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.web.page.TableDataInfo;
import com.ruoyi.department.domain.Department;
import com.ruoyi.department.service.IDepartmentService;

@RestController
@RequestMapping("/department")
public class DepartmentController extends BaseController
{
    @Autowired
    private IDepartmentService departmentService;

    @GetMapping("/list")
    public TableDataInfo list(Department department)
    {
        startPage();
        startOrderBy();
        List<Department> list = departmentService.selectDepartmentList(department);
        return getDataTable(list);
    }

    @GetMapping("/listWithIntro")
    public ResultVO<List<Department>> listWithIntro(Department department)
    {
        List<Department> list = departmentService.selectDepartmentWithIntroList(department);
        return ResultVO.success(list);
    }

    @GetMapping(value = "/{id}")
    public ResultVO<Department> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(departmentService.getById(id));
    }

    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Department department)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_DEPT);
        return ResultVO.success(departmentService.insertDepartment(department));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Department department)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_DEPT);
        return ResultVO.success(departmentService.updateDepartment(department));
    }

    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_DEPT);
        return ResultVO.success(departmentService.deleteDepartmentByIds(ids));
    }

    @PutMapping("/recover/{ids}")
    public ResultVO<Boolean> recover(@PathVariable Long[] ids)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_DEPT);
        return ResultVO.success(departmentService.recoverDepartmentByIds(ids));
    }
}
