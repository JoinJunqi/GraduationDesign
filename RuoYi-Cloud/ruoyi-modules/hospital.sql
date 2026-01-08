-- ----------------------------
-- 1. 管理员表 (新增的核心角色表)
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE admin (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '管理员ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    name VARCHAR(50) NOT NULL COMMENT '管理员姓名',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用(1是,0否)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB COMMENT='管理员信息表';

-- ----------------------------
-- 2. 科室表 (基础信息)
-- ----------------------------
DROP TABLE IF EXISTS `department`;
CREATE TABLE department (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '科室ID',
    name VARCHAR(100) NOT NULL UNIQUE COMMENT '科室名称',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB COMMENT='科室信息表';

-- ----------------------------
-- 3. 医生表 (集成登录信息)
-- ----------------------------
DROP TABLE IF EXISTS `doctor`;
CREATE TABLE doctor (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '医生ID',
    dept_id INT NOT NULL COMMENT '所属科室ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    name VARCHAR(50) NOT NULL COMMENT '医生姓名',
    title VARCHAR(50) COMMENT '职称',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否在职(1是,0否)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (dept_id) REFERENCES department(id) ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='医生信息表';

-- ----------------------------
-- 4. 患者表 (集成登录信息)
-- ----------------------------
DROP TABLE IF EXISTS `patient`;
CREATE TABLE patient (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '患者ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    phone VARCHAR(11) COMMENT '手机号',
    id_card CHAR(18) UNIQUE COMMENT '身份证号',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB COMMENT='患者信息表';

-- ----------------------------
-- 5. 排班表 (核心业务表)
-- ----------------------------
DROP TABLE IF EXISTS `schedule`;
CREATE TABLE schedule (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '排班ID',
    doctor_id INT NOT NULL COMMENT '医生ID',
    work_date DATE NOT NULL COMMENT '出诊日期',
    time_slot ENUM('上午', '下午', '全天') NOT NULL COMMENT '班次',
    total_capacity INT NOT NULL DEFAULT 20 COMMENT '总号源数',
    available_slots INT NOT NULL DEFAULT 20 COMMENT '剩余号源',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_doctor_date_slot (doctor_id, work_date, time_slot),
    FOREIGN KEY (doctor_id) REFERENCES doctor(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='医生排班表';

-- ----------------------------
-- 6. 预约记录表 (核心业务表)
-- ----------------------------
DROP TABLE IF EXISTS `appointment`;
CREATE TABLE appointment (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '预约ID',
    patient_id INT NOT NULL COMMENT '患者ID',
    schedule_id INT NOT NULL COMMENT '排班ID',
    status ENUM('待就诊', '已取消', '已完成') DEFAULT '待就诊' COMMENT '状态',
    booked_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '预约时间',
    UNIQUE KEY uk_schedule_unique (schedule_id), -- 确保一个号源只能被预约一次 (注意：此处业务逻辑可能存在歧义，若一行Schedule代表多个号源，则此约束会导致只能预约一人)
    FOREIGN KEY (patient_id) REFERENCES patient(id) ON DELETE CASCADE,
    FOREIGN KEY (schedule_id) REFERENCES schedule(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='预约记录表';

-- ----------------------------
-- 7. 病历表 (扩展业务表)
-- ----------------------------
DROP TABLE IF EXISTS `medical_record`;
CREATE TABLE medical_record (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '病历ID',
    appointment_id INT NOT NULL UNIQUE COMMENT '关联的预约ID',
    patient_id INT NOT NULL COMMENT '患者ID',
    doctor_id INT NOT NULL COMMENT '医生ID',
    diagnosis TEXT NOT NULL COMMENT '诊断结果',
    prescription TEXT COMMENT '处方信息',
    notes TEXT COMMENT '医嘱备注',
    visit_time DATETIME NOT NULL COMMENT '就诊时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (appointment_id) REFERENCES appointment(id) ON DELETE RESTRICT,
    FOREIGN KEY (patient_id) REFERENCES patient(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctor(id) ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='电子病历表';
