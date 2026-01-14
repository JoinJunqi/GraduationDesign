package com.ruoyi.patient.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;
import java.util.Map;
import java.util.HashMap;

/**
 * 患者对象 patient
 */
@Data
@TableName("patient")
public class Patient implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 请求参数 */
    @TableField(exist = false)
    private Map<String, Object> params = new HashMap<>();

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

    /** 是否有效(1是,0否) */
    private Integer isActive;

    /** 创建时间 */
    private Date createdAt;

    /** 是否删除(1是,0否) */
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;

    /** 删除时间 */
    private Date deletedAt;

    /** 重置密码用 (不存库) */
    @TableField(exist = false)
    private String password;
}
