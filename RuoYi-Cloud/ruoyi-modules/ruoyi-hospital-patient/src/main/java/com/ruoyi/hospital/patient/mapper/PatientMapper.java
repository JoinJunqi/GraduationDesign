package com.ruoyi.hospital.patient.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.hospital.patient.domain.Patient;
import org.apache.ibatis.annotations.Mapper;

/**
 * 患者 Mapper 接口
 */
@Mapper
public interface PatientMapper extends BaseMapper<Patient> {
}
