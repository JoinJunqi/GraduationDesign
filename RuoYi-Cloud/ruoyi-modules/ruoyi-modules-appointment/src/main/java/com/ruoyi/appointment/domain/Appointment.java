package com.ruoyi.appointment.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 预约对象 appointment
 */
@Data
@TableName("appointment")
public class Appointment implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 预约ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 患者ID */
    private Long patientId;

    /** 排班ID */
    private Long scheduleId;

    /** 状态(待就诊,已取消,已完成) */
    private String status;

    /** 预约时间 */
    private Date bookedAt;
}
