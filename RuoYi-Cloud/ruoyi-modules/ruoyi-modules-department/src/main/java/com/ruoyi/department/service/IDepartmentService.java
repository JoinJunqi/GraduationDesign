package com.ruoyi.department.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.department.domain.Department;
import java.util.List;

public interface IDepartmentService extends IService<Department> {
    /**
     * 查询科室列表
     */
    List<Department> selectDepartmentList(Department department);

    /**
     * 查询包含说明的科室列表
     */
    List<Department> selectDepartmentWithIntroList(Department department);

    /**
     * 新增科室
     */
    boolean insertDepartment(Department department);

    /**
     * 修改科室
     */
    boolean updateDepartment(Department department);

    /**
     * 批量删除科室
     */
    boolean deleteDepartmentByIds(Long[] ids);
}
