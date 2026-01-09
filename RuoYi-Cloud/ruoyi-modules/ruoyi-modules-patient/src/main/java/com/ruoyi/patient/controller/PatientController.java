package com.ruoyi.patient.controller;

import java.util.HashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.utils.JwtUtils;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.patient.domain.Patient;
import com.ruoyi.patient.service.IPatientService;

@RestController
@RequestMapping("/patient")
public class PatientController extends BaseController
{
    @Autowired
    private IPatientService patientService;

    @PostMapping("/login")
    public ResultVO<Map<String, Object>> login(@RequestBody Patient patient)
    {
        // 简单模拟登录逻辑，实际应校验密码
        Patient user = patientService.selectPatientByUsername(patient.getUsername());
        if (user == null || !SecurityUtils.matchesPassword(patient.getPasswordHash(), user.getPasswordHash()))
        {
            return ResultVO.error("用户名或密码错误");
        }
        
        // 生成令牌
        Map<String, Object> claims = new HashMap<>();
        claims.put("user_id", user.getId());
        claims.put("username", user.getUsername());
        String token = JwtUtils.createToken(claims);
        
        Map<String, Object> map = new HashMap<>();
        map.put("token", token);
        return ResultVO.success(map);
    }

    @PostMapping("/register")
    public ResultVO<Boolean> register(@RequestBody Patient patient)
    {
        return ResultVO.success(patientService.registerPatient(patient));
    }

    @GetMapping("/profile")
    public ResultVO<Patient> profile()
    {
        // 模拟获取当前登录用户ID
        Long userId = 1L; 
        return ResultVO.success(patientService.getById(userId));
    }

    @PutMapping("/profile")
    public ResultVO<Boolean> updateProfile(@RequestBody Patient patient)
    {
        return ResultVO.success(patientService.updateById(patient));
    }
}
