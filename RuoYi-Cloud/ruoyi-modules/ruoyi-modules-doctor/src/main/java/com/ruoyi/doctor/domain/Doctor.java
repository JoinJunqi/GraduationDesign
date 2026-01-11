package com.ruoyi.doctor.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 医生对象 doctor
 */
@Data
@TableName("doctor")
public class Doctor implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 医生ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 所属科室ID */
    private Long deptId;

    /** 登录账号 */
    private String username;

    /** 密码哈希 */
    private String passwordHash;

    /** 医生姓名 */
    private String name;

    /** 职称 */
    private String title;

    /** 是否在职(1是,0否) */
    private Boolean isActive;

    /** 创建时间 */
    private Date createdAt;

    /** 科室名称 (展示用) */
    @TableField(exist = false)
    private String deptName;

    /** 重置密码用 (不存库) */
    @TableField(exist = false)
    private String password;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public Long getDeptId() {
        return deptId;
    }

    public void setDeptId(Long deptId) {
        this.deptId = deptId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
