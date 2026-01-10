package com.ruoyi.hospital.api.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 排班对象 schedule
 */
@Data
@TableName("schedule")
public class Schedule implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 排班ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 医生ID */
    private Long doctorId;

    /** 出诊日期 */
    private Date workDate;

    /** 班次(上午,下午,全天) */
    private String timeSlot;

    /** 总号源数 */
    private Integer totalCapacity;

    /** 剩余号源 */
    private Integer availableSlots;

    /** 创建时间 */
    private Date createdAt;
}
