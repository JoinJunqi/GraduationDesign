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
        return ResultVO.success(doctorService.login(doctor));
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
        return ResultVO.success(doctorService.insertDoctor(doctor));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Doctor doctor)
    {
        return ResultVO.success(doctorService.updateDoctor(doctor));
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
