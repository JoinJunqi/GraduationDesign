package com.ruoyi.hospital.doctor.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.util.Date;

/**
 * 医生表
 */
@Data
@TableName("doctor")
public class Doctor {
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
    private Integer isActive;

    /** 创建时间 */
    private Date createdAt;
}
