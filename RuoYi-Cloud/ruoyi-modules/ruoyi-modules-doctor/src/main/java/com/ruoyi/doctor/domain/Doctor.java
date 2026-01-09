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

    /** 验证码 */
    @TableField(exist = false)
    private String code;

    /** 唯一标识 */
    @TableField(exist = false)
    private String uuid;
}
