package com.ruoyi.patient.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.patient.domain.Patient;
import com.ruoyi.patient.mapper.PatientMapper;
import com.ruoyi.patient.service.IPatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PatientServiceImpl extends ServiceImpl<PatientMapper, Patient> implements IPatientService {

    @Autowired
    private PatientMapper patientMapper;

    @Override
    public Patient selectPatientByUsername(String username) {
        return patientMapper.selectOne(new LambdaQueryWrapper<Patient>().eq(Patient::getUsername, username));
    }

    @Override
    public boolean registerPatient(Patient patient) {
        if (!checkUsernameUnique(patient.getUsername())) {
            return false;
        }
        if (!checkPhoneUnique(patient)) {
            return false;
        }
        if (!checkIdCardUnique(patient)) {
            return false;
        }
        patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPasswordHash()));
        return this.save(patient);
    }

    @Override
    public boolean checkUsernameUnique(String username) {
        Long count = patientMapper.selectCount(new LambdaQueryWrapper<Patient>().eq(Patient::getUsername, username));
        return count == 0;
    }

    @Override
    public boolean checkPhoneUnique(Patient patient) {
        Long patientId = patient.getId() == null ? -1L : patient.getId();
        Patient info = patientMapper.selectOne(new LambdaQueryWrapper<Patient>().eq(Patient::getPhone, patient.getPhone()));
        if (info != null && !info.getId().equals(patientId)) {
            return false;
        }
        return true;
    }

    @Override
    public boolean checkIdCardUnique(Patient patient) {
        Long patientId = patient.getId() == null ? -1L : patient.getId();
        Patient info = patientMapper.selectOne(new LambdaQueryWrapper<Patient>().eq(Patient::getIdCard, patient.getIdCard()));
        if (info != null && !info.getId().equals(patientId)) {
            return false;
        }
        return true;
    }

    @Override
    public int resetPatientPwd(Long userId, String password) {
        Patient patient = new Patient();
        patient.setId(userId);
        patient.setPasswordHash(password);
        return patientMapper.updateById(patient);
    }
}
