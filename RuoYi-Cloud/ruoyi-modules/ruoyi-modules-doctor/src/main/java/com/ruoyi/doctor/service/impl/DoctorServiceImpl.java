package com.ruoyi.doctor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.exception.ServiceException;
import com.ruoyi.common.core.utils.uuid.IdUtils;
import com.ruoyi.common.security.service.TokenService;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.doctor.domain.Doctor;
import com.ruoyi.doctor.mapper.DoctorMapper;
import com.ruoyi.doctor.service.IDoctorService;
import com.ruoyi.system.api.domain.SysUser;
import com.ruoyi.system.api.model.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class DoctorServiceImpl extends ServiceImpl<DoctorMapper, Doctor> implements IDoctorService {

    private static final Logger log = LoggerFactory.getLogger(DoctorServiceImpl.class);

    @Autowired
    private DoctorMapper doctorMapper;

    @Autowired
    private TokenService tokenService;

    @Override
    public Doctor selectDoctorByUsername(String username) {
        return doctorMapper.selectOne(new LambdaQueryWrapper<Doctor>()
                .eq(Doctor::getUsername, username)
                .or().eq(Doctor::getName, username));
    }

    @Override
    public List<Doctor> selectDoctorList(Doctor doctor) {
        return doctorMapper.selectDoctorList(doctor);
    }

    @Override
    public List<Doctor> selectDoctorsByDeptId(Long deptId) {
        return doctorMapper.selectList(new LambdaQueryWrapper<Doctor>().eq(Doctor::getDeptId, deptId));
    }

    @Override
    public Map<String, Object> login(Doctor doctor) {
        log.info("医生登录尝试: username={}", doctor.getUsername());
        Doctor user = selectDoctorByUsername(doctor.getUsername());
        if (user == null) {
            log.warn("医生登录失败: 用户不存在, username={}", doctor.getUsername());
            throw new ServiceException("用户名或密码错误");
        }

        if (!SecurityUtils.matchesPassword(doctor.getPasswordHash(), user.getPasswordHash())) {
            log.warn("医生登录失败: 密码不匹配, username={}", doctor.getUsername());
            throw new ServiceException("用户名或密码错误");
        }

        if (user.getIsActive() != null && !user.getIsActive()) {
            throw new ServiceException("账号已停用");
        }

        log.info("医生登录成功: username={}", doctor.getUsername());
        // 创建登录用户信息
        LoginUser loginUser = new LoginUser();
        loginUser.setUserid(user.getId());
        loginUser.setUsername(user.getUsername());
        loginUser.setToken(IdUtils.fastUUID());

        // 设置角色
        Set<String> roles = new HashSet<>();
        roles.add("doctor");
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
    public boolean insertDoctor(Doctor doctor) {
        if (!checkUsernameUnique(doctor.getUsername())) {
            throw new ServiceException("新增失败，账号 '" + doctor.getUsername() + "' 已存在");
        }
        if (doctor.getPassword() != null && !doctor.getPassword().isEmpty()) {
            doctor.setPasswordHash(SecurityUtils.encryptPassword(doctor.getPassword()));
        } else {
            // 默认密码
            doctor.setPasswordHash(SecurityUtils.encryptPassword("123456"));
        }
        return save(doctor);
    }

    @Override
    public boolean updateDoctor(Doctor doctor) {
        if (doctor.getPassword() != null && !doctor.getPassword().isEmpty()) {
            doctor.setPasswordHash(SecurityUtils.encryptPassword(doctor.getPassword()));
        } else {
            // 如果没传新密码，则不修改密码字段
            doctor.setPasswordHash(null);
        }
        return updateById(doctor);
    }

    @Override
    public boolean deleteDoctorByIds(Long[] ids) {
        return removeBatchByIds(Arrays.asList(ids));
    }

    @Override
    public boolean checkUsernameUnique(String username) {
        Long count = doctorMapper.selectCount(new LambdaQueryWrapper<Doctor>().eq(Doctor::getUsername, username));
        return count == 0;
    }

    @Override
    public boolean updateDoctorProfile(Doctor doctor) {
        doctor.setId(SecurityUtils.getUserId());
        // 不允许通过此接口修改账号和密码
        doctor.setUsername(null);
        doctor.setPasswordHash(null);
        return updateById(doctor);
    }

    @Override
    public boolean updatePassword(String oldPassword, String newPassword) {
        Long userId = SecurityUtils.getUserId();
        Doctor doctor = getById(userId);
        if (doctor == null) {
            throw new ServiceException("医生不存在");
        }
        String password = doctor.getPasswordHash();
        if (!SecurityUtils.matchesPassword(oldPassword, password)) {
            throw new ServiceException("修改密码失败，旧密码错误");
        }
        if (SecurityUtils.matchesPassword(newPassword, password)) {
            throw new ServiceException("新密码不能与旧密码相同");
        }
        doctor.setPasswordHash(SecurityUtils.encryptPassword(newPassword));
        return updateById(doctor);
    }

    @Override
    public boolean resetPassword(Long id, String password) {
        Doctor doctor = new Doctor();
        doctor.setId(id);
        doctor.setPasswordHash(SecurityUtils.encryptPassword(password));
        return updateById(doctor);
    }
}
