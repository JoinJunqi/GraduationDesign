package com.ruoyi.department.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.department.domain.Department;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

/**
 * 科室Mapper接口
 */
@Mapper
public interface DepartmentMapper extends BaseMapper<Department> {
    /**
     * 查询科室列表
     */
    List<Department> selectDepartmentList(Department department);

    /**
     * 查询包含说明的科室列表
     */
    List<Department> selectDepartmentWithIntroList(Department department);
}
