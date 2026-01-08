package com.ruoyi.hospital.department.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.hospital.department.domain.Department;
import com.ruoyi.hospital.department.mapper.DepartmentMapper;
import com.ruoyi.hospital.department.service.IDepartmentService;
import org.springframework.stereotype.Service;

/**
 * 科室 Service 实现类
 */
@Service
public class DepartmentServiceImpl extends ServiceImpl<DepartmentMapper, Department> implements IDepartmentService {
}
