package com.ruoyi.system.api.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.ruoyi.common.core.web.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.apache.ibatis.type.Alias;

import java.util.Date;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("admin")
@Alias("HospitalAdminEntity")
public class Admin extends BaseEntity {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    private String passwordHash;
    private String name;
    private String phone;
    private Integer adminLevel;
    private Integer isActive;

    /** 操作权限(bitmask) */
    private Integer permissions;

    /** 是否删除(1是,0否) */
    @TableLogic
    private Integer isDeleted;

    /** 删除时间 */
    private Date deletedAt;
}
