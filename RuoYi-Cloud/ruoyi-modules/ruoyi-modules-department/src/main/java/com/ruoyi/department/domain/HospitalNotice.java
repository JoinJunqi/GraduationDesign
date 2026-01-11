package com.ruoyi.department.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 医院通知对象 hospital_notice
 */
@Data
@TableName("hospital_notice")
public class HospitalNotice implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 通知ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 通知标题 */
    private String title;

    /** 通知内容 */
    private String content;

    /** 通知类型 */
    private String noticeType;

    /** 目标受众 */
    private String targetAudience;

    /** 优先级 */
    private String priority;

    /** 发布时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date publishTime;

    /** 过期时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date expireTime;

    /** 是否置顶(1是,0否) */
    private Integer isTop;

    /** 是否有效(1是,0否) */
    private Integer isActive;

    /** 查看次数 */
    private Integer viewCount;

    /** 发布人ID */
    private Long publisherId;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createdAt;

    /** 更新时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date updatedAt;
}
