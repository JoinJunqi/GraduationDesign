package com.ruoyi.record.domain;

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
 * 电子病历对象 medical_record
 */
@Data
@TableName("medical_record")
public class MedicalRecord implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 请求参数 */
    @TableField(exist = false)
    private Map<String, Object> params = new HashMap<>();

    /** 病历ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 关联的预约ID */
    private Long appointmentId;

    /** 患者ID */
    private Long patientId;

    /** 医生ID */
    private Long doctorId;

    /** 诊断结果 */
    private String diagnosis;

    /** 处方信息 */
    private String prescription;

    /** 医嘱备注 */
    private String notes;

    /** 就诊时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date visitTime;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createdAt;

    /** 是否删除(1是,0否) */
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;

    /** 删除时间 */
    private Date deletedAt;

    /** 医生姓名 (非表字段) */
    @TableField(exist = false)
    private String doctorName;

    /** 患者姓名 (非表字段) */
    @TableField(exist = false)
    private String patientName;

    /** 科室名称 (非表字段) */
    @TableField(exist = false)
    private String deptName;
}
