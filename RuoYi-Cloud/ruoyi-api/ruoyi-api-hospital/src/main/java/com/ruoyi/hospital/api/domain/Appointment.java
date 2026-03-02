package com.ruoyi.hospital.api.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 预约对象 DTO
 */
@Data
public class Appointment implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 预约ID */
    private Long id;

    /** 患者ID */
    private Long patientId;

    /** 排班ID */
    private Long scheduleId;

    /** 状态(待就诊,已取消,已完成,已过期,取消审核中) */
    private String status;

    /** 预约时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date bookedAt;

    /** 预约时段 (如 08:00:00) */
    @JsonFormat(pattern = "HH:mm:ss")
    private String appointmentTime;
}
