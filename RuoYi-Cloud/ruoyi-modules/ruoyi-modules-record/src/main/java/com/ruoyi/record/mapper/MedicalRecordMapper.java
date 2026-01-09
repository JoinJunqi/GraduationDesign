package com.ruoyi.record.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.record.domain.MedicalRecord;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

/**
 * 电子病历Mapper接口
 */
@Mapper
public interface MedicalRecordMapper extends BaseMapper<MedicalRecord> {
    /**
     * 查询病历列表（包含医生和科室信息）
     */
    List<MedicalRecord> selectMedicalRecordList(MedicalRecord medicalRecord);
}
