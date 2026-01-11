package com.ruoyi.appointment.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
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

    /** 状态(待就诊,已取消,已完成,取消申请中) */
    private String status;

    /** 预约时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date bookedAt;

    /** 预约时段 (如 08:00:00) */
    @JsonFormat(pattern = "HH:mm:ss")
    private String appointmentTime;

    /** 医生ID (查询用) */
    @TableField(exist = false)
    private Long doctorId;

    /** 患者姓名 (展示用) */
    @TableField(exist = false)
    private String patientName;

    /** 医生姓名 (展示用) */
    @TableField(exist = false)
    private String doctorName;

    /** 出诊日期 (展示用) */
    @TableField(exist = false)
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date workDate;

    /** 班次 (展示用) */
    @TableField(exist = false)
    private String timeSlot;
}
