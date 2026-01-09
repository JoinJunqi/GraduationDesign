package com.ruoyi.record.controller;

import java.util.List;
import java.util.Arrays;
import java.util.Date;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.record.domain.MedicalRecord;
import com.ruoyi.record.service.IMedicalRecordService;
import com.ruoyi.system.api.model.LoginUser;

/**
 * 电子病历Controller
 */
@RestController
@RequestMapping("/record")
public class MedicalRecordController extends BaseController
{
    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(MedicalRecordController.class);

    @Autowired
    private IMedicalRecordService medicalRecordService;

    private boolean hasRole(String role)
    {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getRoles() == null) {
            log.warn("hasRole check: loginUser or roles is null");
            return false;
        }
        boolean result = loginUser.getRoles().contains(role);
        log.info("hasRole check: role={}, result={}", role, result);
        return result;
    }

    @GetMapping("/list")
    public ResultVO<List<MedicalRecord>> list(MedicalRecord medicalRecord)
    {
        Long userId = SecurityUtils.getUserId();
        log.info("MedicalRecord list request: userId={}, medicalRecord={}", userId, medicalRecord);
        
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
        
        List<MedicalRecord> list = medicalRecordService.selectMedicalRecordList(medicalRecord);
        log.info("Query result size: {}", list.size());
        return ResultVO.success(list);
    }

    /**
     * 获取病历详细信息
     */
    @GetMapping(value = "/{id}")
    public ResultVO<MedicalRecord> getInfo(@PathVariable("id") Long id)
    {
        MedicalRecord record = medicalRecordService.getById(id);
        if (record == null) {
            return ResultVO.error("病历不存在");
        }
        
        if (hasRole("admin") || hasRole("doctor")) {
            // 管理员和医生可以查看
            return ResultVO.success(record);
        } else {
            // 患者只能看自己的
            if (!record.getPatientId().equals(SecurityUtils.getUserId())) {
                return ResultVO.error("无权查看他人病历");
            }
        }
        return ResultVO.success(record);
    }

    /**
     * 新增病历
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody MedicalRecord medicalRecord)
    {
        if (hasRole("admin")) {
            // 管理员可以随意新增
        } else if (hasRole("doctor")) {
            medicalRecord.setDoctorId(SecurityUtils.getUserId());
        } else {
            // 患者新增
            medicalRecord.setPatientId(SecurityUtils.getUserId());
            // 患者不能填写诊断、处方、备注
            medicalRecord.setDiagnosis(null);
            medicalRecord.setPrescription(null);
            medicalRecord.setNotes(null);
        }
        
        medicalRecord.setCreatedAt(new Date());
        if (medicalRecord.getVisitTime() == null) {
            medicalRecord.setVisitTime(new Date());
        }
        return ResultVO.success(medicalRecordService.save(medicalRecord));
    }

    /**
     * 修改病历
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody MedicalRecord medicalRecord)
    {
        MedicalRecord oldRecord = medicalRecordService.getById(medicalRecord.getId());
        if (oldRecord == null) {
            return ResultVO.error("病历不存在");
        }

        if (hasRole("admin")) {
            // 管理员全改
            return ResultVO.success(medicalRecordService.updateById(medicalRecord));
        }

        if (hasRole("doctor")) {
            // 医生仅可以修改与看病相关的字段
            MedicalRecord updateRecord = new MedicalRecord();
            updateRecord.setId(medicalRecord.getId());
            updateRecord.setDiagnosis(medicalRecord.getDiagnosis());
            updateRecord.setPrescription(medicalRecord.getPrescription());
            updateRecord.setNotes(medicalRecord.getNotes());
            return ResultVO.success(medicalRecordService.updateById(updateRecord));
        } else {
            // 患者只能改自己的病历，且不能修改医疗核心字段
            if (!oldRecord.getPatientId().equals(SecurityUtils.getUserId())) {
                return ResultVO.error("无权修改他人病历");
            }
            medicalRecord.setDiagnosis(null);
            medicalRecord.setPrescription(null);
            medicalRecord.setNotes(null);
            return ResultVO.success(medicalRecordService.updateById(medicalRecord));
        }
    }

    /**
     * 删除病历
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        if (hasRole("admin")) {
            return ResultVO.success(medicalRecordService.removeBatchByIds(Arrays.asList(ids)));
        }

        for (Long id : ids) {
            MedicalRecord record = medicalRecordService.getById(id);
            if (record == null) continue;
            
            if (hasRole("doctor")) {
                return ResultVO.error("医生无权删除病历");
            } else {
                // 患者可以删除自己的
                if (!record.getPatientId().equals(SecurityUtils.getUserId())) {
                    return ResultVO.error("无权删除他人病历");
                }
            }
        }
        return ResultVO.success(medicalRecordService.removeBatchByIds(Arrays.asList(ids)));
    }
}
