package com.ruoyi.department.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.department.domain.Department;
import com.ruoyi.department.mapper.DepartmentMapper;
import com.ruoyi.department.service.IDepartmentService;
import org.springframework.stereotype.Service;

@Service
public class DepartmentServiceImpl extends ServiceImpl<DepartmentMapper, Department> implements IDepartmentService {
}
