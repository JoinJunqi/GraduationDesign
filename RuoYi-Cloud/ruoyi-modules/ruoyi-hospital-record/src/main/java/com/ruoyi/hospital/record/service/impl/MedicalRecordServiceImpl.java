package com.ruoyi.hospital.record.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.hospital.record.domain.MedicalRecord;
import com.ruoyi.hospital.record.mapper.MedicalRecordMapper;
import com.ruoyi.hospital.record.service.IMedicalRecordService;
import org.springframework.stereotype.Service;

/**
 * 电子病历 Service 实现类
 */
@Service
public class MedicalRecordServiceImpl extends ServiceImpl<MedicalRecordMapper, MedicalRecord> implements IMedicalRecordService {
}
