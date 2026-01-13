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
import java.util.HashMap;
import java.util.Map;

/**
 * 系统操作审核对象 sys_operation_audit
 */
@Data
@TableName("sys_operation_audit")
public class SysOperationAudit implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 请求参数 */
    @TableField(exist = false)
    private Map<String, Object> params = new HashMap<>();

    /** 审核ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 审核类型(APPOINTMENT_CANCEL: 预约取消, OTHER: 其他操作) */
    private String auditType;

    /** 关联业务ID(如预约记录ID) */
    private Long targetId;

    /** 申请人ID(对应患者或医生的ID) */
    private Long requesterId;

    /** 申请人角色(doctor:医生, patient:患者) */
    private String requesterRole;

    /** 申请取消的原因说明 */
    private String requestReason;

    /** 审核状态(0:待审核, 1:已通过, 2:已驳回) */
    private Integer auditStatus;

    /** 管理员审核处理人ID(关联后台系统用户) */
    private Long adminId;

    /** 管理员审核处理时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date auditTime;

    /** 管理员审核备注或驳回理由 */
    private String auditRemark;

    /** 提交申请的时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createdAt;

    /** 是否逻辑删除(1是,0否) */
    @TableLogic(value = "0", delval = "1")
    private Integer isDeleted;

    /** 逻辑删除时间 */
    private Date deletedAt;

    // 冗余字段用于展示
    @TableField(exist = false)
    private String requesterName;
    
    @TableField(exist = false)
    private String appointmentInfo;
}
