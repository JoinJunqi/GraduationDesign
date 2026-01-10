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

    /**
     * 根据ID查询病历详情（包含关联信息）
     */
    MedicalRecord selectMedicalRecordById(Long id);
}
