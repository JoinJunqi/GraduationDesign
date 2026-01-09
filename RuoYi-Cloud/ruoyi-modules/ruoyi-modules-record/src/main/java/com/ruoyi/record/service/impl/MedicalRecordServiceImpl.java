package com.ruoyi.record.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.record.domain.MedicalRecord;
import com.ruoyi.record.mapper.MedicalRecordMapper;
import com.ruoyi.record.service.IMedicalRecordService;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * 电子病历Service业务层处理
 */
@Service
public class MedicalRecordServiceImpl extends ServiceImpl<MedicalRecordMapper, MedicalRecord> implements IMedicalRecordService {
    @Override
    public List<MedicalRecord> selectMedicalRecordList(MedicalRecord medicalRecord) {
        return baseMapper.selectMedicalRecordList(medicalRecord);
    }
}
