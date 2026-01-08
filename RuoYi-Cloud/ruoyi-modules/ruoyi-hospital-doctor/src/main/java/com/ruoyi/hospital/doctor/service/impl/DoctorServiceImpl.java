package com.ruoyi.hospital.doctor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.common.core.utils.JwtTokenUtil;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.hospital.doctor.domain.Doctor;
import com.ruoyi.hospital.doctor.domain.Schedule;
import com.ruoyi.hospital.doctor.mapper.DoctorMapper;
import com.ruoyi.hospital.doctor.mapper.ScheduleMapper;
import com.ruoyi.hospital.doctor.service.IDoctorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 医生 Service 实现类
 */
@Service
public class DoctorServiceImpl extends ServiceImpl<DoctorMapper, Doctor> implements IDoctorService {

    @Autowired
    private ScheduleMapper scheduleMapper;

    @Override
    public boolean save(Doctor entity) {
        // 新增时加密密码
        if (entity.getPasswordHash() != null) {
            entity.setPasswordHash(SecurityUtils.encryptPassword(entity.getPasswordHash()));
        }
        return super.save(entity);
    }

    @Override
    public boolean updateById(Doctor entity) {
        // 修改时，如果传了新密码，则加密；否则保留原密码 (这里假设前端传空则不修)
        // 注意：前端传空时，entity.getPasswordHash() 可能是空字符串或 null
        if (entity.getPasswordHash() != null && !entity.getPasswordHash().isEmpty()) {
            entity.setPasswordHash(SecurityUtils.encryptPassword(entity.getPasswordHash()));
        } else {
            entity.setPasswordHash(null); // 防止将密码更新为空
        }
        return super.updateById(entity);
    }

    @Override
    public String login(String username, String password) {
        Doctor doctor = getOne(new LambdaQueryWrapper<Doctor>()
                .eq(Doctor::getUsername, username));

        if (doctor == null) {
            throw new ServiceException("用户不存在");
        }

        if (doctor.getIsActive() == 0) {
            throw new ServiceException("账号已停用");
        }

        if (!SecurityUtils.matchesPassword(password, doctor.getPasswordHash())) {
            throw new ServiceException("密码错误");
        }

        return JwtTokenUtil.createToken(doctor.getId(), doctor.getUsername(), "doctor");
    }

    @Override
    public List<Doctor> selectByDeptId(Long deptId) {
        return list(new LambdaQueryWrapper<Doctor>()
                .eq(Doctor::getDeptId, deptId)
                .eq(Doctor::getIsActive, 1));
    }

    @Override
    public List<Schedule> getMySchedules(Long doctorId) {
        return scheduleMapper.selectList(new LambdaQueryWrapper<Schedule>()
                .eq(Schedule::getDoctorId, doctorId)
                .orderByDesc(Schedule::getWorkDate));
    }
}
