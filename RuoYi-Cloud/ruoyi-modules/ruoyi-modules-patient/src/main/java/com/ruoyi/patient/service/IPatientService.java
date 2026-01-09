package com.ruoyi.patient.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.patient.domain.Patient;

public interface IPatientService extends IService<Patient> {
    Patient selectPatientByUsername(String username);
    boolean registerPatient(Patient patient);
    boolean checkUsernameUnique(String username);
    boolean checkPhoneUnique(Patient patient);
    boolean checkIdCardUnique(Patient patient);
    int resetPatientPwd(Long userId, String password);
}
