package com.ruoyi.patient.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.patient.domain.Patient;

public interface IPatientService extends IService<Patient> {
    Patient selectPatientByUsername(String username);
    boolean registerPatient(Patient patient);
}
