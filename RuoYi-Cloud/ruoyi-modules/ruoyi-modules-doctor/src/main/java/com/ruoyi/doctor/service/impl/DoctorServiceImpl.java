package com.ruoyi.doctor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.doctor.domain.Doctor;
import com.ruoyi.doctor.mapper.DoctorMapper;
import com.ruoyi.doctor.service.IDoctorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class DoctorServiceImpl extends ServiceImpl<DoctorMapper, Doctor> implements IDoctorService {

    @Autowired
    private DoctorMapper doctorMapper;

    @Override
    public Doctor selectDoctorByUsername(String username) {
        return doctorMapper.selectOne(new LambdaQueryWrapper<Doctor>().eq(Doctor::getUsername, username));
    }

    @Override
    public List<Doctor> selectDoctorsByDeptId(Long deptId) {
        return doctorMapper.selectList(new LambdaQueryWrapper<Doctor>().eq(Doctor::getDeptId, deptId));
    }
}
