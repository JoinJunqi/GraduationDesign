package com.ruoyi.hospital.patient.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.hospital.patient.domain.Patient;

/**
 * 患者 Service 接口
 */
public interface IPatientService extends IService<Patient> {
    /**
     * 注册患者
     *
     * @param patient 患者信息
     * @return 是否成功
     */
    boolean register(Patient patient);

    /**
     * 登录
     *
     * @param username 用户名或手机号
     * @param password 密码
     * @return Token
     */
    String login(String username, String password);

    /**
     * 根据用户名查询
     *
     * @param username 用户名
     * @return 患者信息
     */
    Patient selectByUsername(String username);
}
