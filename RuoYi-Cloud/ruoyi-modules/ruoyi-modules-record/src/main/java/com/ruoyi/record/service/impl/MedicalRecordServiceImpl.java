package com.ruoyi.record.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.record.domain.MedicalRecord;
import com.ruoyi.record.mapper.MedicalRecordMapper;
import com.ruoyi.record.service.IMedicalRecordService;
import com.ruoyi.system.api.model.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Arrays;
import java.util.Date;

@Service
public class MedicalRecordServiceImpl extends ServiceImpl<MedicalRecordMapper, MedicalRecord> implements IMedicalRecordService {

    private static final Logger log = LoggerFactory.getLogger(MedicalRecordServiceImpl.class);

    @Autowired
    private MedicalRecordMapper medicalRecordMapper;

    private boolean hasRole(String role) {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getRoles() == null) {
            return false;
        }
        return loginUser.getRoles().contains(role);
    }

    @Override
    public List<MedicalRecord> selectMedicalRecordList(MedicalRecord medicalRecord) {
        Long userId = SecurityUtils.getUserId();
        if (hasRole("admin")) {
            log.info("User is admin, viewing all records");
        } else if (hasRole("doctor")) {
            log.info("User is doctor, filtering by doctorId={}", userId);
            medicalRecord.setDoctorId(userId);
        } else if (hasRole("patient")) {
            log.info("User is patient, filtering by patientId={}", userId);
            medicalRecord.setPatientId(userId);
        } else {
            log.warn("User has no recognized role, defaulting to patientId={}", userId);
            medicalRecord.setPatientId(userId);
        }
        return medicalRecordMapper.selectMedicalRecordList(medicalRecord);
    }

    @Override
    public MedicalRecord getMedicalRecordById(Long id) {
        MedicalRecord record = getById(id);
        if (record == null) {
            throw new ServiceException("病历不存在");
        }
        if (!hasRole("admin") && !hasRole("doctor") && !record.getPatientId().equals(SecurityUtils.getUserId())) {
            throw new ServiceException("无权查看他人病历");
        }
        return record;
    }

    @Override
    public boolean insertMedicalRecord(MedicalRecord medicalRecord) {
        if (hasRole("admin")) {
            // 管理员可以随意新增
        } else if (hasRole("doctor")) {
            medicalRecord.setDoctorId(SecurityUtils.getUserId());
        } else {
            // 患者新增
            medicalRecord.setPatientId(SecurityUtils.getUserId());
            medicalRecord.setDiagnosis(null);
            medicalRecord.setPrescription(null);
            medicalRecord.setNotes(null);
        }
        medicalRecord.setCreatedAt(new Date());
        if (medicalRecord.getVisitTime() == null) {
            medicalRecord.setVisitTime(new Date());
        }
        return save(medicalRecord);
    }

    @Override
    public boolean updateMedicalRecord(MedicalRecord medicalRecord) {
        MedicalRecord oldRecord = getById(medicalRecord.getId());
        if (oldRecord == null) {
            throw new ServiceException("病历不存在");
        }

        if (hasRole("admin")) {
            return updateById(medicalRecord);
        }

        if (hasRole("doctor")) {
            MedicalRecord updateRecord = new MedicalRecord();
            updateRecord.setId(medicalRecord.getId());
            updateRecord.setDiagnosis(medicalRecord.getDiagnosis());
            updateRecord.setPrescription(medicalRecord.getPrescription());
            updateRecord.setNotes(medicalRecord.getNotes());
            return updateById(updateRecord);
        } else {
            if (!oldRecord.getPatientId().equals(SecurityUtils.getUserId())) {
                throw new ServiceException("无权修改他人病历");
            }
            medicalRecord.setDiagnosis(null);
            medicalRecord.setPrescription(null);
            medicalRecord.setNotes(null);
            return updateById(medicalRecord);
        }
    }

    @Override
    public boolean deleteMedicalRecordByIds(Long[] ids) {
        if (hasRole("admin")) {
            return removeBatchByIds(Arrays.asList(ids));
        }

        for (Long id : ids) {
            MedicalRecord record = getById(id);
            if (record == null) continue;
            if (hasRole("doctor")) {
                throw new ServiceException("医生无权删除病历");
            } else {
                if (!record.getPatientId().equals(SecurityUtils.getUserId())) {
                    throw new ServiceException("无权删除他人病历");
                }
            }
        }
        return removeBatchByIds(Arrays.asList(ids));
    }
}
