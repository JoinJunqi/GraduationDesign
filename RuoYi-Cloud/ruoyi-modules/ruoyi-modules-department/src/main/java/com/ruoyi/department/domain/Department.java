package com.ruoyi.department.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 科室对象 department
 */
@Data
@TableName("department")
public class Department implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 科室ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 科室名称 */
    private String name;

    /** 创建时间 */
    private Date createdAt;

    /** 科室概述 (来自 department_intro) */
    @com.baomidou.mybatisplus.annotation.TableField(exist = false)
    private String overview;
}
