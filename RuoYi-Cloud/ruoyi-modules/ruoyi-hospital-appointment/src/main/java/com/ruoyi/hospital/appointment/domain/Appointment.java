package com.ruoyi.hospital.appointment.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.util.Date;

/**
 * 预约记录表
 */
@Data
@TableName("appointment")
public class Appointment {
    /** 预约ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 患者ID */
    private Long patientId;

    /** 排班ID */
    private Long scheduleId;

    /** 状态 */
    private String status;

    /** 预约时间 */
    private Date bookedAt;
}
