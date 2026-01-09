package com.ruoyi.doctor.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.utils.JwtUtils;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.doctor.domain.Doctor;
import com.ruoyi.doctor.service.IDoctorService;

import com.ruoyi.common.core.constant.SecurityConstants;
import com.ruoyi.common.core.utils.uuid.IdUtils;
import com.ruoyi.common.security.service.TokenService;
import com.ruoyi.system.api.domain.SysUser;
import com.ruoyi.system.api.model.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
public class DoctorController extends BaseController
{
    private static final Logger log = LoggerFactory.getLogger(DoctorController.class);

    @Autowired
    private IDoctorService doctorService;

    @Autowired
    private TokenService tokenService;

    @PostMapping("/login")
    public ResultVO<Map<String, Object>> login(@RequestBody Doctor doctor)
    {
        log.info("医生登录尝试: username={}", doctor.getUsername());
        // 简单模拟登录逻辑，实际应校验密码
        Doctor user = doctorService.selectDoctorByUsername(doctor.getUsername());
        if (user == null)
        {
            log.warn("医生登录失败: 用户不存在, username={}", doctor.getUsername());
            return ResultVO.error("用户名或密码错误");
        }
        
        if (!SecurityUtils.matchesPassword(doctor.getPasswordHash(), user.getPasswordHash()))
        {
            log.warn("医生登录失败: 密码不匹配, username={}", doctor.getUsername());
            return ResultVO.error("用户名或密码错误");
        }
        
        log.info("医生登录成功: username={}", doctor.getUsername());
        // 创建登录用户信息
        LoginUser loginUser = new LoginUser();
        loginUser.setUserid(user.getId());
        loginUser.setUsername(user.getUsername());
        loginUser.setToken(IdUtils.fastUUID());
        
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
        return ResultVO.success(map);
    }

    @GetMapping("/list")
    public ResultVO<List<Doctor>> list(Doctor doctor)
    {
        return ResultVO.success(doctorService.list());
    }

    @GetMapping(value = "/{id}")
    public ResultVO<Doctor> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(doctorService.getById(id));
    }

    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Doctor doctor)
    {
        doctor.setPasswordHash(SecurityUtils.encryptPassword(doctor.getPasswordHash()));
        return ResultVO.success(doctorService.save(doctor));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Doctor doctor)
    {
        if (doctor.getPasswordHash() != null && !doctor.getPasswordHash().isEmpty()) {
            doctor.setPasswordHash(SecurityUtils.encryptPassword(doctor.getPasswordHash()));
        }
        return ResultVO.success(doctorService.updateById(doctor));
    }

    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        return ResultVO.success(doctorService.removeByIds(Arrays.asList(ids)));
    }

    @GetMapping("/profile")
    public ResultVO<Doctor> profile()
    {
        Long userId = SecurityUtils.getUserId();
        return ResultVO.success(doctorService.getById(userId));
    }

    @GetMapping("/list/{deptId}")
    public ResultVO<List<Doctor>> listByDept(@PathVariable Long deptId)
    {
        return ResultVO.success(doctorService.selectDoctorsByDeptId(deptId));
    }
}
