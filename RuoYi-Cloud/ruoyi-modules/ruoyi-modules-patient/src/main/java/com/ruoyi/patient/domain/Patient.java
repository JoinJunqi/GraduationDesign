package com.ruoyi.patient.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 患者对象 patient
 */
@Data
@TableName("patient")
public class Patient implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 患者ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 登录账号 */
    private String username;

    /** 密码哈希 */
    private String passwordHash;

    /** 姓名 */
    private String name;

    /** 手机号 */
    private String phone;

    /** 身份证号 */
    private String idCard;

    /** 创建时间 */
    private Date createdAt;
}
