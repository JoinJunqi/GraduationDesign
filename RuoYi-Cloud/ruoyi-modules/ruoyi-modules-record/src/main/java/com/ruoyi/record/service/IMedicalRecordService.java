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

    /**
     * 获取病历详细信息（带权限校验）
     */
    MedicalRecord getMedicalRecordById(Long id);

    /**
     * 新增病历（带权限校验）
     */
    boolean insertMedicalRecord(MedicalRecord medicalRecord);

    /**
     * 修改病历（带权限校验）
     */
    boolean updateMedicalRecord(MedicalRecord medicalRecord);

    /**
     * 删除病历（带权限校验）
     */
    boolean deleteMedicalRecordByIds(Long[] ids);
}
