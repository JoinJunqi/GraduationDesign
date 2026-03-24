package com.ruoyi.patient.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.patient.domain.Patient;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PatientMapper extends BaseMapper<Patient> {
    /**
     * 查询患者列表
     * 
     * @param patient 患者信息
     * @return 患者列表
     */
    public java.util.List<Patient> selectPatientList(Patient patient);

    /**
     * 批量恢复逻辑删除的患者
     */
    int recoverPatientByIds(@Param("ids") Long[] ids);
}
