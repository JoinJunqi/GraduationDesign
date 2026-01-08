package com.ruoyi.hospital.doctor.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.utils.JwtTokenUtil;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.hospital.doctor.domain.Doctor;
import com.ruoyi.hospital.doctor.domain.Schedule;
import com.ruoyi.hospital.doctor.service.IDoctorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

/**
 * 医生控制器
 */
@RestController
@RequestMapping("/doctor")
public class DoctorController {

    @Autowired
    private IDoctorService doctorService;

    /**
     * 查询医生列表 (管理端)
     */
    @GetMapping("/list")
    public ResultVO<List<Doctor>> list(Doctor doctor) {
        LambdaQueryWrapper<Doctor> queryWrapper = new LambdaQueryWrapper<>();
        if (doctor.getName() != null) {
            queryWrapper.like(Doctor::getName, doctor.getName());
        }
        if (doctor.getDeptId() != null) {
            queryWrapper.eq(Doctor::getDeptId, doctor.getDeptId());
        }
        return ResultVO.success(doctorService.list(queryWrapper));
    }

    /**
     * 获取医生详细信息 (管理端)
     */
    @GetMapping(value = "/{id}")
    public ResultVO<Doctor> getInfo(@PathVariable("id") Long id) {
        return ResultVO.success(doctorService.getById(id));
    }

    /**
     * 新增医生 (管理端)
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Doctor doctor) {
        // 这里应该加入密码加密逻辑，暂时略过，或者复用Service中的逻辑
        return ResultVO.success(doctorService.save(doctor));
    }

    /**
     * 修改医生 (管理端)
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Doctor doctor) {
        return ResultVO.success(doctorService.updateById(doctor));
    }

    /**
     * 删除医生 (管理端)
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable List<Long> ids) {
        return ResultVO.success(doctorService.removeByIds(ids));
    }

    /**
     * 医生登录
     */
    @PostMapping("/login")
    public ResultVO<String> login(@RequestBody Map<String, String> loginBody) {
        String username = loginBody.get("username");
        String password = loginBody.get("password");
        String token = doctorService.login(username, password);
        return ResultVO.success(token, "登录成功");
    }

    /**
     * 获取当前医生信息
     */
    @GetMapping("/profile")
    public ResultVO<Doctor> getProfile(HttpServletRequest request) {
        String token = SecurityUtils.getToken(request);
        Long doctorId = JwtTokenUtil.getUserId(token);
        String role = JwtTokenUtil.getRole(token);
        
        if (!"doctor".equals(role)) {
            return ResultVO.error(403, "无权访问");
        }

        Doctor doctor = doctorService.getById(doctorId);
        if (doctor != null) {
            doctor.setPasswordHash(null);
        }
        return ResultVO.success(doctor);
    }

    /**
     * 查看我的排班
     */
    @GetMapping("/schedules")
    public ResultVO<List<Schedule>> getMySchedules(HttpServletRequest request) {
        String token = SecurityUtils.getToken(request);
        Long doctorId = JwtTokenUtil.getUserId(token);
        String role = JwtTokenUtil.getRole(token);
        
        if (!"doctor".equals(role)) {
            return ResultVO.error(403, "无权访问");
        }

        return ResultVO.success(doctorService.getMySchedules(doctorId));
    }

    /**
     * 根据科室查询医生列表 (公开接口)
     */
    @GetMapping("/list-by-dept/{deptId}")
    public ResultVO<List<Doctor>> getDoctorsByDept(@PathVariable Long deptId) {
        List<Doctor> doctors = doctorService.selectByDeptId(deptId);
        doctors.forEach(d -> d.setPasswordHash(null));
        return ResultVO.success(doctors);
    }
}
