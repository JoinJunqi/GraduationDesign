package com.ruoyi.hospital.patient.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.utils.JwtTokenUtil;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.hospital.patient.domain.Patient;
import com.ruoyi.hospital.patient.service.IPatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

/**
 * 患者控制器
 */
@RestController
@RequestMapping("/patient")
public class PatientController {

    @Autowired
    private IPatientService patientService;

    /**
     * 查询患者列表 (管理端)
     */
    @GetMapping("/list")
    public ResultVO<List<Patient>> list(Patient patient) {
        LambdaQueryWrapper<Patient> queryWrapper = new LambdaQueryWrapper<>();
        if (patient.getName() != null) {
            queryWrapper.like(Patient::getName, patient.getName());
        }
        if (patient.getPhone() != null) {
            queryWrapper.like(Patient::getPhone, patient.getPhone());
        }
        return ResultVO.success(patientService.list(queryWrapper));
    }

    /**
     * 获取患者详细信息 (管理端)
     */
    @GetMapping(value = "/{id}")
    public ResultVO<Patient> getInfo(@PathVariable("id") Long id) {
        return ResultVO.success(patientService.getById(id));
    }

    /**
     * 新增患者 (管理端)
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Patient patient) {
        // 这里可以直接调用注册逻辑，或者直接保存
        return ResultVO.success(patientService.register(patient));
    }

    /**
     * 修改患者 (管理端)
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Patient patient) {
        return ResultVO.success(patientService.updateById(patient));
    }

    /**
     * 删除患者 (管理端)
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable List<Long> ids) {
        return ResultVO.success(patientService.removeByIds(ids));
    }

    /**
     * 患者注册
     */
    @PostMapping("/register")
    public ResultVO<Boolean> register(@RequestBody Patient patient) {
        return ResultVO.success(patientService.register(patient));
    }

    /**
     * 患者登录
     */
    @PostMapping("/login")
    public ResultVO<String> login(@RequestBody Map<String, String> loginBody) {
        String username = loginBody.get("username");
        String password = loginBody.get("password");
        String token = patientService.login(username, password);
        return ResultVO.success(token, "登录成功");
    }

    /**
     * 获取个人资料
     */
    @GetMapping("/profile")
    public ResultVO<Patient> getProfile(HttpServletRequest request) {
        String token = SecurityUtils.getToken(request);
        Long userId = JwtTokenUtil.getUserId(token);
        Patient patient = patientService.getById(userId);
        if (patient != null) {
            patient.setPasswordHash(null); // 隐藏密码
        }
        return ResultVO.success(patient);
    }

    /**
     * 修改个人资料
     */
    @PutMapping("/profile")
    public ResultVO<Boolean> updateProfile(@RequestBody Patient patient, HttpServletRequest request) {
        String token = SecurityUtils.getToken(request);
        Long userId = JwtTokenUtil.getUserId(token);
        
        if (userId == null) {
            return ResultVO.error("未登录或Token已过期");
        }

        patient.setId(userId); // 强制更新当前用户
        patient.setPasswordHash(null); // 防止此处修改密码
        patient.setUsername(null); // 防止此处修改用户名
        return ResultVO.success(patientService.updateById(patient));
    }
}
