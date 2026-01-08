package com.ruoyi.hospital.patient.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.common.core.utils.JwtTokenUtil;
import com.ruoyi.common.core.utils.StringUtils;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.hospital.patient.domain.Patient;
import com.ruoyi.hospital.patient.mapper.PatientMapper;
import com.ruoyi.hospital.patient.service.IPatientService;
import org.springframework.stereotype.Service;

/**
 * 患者 Service 实现类
 */
@Service
public class PatientServiceImpl extends ServiceImpl<PatientMapper, Patient> implements IPatientService {

    @Override
    public boolean save(Patient entity) {
        // 新增时加密密码
        if (entity.getPasswordHash() != null) {
            entity.setPasswordHash(SecurityUtils.encryptPassword(entity.getPasswordHash()));
        }
        return super.save(entity);
    }

    @Override
    public boolean updateById(Patient entity) {
        // 修改时，如果传了新密码，则加密；否则保留原密码
        if (entity.getPasswordHash() != null && !entity.getPasswordHash().isEmpty()) {
            entity.setPasswordHash(SecurityUtils.encryptPassword(entity.getPasswordHash()));
        } else {
            entity.setPasswordHash(null); // 防止将密码更新为空
        }
        return super.updateById(entity);
    }

    @Override
    public boolean register(Patient patient) {
        // 校验用户名唯一
        if (count(new LambdaQueryWrapper<Patient>().eq(Patient::getUsername, patient.getUsername())) > 0) {
            throw new ServiceException("用户名已存在");
        }
        // 校验手机号唯一
        if (StringUtils.isNotEmpty(patient.getPhone()) && 
            count(new LambdaQueryWrapper<Patient>().eq(Patient::getPhone, patient.getPhone())) > 0) {
            throw new ServiceException("手机号已注册");
        }
        
        // 调用 save 方法，它会处理加密
        return save(patient);
    }
    
    @Override
    public String login(String username, String password) {
        // 查询用户
        Patient patient = getOne(new LambdaQueryWrapper<Patient>()
            .eq(Patient::getUsername, username)
            .or()
            .eq(Patient::getPhone, username));
            
        if (patient == null) {
            throw new ServiceException("用户不存在");
        }
        
        if (!SecurityUtils.matchesPassword(password, patient.getPasswordHash())) {
            throw new ServiceException("密码错误");
        }
        
        // 生成Token
        return JwtTokenUtil.createToken(patient.getId(), patient.getUsername(), "patient");
    }

    @Override
    public Patient selectByUsername(String username) {
        return getOne(new LambdaQueryWrapper<Patient>().eq(Patient::getUsername, username));
    }
}
