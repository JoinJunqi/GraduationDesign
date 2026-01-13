package com.ruoyi.department.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;
import java.util.Map;
import java.util.HashMap;

/**
 * 科室对象 department
 */
@Data
@TableName("department")
public class Department implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 请求参数 */
    @TableField(exist = false)
    private Map<String, Object> params = new HashMap<>();

    /** 科室ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 科室名称 */
    private String name;

    /** 创建时间 */
    private Date createdAt;

    /** 是否删除(1是,0否) */
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;

    /** 删除时间 */
    private Date deletedAt;

    /** 科室概述 (来自 department_intro) */
    @com.baomidou.mybatisplus.annotation.TableField(exist = false)
    private String overview;
}
