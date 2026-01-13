package com.ruoyi.schedule.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;
import java.util.Map;
import java.util.HashMap;

/**
 * 排班对象 schedule
 */
@Data
@TableName("schedule")
public class Schedule implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 请求参数 */
    @TableField(exist = false)
    private Map<String, Object> params = new HashMap<>();

    /** 排班ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 医生ID */
    private Long doctorId;

    /** 出诊日期 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date workDate;

    /** 班次(上午,下午,全天) */
    private String timeSlot;

    /** 总号源数 */
    private Integer totalCapacity;

    /** 剩余号源 */
    private Integer availableSlots;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createdAt;

    /** 是否删除(1是,0否) */
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;

    /** 删除时间 */
    private Date deletedAt;

    /** 医生姓名 (展示用) */
    @TableField(exist = false)
    private String doctorName;

    /** 科室名称 (展示用) */
    @TableField(exist = false)
    private String deptName;

    /** 科室ID (查询用) */
    @TableField(exist = false)
    private Long deptId;

    /** 职称 (展示/查询用) */
    @TableField(exist = false)
    private String title;
}
