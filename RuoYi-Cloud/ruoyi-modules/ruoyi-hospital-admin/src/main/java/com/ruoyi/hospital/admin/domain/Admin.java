package com.ruoyi.hospital.admin.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 管理员表
 */
@Data
@TableName("admin")
public class Admin {
    /** 管理员ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 登录账号 */
    private String username;

    /** 密码哈希 */
    private String passwordHash;

    /** 管理员姓名 */
    private String name;

    /** 是否启用(1是,0否) */
    private Integer isActive;

    /** 创建时间 */
    private Date createdAt;
}
