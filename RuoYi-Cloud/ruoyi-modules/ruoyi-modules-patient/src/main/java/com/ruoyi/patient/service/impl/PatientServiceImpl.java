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
        patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPasswordHash()));
        return this.save(patient);
    }
}
