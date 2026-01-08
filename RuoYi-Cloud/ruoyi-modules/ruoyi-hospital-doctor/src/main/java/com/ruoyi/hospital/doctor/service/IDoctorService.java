package com.ruoyi.hospital.doctor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.hospital.doctor.domain.Doctor;
import com.ruoyi.hospital.doctor.domain.Schedule;
import java.util.List;

/**
 * 医生 Service 接口
 */
public interface IDoctorService extends IService<Doctor> {
    
    /**
     * 医生登录
     *
     * @param username 用户名
     * @param password 密码
     * @return Token
     */
    String login(String username, String password);

    /**
     * 根据科室ID查询医生列表
     *
     * @param deptId 科室ID
     * @return 医生列表
     */
    List<Doctor> selectByDeptId(Long deptId);

    /**
     * 获取医生排班信息
     *
     * @param doctorId 医生ID
     * @return 排班列表
     */
    List<Schedule> getMySchedules(Long doctorId);
}
