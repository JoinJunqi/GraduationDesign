package com.ruoyi.patient.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.utils.JwtUtils;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.common.core.web.controller.BaseController;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.patient.domain.Patient;
import com.ruoyi.patient.service.IPatientService;

import com.ruoyi.common.core.constant.SecurityConstants;
import com.ruoyi.common.core.utils.uuid.IdUtils;
import com.ruoyi.common.security.service.TokenService;
import com.ruoyi.system.api.domain.SysUser;
import com.ruoyi.system.api.model.LoginUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
public class PatientController extends BaseController
{
    private static final Logger log = LoggerFactory.getLogger(PatientController.class);

    @Autowired
    private IPatientService patientService;

    @Autowired
    private TokenService tokenService;

    @PostMapping("/login")
    public ResultVO<Map<String, Object>> login(@RequestBody Patient patient)
    {
        log.info("患者登录尝试: username={}", patient.getUsername());
        // 简单模拟登录逻辑，实际应校验密码
        Patient user = patientService.selectPatientByUsername(patient.getUsername());
        if (user == null)
        {
            log.warn("患者登录失败: 用户不存在, username={}", patient.getUsername());
            return ResultVO.error("用户名或密码错误");
        }
        
        if (!SecurityUtils.matchesPassword(patient.getPasswordHash(), user.getPasswordHash()))
        {
            log.warn("患者登录失败: 密码不匹配, username={}", patient.getUsername());
            return ResultVO.error("用户名或密码错误");
        }
        
        log.info("患者登录成功: username={}", patient.getUsername());
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

    @PostMapping("/register")
    public ResultVO<Boolean> register(@RequestBody Patient patient)
    {
        if (!patientService.checkUsernameUnique(patient.getUsername()))
        {
            return ResultVO.error("注册失败，账号已存在");
        }
        if (!patientService.checkPhoneUnique(patient))
        {
            return ResultVO.error("注册失败，手机号已存在");
        }
        if (!patientService.checkIdCardUnique(patient))
        {
            return ResultVO.error("注册失败，身份证号已存在");
        }
        patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPasswordHash()));
        return ResultVO.success(patientService.save(patient));
    }

    @GetMapping("/list")
    public ResultVO<List<Patient>> list(Patient patient)
    {
        return ResultVO.success(patientService.list());
    }

    @GetMapping(value = "/{id}")
    public ResultVO<Patient> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(patientService.getById(id));
    }

    @PostMapping
    public ResultVO<Boolean> add(@RequestBody Patient patient)
    {
        if (!patientService.checkUsernameUnique(patient.getUsername()))
        {
            return ResultVO.error("新增失败，账号 '" + patient.getUsername() + "' 已存在");
        }
        patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPasswordHash()));
        return ResultVO.success(patientService.save(patient));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody Patient patient)
    {
        if (!patientService.checkPhoneUnique(patient))
        {
            return ResultVO.error("修改失败，手机号 '" + patient.getPhone() + "' 已存在");
        }
        if (!patientService.checkIdCardUnique(patient))
        {
            return ResultVO.error("修改失败，身份证号 '" + patient.getIdCard() + "' 已存在");
        }
        if (patient.getPasswordHash() != null && !patient.getPasswordHash().isEmpty()) {
            patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPasswordHash()));
        }
        return ResultVO.success(patientService.updateById(patient));
    }

    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        return ResultVO.success(patientService.removeByIds(Arrays.asList(ids)));
    }

    @GetMapping("/profile")
    public ResultVO<Patient> profile()
    {
        Long userId = SecurityUtils.getUserId();
        return ResultVO.success(patientService.getById(userId));
    }

    @PutMapping("/profile")
    public ResultVO<Boolean> updateProfile(@RequestBody Patient patient)
    {
        patient.setId(SecurityUtils.getUserId());
        if (!patientService.checkPhoneUnique(patient))
        {
            return ResultVO.error("修改失败，手机号 '" + patient.getPhone() + "' 已存在");
        }
        if (!patientService.checkIdCardUnique(patient))
        {
            return ResultVO.error("修改失败，身份证号 '" + patient.getIdCard() + "' 已存在");
        }
        // 不允许通过此接口修改密码和账号
        patient.setPasswordHash(null);
        patient.setUsername(null);
        return ResultVO.success(patientService.updateById(patient));
    }

    @PutMapping("/profile/updatePwd")
    public ResultVO<Boolean> updatePwd(@RequestParam("oldPassword") String oldPassword, @RequestParam("newPassword") String newPassword)
    {
        Long userId = SecurityUtils.getUserId();
        Patient patient = patientService.getById(userId);
        String password = patient.getPasswordHash();
        if (!SecurityUtils.matchesPassword(oldPassword, password))
        {
            return ResultVO.error("修改密码失败，旧密码错误");
        }
        if (SecurityUtils.matchesPassword(newPassword, password))
        {
            return ResultVO.error("新密码不能与旧密码相同");
        }
        if (patientService.resetPatientPwd(userId, SecurityUtils.encryptPassword(newPassword)) > 0)
        {
            return ResultVO.success(true);
        }
        return ResultVO.error("修改密码异常，请联系管理员");
    }

    /**
     * 患者头像上传
     */
    @PostMapping("/profile/avatar")
    public ResultVO<String> avatar(@RequestParam("avatarfile") MultipartFile file) throws Exception
    {
        if (!file.isEmpty())
        {
            Long userId = SecurityUtils.getUserId();
            // 模拟上传，实际应调用文件服务
            String avatar = "/profile/avatar/default_patient.png";
            Patient patient = new Patient();
            patient.setId(userId);
            patient.setAvatar(avatar);
            if (patientService.updateById(patient))
            {
                return ResultVO.success(avatar);
            }
        }
        return ResultVO.error("上传图片异常，请联系管理员");
    }
}
