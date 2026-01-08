package com.ruoyi.hospital.doctor.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.util.Date;

/**
 * 医生排班表 (副本，用于解决模块依赖)
 */
@Data
@TableName("schedule")
public class Schedule {
    /** 排班ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 医生ID */
    private Long doctorId;

    /** 出诊日期 */
    private Date workDate;

    /** 班次 */
    private String timeSlot;

    /** 总号源数 */
    private Integer totalCapacity;

    /** 剩余号源 */
    private Integer availableSlots;

    /** 创建时间 */
    private Date createdAt;
}
