package com.ruoyi.doctor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.doctor.domain.Doctor;
import java.util.List;

public interface IDoctorService extends IService<Doctor> {
    Doctor selectDoctorByUsername(String username);
    List<Doctor> selectDoctorsByDeptId(Long deptId);
}
