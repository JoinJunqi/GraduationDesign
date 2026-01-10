package com.ruoyi.patient.controller;

import java.util.Map;
import java.util.List;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.patient.domain.Patient;
import com.ruoyi.patient.service.IPatientService;
import com.ruoyi.common.security.utils.SecurityUtils;

@RestController
@RequestMapping("/patient")
public class PatientController extends BaseController
{
    @Autowired
    private IPatientService patientService;

    @PostMapping("/login")
    public ResultVO<Map<String, Object>> login(@RequestBody Patient patient)
    {
        return ResultVO.success(patientService.login(patient));
    }

    @PostMapping("/register")
    public ResultVO<Boolean> register(@RequestBody Patient patient)
    {
        return ResultVO.success(patientService.register(patient));
    }

    @GetMapping("/list")
    public ResultVO<List<Patient>> list(Patient patient)
    {
        return ResultVO.success(patientService.selectPatientList(patient));
    }

    @GetMapping(value = "/{id}")
    public ResultVO<Patient> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(patientService.getById(id));
    }

    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Patient patient)
    {
        return ResultVO.success(patientService.insertPatient(patient));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Patient patient)
    {
        return ResultVO.success(patientService.updatePatient(patient));
    }

    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        return ResultVO.success(patientService.deletePatientByIds(ids));
    }

    @GetMapping("/profile")
    public ResultVO<Map<String, Object>> profile()
    {
        com.ruoyi.system.api.model.LoginUser loginUser = com.ruoyi.common.security.utils.SecurityUtils.getLoginUser();
        Map<String, Object> ajax = new java.util.HashMap<>();
        ajax.put("user", loginUser.getSysUser());
        ajax.put("roles", loginUser.getRoles());
        ajax.put("permissions", loginUser.getPermissions());
        // 额外提供完整的患者信息
        ajax.put("patient", patientService.getById(loginUser.getUserid()));
        return ResultVO.success(ajax);
    }

    @PutMapping("/profile")
    public ResultVO<Boolean> updateProfile(@RequestBody Patient patient)
    {
        return ResultVO.success(patientService.updatePatientProfile(patient));
    }

    @PutMapping("/profile/updatePwd")
    public ResultVO<Boolean> updatePwd(@RequestParam("oldPassword") String oldPassword, @RequestParam("newPassword") String newPassword)
    {
        return ResultVO.success(patientService.updatePassword(oldPassword, newPassword));
    }
}
