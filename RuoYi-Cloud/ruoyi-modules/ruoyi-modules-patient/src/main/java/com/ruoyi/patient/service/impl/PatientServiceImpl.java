package com.ruoyi.patient.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.common.core.utils.uuid.IdUtils;
import com.ruoyi.common.security.service.TokenService;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.patient.domain.Patient;
import com.ruoyi.patient.mapper.PatientMapper;
import com.ruoyi.patient.service.IPatientService;
import com.ruoyi.system.api.domain.SysUser;
import com.ruoyi.system.api.model.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class PatientServiceImpl extends ServiceImpl<PatientMapper, Patient> implements IPatientService {

    private static final Logger log = LoggerFactory.getLogger(PatientServiceImpl.class);

    @Autowired
    private PatientMapper patientMapper;

    @Autowired
    private TokenService tokenService;

    @Override
    public Patient selectPatientByUsername(String username) {
        return patientMapper.selectOne(new LambdaQueryWrapper<Patient>()
                .eq(Patient::getUsername, username)
                .or().eq(Patient::getPhone, username)
                .or().eq(Patient::getIdCard, username));
    }

    @Override
    public List<Patient> selectPatientList(Patient patient) {
        LambdaQueryWrapper<Patient> queryWrapper = new LambdaQueryWrapper<>();
        if (patient.getName() != null && !patient.getName().isEmpty()) {
            queryWrapper.like(Patient::getName, patient.getName());
        }
        if (patient.getPhone() != null && !patient.getPhone().isEmpty()) {
            queryWrapper.eq(Patient::getPhone, patient.getPhone());
        }
        if (patient.getIdCard() != null && !patient.getIdCard().isEmpty()) {
            queryWrapper.eq(Patient::getIdCard, patient.getIdCard());
        }
        if (patient.getUsername() != null && !patient.getUsername().isEmpty()) {
            queryWrapper.like(Patient::getUsername, patient.getUsername());
        }
        if (patient.getIsActive() != null) {
            queryWrapper.eq(Patient::getIsActive, patient.getIsActive());
        }
        return patientMapper.selectList(queryWrapper);
    }

    @Override
    public boolean checkUsernameUnique(String username) {
        return patientMapper.selectCount(new LambdaQueryWrapper<Patient>().eq(Patient::getUsername, username)) == 0;
    }

    @Override
    public boolean checkPhoneUnique(Patient patient) {
        Long id = patient.getId() == null ? -1L : patient.getId();
        Patient info = patientMapper.selectOne(new LambdaQueryWrapper<Patient>().eq(Patient::getPhone, patient.getPhone()));
        return info == null || info.getId().equals(id);
    }

    @Override
    public boolean checkIdCardUnique(Patient patient) {
        Long id = patient.getId() == null ? -1L : patient.getId();
        Patient info = patientMapper.selectOne(new LambdaQueryWrapper<Patient>().eq(Patient::getIdCard, patient.getIdCard()));
        return info == null || info.getId().equals(id);
    }

    @Override
    public int resetPatientPwd(Long userId, String password) {
        Patient patient = new Patient();
        patient.setId(userId);
        patient.setPasswordHash(SecurityUtils.encryptPassword(password));
        return patientMapper.updateById(patient);
    }

    @Override
    public Map<String, Object> login(Patient patient) {
        log.info("患者登录尝试: username={}", patient.getUsername());
        Patient user = selectPatientByUsername(patient.getUsername());
        if (user == null) {
            log.warn("患者登录失败: 用户不存在, username={}", patient.getUsername());
            throw new ServiceException("用户名或密码错误");
        }

        if (!SecurityUtils.matchesPassword(patient.getPasswordHash(), user.getPasswordHash())) {
            log.warn("患者登录失败: 密码不匹配, username={}", patient.getUsername());
            throw new ServiceException("用户名或密码错误");
        }

        log.info("患者登录成功: username={}", patient.getUsername());
        // 创建登录用户信息
        LoginUser loginUser = new LoginUser();
        loginUser.setUserid(user.getId());
        loginUser.setUsername(user.getUsername());
        loginUser.setToken(IdUtils.fastUUID());

        // 设置角色
        Set<String> roles = new HashSet<>();
        roles.add("patient");
        loginUser.setRoles(roles);

        // 必须设置 sysUser 否则 TokenService 会抛 NPE
        SysUser sysUser = new SysUser();
        sysUser.setUserId(user.getId());
        sysUser.setUserName(user.getUsername());
        sysUser.setNickName(user.getName());
        loginUser.setSysUser(sysUser);

        // 保存到 Redis 并生成令牌
        Map<String, Object> tokenMap = tokenService.createToken(loginUser);

        Map<String, Object> map = new HashMap<>();
        map.put("token", tokenMap.get("access_token"));
        return map;
    }

    @Override
    public boolean register(Patient patient) {
        if (!checkUsernameUnique(patient.getUsername())) {
            throw new ServiceException("注册失败，账号已存在");
        }
        if (!checkPhoneUnique(patient)) {
            throw new ServiceException("注册失败，手机号已存在");
        }
        if (!checkIdCardUnique(patient)) {
            throw new ServiceException("注册失败，身份证号已存在");
        }
        patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPasswordHash()));
        return save(patient);
    }

    @Override
    public boolean insertPatient(Patient patient) {
        if (!checkUsernameUnique(patient.getUsername())) {
            throw new ServiceException("新增失败，账号 '" + patient.getUsername() + "' 已存在");
        }
        if (patient.getPassword() != null && !patient.getPassword().isEmpty()) {
            patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPassword()));
        } else {
            // 默认密码
            patient.setPasswordHash(SecurityUtils.encryptPassword("123456"));
        }
        return save(patient);
    }

    @Override
    public boolean updatePatient(Patient patient) {
        if (!checkPhoneUnique(patient)) {
            throw new ServiceException("修改失败，手机号 '" + patient.getPhone() + "' 已存在");
        }
        if (!checkIdCardUnique(patient)) {
            throw new ServiceException("修改失败，身份证号 '" + patient.getIdCard() + "' 已存在");
        }
        if (patient.getPassword() != null && !patient.getPassword().isEmpty()) {
            patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPassword()));
        }
        return updateById(patient);
    }

    @Override
    public boolean deletePatientByIds(Long[] ids) {
        return removeBatchByIds(Arrays.asList(ids));
    }

    @Override
    public boolean updatePatientProfile(Patient patient) {
        patient.setId(SecurityUtils.getUserId());
        if (!checkPhoneUnique(patient)) {
            throw new ServiceException("修改失败，手机号 '" + patient.getPhone() + "' 已存在");
        }
        if (!checkIdCardUnique(patient)) {
            throw new ServiceException("修改失败，身份证号 '" + patient.getIdCard() + "' 已存在");
        }
        // 不允许通过此接口修改密码和账号
        patient.setPasswordHash(null);
        patient.setUsername(null);
        return updateById(patient);
    }

    @Override
    public boolean updatePassword(String oldPassword, String newPassword) {
        Long userId = SecurityUtils.getUserId();
        Patient patient = getById(userId);
        if (patient == null) {
            throw new ServiceException("用户不存在");
        }
        String password = patient.getPasswordHash();
        if (!SecurityUtils.matchesPassword(oldPassword, password)) {
            throw new ServiceException("修改密码失败，旧密码错误");
        }
        if (SecurityUtils.matchesPassword(newPassword, password)) {
            throw new ServiceException("新密码不能与旧密码相同");
        }
        return resetPatientPwd(userId, newPassword) > 0;
    }
}
