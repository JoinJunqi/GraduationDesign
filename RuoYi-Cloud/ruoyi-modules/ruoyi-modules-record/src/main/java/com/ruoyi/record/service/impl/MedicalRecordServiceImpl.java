package com.ruoyi.record.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.hospital.api.RemoteAppointmentService;
import com.ruoyi.hospital.api.RemoteScheduleService;
import com.ruoyi.hospital.api.domain.Schedule;
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

    @Autowired
    private RemoteScheduleService remoteScheduleService;

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
            boolean hasPatientIdFilter = medicalRecord.getPatientId() != null;
            boolean hasAppointmentIdFilter = medicalRecord.getAppointmentId() != null;

            if (hasAppointmentIdFilter) {
                Long patientId = resolvePatientIdFromAppointmentForDoctor(medicalRecord.getAppointmentId(), userId);
                medicalRecord.setPatientId(patientId);
                medicalRecord.setDoctorId(null);
            } else if (hasPatientIdFilter) {
                if (hasDoctorTreatedPatient(userId, medicalRecord.getPatientId())) {
                    medicalRecord.setDoctorId(null);
                } else {
                    log.info("Doctor access denied: no relationship with patientId={}", medicalRecord.getPatientId());
                    throw new ServiceException("无权查看该患者病历，请从该患者的预约记录进入");
                }
            } else {
                log.info("Doctor access: defaulting to own records. doctorId={}", userId);
                medicalRecord.setDoctorId(userId);
                medicalRecord.setPatientId(null);
                medicalRecord.setPatientName(null);
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
        return getMedicalRecordById(id, null);
    }

    @Override
    public MedicalRecord getMedicalRecordById(Long id, Long appointmentId) {
        MedicalRecord record = medicalRecordMapper.selectMedicalRecordById(id);
        if (record == null) {
            throw new ServiceException("病历不存在");
        }
        
        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();
        
        if (isAdminUser()) {
            return record;
        }

        if (roles.contains("patient")) {
            if (!record.getPatientId().equals(userId)) {
                throw new ServiceException("无权查看他人病历");
            }
            return record;
        }

        if (roles.contains("doctor")) {
            if (Objects.equals(record.getDoctorId(), userId)) {
                return record;
            }
            if (appointmentId != null) {
                Long patientIdFromAppt = resolvePatientIdFromAppointmentForDoctor(appointmentId, userId);
                if (Objects.equals(record.getPatientId(), patientIdFromAppt)) {
                    return record;
                }
            }
            if (record.getPatientId() != null && hasDoctorTreatedPatient(userId, record.getPatientId())) {
                return record;
            }
            throw new ServiceException("无权查看该病历详情");
        }

        throw new ServiceException("无权查看他人病历");
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
            if (medicalRecord.getAppointmentId() == null) {
                throw new ServiceException("医生新增病历必须关联预约记录");
            }
        } else {
            log.error("Patient or unknown role tried to insert medical record. User: {}, roles: {}", userId, roles);
            throw new ServiceException("患者无权新增病历单，请联系医生操作");
        }

        if (medicalRecord.getAppointmentId() != null) {
            Long patientIdFromAppt = resolvePatientIdFromAppointmentForDoctor(medicalRecord.getAppointmentId(), medicalRecord.getDoctorId());
            medicalRecord.setPatientId(patientIdFromAppt);
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
            if (result == null || result.getCode() != ResultVO.SUCCESS || !Boolean.TRUE.equals(result.getData())) {
                log.error("Failed to update appointment status: {}", result != null ? result.getMsg() : "null");
                throw new ServiceException("更新预约状态失败");
            }
        }

        log.info("Final medical record to save: {}", medicalRecord);
        return save(medicalRecord);
    }

    private boolean hasDoctorTreatedPatient(Long doctorId, Long patientId) {
        if (doctorId == null || patientId == null) {
            return false;
        }
        LambdaQueryWrapper<MedicalRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MedicalRecord::getDoctorId, doctorId).eq(MedicalRecord::getPatientId, patientId);
        return this.count(wrapper) > 0;
    }

    private Long resolvePatientIdFromAppointmentForDoctor(Long appointmentId, Long doctorId) {
        if (appointmentId == null) {
            throw new ServiceException("预约ID不能为空");
        }
        if (doctorId == null) {
            throw new ServiceException("医生信息缺失");
        }

        ResultVO<com.ruoyi.hospital.api.domain.Appointment> appointmentResult = remoteAppointmentService.getInfo(appointmentId);
        if (appointmentResult == null || appointmentResult.getCode() != ResultVO.SUCCESS || appointmentResult.getData() == null) {
            throw new ServiceException("预约记录不存在");
        }

        com.ruoyi.hospital.api.domain.Appointment appointment = appointmentResult.getData();
        if (appointment.getPatientId() == null) {
            throw new ServiceException("预约记录患者信息缺失");
        }
        if (appointment.getScheduleId() == null) {
            throw new ServiceException("预约记录排班信息缺失");
        }

        ResultVO<Schedule> scheduleResult = remoteScheduleService.getById(appointment.getScheduleId());
        if (scheduleResult == null || scheduleResult.getCode() != ResultVO.SUCCESS || scheduleResult.getData() == null) {
            throw new ServiceException("排班记录不存在");
        }

        Schedule schedule = scheduleResult.getData();
        if (!Objects.equals(schedule.getDoctorId(), doctorId)) {
            throw new ServiceException("无权访问该预约对应的患者信息");
        }

        return appointment.getPatientId();
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

    @Override
    public boolean recoverMedicalRecordByIds(Long[] ids) {
        Long userId = SecurityUtils.getUserId();
        Set<String> roles = getRoles();

        log.info("Recover medical records: {}. User: {}, roles: {}", Arrays.toString(ids), userId, roles);

        if (isAdminUser()) {
            MedicalRecord record = new MedicalRecord();
            record.setIsDeleted(0);
            record.setDeletedAt(null);
            return update(record,
                    new LambdaQueryWrapper<MedicalRecord>()
                            .in(MedicalRecord::getId, Arrays.asList(ids))
                            .eq(MedicalRecord::getIsDeleted, 1));
        }

        log.error("Unauthorized recover attempt by User: {}, roles: {}", userId, roles);
        throw new ServiceException("无权恢复病历单，仅管理员可执行此操作");
    }
}
