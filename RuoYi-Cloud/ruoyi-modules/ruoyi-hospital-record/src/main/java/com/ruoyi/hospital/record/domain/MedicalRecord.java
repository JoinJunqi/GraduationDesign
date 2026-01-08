package com.ruoyi.hospital.record.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.util.Date;

/**
 * 电子病历表
 */
@Data
@TableName("medical_record")
public class MedicalRecord {
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
    private Date visitTime;

    /** 创建时间 */
    private Date createdAt;
}
