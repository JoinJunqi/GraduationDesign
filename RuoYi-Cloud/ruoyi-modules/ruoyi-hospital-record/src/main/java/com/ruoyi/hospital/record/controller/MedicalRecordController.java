package com.ruoyi.hospital.record.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.hospital.record.domain.MedicalRecord;
import com.ruoyi.hospital.record.service.IMedicalRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 电子病历控制器
 */
@RestController
@RequestMapping("/record")
public class MedicalRecordController {

    @Autowired
    private IMedicalRecordService medicalRecordService;

    /**
     * 查询病历列表
     */
    @GetMapping("/list")
    public ResultVO<List<MedicalRecord>> list(MedicalRecord medicalRecord) {
        LambdaQueryWrapper<MedicalRecord> queryWrapper = new LambdaQueryWrapper<>();
        if (medicalRecord.getPatientId() != null) {
            queryWrapper.eq(MedicalRecord::getPatientId, medicalRecord.getPatientId());
        }
        if (medicalRecord.getDoctorId() != null) {
            queryWrapper.eq(MedicalRecord::getDoctorId, medicalRecord.getDoctorId());
        }
        return ResultVO.success(medicalRecordService.list(queryWrapper));
    }

    /**
     * 获取病历详细信息
     */
    @GetMapping(value = "/{id}")
    public ResultVO<MedicalRecord> getInfo(@PathVariable("id") Long id) {
        return ResultVO.success(medicalRecordService.getById(id));
    }

    /**
     * 新增病历
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody MedicalRecord medicalRecord) {
        return ResultVO.success(medicalRecordService.save(medicalRecord));
    }

    /**
     * 修改病历
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody MedicalRecord medicalRecord) {
        return ResultVO.success(medicalRecordService.updateById(medicalRecord));
    }

    /**
     * 删除病历
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable List<Long> ids) {
        return ResultVO.success(medicalRecordService.removeByIds(ids));
    }
}
