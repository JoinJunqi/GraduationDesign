package com.ruoyi.hospital.department.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.util.Date;

/**
 * 科室表
 */
@Data
@TableName("department")
public class Department {
    /** 科室ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 科室名称 */
    private String name;

    /** 创建时间 */
    private Date createdAt;
}
