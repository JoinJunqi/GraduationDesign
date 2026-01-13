package com.ruoyi.record.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
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
        if (loginUser == null) return false;
        
        // 1. 检查角色标识 (不区分大小写)
        Set<String> roles = loginUser.getRoles();
        if (roles != null) {
            for (String role : roles) {
                if ("admin".equalsIgnoreCase(role) || "ROLE_ADMIN".equalsIgnoreCase(role)) {
                    return true;
                }
            }
        }
        
        // 2. 检查用户ID (RuoYi默认超级管理员ID为1)
        if (loginUser.getUserid() != null && loginUser.getUserid() == 1L) {
            return true;
        }

        // 3. 检查系统用户标识 (如果存在)
        if (loginUser.getSysUser() != null && loginUser.getSysUser().isAdmin()) {
            return true;
        }

        return false;
    }

    @Override
    public List<MedicalRecord> selectMedicalRecordList(MedicalRecord medicalRecord) {
        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();
        
        log.info("selectMedicalRecordList - userId: {}, roles: {}, medicalRecord: {}", userId, roles, medicalRecord);

        if (isAdminUser()) {
            log.info("Admin access: viewing all records");
        } else if (roles.contains("doctor")) {
            // 医生视角：如果提供了患者查询条件，则允许查看该患者的所有病历；否则只看自己开具的病历
            if (medicalRecord.getPatientId() != null || (medicalRecord.getPatientName() != null && !medicalRecord.getPatientName().isEmpty())) {
                log.info("Doctor access: searching for patient history. Not filtering by doctorId.");
            } else {
                log.info("Doctor access: no patient filter, defaulting to own records. doctorId={}", userId);
                medicalRecord.setDoctorId(userId);
            }
        } else if (roles.contains("patient")) {
            log.info("Patient access: filtering by patientId={}", userId);
            medicalRecord.setPatientId(userId);
        } else {
            // 如果没有任何角色，默认可能是通过其他方式登录的，也尝试使用userId作为patientId
            log.info("Unknown access (roles empty): filtering by patientId={}", userId);
            medicalRecord.setPatientId(userId);
        }
        
        log.info("Executing selectMedicalRecordList with params: patientId={}, doctorId={}, diagnosis={}", 
                 medicalRecord.getPatientId(), medicalRecord.getDoctorId(), medicalRecord.getDiagnosis());
                 
        List<MedicalRecord> list = medicalRecordMapper.selectMedicalRecordList(medicalRecord);
        log.info("selectMedicalRecordList result size: {}", list != null ? list.size() : 0);
        return list;
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
        } else {
            log.error("Patient or unknown role tried to insert medical record. User: {}, roles: {}", userId, roles);
            throw new ServiceException("患者无权新增病历单，请联系医生操作");
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
        
        // 1. 如果有关联预约，先更新预约状态（避免死锁）
        // 为什么先更新？因为 INSERT INTO medical_record 会持有 appointment 表的 S 锁（外键检查）
        // 如果先 INSERT 再调远程更新，远程更新需要 appointment 表的 X 锁，会导致循环等待。
        if (medicalRecord.getAppointmentId() != null) {
            log.info("Updating appointment status to '已完成' for appointmentId={}", medicalRecord.getAppointmentId());
            ResultVO<Boolean> result = remoteAppointmentService.updateStatus(medicalRecord.getAppointmentId(), "已完成");
            if (result == null || !result.getData()) {
                log.error("Failed to update appointment status");
                throw new ServiceException("更新预约状态失败");
            }
        }

        log.info("Final medical record to save: {}", medicalRecord);
        return save(medicalRecord);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateMedicalRecord(MedicalRecord medicalRecord) {
        MedicalRecord oldRecord = getById(medicalRecord.getId());
        if (oldRecord == null) {
            throw new ServiceException("病历不存在");
        }

        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();
        
        log.info("Update medical record ID: {}. User: {}, roles: {}", medicalRecord.getId(), userId, roles);

        // 如果有关联预约且是医生操作，尝试更新状态（以防万一之前没更新成功）
        if (medicalRecord.getAppointmentId() != null && roles.contains("doctor")) {
            remoteAppointmentService.updateStatus(medicalRecord.getAppointmentId(), "已完成");
        }

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
            log.error("Patient or unknown role tried to update medical record. User: {}, roles: {}", userId, roles);
            throw new ServiceException("患者无权修改病历单");
        }
    }

    @Override
    public boolean deleteMedicalRecordByIds(Long[] ids) {
        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();

        log.info("Delete medical records: {}. User: {}, roles: {}", Arrays.toString(ids), userId, roles);

        if (isAdminUser()) {
            MedicalRecord record = new MedicalRecord();
            record.setIsDeleted(1);
            record.setDeletedAt(new Date());
            return update(record, new LambdaQueryWrapper<MedicalRecord>().in(MedicalRecord::getId, Arrays.asList(ids)));
        }

        // 既不是管理员，也不允许医生或患者删除
        log.error("Unauthorized delete attempt by User: {}, roles: {}", userId, roles);
        throw new ServiceException("无权删除病历单，仅管理员可执行此操作");
    }
}
