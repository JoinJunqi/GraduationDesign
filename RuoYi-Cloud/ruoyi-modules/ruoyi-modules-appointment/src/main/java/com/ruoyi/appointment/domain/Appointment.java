package com.ruoyi.appointment.domain;

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
 * 预约对象 appointment
 */
@Data
@TableName("appointment")
public class Appointment implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 请求参数 */
    @TableField(exist = false)
    private Map<String, Object> params = new HashMap<>();

    public Map<String, Object> getParams() {
        return params;
    }

    public void setParams(Map<String, Object> params) {
        this.params = params;
    }

    /** 预约ID */
    @TableId(type = IdType.AUTO)
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

    /** 是否删除(1是,0否) */
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;

    /** 删除时间 */
    private Date deletedAt;

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

    /** 科室名称 (展示用) */
    @TableField(exist = false)
    private String deptName;

    /** 科室ID (查询用) */
    @TableField(exist = false)
    private Long deptId;

    /** 职称 (展示/查询用) */
    @TableField(exist = false)
    private String title;

    /** 班次变更通知 */
    private String timeChangeNotice;
}
