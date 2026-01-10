/*
 Navicat Premium Dump SQL

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 50732 (5.7.32-log)
 Source Host           : localhost:3306
 Source Schema         : hospital_booking

 Target Server Type    : MySQL
 Target Server Version : 50732 (5.7.32-log)
 File Encoding         : 65001

 Date: 10/01/2026 21:24:56
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录账号',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '管理员姓名',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用(1是,0否)',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '管理员信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', '$2a$10$GIMZcpW99EG0FWFA0oCdOOagK1QTYbtvpjvxtQlasgNcwxaE0D126', '系统管理员1', 1, '2026-01-08 19:54:43');

-- ----------------------------
-- Table structure for appointment
-- ----------------------------
DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '预约ID',
  `patient_id` int(11) NOT NULL COMMENT '患者ID',
  `schedule_id` int(11) NOT NULL COMMENT '排班ID',
  `status` enum('待就诊','已取消','已完成') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '待就诊' COMMENT '状态',
  `booked_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预约时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_schedule_unique`(`schedule_id`) USING BTREE,
  INDEX `patient_id`(`patient_id`) USING BTREE,
  CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `appointment_ibfk_2` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '预约记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of appointment
-- ----------------------------
INSERT INTO `appointment` VALUES (1, 1, 1, '已完成', '2026-01-08 10:00:00');
INSERT INTO `appointment` VALUES (2, 1, 2, '已完成', '2026-01-08 11:00:00');
INSERT INTO `appointment` VALUES (3, 1, 4, '已完成', '2026-01-09 09:00:00');
INSERT INTO `appointment` VALUES (4, 2, 3, '已完成', '2026-01-09 10:00:00');
INSERT INTO `appointment` VALUES (5, 2, 5, '已完成', '2026-01-09 14:00:00');
INSERT INTO `appointment` VALUES (6, 2, 6, '已完成', '2026-01-10 08:00:00');

-- ----------------------------
-- Table structure for department
-- ----------------------------
DROP TABLE IF EXISTS `department`;
CREATE TABLE `department`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '科室ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '科室名称',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '科室信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of department
-- ----------------------------
INSERT INTO `department` VALUES (1, '内科', '2026-01-09 02:44:31');
INSERT INTO `department` VALUES (2, '外科', '2026-01-09 02:44:31');
INSERT INTO `department` VALUES (3, '儿科', '2026-01-09 02:44:31');
INSERT INTO `department` VALUES (4, '妇科', '2026-01-09 02:44:31');
INSERT INTO `department` VALUES (5, '眼科', '2026-01-09 02:44:31');

-- ----------------------------
-- Table structure for doctor
-- ----------------------------
DROP TABLE IF EXISTS `doctor`;
CREATE TABLE `doctor`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '医生ID',
  `dept_id` int(11) NOT NULL COMMENT '所属科室ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录账号',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '医生姓名',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '职称',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否在职(1是,0否)',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE,
  INDEX `dept_id`(`dept_id`) USING BTREE,
  CONSTRAINT `doctor_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `department` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '医生信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctor
-- ----------------------------
INSERT INTO `doctor` VALUES (1, 1, 'doc1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张内科', '主任医师', 1, '2026-01-09 02:44:31');
INSERT INTO `doctor` VALUES (2, 2, 'doc_surgery', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李外科', '副主任医师', 1, '2026-01-09 02:44:31');
INSERT INTO `doctor` VALUES (3, 3, 'doc_pediatrics', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王儿科', '主治医师', 1, '2026-01-09 02:44:31');

-- ----------------------------
-- Table structure for medical_record
-- ----------------------------
DROP TABLE IF EXISTS `medical_record`;
CREATE TABLE `medical_record`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '病历ID',
  `appointment_id` int(11) NOT NULL COMMENT '关联的预约ID',
  `patient_id` int(11) NOT NULL COMMENT '患者ID',
  `doctor_id` int(11) NOT NULL COMMENT '医生ID',
  `diagnosis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '诊断结果',
  `prescription` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '处方信息',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '医嘱备注',
  `visit_time` datetime NOT NULL COMMENT '就诊时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `appointment_id`(`appointment_id`) USING BTREE,
  INDEX `patient_id`(`patient_id`) USING BTREE,
  INDEX `doctor_id`(`doctor_id`) USING BTREE,
  CONSTRAINT `medical_record_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointment` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `medical_record_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `medical_record_ibfk_3` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '电子病历表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of medical_record
-- ----------------------------
INSERT INTO `medical_record` VALUES (1, 1, 1, 1, '急性上呼吸道感染（感冒）', '阿莫西林胶囊 0.5g，每日三次，连续7天；对乙酰氨基酚片 0.5g，发热时服用', '注意休息，多饮水，监测体温', '2026-01-09 09:00:00', '2026-01-09 22:48:13');
INSERT INTO `medical_record` VALUES (2, 2, 1, 1, '慢性咽炎急性发作', '头孢克肟片 100mg，每日两次，连续5天；复方硼砂溶液漱口，每日三次', '避免辛辣刺激食物，戒烟酒', '2026-01-09 14:00:00', '2026-01-09 22:48:13');
INSERT INTO `medical_record` VALUES (3, 3, 1, 1, '支气管炎', '左氧氟沙星片 0.5g，每日一次，连续7天；氨溴索口服液 10ml，每日三次', '保持室内空气流通，避免冷空气刺激', '2026-01-10 09:00:00', '2026-01-09 22:48:13');
INSERT INTO `medical_record` VALUES (4, 4, 2, 2, '阑尾炎术后复查', '无特殊处方', '伤口愈合良好，建议逐步恢复正常活动，定期复查', '2026-01-10 09:00:00', '2026-01-09 22:48:13');
INSERT INTO `medical_record` VALUES (5, 5, 2, 2, '软组织挫伤', '布洛芬缓释胶囊 0.3g，每日两次，连续3天；局部外用扶他林软膏', '限制活动，患处抬高，48小时后热敷', '2026-01-10 14:00:00', '2026-01-09 22:48:13');
INSERT INTO `medical_record` VALUES (6, 6, 2, 3, '小儿过敏性鼻炎', '氯雷他定片 10mg，每日一次，连续14天；生理盐水鼻腔喷雾器清洗，每日两次', '避免接触过敏原，保持室内清洁', '2026-01-11 09:00:00', '2026-01-09 22:48:13');

-- ----------------------------
-- Table structure for patient
-- ----------------------------
DROP TABLE IF EXISTS `patient`;
CREATE TABLE `patient`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '患者ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录账号',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '姓名',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `id_card` char(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '身份证号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像地址',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE,
  UNIQUE INDEX `id_card`(`id_card`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '患者信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of patient
-- ----------------------------
INSERT INTO `patient` VALUES (1, 'patient1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵患者1', '13800138000', '110101199001011234', NULL, '2026-01-09 02:44:31');
INSERT INTO `patient` VALUES (2, 'patient002', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '钱患者', '13900139000', '110101199505055678', NULL, '2026-01-09 02:44:31');

-- ----------------------------
-- Table structure for schedule
-- ----------------------------
DROP TABLE IF EXISTS `schedule`;
CREATE TABLE `schedule`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '排班ID',
  `doctor_id` int(11) NOT NULL COMMENT '医生ID',
  `work_date` date NOT NULL COMMENT '出诊日期',
  `time_slot` enum('上午','下午','全天') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '班次',
  `total_capacity` int(11) NOT NULL DEFAULT 20 COMMENT '总号源数',
  `available_slots` int(11) NOT NULL DEFAULT 20 COMMENT '剩余号源',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_doctor_date_slot`(`doctor_id`, `work_date`, `time_slot`) USING BTREE,
  CONSTRAINT `schedule_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctor` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '医生排班表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of schedule
-- ----------------------------
INSERT INTO `schedule` VALUES (1, 1, '2026-01-09', '上午', 20, 20, '2026-01-09 02:44:31');
INSERT INTO `schedule` VALUES (2, 1, '2026-01-09', '下午', 20, 20, '2026-01-09 02:44:31');
INSERT INTO `schedule` VALUES (3, 2, '2026-01-10', '上午', 15, 15, '2026-01-09 02:44:31');
INSERT INTO `schedule` VALUES (4, 1, '2026-01-10', '上午', 20, 20, '2026-01-09 22:48:13');
INSERT INTO `schedule` VALUES (5, 2, '2026-01-10', '下午', 15, 15, '2026-01-09 22:48:13');
INSERT INTO `schedule` VALUES (6, 3, '2026-01-11', '全天', 10, 10, '2026-01-09 22:48:13');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int(4) NOT NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '1' COMMENT '是否为外链（1是 0否）',
  `is_cache` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '是否缓存（1是 0否）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id`) USING BTREE,
  INDEX `idx_menu_type`(`menu_type`) USING BTREE,
  INDEX `idx_visible`(`visible`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '医院管理', 0, 10, 'hospital', NULL, NULL, '', '1', '0', 'M', '0', '0', '', 'hospital', 'admin', '2026-01-08 16:14:48', '', NULL, '医院管理系统菜单');
INSERT INTO `sys_menu` VALUES (2, '管理员管理', 1, 1, 'admin', 'hospital/admin/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:admin:list', 'user', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3, '科室管理', 1, 2, 'department', 'hospital/department/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:department:list', 'tree', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (4, '医生管理', 1, 3, 'doctor', 'hospital/doctor/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:doctor:list', 'peoples', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (5, '患者管理', 1, 4, 'patient', 'hospital/patient/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:patient:list', 'user', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (6, '排班管理', 1, 5, 'schedule', 'hospital/schedule/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:schedule:list', 'date', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (7, '预约管理', 1, 6, 'appointment', 'hospital/appointment/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:appointment:list', 'list', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (8, '病历管理', 1, 7, 'record', 'hospital/record/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:record:list', 'form', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (9, '医生查询', 4, 1, '#', '', NULL, '', '1', '0', 'F', '0', '0', 'hospital:doctor:query', '#', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (10, '医生新增', 4, 2, '#', '', NULL, '', '1', '0', 'F', '0', '0', 'hospital:doctor:add', '#', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (11, '医生修改', 4, 3, '#', '', NULL, '', '1', '0', 'F', '0', '0', 'hospital:doctor:edit', '#', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (12, '医生删除', 4, 4, '#', '', NULL, '', '1', '0', 'F', '0', '0', 'hospital:doctor:remove', '#', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (13, '预约挂号', 1, 8, 'register', 'hospital/appointment/register', NULL, '', '1', '0', 'C', '0', '0', 'hospital:appointment:register', 'edit', 'admin', '2026-01-10 20:06:16', '', NULL, '');

SET FOREIGN_KEY_CHECKS = 1;
