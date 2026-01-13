package com.ruoyi.doctor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.doctor.domain.Doctor;

import java.util.List;
import java.util.Map;

public interface IDoctorService extends IService<Doctor> {
    Doctor selectDoctorByUsername(String username);

    /**
     * 查询医生列表
     */
    public List<Doctor> selectDoctorList(Doctor doctor);

    /**
     * 根据科室ID查询医生列表
     */
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

    /**
     * 批量删除医生
     */
    boolean deleteDoctorByIds(Long[] ids);

    /**
     * 批量恢复医生
     */
    boolean recoverDoctorByIds(Long[] ids);

    /**
     * 校验用户名是否唯一
     */
    boolean checkUsernameUnique(String username);

    /**
     * 修改医生个人信息
     */
    boolean updateDoctorProfile(Doctor doctor);

    /**
     * 修改密码
     */
    boolean updatePassword(String oldPassword, String newPassword);

    /**
     * 重置密码
     */
    boolean resetPassword(Long id, String password);
}
