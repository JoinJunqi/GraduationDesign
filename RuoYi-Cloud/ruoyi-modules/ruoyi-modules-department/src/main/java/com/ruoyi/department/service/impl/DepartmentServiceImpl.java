package com.ruoyi.department.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.department.domain.Department;
import com.ruoyi.department.mapper.DepartmentMapper;
import com.ruoyi.department.service.IDepartmentIntroService;
import com.ruoyi.department.service.IDepartmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Service
public class DepartmentServiceImpl extends ServiceImpl<DepartmentMapper, Department> implements IDepartmentService {

    @Autowired
    private IDepartmentIntroService departmentIntroService;

    @Override
    public List<Department> selectDepartmentList(Department department) {
        return list(new LambdaQueryWrapper<Department>()
                .like(department.getName() != null, Department::getName, department.getName()));
    }

    @Override
    public List<Department> selectDepartmentWithIntroList(Department department) {
        return baseMapper.selectDepartmentWithIntroList(department);
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
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteDepartmentByIds(Long[] ids) {
        // 先逻辑删除关联的科室说明
        departmentIntroService.deleteByDeptIds(ids);
        
        Department department = new Department();
        department.setIsDeleted(1);
        department.setDeletedAt(new Date());
        return update(department, new LambdaQueryWrapper<Department>().in(Department::getId, Arrays.asList(ids)));
    }
}
