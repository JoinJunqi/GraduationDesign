package com.ruoyi.patient.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.patient.domain.Patient;
import java.util.List;
import java.util.Map;

public interface IPatientService extends IService<Patient> {
    Patient selectPatientByUsername(String username);

    boolean checkUsernameUnique(String username);

    boolean checkPhoneUnique(Patient patient);

    boolean checkIdCardUnique(Patient patient);

    int resetPatientPwd(Long userId, String password);

    /**
     * 患者登录
     */
    Map<String, Object> login(Patient patient);

    /**
     * 查询患者列表
     */
    public List<Patient> selectPatientList(Patient patient);

    /**
     * 患者注册
     */
    boolean register(Patient patient);

    /**
     * 新增患者
     */
    boolean insertPatient(Patient patient);

    /**
     * 修改患者
     */
    boolean updatePatient(Patient patient);

    /**
     * 批量删除患者
     */
    boolean deletePatientByIds(Long[] ids);

    /**
     * 批量恢复患者
     */
    boolean recoverPatientByIds(Long[] ids);

    /**
     * 修改患者个人信息
     */
    boolean updatePatientProfile(Patient patient);

    /**
     * 修改密码
     */
    boolean updatePassword(String oldPassword, String newPassword);
}
