-- ----------------------------
-- 1. 建库脚本 (请在数据库连接工具中执行，或者确保已有该库)
-- ----------------------------
CREATE DATABASE IF NOT EXISTS `hospital_booking` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `hospital_booking`;

-- ----------------------------
-- 2. 建表脚本 (业务表)
-- ----------------------------

-- 2.1 管理员表
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) NOT NULL COMMENT '登录账号',
  `password_hash` varchar(100) NOT NULL COMMENT '密码哈希',
  `name` varchar(50) NOT NULL COMMENT '管理员姓名',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否启用(1是,0否)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- 插入默认管理员 (密码: 123456 的 BCrypt密文)
INSERT INTO `admin` (`username`, `password_hash`, `name`, `is_active`) VALUES 
('admin_hosp', '$2a$10$7JB720yubVSZv5x8vlmZ9.n/jQaaQDf1u5.yv.151q.123456', '超级管理员', 1);


-- 2.2 科室表
DROP TABLE IF EXISTS `department`;
CREATE TABLE `department` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '科室ID',
  `name` varchar(50) NOT NULL COMMENT '科室名称',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COMMENT='科室表';

-- 插入默认科室
INSERT INTO `department` (`name`) VALUES ('内科'), ('外科'), ('儿科'), ('妇产科'), ('眼科'), ('口腔科'), ('骨科');


-- 2.3 医生表
DROP TABLE IF EXISTS `doctor`;
CREATE TABLE `doctor` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '医生ID',
  `dept_id` bigint(20) NOT NULL COMMENT '所属科室ID',
  `username` varchar(50) NOT NULL COMMENT '登录账号',
  `password_hash` varchar(100) NOT NULL COMMENT '密码哈希',
  `name` varchar(50) NOT NULL COMMENT '医生姓名',
  `title` varchar(50) DEFAULT NULL COMMENT '职称',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '是否在职(1是,0否)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COMMENT='医生表';

-- 插入默认医生 (假设内科ID=100, 外科ID=101)
-- 密码均为 123456
INSERT INTO `doctor` (`dept_id`, `username`, `password_hash`, `name`, `title`) VALUES 
(100, 'doc_zhang', '$2a$10$7JB720yubVSZv5x8vlmZ9.n/jQaaQDf1u5.yv.151q.123456', '张医生', '主任医师'),
(100, 'doc_li', '$2a$10$7JB720yubVSZv5x8vlmZ9.n/jQaaQDf1u5.yv.151q.123456', '李医生', '主治医师'),
(101, 'doc_wang', '$2a$10$7JB720yubVSZv5x8vlmZ9.n/jQaaQDf1u5.yv.151q.123456', '王医生', '副主任医师');


-- 2.4 患者表
DROP TABLE IF EXISTS `patient`;
CREATE TABLE `patient` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '患者ID',
  `username` varchar(50) NOT NULL COMMENT '登录账号',
  `password_hash` varchar(100) NOT NULL COMMENT '密码哈希',
  `name` varchar(50) NOT NULL COMMENT '姓名',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `id_card` varchar(20) DEFAULT NULL COMMENT '身份证号',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COMMENT='患者表';

-- 插入默认患者
INSERT INTO `patient` (`username`, `password_hash`, `name`, `phone`, `id_card`) VALUES 
('pat_chen', '$2a$10$7JB720yubVSZv5x8vlmZ9.n/jQaaQDf1u5.yv.151q.123456', '陈小明', '13800138000', '110101199001011234'),
('pat_zhao', '$2a$10$7JB720yubVSZv5x8vlmZ9.n/jQaaQDf1u5.yv.151q.123456', '赵小红', '13900139000', '110101199202025678');


-- 2.5 排班表
DROP TABLE IF EXISTS `schedule`;
CREATE TABLE `schedule` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '排班ID',
  `doctor_id` bigint(20) NOT NULL COMMENT '医生ID',
  `work_date` date NOT NULL COMMENT '出诊日期',
  `time_slot` varchar(20) NOT NULL COMMENT '班次(上午/下午/全天)',
  `total_capacity` int(11) DEFAULT '20' COMMENT '总号源数',
  `available_slots` int(11) DEFAULT '20' COMMENT '剩余号源',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_doctor_date_slot` (`doctor_id`,`work_date`,`time_slot`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COMMENT='医生排班表';

-- 插入排班数据 (假设张医生ID=100)
INSERT INTO `schedule` (`doctor_id`, `work_date`, `time_slot`, `total_capacity`, `available_slots`) VALUES 
(100, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '上午', 20, 20),
(100, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '下午', 20, 20),
(100, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '上午', 20, 20);


-- 2.6 预约表
DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '预约ID',
  `patient_id` bigint(20) NOT NULL COMMENT '患者ID',
  `schedule_id` bigint(20) NOT NULL COMMENT '排班ID',
  `status` varchar(20) DEFAULT '待就诊' COMMENT '状态(待就诊, 已取消, 已完成)',
  `booked_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '预约时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COMMENT='预约记录表';


-- 2.7 病历表
DROP TABLE IF EXISTS `medical_record`;
CREATE TABLE `medical_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '病历ID',
  `appointment_id` bigint(20) DEFAULT NULL COMMENT '关联的预约ID',
  `patient_id` bigint(20) NOT NULL COMMENT '患者ID',
  `doctor_id` bigint(20) NOT NULL COMMENT '医生ID',
  `diagnosis` text NOT NULL COMMENT '诊断结果',
  `prescription` text COMMENT '处方信息',
  `notes` text COMMENT '医嘱备注',
  `visit_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '就诊时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COMMENT='电子病历表';

-- ----------------------------
-- 3. 菜单表 (将系统菜单表集成到业务库，实现单库管理)
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
  `menu_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) NOT NULL COMMENT '菜单名称',
  `parent_id` bigint(20) DEFAULT '0' COMMENT '父菜单ID',
  `order_num` int(4) DEFAULT '0' COMMENT '显示顺序',
  `path` varchar(200) DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) DEFAULT NULL COMMENT '路由参数',
  `is_frame` int(1) DEFAULT '1' COMMENT '是否为外链（0是 1否）',
  `is_cache` int(1) DEFAULT '0' COMMENT '是否缓存（0是 1否）',
  `menu_type` char(1) DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2000 DEFAULT CHARSET=utf8mb4 COMMENT='菜单权限表';

-- ----------------------------
-- 4. 菜单数据初始化
-- ----------------------------

-- 4.1 医院管理 (目录)
INSERT INTO `sys_menu` VALUES (2000, '医院管理', 0, 1, 'hospital', NULL, NULL, 1, 0, 'M', '0', '0', '', 'hospital', 'admin', SYSDATE(), '', NULL, '医院管理系统菜单');

-- 4.2 管理员管理
INSERT INTO `sys_menu` VALUES (2001, '管理员管理', 2000, 1, 'admin', 'hospital/admin/index', NULL, 1, 0, 'C', '0', '0', 'hospital:admin:list', 'user', 'admin', SYSDATE(), '', NULL, '管理员管理菜单');
INSERT INTO `sys_menu` VALUES (2002, '管理员查询', 2001, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:admin:query', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2003, '管理员新增', 2001, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:admin:add', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2004, '管理员修改', 2001, 3, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:admin:edit', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2005, '管理员删除', 2001, 4, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:admin:remove', '#', 'admin', SYSDATE(), '', NULL, '');

-- 4.3 科室管理
INSERT INTO `sys_menu` VALUES (2006, '科室管理', 2000, 2, 'department', 'hospital/department/index', NULL, 1, 0, 'C', '0', '0', 'hospital:department:list', 'tree', 'admin', SYSDATE(), '', NULL, '科室管理菜单');
INSERT INTO `sys_menu` VALUES (2007, '科室查询', 2006, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:department:query', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2008, '科室新增', 2006, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:department:add', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2009, '科室修改', 2006, 3, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:department:edit', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2010, '科室删除', 2006, 4, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:department:remove', '#', 'admin', SYSDATE(), '', NULL, '');

-- 4.4 医生管理
INSERT INTO `sys_menu` VALUES (2011, '医生管理', 2000, 3, 'doctor', 'hospital/doctor/index', NULL, 1, 0, 'C', '0', '0', 'hospital:doctor:list', 'peoples', 'admin', SYSDATE(), '', NULL, '医生管理菜单');
INSERT INTO `sys_menu` VALUES (2012, '医生查询', 2011, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:doctor:query', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2013, '医生新增', 2011, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:doctor:add', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2014, '医生修改', 2011, 3, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:doctor:edit', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2015, '医生删除', 2011, 4, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:doctor:remove', '#', 'admin', SYSDATE(), '', NULL, '');

-- 4.5 患者管理
INSERT INTO `sys_menu` VALUES (2016, '患者管理', 2000, 4, 'patient', 'hospital/patient/index', NULL, 1, 0, 'C', '0', '0', 'hospital:patient:list', 'user', 'admin', SYSDATE(), '', NULL, '患者管理菜单');
INSERT INTO `sys_menu` VALUES (2017, '患者查询', 2016, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:patient:query', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2018, '患者新增', 2016, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:patient:add', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2019, '患者修改', 2016, 3, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:patient:edit', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2020, '患者删除', 2016, 4, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:patient:remove', '#', 'admin', SYSDATE(), '', NULL, '');

-- 4.6 排班管理
INSERT INTO `sys_menu` VALUES (2021, '排班管理', 2000, 5, 'schedule', 'hospital/schedule/index', NULL, 1, 0, 'C', '0', '0', 'hospital:schedule:list', 'date', 'admin', SYSDATE(), '', NULL, '排班管理菜单');
INSERT INTO `sys_menu` VALUES (2022, '排班查询', 2021, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:schedule:query', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2023, '排班新增', 2021, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:schedule:add', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2024, '排班修改', 2021, 3, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:schedule:edit', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2025, '排班删除', 2021, 4, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:schedule:remove', '#', 'admin', SYSDATE(), '', NULL, '');

-- 4.7 预约管理
INSERT INTO `sys_menu` VALUES (2026, '预约管理', 2000, 6, 'appointment', 'hospital/appointment/index', NULL, 1, 0, 'C', '0', '0', 'hospital:appointment:list', 'list', 'admin', SYSDATE(), '', NULL, '预约管理菜单');
INSERT INTO `sys_menu` VALUES (2027, '预约查询', 2026, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:appointment:query', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2028, '预约新增', 2026, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:appointment:add', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2029, '预约修改', 2026, 3, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:appointment:edit', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2030, '预约删除', 2026, 4, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:appointment:remove', '#', 'admin', SYSDATE(), '', NULL, '');

-- 4.8 病历管理
INSERT INTO `sys_menu` VALUES (2031, '病历管理', 2000, 7, 'record', 'hospital/record/index', NULL, 1, 0, 'C', '0', '0', 'hospital:record:list', 'form', 'admin', SYSDATE(), '', NULL, '病历管理菜单');
INSERT INTO `sys_menu` VALUES (2032, '病历查询', 2031, 1, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:record:query', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2033, '病历新增', 2031, 2, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:record:add', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2034, '病历修改', 2031, 3, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:record:edit', '#', 'admin', SYSDATE(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (2035, '病历删除', 2031, 4, '#', '', NULL, 1, 0, 'F', '0', '0', 'hospital:record:remove', '#', 'admin', SYSDATE(), '', NULL, '');
