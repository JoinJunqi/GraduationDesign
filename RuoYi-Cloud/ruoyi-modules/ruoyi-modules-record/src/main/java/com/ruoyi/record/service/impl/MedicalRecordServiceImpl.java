package com.ruoyi.record.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.hospital.api.RemoteAppointmentService;
import com.ruoyi.record.domain.MedicalRecord;
import com.ruoyi.record.mapper.MedicalRecordMapper;
import com.ruoyi.record.service.IMedicalRecordService;
import com.ruoyi.system.api.model.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class MedicalRecordServiceImpl extends ServiceImpl<MedicalRecordMapper, MedicalRecord> implements IMedicalRecordService {

    private static final Logger log = LoggerFactory.getLogger(MedicalRecordServiceImpl.class);

    @Autowired
    private MedicalRecordMapper medicalRecordMapper;

    @Autowired
    private RemoteAppointmentService remoteAppointmentService;

    /**
     * 判断是否为管理员
     */
    private boolean isAdminUser() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null) return SecurityUtils.isAdmin(SecurityUtils.getUserId());
        Set<String> roles = loginUser.getRoles();
        return roles != null && (roles.contains("admin") || roles.contains("ROLE_ADMIN")) || SecurityUtils.isAdmin(loginUser.getUserid());
    }

    @Override
    public List<MedicalRecord> selectMedicalRecordList(MedicalRecord medicalRecord) {
        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();
        
        log.info("MedicalRecord List Query - UserID: {}, Roles: {}, Params: {}", userId, roles, medicalRecord);
        
        if (isAdminUser()) {
            log.info("Admin access: viewing all records");
        } else if (roles.contains("doctor")) {
            log.info("Doctor access: filtering by doctorId={}", userId);
            medicalRecord.setDoctorId(userId);
        } else if (roles.contains("patient")) {
            log.info("Patient access: filtering by patientId={}", userId);
            medicalRecord.setPatientId(userId);
        } else {
            // 兜底逻辑
            if (userId != null && userId == 1L) {
                log.info("System Admin(ID=1) access: viewing all records");
            } else {
                log.warn("Unknown role: defaulting to patient filter for userId={}", userId);
                medicalRecord.setPatientId(userId);
            }
        }
        return medicalRecordMapper.selectMedicalRecordList(medicalRecord);
    }

    @Override
    public MedicalRecord getMedicalRecordById(Long id) {
        MedicalRecord record = medicalRecordMapper.selectMedicalRecordById(id);
        if (record == null) {
            throw new ServiceException("病历不存在");
        }
        
        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();
        
        if (!isAdminUser() && !roles.contains("doctor") && !record.getPatientId().equals(userId)) {
            throw new ServiceException("无权查看他人病历");
        }
        return record;
    }

    /**
     * 获取当前用户角色集合
     */
    private Set<String> getRoles() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        return loginUser != null ? loginUser.getRoles() : new HashSet<>();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean insertMedicalRecord(MedicalRecord medicalRecord) {
        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();
        
        log.info("Insert medical record. User: {}, roles: {}", userId, roles);

        if (isAdminUser()) {
            log.info("Admin inserting medical record");
        } else if (roles.contains("doctor")) {
            log.info("Doctor inserting medical record, setting doctorId={}", userId);
            medicalRecord.setDoctorId(userId);
        } else if (roles.contains("patient")) {
            log.info("Patient inserting medical record, setting patientId={}", userId);
            medicalRecord.setPatientId(userId);
            // 患者不能直接新增包含诊断信息的病历
            medicalRecord.setDiagnosis(null);
            medicalRecord.setPrescription(null);
            medicalRecord.setNotes(null);
        } else {
            log.warn("Unknown role inserting medical record, default to patientId={}", userId);
            medicalRecord.setPatientId(userId);
        }

        // 如果有关联预约，从预约中获取患者ID以确保正确性
        if (medicalRecord.getAppointmentId() != null) {
            log.info("Fetching appointment info for appointmentId={}", medicalRecord.getAppointmentId());
            ResultVO<com.ruoyi.hospital.api.domain.Appointment> appointmentResult = remoteAppointmentService.getInfo(medicalRecord.getAppointmentId());
            if (appointmentResult != null && appointmentResult.getData() != null) {
                Long patientIdFromAppt = appointmentResult.getData().getPatientId();
                log.info("Found patientId={} from appointment", patientIdFromAppt);
                medicalRecord.setPatientId(patientIdFromAppt);
            } else {
                log.warn("Could not find appointment info for ID={}", medicalRecord.getAppointmentId());
            }
        }

        medicalRecord.setCreatedAt(new Date());
        if (medicalRecord.getVisitTime() == null) {
            medicalRecord.setVisitTime(new Date());
        }
        
        log.info("Final medical record to save: {}", medicalRecord);
        boolean saved = save(medicalRecord);
        if (saved && medicalRecord.getAppointmentId() != null) {
            // 就诊完成，更新预约状态为“已完成”
            log.info("Updating appointment status to '已完成' for appointmentId={}", medicalRecord.getAppointmentId());
            ResultVO<Boolean> result = remoteAppointmentService.updateStatus(medicalRecord.getAppointmentId(), "已完成");
            if (result == null || !result.getData()) {
                log.error("Failed to update appointment status");
                throw new ServiceException("更新预约状态失败");
            }
        }
        return saved;
    }

    @Override
    public boolean updateMedicalRecord(MedicalRecord medicalRecord) {
        MedicalRecord oldRecord = getById(medicalRecord.getId());
        if (oldRecord == null) {
            throw new ServiceException("病历不存在");
        }

        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();
        
        log.info("Update medical record ID: {}. User: {}, roles: {}", medicalRecord.getId(), userId, roles);

        if (isAdminUser()) {
            return updateById(medicalRecord);
        }

        if (roles.contains("doctor")) {
            // 医生只能修改诊断和处方
            MedicalRecord updateRecord = new MedicalRecord();
            updateRecord.setId(medicalRecord.getId());
            updateRecord.setDiagnosis(medicalRecord.getDiagnosis());
            updateRecord.setPrescription(medicalRecord.getPrescription());
            updateRecord.setNotes(medicalRecord.getNotes());
            log.info("Doctor updating record details");
            return updateById(updateRecord);
        } else {
            // 患者只能查看或修改有限信息（通常患者不应修改病历）
            if (oldRecord.getPatientId() != null && !oldRecord.getPatientId().equals(userId)) {
                log.error("Permission denied. Record patientId={}, current userId={}", oldRecord.getPatientId(), userId);
                throw new ServiceException("无权修改他人病历");
            }
            medicalRecord.setDiagnosis(null);
            medicalRecord.setPrescription(null);
            medicalRecord.setNotes(null);
            log.info("Patient updating record (limited fields)");
            return updateById(medicalRecord);
        }
    }

    @Override
    public boolean deleteMedicalRecordByIds(Long[] ids) {
        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();

        log.info("Delete medical records: {}. User: {}, roles: {}", Arrays.toString(ids), userId, roles);

        if (isAdminUser()) {
            return removeBatchByIds(Arrays.asList(ids));
        }

        for (Long id : ids) {
            MedicalRecord record = getById(id);
            if (record == null) continue;
            
            if (roles.contains("doctor")) {
                log.error("Doctor tried to delete record ID: {}", id);
                throw new ServiceException("医生无权删除病历");
            } else {
                if (record.getPatientId() != null && !record.getPatientId().equals(userId)) {
                    log.error("Permission denied. Record patientId={}, current userId={}", record.getPatientId(), userId);
                    throw new ServiceException("无权删除他人病历");
                }
            }
        }
        return removeBatchByIds(Arrays.asList(ids));
    }
}
