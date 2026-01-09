package com.ruoyi.doctor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.doctor.domain.Doctor;

import java.util.List;
import java.util.Map;

public interface IDoctorService extends IService<Doctor> {
    Doctor selectDoctorByUsername(String username);

    List<Doctor> selectDoctorsByDeptId(Long deptId);

    /**
     * 医生登录
     * 
     * @param doctor 登录信息
     * @return 结果
     */
    Map<String, Object> login(Doctor doctor);

    /**
     * 新增医生
     */
    boolean insertDoctor(Doctor doctor);

    /**
     * 修改医生
     */
    boolean updateDoctor(Doctor doctor);
}
