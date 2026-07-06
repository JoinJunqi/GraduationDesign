package com.ruoyi.patient.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.support.SFunction;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.common.core.utils.StringUtils;
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
import java.util.regex.Pattern;

@Service
public class PatientServiceImpl extends ServiceImpl<PatientMapper, Patient> implements IPatientService {

    private static final Logger log = LoggerFactory.getLogger(PatientServiceImpl.class);
    // 手机号：11 位且以 1 开头（中国大陆常见格式）
    private static final Pattern PHONE_PATTERN = Pattern.compile("^1\\d{10}$");
    // 身份证号：支持 15 位或 18 位（最后一位可为 X/x）
    private static final Pattern IDCARD_PATTERN = Pattern.compile("^([1-9]\\d{14}|[1-9]\\d{16}[0-9Xx])$");

    @Autowired
    private PatientMapper patientMapper;

    @Autowired
    private TokenService tokenService;

    /**
     * 根据登录账号（手机号/身份证号）查询唯一患者。
     */
    @Override
    public Patient selectPatientByUsername(String username) {
        // 登录入口允许传入手机号/身份证号，这里先做统一去空格
        String account = StringUtils.trim(username);
        if (StringUtils.isEmpty(account)) {
            return null;
        }

        // 依次按“手机号 -> 身份证号”识别并查询唯一患者
        if (isPhone(account)) {
            return selectSingleByField(Patient::getPhone, account, "手机号");
        }
        if (isIdCard(account)) {
            return selectSingleByField(Patient::getIdCard, account, "身份证号");
        }
        return null;
    }

    /**
     * 按条件分页/列表查询患者信息。
     */
    @Override
    public List<Patient> selectPatientList(Patient patient) {
        return patientMapper.selectPatientList(patient);
    }

    /**
     * 校验账号是否唯一。
     */
    @Override
    public boolean checkUsernameUnique(String username) {
        return patientMapper.selectCount(new LambdaQueryWrapper<Patient>().eq(Patient::getUsername, username)) == 0;
    }

    /**
     * 校验手机号是否唯一（编辑时允许与本人记录重复）。
     */
    @Override
    public boolean checkPhoneUnique(Patient patient) {
        // 步骤1：拿到当前编辑对象 id（新增场景用 -1 占位）
        Long id = patient.getId() == null ? -1L : patient.getId();
        // 步骤2：按手机号查询所有命中记录
        List<Patient> list = patientMapper.selectList(new LambdaQueryWrapper<Patient>().eq(Patient::getPhone, patient.getPhone()));
        // 步骤3：只要命中的记录都属于“自己”，就视为唯一
        return list.stream().allMatch(info -> info.getId().equals(id));
    }

    /**
     * 校验身份证号是否唯一（编辑时允许与本人记录重复）。
     */
    @Override
    public boolean checkIdCardUnique(Patient patient) {
        // 步骤1：拿到当前编辑对象 id（新增场景用 -1 占位）
        Long id = patient.getId() == null ? -1L : patient.getId();
        // 步骤2：按身份证号查询所有命中记录
        List<Patient> list = patientMapper.selectList(new LambdaQueryWrapper<Patient>().eq(Patient::getIdCard, patient.getIdCard()));
        // 步骤3：只要命中的记录都属于“自己”，就视为唯一
        return list.stream().allMatch(info -> info.getId().equals(id));
    }

    /**
     * 通用唯一字段查询：返回唯一记录；无记录返回 null；多记录抛异常。
     */
    private Patient selectSingleByField(SFunction<Patient, ?> field, String account, String fieldLabel) {
        // 理论上手机号/身份证号应全局唯一；查到多条说明数据异常
        List<Patient> list = patientMapper.selectList(new LambdaQueryWrapper<Patient>().eq(field, account));
        if (list.isEmpty()) {
            return null;
        }
        if (list.size() > 1) {
            throw new ServiceException(fieldLabel + "存在重复数据，请联系管理员处理");
        }
        return list.get(0);
    }

    /**
     * 判断字符串是否符合手机号格式。
     */
    private boolean isPhone(String account) {
        return PHONE_PATTERN.matcher(account).matches();
    }

    /**
     * 判断字符串是否符合身份证号格式。
     */
    private boolean isIdCard(String account) {
        return IDCARD_PATTERN.matcher(account).matches();
    }

    /**
     * 重置指定患者密码（内部统一加密处理）。
     */
    @Override
    public int resetPatientPwd(Long userId, String password) {
        // 只更新密码字段，避免覆盖其他信息
        Patient patient = new Patient();
        patient.setId(userId);
        patient.setPasswordHash(SecurityUtils.encryptPassword(password));
        return patientMapper.updateById(patient);
    }

    /**
     * 患者登录：校验身份后创建登录态并返回 token。
     */
    @Override
    public Map<String, Object> login(Patient patient) {
        log.info("患者登录尝试: username={}", patient.getUsername());
        // 步骤1：根据输入账号（手机号/身份证号）定位患者
        Patient user = selectPatientByUsername(patient.getUsername());
        if (user == null) {
            log.warn("患者登录失败: 用户不存在, username={}", patient.getUsername());
            throw new ServiceException("用户名或密码错误");
        }

        // 步骤2：兼容前端传 password 或 passwordHash 两种字段
        String rawPassword = patient.getPassword();
        if (rawPassword == null || rawPassword.isEmpty()) {
            rawPassword = patient.getPasswordHash();
        }

        // 步骤3：校验明文密码与数据库加密密码是否匹配
        if (rawPassword == null || !SecurityUtils.matchesPassword(rawPassword, user.getPasswordHash())) {
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

        // 必须设置 sysUser，否则 TokenService 在构造 token 相关信息时会抛 NPE
        SysUser sysUser = new SysUser();
        sysUser.setUserId(user.getId());
        sysUser.setUserName(user.getUsername());
        sysUser.setNickName(user.getName());
        loginUser.setSysUser(sysUser);

        // 步骤4：保存登录态到 Redis，并生成 access_token
        Map<String, Object> tokenMap = tokenService.createToken(loginUser);

        // 步骤5：按前端约定仅返回 token 字段
        Map<String, Object> map = new HashMap<>();
        map.put("token", tokenMap.get("access_token"));
        return map;
    }

    /**
     * 患者自助注册：完成唯一性校验、密码加密并保存。
     */
    @Override
    public boolean register(Patient patient) {
        // 步骤1：注册前做账号唯一校验
        if (!checkUsernameUnique(patient.getUsername())) {
            throw new ServiceException("注册失败，账号已存在");
        }
        // 步骤2：注册前做手机号唯一校验
        if (!checkPhoneUnique(patient)) {
            throw new ServiceException("注册失败，手机号已存在");
        }
        // 步骤3：注册前做身份证号唯一校验
        if (!checkIdCardUnique(patient)) {
            throw new ServiceException("注册失败，身份证号已存在");
        }
        
        // 兼容前端字段差异：优先取 password，回退到 passwordHash
        String password = patient.getPassword();
        if (password == null || password.isEmpty()) {
            password = patient.getPasswordHash();
        }
        
        // 步骤4：没有拿到密码则直接拦截
        if (password == null || password.isEmpty()) {
            throw new ServiceException("注册失败，密码不能为空");
        }
        
        // 步骤5：加密后入库，避免明文存储
        patient.setPasswordHash(SecurityUtils.encryptPassword(password));
        return save(patient);
    }

    /**
     * 管理端新增患者：校验账号并设置初始密码后保存。
     */
    @Override
    public boolean insertPatient(Patient patient) {
        // 步骤1：后台新增患者时先校验账号唯一
        if (!checkUsernameUnique(patient.getUsername())) {
            throw new ServiceException("新增失败，账号 '" + patient.getUsername() + "' 已存在");
        }
        // 步骤2：若管理员填写了密码，则使用填写值；否则下发默认密码
        if (patient.getPassword() != null && !patient.getPassword().isEmpty()) {
            patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPassword()));
        } else {
            // 默认密码
            patient.setPasswordHash(SecurityUtils.encryptPassword("123456"));
        }
        // 步骤3：执行保存
        return save(patient);
    }

    /**
     * 管理端更新患者：做唯一性校验并按需更新密码。
     */
    @Override
    public boolean updatePatient(Patient patient) {
        // 步骤1：更新前校验手机号唯一
        if (!checkPhoneUnique(patient)) {
            throw new ServiceException("修改失败，手机号 '" + patient.getPhone() + "' 已存在");
        }
        // 步骤2：更新前校验身份证号唯一
        if (!checkIdCardUnique(patient)) {
            throw new ServiceException("修改失败，身份证号 '" + patient.getIdCard() + "' 已存在");
        }
        // 步骤3：如果本次提交包含新密码，则重新加密
        if (patient.getPassword() != null && !patient.getPassword().isEmpty()) {
            patient.setPasswordHash(SecurityUtils.encryptPassword(patient.getPassword()));
        }
        // 步骤4：执行更新
        return updateById(patient);
    }

    /**
     * 批量逻辑删除患者（打删除标记，不做物理删除）。
     */
    @Override
    public boolean deletePatientByIds(Long[] ids) {
        // 步骤1：将 is_deleted 标记置为 1
        // 步骤2：记录 deleted_at 作为删除时间
        // 步骤3：按 ids 批量更新（逻辑删除，不做物理删除）
        return update(new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<Patient>()
                .set("is_deleted", 1)
                .set("deleted_at", new Date())
                .in("id", Arrays.asList(ids)));
    }

    /**
     * 批量恢复已逻辑删除的患者。
     */
    @Override
    public boolean recoverPatientByIds(Long[] ids) {
        // 步骤1：调用 mapper 执行批量恢复（通常会清理删除标记）
        int recovered = patientMapper.recoverPatientByIds(ids);
        // 步骤2：返回是否至少恢复 1 条
        return recovered > 0;
    }

    /**
     * 患者更新个人资料（仅允许修改当前登录用户本人资料）。
     */
    @Override
    public boolean updatePatientProfile(Patient patient) {
        // 步骤1：资料维护接口强制绑定当前登录用户，防止越权修改他人资料
        patient.setId(SecurityUtils.getUserId());
        // 步骤2：校验手机号唯一
        if (!checkPhoneUnique(patient)) {
            throw new ServiceException("修改失败，手机号 '" + patient.getPhone() + "' 已存在");
        }
        // 步骤3：校验身份证号唯一
        if (!checkIdCardUnique(patient)) {
            throw new ServiceException("修改失败，身份证号 '" + patient.getIdCard() + "' 已存在");
        }
        // 步骤4：不允许通过资料接口修改密码和账号
        patient.setPasswordHash(null);
        patient.setUsername(null);
        // 步骤5：执行更新
        return updateById(patient);
    }

    /**
     * 患者修改密码：校验旧密码与新密码后完成更新。
     */
    @Override
    public boolean updatePassword(String oldPassword, String newPassword) {
        // 步骤1：获取当前登录用户并查询数据库中的患者记录
        Long userId = SecurityUtils.getUserId();
        Patient patient = getById(userId);
        if (patient == null) {
            throw new ServiceException("用户不存在");
        }
        String password = patient.getPasswordHash();
        // 步骤2：校验旧密码是否正确
        if (!SecurityUtils.matchesPassword(oldPassword, password)) {
            throw new ServiceException("修改密码失败，旧密码错误");
        }
        // 步骤3：避免用户将新密码设置为当前密码
        if (SecurityUtils.matchesPassword(newPassword, password)) {
            throw new ServiceException("新密码不能与旧密码相同");
        }
        // 步骤4：复用重置密码方法执行加密更新
        return resetPatientPwd(userId, newPassword) > 0;
    }
}
