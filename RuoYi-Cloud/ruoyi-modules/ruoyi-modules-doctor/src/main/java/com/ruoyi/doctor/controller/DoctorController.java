package com.ruoyi.doctor.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.utils.JwtUtils;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.doctor.domain.Doctor;
import com.ruoyi.doctor.service.IDoctorService;

@RestController
@RequestMapping("/doctor")
public class DoctorController extends BaseController
{
    @Autowired
    private IDoctorService doctorService;

    @PostMapping("/login")
    public ResultVO<Map<String, Object>> login(@RequestBody Doctor doctor)
    {
        Doctor user = doctorService.selectDoctorByUsername(doctor.getUsername());
        if (user == null || !SecurityUtils.matchesPassword(doctor.getPasswordHash(), user.getPasswordHash()))
        {
            return ResultVO.error("用户名或密码错误");
        }
        
        Map<String, Object> claims = new HashMap<>();
        claims.put("user_id", user.getId());
        claims.put("username", user.getUsername());
        String token = JwtUtils.createToken(claims);
        
        Map<String, Object> map = new HashMap<>();
        map.put("token", token);
        return ResultVO.success(map);
    }

    @GetMapping("/profile")
    public ResultVO<Doctor> profile()
    {
        Long userId = 1L; // 模拟
        return ResultVO.success(doctorService.getById(userId));
    }

    @GetMapping("/list/{deptId}")
    public ResultVO<List<Doctor>> listByDept(@PathVariable Long deptId)
    {
        return ResultVO.success(doctorService.selectDoctorsByDeptId(deptId));
    }
}
