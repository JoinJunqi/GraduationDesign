package com.ruoyi.doctor.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.doctor.domain.Doctor;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface DoctorMapper extends BaseMapper<Doctor> {
    /**
     * 查询医生列表
     * 
     * @param doctor 医生信息
     * @return 医生列表
     */
    public List<Doctor> selectDoctorList(Doctor doctor);

    /**
     * 根据ID查询医生信息
     * 
     * @param id 医生ID
     * @return 医生信息
     */
    public Doctor selectDoctorById(Long id);

    /**
     * 批量恢复逻辑删除的医生
     */
    int recoverDoctorByIds(@Param("ids") Long[] ids);
}
