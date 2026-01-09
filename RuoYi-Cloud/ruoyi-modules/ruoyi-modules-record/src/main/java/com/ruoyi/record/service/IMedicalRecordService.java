package com.ruoyi.record.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.record.domain.MedicalRecord;
import java.util.List;

/**
 * 电子病历Service接口
 */
public interface IMedicalRecordService extends IService<MedicalRecord> {
    /**
     * 查询病历列表
     */
    List<MedicalRecord> selectMedicalRecordList(MedicalRecord medicalRecord);
}
