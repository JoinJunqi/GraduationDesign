package com.ruoyi.department.controller;

import java.util.List;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.web.page.TableDataInfo;
import com.ruoyi.department.domain.Department;
import com.ruoyi.department.service.IDepartmentService;

@RestController
public class DepartmentController extends BaseController
{
    @Autowired
    private IDepartmentService departmentService;

    @GetMapping("/list")
    public ResultVO<List<Department>> list(Department department)
    {
        List<Department> list = departmentService.list();
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
        return ResultVO.success(departmentService.save(department));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Department department)
    {
        return ResultVO.success(departmentService.updateById(department));
    }

    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        return ResultVO.success(departmentService.removeBatchByIds(Arrays.asList(ids)));
    }
}
