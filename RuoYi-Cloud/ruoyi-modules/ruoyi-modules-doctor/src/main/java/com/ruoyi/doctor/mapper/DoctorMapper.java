package com.ruoyi.doctor.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.doctor.domain.Doctor;
import org.apache.ibatis.annotations.Mapper;
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
}
