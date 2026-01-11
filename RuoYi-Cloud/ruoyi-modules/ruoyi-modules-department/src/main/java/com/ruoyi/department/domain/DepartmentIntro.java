package com.ruoyi.department.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 科室说明对象 department_intro
 */
@Data
@TableName("department_intro")
public class DepartmentIntro implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 说明ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 科室ID */
    private Long deptId;

    /** 科室概述 */
    private String overview;

    /** 详细科室说明 */
    private String detailedIntro;

    /** 主要服务项目 */
    private String services;

    /** 科室特色 */
    private String features;

    /** 就诊须知 */
    private String notice;

    /** 是否启用(1是,0否) */
    private Integer isActive;

    /** 创建人ID */
    private Long createdBy;

    /** 最后更新人ID */
    private Long updatedBy;

    /** 创建时间 */
    private Date createdAt;

    /** 更新时间 */
    private Date updatedAt;
}
