package com.ruoyi.department.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.department.domain.Department;
import com.ruoyi.department.mapper.DepartmentMapper;
import com.ruoyi.department.service.IDepartmentService;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

@Service
public class DepartmentServiceImpl extends ServiceImpl<DepartmentMapper, Department> implements IDepartmentService {

    @Override
    public List<Department> selectDepartmentList(Department department) {
        return list(new LambdaQueryWrapper<Department>()
                .like(department.getName() != null, Department::getName, department.getName()));
    }

    @Override
    public boolean insertDepartment(Department department) {
        // 检查名称唯一性
        Long count = baseMapper.selectCount(new LambdaQueryWrapper<Department>()
                .eq(Department::getName, department.getName()));
        if (count > 0) {
            throw new ServiceException("科室名称 '" + department.getName() + "' 已存在");
        }
        return save(department);
    }

    @Override
    public boolean updateDepartment(Department department) {
        // 检查名称唯一性
        Department oldDept = baseMapper.selectOne(new LambdaQueryWrapper<Department>()
                .eq(Department::getName, department.getName()));
        if (oldDept != null && !oldDept.getId().equals(department.getId())) {
            throw new ServiceException("科室名称 '" + department.getName() + "' 已存在");
        }
        return updateById(department);
    }

    @Override
    public boolean deleteDepartmentByIds(Long[] ids) {
        return removeBatchByIds(Arrays.asList(ids));
    }
}
