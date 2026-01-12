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

 Date: 13/01/2026 02:37:05
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
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `admin_level` tinyint(1) NOT NULL DEFAULT 0 COMMENT '管理员等级(0普通管理员,1超级管理员)',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用(1是,0否)',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE,
  UNIQUE INDEX `phone`(`phone`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '管理员信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '系统管理员', '13800000000', 1, 1, '2026-01-08 19:54:43');
INSERT INTO `admin` VALUES (2, 'admintest', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '测试管理员', '13900000001', 0, 1, '2026-01-12 17:46:11');

-- ----------------------------
-- Table structure for appointment
-- ----------------------------
DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '预约ID',
  `patient_id` int(11) NOT NULL COMMENT '患者ID',
  `schedule_id` int(11) NOT NULL COMMENT '排班ID',
  `status` enum('待就诊','已取消','已完成','已过期') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '待就诊' COMMENT '状态',
  `booked_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预约时间',
  `appointment_time` time NULL DEFAULT NULL COMMENT '预约时段（如08:00:00）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_schedule_id`(`schedule_id`) USING BTREE,
  INDEX `patient_id`(`patient_id`) USING BTREE,
  INDEX `idx_appointment_time`(`appointment_time`) USING BTREE,
  CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `appointment_ibfk_2` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1243 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '预约记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of appointment
-- ----------------------------
INSERT INTO `appointment` VALUES (3, 1, 4, '已完成', '2026-01-09 09:00:00', '08:15:00');
INSERT INTO `appointment` VALUES (6, 2, 6, '已完成', '2026-01-10 08:00:00', '16:15:00');
INSERT INTO `appointment` VALUES (21, 8, 27, '已过期', '2026-01-11 18:10:42', '17:00:00');
INSERT INTO `appointment` VALUES (24, 10, 30, '已取消', '2026-01-11 18:10:42', '08:00:00');
INSERT INTO `appointment` VALUES (52, 7, 70, '已过期', '2026-01-09 18:10:42', '15:15:00');
INSERT INTO `appointment` VALUES (53, 9, 71, '已取消', '2026-01-07 18:10:42', '16:45:00');
INSERT INTO `appointment` VALUES (62, 8, 82, '已取消', '2026-01-09 18:10:42', '15:45:00');
INSERT INTO `appointment` VALUES (66, 13, 86, '已完成', '2026-01-11 18:10:42', '09:15:00');
INSERT INTO `appointment` VALUES (70, 9, 93, '已过期', '2026-01-10 18:10:42', '10:30:00');
INSERT INTO `appointment` VALUES (73, 2, 96, '已完成', '2026-01-10 18:10:42', '09:00:00');
INSERT INTO `appointment` VALUES (99, 11, 137, '已过期', '2026-01-10 18:10:42', '16:30:00');
INSERT INTO `appointment` VALUES (110, 3, 150, '已完成', '2026-01-11 18:10:42', '11:45:00');
INSERT INTO `appointment` VALUES (113, 13, 154, '已取消', '2026-01-11 18:10:42', '17:15:00');
INSERT INTO `appointment` VALUES (115, 12, 156, '已过期', '2026-01-09 18:10:42', '13:45:00');
INSERT INTO `appointment` VALUES (129, 8, 175, '已完成', '2026-01-10 18:10:42', '14:15:00');
INSERT INTO `appointment` VALUES (142, 4, 190, '已完成', '2026-01-10 18:10:42', '11:15:00');
INSERT INTO `appointment` VALUES (150, 1, 198, '已过期', '2026-01-08 18:10:42', '15:30:00');
INSERT INTO `appointment` VALUES (171, 6, 232, '已取消', '2026-01-10 18:10:42', '11:00:00');
INSERT INTO `appointment` VALUES (176, 1, 238, '已取消', '2026-01-11 18:10:42', '15:00:00');
INSERT INTO `appointment` VALUES (183, 13, 245, '已完成', '2026-01-11 18:10:42', '15:45:00');
INSERT INTO `appointment` VALUES (189, 10, 254, '已完成', '2026-01-10 18:10:42', '09:45:00');
INSERT INTO `appointment` VALUES (190, 2, 255, '已取消', '2026-01-11 18:10:42', '17:30:00');
INSERT INTO `appointment` VALUES (202, 12, 273, '已完成', '2026-01-10 18:10:42', '08:45:00');
INSERT INTO `appointment` VALUES (205, 4, 276, '已取消', '2026-01-11 18:10:42', '09:00:00');
INSERT INTO `appointment` VALUES (210, 8, 282, '已完成', '2026-01-09 18:10:42', '11:00:00');
INSERT INTO `appointment` VALUES (211, 5, 283, '已过期', '2026-01-11 18:10:42', '08:15:00');
INSERT INTO `appointment` VALUES (217, 9, 291, '已取消', '2026-01-09 18:10:42', '09:45:00');
INSERT INTO `appointment` VALUES (239, 4, 325, '已取消', '2026-01-09 18:10:42', '16:00:00');
INSERT INTO `appointment` VALUES (240, 1, 327, '已完成', '2026-01-10 18:10:42', '10:00:00');
INSERT INTO `appointment` VALUES (260, 14, 354, '已取消', '2026-01-09 18:10:42', '09:30:00');
INSERT INTO `appointment` VALUES (270, 11, 368, '已取消', '2026-01-10 18:10:42', '09:30:00');
INSERT INTO `appointment` VALUES (271, 5, 369, '已过期', '2026-01-09 18:10:42', '17:15:00');
INSERT INTO `appointment` VALUES (295, 12, 404, '已完成', '2026-01-08 18:10:42', '11:30:00');
INSERT INTO `appointment` VALUES (302, 7, 416, '已过期', '2026-01-11 18:10:42', '17:45:00');
INSERT INTO `appointment` VALUES (305, 9, 420, '已取消', '2026-01-09 18:10:42', '10:15:00');
INSERT INTO `appointment` VALUES (308, 6, 425, '已取消', '2026-01-10 18:10:42', '08:45:00');
INSERT INTO `appointment` VALUES (320, 5, 446, '已完成', '2026-01-07 18:10:42', '10:45:00');
INSERT INTO `appointment` VALUES (324, 2, 450, '已完成', '2026-01-09 18:10:42', '16:15:00');
INSERT INTO `appointment` VALUES (328, 10, 455, '已过期', '2026-01-10 18:10:42', '11:00:00');
INSERT INTO `appointment` VALUES (329, 13, 456, '已取消', '2026-01-10 18:10:42', '14:15:00');
INSERT INTO `appointment` VALUES (351, 11, 485, '已过期', '2026-01-11 18:10:42', '10:15:00');
INSERT INTO `appointment` VALUES (362, 10, 501, '已过期', '2026-01-10 18:10:42', '16:30:00');
INSERT INTO `appointment` VALUES (391, 10, 537, '已过期', '2026-01-09 18:10:43', '10:00:00');
INSERT INTO `appointment` VALUES (410, 3, 569, '已过期', '2026-01-07 18:10:43', '17:00:00');
INSERT INTO `appointment` VALUES (421, 14, 583, '已过期', '2026-01-08 18:10:43', '08:30:00');
INSERT INTO `appointment` VALUES (422, 5, 584, '已取消', '2026-01-08 18:10:43', '09:30:00');
INSERT INTO `appointment` VALUES (423, 13, 586, '已取消', '2026-01-08 18:10:43', '14:00:00');
INSERT INTO `appointment` VALUES (442, 2, 613, '已取消', '2026-01-10 18:10:43', '17:15:00');
INSERT INTO `appointment` VALUES (445, 6, 617, '已取消', '2026-01-10 18:10:43', '12:45:00');
INSERT INTO `appointment` VALUES (448, 7, 621, '已完成', '2026-01-11 18:10:43', '17:15:00');
INSERT INTO `appointment` VALUES (461, 13, 640, '已取消', '2026-01-11 18:10:43', '11:15:00');
INSERT INTO `appointment` VALUES (464, 7, 644, '已取消', '2026-01-10 18:10:43', '14:45:00');
INSERT INTO `appointment` VALUES (465, 14, 645, '已过期', '2026-01-10 18:10:43', '17:30:00');
INSERT INTO `appointment` VALUES (470, 7, 651, '已过期', '2026-01-08 18:10:43', '12:15:00');
INSERT INTO `appointment` VALUES (479, 7, 663, '已过期', '2026-01-11 18:10:43', '13:00:00');
INSERT INTO `appointment` VALUES (480, 10, 664, '已过期', '2026-01-09 18:10:43', '14:45:00');
INSERT INTO `appointment` VALUES (501, 11, 693, '已完成', '2026-01-09 18:10:43', '12:45:00');
INSERT INTO `appointment` VALUES (505, 12, 697, '已过期', '2026-01-10 18:10:43', '15:45:00');
INSERT INTO `appointment` VALUES (507, 8, 700, '已过期', '2026-01-09 18:10:43', '13:15:00');
INSERT INTO `appointment` VALUES (518, 6, 713, '已完成', '2026-01-10 18:10:43', '09:00:00');
INSERT INTO `appointment` VALUES (519, 14, 714, '已过期', '2026-01-10 18:10:43', '15:45:00');
INSERT INTO `appointment` VALUES (541, 13, 741, '已过期', '2026-01-11 18:10:43', '08:15:00');
INSERT INTO `appointment` VALUES (556, 6, 762, '已取消', '2026-01-11 18:10:43', '08:45:00');
INSERT INTO `appointment` VALUES (564, 8, 774, '已取消', '2026-01-10 18:10:43', '09:30:00');
INSERT INTO `appointment` VALUES (573, 5, 787, '已过期', '2026-01-08 18:10:43', '14:00:00');
INSERT INTO `appointment` VALUES (581, 9, 797, '已过期', '2026-01-07 18:10:43', '13:00:00');
INSERT INTO `appointment` VALUES (607, 14, 829, '已过期', '2026-01-09 18:10:43', '16:45:00');
INSERT INTO `appointment` VALUES (611, 5, 834, '已过期', '2026-01-07 18:10:43', '09:00:00');
INSERT INTO `appointment` VALUES (615, 13, 838, '已取消', '2026-01-09 18:10:43', '15:30:00');
INSERT INTO `appointment` VALUES (618, 4, 845, '已取消', '2026-01-11 18:10:43', '16:15:00');
INSERT INTO `appointment` VALUES (627, 8, 857, '已完成', '2026-01-10 18:10:43', '11:00:00');
INSERT INTO `appointment` VALUES (674, 10, 913, '已过期', '2026-01-10 18:10:43', '08:30:00');
INSERT INTO `appointment` VALUES (675, 8, 914, '已完成', '2026-01-11 18:10:43', '12:15:00');
INSERT INTO `appointment` VALUES (701, 2, 945, '已取消', '2026-01-09 18:10:43', '17:00:00');
INSERT INTO `appointment` VALUES (711, 3, 959, '已过期', '2026-01-10 18:10:43', '15:45:00');
INSERT INTO `appointment` VALUES (717, 7, 968, '已完成', '2026-01-11 18:10:43', '08:00:00');
INSERT INTO `appointment` VALUES (722, 5, 975, '已取消', '2026-01-08 18:10:43', '10:30:00');
INSERT INTO `appointment` VALUES (726, 1, 986, '已取消', '2026-01-08 18:10:43', '11:00:00');
INSERT INTO `appointment` VALUES (742, 12, 1009, '已过期', '2026-01-11 18:10:43', '10:00:00');
INSERT INTO `appointment` VALUES (755, 13, 1030, '已完成', '2026-01-10 18:10:43', '17:00:00');
INSERT INTO `appointment` VALUES (756, 5, 1032, '已取消', '2026-01-11 18:10:43', '14:30:00');
INSERT INTO `appointment` VALUES (761, 11, 1037, '已取消', '2026-01-11 18:10:43', '16:15:00');
INSERT INTO `appointment` VALUES (768, 4, 1044, '已过期', '2026-01-11 18:10:43', '15:30:00');
INSERT INTO `appointment` VALUES (784, 14, 1073, '已完成', '2026-01-08 18:10:43', '12:00:00');
INSERT INTO `appointment` VALUES (787, 14, 1079, '已过期', '2026-01-09 18:10:43', '16:45:00');
INSERT INTO `appointment` VALUES (792, 14, 1088, '已取消', '2026-01-10 18:10:43', '09:15:00');
INSERT INTO `appointment` VALUES (807, 11, 1108, '已过期', '2026-01-10 18:10:43', '14:00:00');
INSERT INTO `appointment` VALUES (809, 3, 1110, '已过期', '2026-01-08 18:10:43', '11:45:00');
INSERT INTO `appointment` VALUES (813, 5, 1115, '已过期', '2026-01-07 18:10:43', '09:00:00');
INSERT INTO `appointment` VALUES (816, 7, 1118, '已完成', '2026-01-09 18:10:43', '14:00:00');
INSERT INTO `appointment` VALUES (824, 8, 1127, '已过期', '2026-01-11 18:10:43', '17:00:00');
INSERT INTO `appointment` VALUES (829, 3, 1132, '已完成', '2026-01-10 18:10:43', '17:30:00');
INSERT INTO `appointment` VALUES (850, 2, 1160, '已过期', '2026-01-10 18:10:43', '10:30:00');
INSERT INTO `appointment` VALUES (852, 4, 1163, '已完成', '2026-01-10 18:10:43', '10:30:00');
INSERT INTO `appointment` VALUES (865, 1, 1185, '已取消', '2026-01-10 18:10:43', '12:00:00');
INSERT INTO `appointment` VALUES (866, 11, 1186, '已过期', '2026-01-10 18:10:43', '08:15:00');
INSERT INTO `appointment` VALUES (868, 2, 1188, '已完成', '2026-01-09 18:10:43', '09:15:00');
INSERT INTO `appointment` VALUES (869, 2, 1189, '已完成', '2026-01-09 18:10:43', '16:00:00');
INSERT INTO `appointment` VALUES (870, 9, 1190, '已完成', '2026-01-08 18:10:43', '14:45:00');
INSERT INTO `appointment` VALUES (879, 3, 1200, '已完成', '2026-01-08 18:10:43', '15:30:00');
INSERT INTO `appointment` VALUES (896, 1, 1223, '已取消', '2026-01-10 18:10:43', '12:45:00');
INSERT INTO `appointment` VALUES (900, 13, 1230, '已取消', '2026-01-11 18:10:43', '14:30:00');
INSERT INTO `appointment` VALUES (903, 1, 1234, '已完成', '2026-01-09 18:10:43', '15:15:00');
INSERT INTO `appointment` VALUES (912, 5, 1246, '已取消', '2026-01-11 18:10:43', '08:45:00');
INSERT INTO `appointment` VALUES (917, 2, 1253, '已完成', '2026-01-10 18:10:43', '08:00:00');
INSERT INTO `appointment` VALUES (919, 6, 1257, '已过期', '2026-01-10 18:10:43', '09:45:00');
INSERT INTO `appointment` VALUES (922, 4, 1261, '已完成', '2026-01-11 18:10:43', '10:15:00');
INSERT INTO `appointment` VALUES (929, 9, 1273, '已取消', '2026-01-10 18:10:43', '17:00:00');
INSERT INTO `appointment` VALUES (942, 6, 1287, '已过期', '2026-01-09 18:10:43', '10:30:00');
INSERT INTO `appointment` VALUES (950, 3, 1300, '已过期', '2026-01-10 18:10:43', '17:45:00');
INSERT INTO `appointment` VALUES (952, 14, 1302, '已过期', '2026-01-10 18:10:43', '14:15:00');
INSERT INTO `appointment` VALUES (957, 9, 1309, '已过期', '2026-01-09 18:10:43', '16:15:00');
INSERT INTO `appointment` VALUES (968, 10, 1323, '已完成', '2026-01-11 18:10:43', '14:30:00');
INSERT INTO `appointment` VALUES (978, 4, 1338, '已完成', '2026-01-11 18:10:43', '13:15:00');
INSERT INTO `appointment` VALUES (992, 9, 1361, '已取消', '2026-01-11 18:10:43', '16:30:00');
INSERT INTO `appointment` VALUES (1003, 9, 1377, '已完成', '2026-01-11 18:10:43', '17:00:00');
INSERT INTO `appointment` VALUES (1012, 11, 1393, '已取消', '2026-01-09 18:10:43', '11:30:00');
INSERT INTO `appointment` VALUES (1017, 8, 1398, '已过期', '2026-01-09 18:10:43', '08:45:00');
INSERT INTO `appointment` VALUES (1030, 4, 1419, '已完成', '2026-01-11 18:10:43', '11:00:00');
INSERT INTO `appointment` VALUES (1037, 12, 1429, '已完成', '2026-01-11 18:10:43', '16:00:00');
INSERT INTO `appointment` VALUES (1041, 7, 1433, '已完成', '2026-01-10 18:10:43', '09:15:00');
INSERT INTO `appointment` VALUES (1056, 12, 1450, '已完成', '2026-01-08 18:10:43', '09:30:00');
INSERT INTO `appointment` VALUES (1061, 1, 1458, '已取消', '2026-01-09 18:10:43', '11:15:00');
INSERT INTO `appointment` VALUES (1084, 10, 1487, '已过期', '2026-01-11 18:10:43', '16:00:00');
INSERT INTO `appointment` VALUES (1090, 4, 1496, '已完成', '2026-01-10 18:10:43', '09:15:00');
INSERT INTO `appointment` VALUES (1095, 12, 1501, '已过期', '2026-01-08 18:10:43', '08:00:00');
INSERT INTO `appointment` VALUES (1101, 3, 1509, '已取消', '2026-01-11 18:10:43', '08:45:00');
INSERT INTO `appointment` VALUES (1112, 6, 1528, '已取消', '2026-01-11 18:10:43', '17:15:00');
INSERT INTO `appointment` VALUES (1117, 3, 1537, '已过期', '2026-01-10 18:10:43', '08:15:00');
INSERT INTO `appointment` VALUES (1128, 1, 1549, '已取消', '2026-01-09 18:10:43', '13:15:00');
INSERT INTO `appointment` VALUES (1143, 10, 1568, '已取消', '2026-01-10 18:10:43', '09:30:00');
INSERT INTO `appointment` VALUES (1146, 6, 1573, '已完成', '2026-01-10 18:10:43', '09:45:00');
INSERT INTO `appointment` VALUES (1158, 11, 1587, '已过期', '2026-01-10 18:10:43', '08:30:00');
INSERT INTO `appointment` VALUES (1180, 6, 1617, '已过期', '2026-01-11 18:10:43', '08:45:00');
INSERT INTO `appointment` VALUES (1183, 14, 1622, '已完成', '2026-01-11 18:10:43', '10:45:00');
INSERT INTO `appointment` VALUES (1191, 12, 1632, '已取消', '2026-01-10 18:10:43', '17:00:00');
INSERT INTO `appointment` VALUES (1196, 3, 1638, '已过期', '2026-01-10 18:10:43', '09:30:00');
INSERT INTO `appointment` VALUES (1207, 11, 1650, '已取消', '2026-01-10 18:10:43', '15:15:00');
INSERT INTO `appointment` VALUES (1217, 12, 1668, '已完成', '2026-01-09 18:10:43', '13:30:00');
INSERT INTO `appointment` VALUES (1233, 7, 1689, '已完成', '2026-01-10 18:10:43', '16:45:00');
INSERT INTO `appointment` VALUES (1234, 1, 1635, '已取消', '2026-01-11 21:14:07', '15:45:00');
INSERT INTO `appointment` VALUES (1235, 1, 1651, '已取消', '2026-01-11 21:14:20', '11:15:00');
INSERT INTO `appointment` VALUES (1236, 1, 1575, '已取消', '2026-01-11 21:15:19', '17:15:00');
INSERT INTO `appointment` VALUES (1237, 1, 9, '已过期', '2026-01-11 21:46:13', '15:15:00');
INSERT INTO `appointment` VALUES (1239, 1, 8, '已过期', '2026-01-11 22:42:08', '11:15:00');
INSERT INTO `appointment` VALUES (1240, 1, 7, '已取消', '2026-01-13 01:28:45', '08:45:00');
INSERT INTO `appointment` VALUES (1241, 1, 66, '已取消', '2026-01-13 02:18:22', '08:30:00');

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
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '科室信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of department
-- ----------------------------
INSERT INTO `department` VALUES (1, '内科', '2026-01-09 02:44:31');
INSERT INTO `department` VALUES (2, '外科', '2026-01-09 02:44:31');
INSERT INTO `department` VALUES (3, '儿科', '2026-01-09 02:44:31');
INSERT INTO `department` VALUES (4, '妇科', '2026-01-09 02:44:31');
INSERT INTO `department` VALUES (5, '眼科', '2026-01-09 02:44:31');
INSERT INTO `department` VALUES (6, '骨科', '2026-01-11 10:00:00');
INSERT INTO `department` VALUES (7, '皮肤科', '2026-01-11 10:00:00');
INSERT INTO `department` VALUES (8, '耳鼻喉科', '2026-01-11 10:00:00');
INSERT INTO `department` VALUES (9, '口腔科', '2026-01-11 10:00:00');
INSERT INTO `department` VALUES (10, '中医科', '2026-01-11 10:00:00');
INSERT INTO `department` VALUES (11, '神经内科', '2026-01-11 10:00:00');
INSERT INTO `department` VALUES (12, '心血管科', '2026-01-11 10:00:00');
INSERT INTO `department` VALUES (13, '消化内科', '2026-01-11 10:00:00');
INSERT INTO `department` VALUES (14, '呼吸科', '2026-01-11 10:00:00');
INSERT INTO `department` VALUES (15, '内分泌科', '2026-01-11 10:00:00');

-- ----------------------------
-- Table structure for department_intro
-- ----------------------------
DROP TABLE IF EXISTS `department_intro`;
CREATE TABLE `department_intro`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '说明ID',
  `dept_id` int(11) NOT NULL COMMENT '科室ID',
  `overview` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '科室概述',
  `detailed_intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '详细科室说明',
  `services` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '主要服务项目',
  `features` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '科室特色',
  `notice` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '就诊须知',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用(1是,0否)',
  `created_by` int(11) NULL DEFAULT NULL COMMENT '创建人ID(关联admin.id)',
  `updated_by` int(11) NULL DEFAULT NULL COMMENT '最后更新人ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_dept_id`(`dept_id`) USING BTREE,
  INDEX `created_by`(`created_by`) USING BTREE,
  INDEX `updated_by`(`updated_by`) USING BTREE,
  CONSTRAINT `department_intro_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `department` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `department_intro_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `admin` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `department_intro_ibfk_3` FOREIGN KEY (`updated_by`) REFERENCES `admin` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '科室说明表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of department_intro
-- ----------------------------
INSERT INTO `department_intro` VALUES (1, 1, '内科疾病诊治中心', '内科是医院的核心科室之一，专注于各种内科疾病的诊断和治疗。我们拥有先进的医疗设备和经验丰富的医疗团队，为患者提供全面的内科医疗服务。', '高血压、糖尿病、冠心病、呼吸道疾病、消化系统疾病、内分泌疾病等内科常见病和多发病的诊治', '拥有先进的检查设备，提供个性化治疗方案，注重慢性病管理', '请携带相关检查报告，空腹就诊需提前告知', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (2, 2, '外科手术专业团队', '外科是医院的重点科室，开展各类外科手术。科室技术力量雄厚，手术成功率高，术后康复指导完善。', '普外科手术、骨科手术、神经外科手术、胸外科手术、泌尿外科手术等', '微创手术技术领先，快速康复理念，多学科协作', '手术前需完成相关检查，遵守术前禁食要求', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (3, 3, '儿童健康守护专家', '儿科专注于0-14岁儿童的疾病防治和健康管理。科室环境温馨，医护人员耐心细致，深受家长信赖。', '儿童常见病诊治、预防接种、生长发育评估、营养指导、儿童保健', '儿童专用诊疗区，游戏化就诊环境，专业儿童心理疏导', '请携带儿童健康手册，一名患儿限两名家长陪同', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (4, 4, '女性健康专业关怀', '妇科致力于女性生殖系统疾病的预防、诊断和治疗。注重保护患者隐私，提供人性化服务。', '妇科炎症、月经不调、不孕不育、妇科肿瘤、更年期保健', '无痛诊疗技术，私密诊疗空间，全程陪护服务', '就诊请避开月经期，需提前预约特殊检查', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (5, 5, '视力健康守护者', '眼科拥有先进的眼科设备，开展各种眼部疾病的诊断和治疗手术，帮助患者重获清晰视界。', '近视矫正、白内障手术、青光眼治疗、眼底病诊治、眼表疾病', '飞秒激光手术，日间手术模式，个性化视力矫正', '散瞳检查后不宜驾驶，请安排陪同人员', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (6, 6, '骨骼健康专业维护', '骨科专注于骨骼、关节、肌肉等运动系统疾病的诊治，拥有先进的康复设备和完善的治疗体系。', '骨折治疗、关节置换、脊柱疾病、运动损伤、骨质疏松', '微创骨科手术，快速康复流程，个性化康复计划', '外伤患者优先就诊，请携带影像学资料', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (7, 7, '皮肤健康美丽专家', '皮肤科诊治各种皮肤病和性病，同时开展医疗美容服务，帮助患者恢复皮肤健康与美丽。', '湿疹、痤疮、银屑病、白癜风、皮肤肿瘤、医学美容', '光动力治疗，皮肤外科手术，中医外治疗法', '治疗前需清洁皮肤，避免使用化妆品', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (8, 8, '耳鼻喉健康专诊', '耳鼻喉科专业诊治耳、鼻、咽喉相关疾病，拥有先进的内窥镜系统和听力检测设备。', '鼻炎、中耳炎、咽喉炎、听力障碍、头颈肿瘤', '鼻内镜手术，听力重建，嗓音康复训练', '检查前需清理鼻腔，听力检查需安静环境', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (9, 9, '口腔健康微笑中心', '口腔科提供全面的口腔疾病诊治和预防保健服务，拥有数字化的诊疗设备和技术。', '牙病治疗、牙齿矫正、种植牙、牙齿美白、口腔保健', '数字化种植，隐形矫正，无痛治疗技术', '就诊前请清洁口腔，复杂治疗需预约', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (10, 10, '传统医学养生之道', '中医科秉承传统医学精髓，结合现代诊疗技术，为患者提供个性化的中医治疗和养生指导。', '中医内科、针灸推拿、中药调理、养生保健、治未病', '名老中医坐诊，个体化配方，综合调理', '服用中药期间注意饮食禁忌，定期复诊', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (11, 11, '神经系统疾病专治', '神经内科专注于脑血管疾病、神经系统变性疾病等的诊治，拥有神经电生理等先进设备。', '脑卒中、癫痫、帕金森病、痴呆、头痛头晕', '卒中绿色通道，神经康复，远程会诊', '急症患者优先，请携带既往病历', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (12, 12, '心血管健康守护', '心血管科是医院的重点学科，在心血管疾病诊治方面具有丰富的经验和先进的技术。', '冠心病、高血压、心力衰竭、心律失常、心肌病', '心脏介入治疗，心脏康复，健康管理', '危重患者绿色通道，定期随访很重要', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (13, 13, '消化系统疾病专家', '消化内科专业诊治食管、胃、肠、肝、胆、胰等消化系统疾病，内镜技术领先。', '胃炎、溃疡病、肝炎、肝硬化、胰腺炎', '无痛胃肠镜，内镜下治疗，肝病综合治疗', '胃肠镜检查需空腹准备，按医嘱服药', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (14, 14, '呼吸系统疾病防治', '呼吸科在呼吸道感染、慢性肺病等诊治方面经验丰富，设有呼吸重症监护室。', '肺炎、哮喘、慢阻肺、肺癌、呼吸衰竭', '呼吸支持技术，肺康复，戒烟指导', '呼吸道传染病需隔离诊疗，佩戴口罩', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');
INSERT INTO `department_intro` VALUES (15, 15, '内分泌代谢病中心', '内分泌科专业诊治糖尿病、甲状腺疾病等内分泌代谢性疾病，开展患者教育。', '糖尿病、甲状腺病、骨质疏松、肥胖症', '糖尿病综合管理，甲状腺微创治疗', '血糖监测需空腹，定期复查指标', 1, 1, 1, '2026-01-11 19:06:05', '2026-01-11 19:06:05');

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
) ENGINE = InnoDB AUTO_INCREMENT = 71 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '医生信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctor
-- ----------------------------
INSERT INTO `doctor` VALUES (1, 1, 'doc1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张内科', '主任医师', 1, '2026-01-09 02:44:31');
INSERT INTO `doctor` VALUES (2, 2, 'doc_surgery', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李外科', '副主任医师', 1, '2026-01-09 02:44:31');
INSERT INTO `doctor` VALUES (3, 3, 'doc_pediatrics', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王儿科', '主治医师', 1, '2026-01-09 02:44:31');
INSERT INTO `doctor` VALUES (4, 1, 'doc_1_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '陈伟', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (5, 1, 'doc_1_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '黄勇', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (6, 1, 'doc_1_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王勇', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (7, 1, 'doc_1_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王洋', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (8, 2, 'doc_2_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵洋', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (9, 2, 'doc_2_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '刘勇', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (10, 2, 'doc_2_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '杨静', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (11, 2, 'doc_2_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '黄磊', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (12, 2, 'doc_2_5', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '陈洋', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (13, 3, 'doc_3_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王勇', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (14, 3, 'doc_3_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵强', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (15, 3, 'doc_3_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '周洋', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (16, 3, 'doc_3_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张勇', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (17, 3, 'doc_3_5', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '杨敏', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (18, 4, 'doc_4_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵洋', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (19, 4, 'doc_4_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张婷', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (20, 4, 'doc_4_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵婷', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (21, 4, 'doc_4_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王伟', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (22, 5, 'doc_5_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '吴婷', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (23, 5, 'doc_5_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '黄娜', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (24, 5, 'doc_5_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '周杰', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (25, 5, 'doc_5_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵婷', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (26, 6, 'doc_6_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李伟', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (27, 6, 'doc_6_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '黄勇', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (28, 6, 'doc_6_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张强', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (29, 6, 'doc_6_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李婷', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (30, 6, 'doc_6_5', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王洋', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (31, 7, 'doc_7_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张强', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (32, 7, 'doc_7_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '吴静', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (33, 7, 'doc_7_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '黄洋', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (34, 7, 'doc_7_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张伟', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (35, 7, 'doc_7_5', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵敏', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (36, 8, 'doc_8_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵勇', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (37, 8, 'doc_8_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '黄洋', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (38, 8, 'doc_8_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王娜', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (39, 9, 'doc_9_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李洋', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (40, 9, 'doc_9_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张静', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (41, 9, 'doc_9_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '吴伟', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (42, 10, 'doc_10_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张强', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (43, 10, 'doc_10_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王婷', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (44, 10, 'doc_10_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '陈静', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (45, 10, 'doc_10_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '黄磊', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (46, 10, 'doc_10_5', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵杰', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (47, 11, 'doc_11_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '黄洋', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (48, 11, 'doc_11_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵洋', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (49, 11, 'doc_11_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵磊', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (50, 11, 'doc_11_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李娜', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (51, 11, 'doc_11_5', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '黄磊', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (52, 12, 'doc_12_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '陈静', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (53, 12, 'doc_12_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王洋', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (54, 12, 'doc_12_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李磊', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (55, 12, 'doc_12_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '吴娜', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (56, 13, 'doc_13_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '刘勇', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (57, 13, 'doc_13_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '吴磊', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (58, 13, 'doc_13_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '周磊', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (59, 13, 'doc_13_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '陈洋', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (60, 13, 'doc_13_5', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张洋', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (61, 14, 'doc_14_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '杨磊', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (62, 14, 'doc_14_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵杰', '\"主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (63, 14, 'doc_14_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王伟', '\"住院医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (64, 14, 'doc_14_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵洋', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (65, 14, 'doc_14_5', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '陈洋', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (66, 15, 'doc_15_1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '周洋', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (67, 15, 'doc_15_2', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '刘勇', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (68, 15, 'doc_15_3', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王勇', '\"主治医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (69, 15, 'doc_15_4', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王杰', '\"副主任医师\"', 1, '2026-01-11 18:09:43');
INSERT INTO `doctor` VALUES (70, 15, 'doc_15_5', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '杨磊', '\"住院医师\"', 1, '2026-01-11 18:09:43');

-- ----------------------------
-- Table structure for hospital_notice
-- ----------------------------
DROP TABLE IF EXISTS `hospital_notice`;
CREATE TABLE `hospital_notice`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知内容',
  `notice_type` enum('系统公告','医院动态','停诊通知','政策法规','温馨提示') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '系统公告' COMMENT '通知类型',
  `target_audience` enum('全部','患者','医生','管理员') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '全部' COMMENT '目标受众',
  `priority` enum('普通','重要','紧急') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '普通' COMMENT '优先级',
  `publish_time` datetime NOT NULL COMMENT '发布时间',
  `expire_time` datetime NULL DEFAULT NULL COMMENT '过期时间',
  `is_top` tinyint(1) NULL DEFAULT 0 COMMENT '是否置顶(1是,0否)',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否有效(1是,0否)',
  `view_count` int(11) NULL DEFAULT 0 COMMENT '查看次数',
  `publisher_id` int(11) NOT NULL COMMENT '发布人ID(关联admin.id)',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `publisher_id`(`publisher_id`) USING BTREE,
  INDEX `idx_publish_time`(`publish_time`) USING BTREE,
  INDEX `idx_notice_type`(`notice_type`) USING BTREE,
  INDEX `idx_target_audience`(`target_audience`) USING BTREE,
  INDEX `idx_priority`(`priority`) USING BTREE,
  INDEX `idx_is_top`(`is_top`) USING BTREE,
  INDEX `idx_is_active`(`is_active`) USING BTREE,
  CONSTRAINT `hospital_notice_ibfk_1` FOREIGN KEY (`publisher_id`) REFERENCES `admin` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '医院通知表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of hospital_notice
-- ----------------------------
INSERT INTO `hospital_notice` VALUES (1, '春节假期门诊安排通知', '根据国家法定节假日安排，我院2026年春节假期门诊时间调整如下：2月7日-2月13日放假调休，共7天。2月6日（星期六）、2月14日（星期日）正常上班。急诊24小时开放。祝大家春节快乐！', '停诊通知', '全部', '重要', '2026-01-15 09:00:00', '2026-02-15 23:59:59', 1, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (2, '新引进256排CT投入使用', '我院最新引进的256排螺旋CT已正式投入使用，该设备具有扫描速度快、图像清晰、辐射剂量低等优点，将极大提升诊疗水平。欢迎有需要的患者前来检查。', '医院动态', '全部', '普通', '2026-01-20 14:30:00', '2026-02-20 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (3, '医保电子凭证使用指南', '自2026年2月1日起，我院全面支持医保电子凭证结算。患者可通过国家医保服务平台APP、支付宝、微信等渠道激活使用，实现无卡就医，方便快捷。', '政策法规', '患者', '重要', '2026-01-25 10:00:00', '2026-12-31 23:59:59', 1, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (4, '预防流感健康讲座通知', '我院将于2026年2月8日下午2点在门诊大楼5楼会议厅举办\"冬季流感预防与治疗\"健康讲座，由呼吸科主任医师主讲，欢迎广大市民参加。', '医院动态', '患者', '普通', '2026-01-28 15:00:00', '2026-02-08 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (5, '系统维护通知', '为提升服务质量，医院信息系统将于2026年2月5日（周五）22:00至2月6日（周六）06:00进行维护，期间预约、挂号等功能可能受影响，敬请谅解。', '系统公告', '全部', '普通', '2026-01-30 16:00:00', '2026-02-06 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (6, '专家门诊时间调整', '因学术会议安排，张伟主任医师（心血管科）2月10日专家门诊暂停一次，2月17日恢复正常。李敏副主任医师（儿科）2月12日上午门诊调至2月14日下午。', '停诊通知', '患者', '重要', '2026-02-01 09:30:00', '2026-02-28 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (7, '疫情防控重要提醒', '当前处于呼吸道传染病高发季节，请来院患者及家属全程佩戴口罩，配合体温检测，保持安全距离。有发热、咳嗽等症状请主动告知预检分诊人员。', '温馨提示', '全部', '紧急', '2026-02-03 08:00:00', '2026-03-31 23:59:59', 1, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (8, '新停车场投入使用', '医院新建地下停车场已于2026年2月1日正式投入使用，新增车位200个，实行智能化管理。前30分钟免费，后续按标准收费。', '医院动态', '全部', '普通', '2026-02-01 10:00:00', '2026-03-01 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (9, '糖尿病俱乐部活动通知', '糖尿病俱乐部定于2026年2月15日下午2点举办\"糖尿病饮食管理\"主题活动，届时将有营养师现场指导，欢迎糖友参加。', '医院动态', '患者', '普通', '2026-02-05 14:00:00', '2026-02-15 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (10, '医疗收费标准公示', '根据市卫健委要求，我院2026年度医疗服务价格标准已更新，具体收费标准详见门诊大厅公示栏或医院官方网站。', '政策法规', '全部', '重要', '2026-01-01 00:00:00', '2026-12-31 23:59:59', 0, 1, 3, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (11, '志愿者招募公告', '我院现面向社会招募医疗志愿者，要求年龄18-65岁，身体健康，有爱心和责任心。报名时间：即日起至2月28日。', '医院动态', '全部', '普通', '2026-02-10 09:00:00', '2026-02-28 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (12, '孕妇学校开课通知', '孕妇学校2026年春季班将于2月20日开课，课程内容包括孕期保健、分娩准备、新生儿护理等。欢迎准爸妈报名参加。', '医院动态', '患者', '普通', '2026-02-12 10:00:00', '2026-02-20 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (13, '医疗质量安全月活动', '我院将于3月开展\"医疗质量安全月\"活动，期间将组织多项质量改进措施和患者安全教育活动，欢迎监督。', '医院动态', '全部', '重要', '2026-02-25 15:00:00', '2026-03-31 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (14, '远程会诊服务开通', '我院已开通与北京、上海等多家顶级医院的远程会诊服务，疑难重症患者可申请专家远程会诊。详情咨询医务科。', '医院动态', '患者', '重要', '2026-02-18 11:00:00', '2026-12-31 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (15, '医院APP新版上线', '我院官方APP3.0版本已上线，新增智能导诊、检查报告推送、用药提醒等功能，欢迎下载使用。', '系统公告', '患者', '普通', '2026-02-22 14:00:00', '2026-03-22 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (16, '爱心献血活动通知', '我院将于2026年3月1日联合市中心血站开展无偿献血活动，地点：门诊楼前广场。献血有益健康，欢迎参与。', '医院动态', '全部', '普通', '2026-02-28 09:00:00', '2026-03-01 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (17, '医保政策调整说明', '根据最新医保政策，2026年3月1日起部分药品和诊疗项目报销比例有所调整，具体变化请咨询医保办。', '政策法规', '患者', '重要', '2026-02-15 16:00:00', '2026-03-31 23:59:59', 1, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (18, '医院环境改造公告', '为改善就诊环境，医院将于2026年3月进行部分区域装修改造，施工期间可能产生噪音，敬请谅解。', '温馨提示', '全部', '普通', '2026-02-20 08:30:00', '2026-03-31 23:59:59', 0, 1, 0, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (19, '专家义诊活动预告', '为庆祝建院70周年，我院将于2026年3月15日举办大型专家义诊活动，届时各科专家将免费为市民提供咨询服务。', '医院动态', '患者', '重要', '2026-03-01 10:00:00', '2026-03-15 23:59:59', 1, 1, 2, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');
INSERT INTO `hospital_notice` VALUES (20, '医疗投诉渠道公示', '为更好服务患者，现将医疗投诉渠道公示：投诉电话：XXXX-XXXXXXX，投诉邮箱：ts@hospital.com，现场投诉：医患关系办公室。', '政策法规', '患者', '普通', '2026-01-10 09:00:00', '2026-12-31 23:59:59', 0, 1, 3, 1, '2026-01-11 19:06:11', '2026-01-11 19:06:11');

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
) ENGINE = InnoDB AUTO_INCREMENT = 430 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '电子病历表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of medical_record
-- ----------------------------
INSERT INTO `medical_record` VALUES (3, 3, 1, 1, '支气管炎', '左氧氟沙星片 0.5g，每日一次，连续7天；氨溴索口服液 10ml，每日三次', '保持室内空气流通，避免冷空气刺激', '2026-01-10 09:00:00', '2026-01-09 22:48:13');
INSERT INTO `medical_record` VALUES (6, 6, 2, 3, '小儿过敏性鼻炎', '氯雷他定片 10mg，每日一次，连续14天；生理盐水鼻腔喷雾器清洗，每日两次', '避免接触过敏原，保持室内清洁', '2026-01-11 09:00:00', '2026-01-09 22:48:13');
INSERT INTO `medical_record` VALUES (33, 66, 13, 26, '近视', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (36, 73, 2, 41, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (53, 110, 3, 33, '关节炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (57, 129, 8, 66, '糖尿病', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (60, 142, 4, 17, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (71, 183, 13, 10, '牙周炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (73, 189, 10, 19, '牙周炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (75, 202, 12, 39, '近视', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (76, 210, 8, 52, '胃炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-09 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (86, 240, 1, 37, '上呼吸道感染', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (102, 295, 12, 10, '感冒', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-08 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (110, 320, 5, 69, '上呼吸道感染', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-07 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (113, 324, 2, 3, '近视', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-09 18:10:42', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (155, 448, 7, 7, '胃炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:43');
INSERT INTO `medical_record` VALUES (170, 501, 11, 27, '感冒', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-09 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (174, 518, 6, 49, '近视', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (211, 627, 8, 19, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (230, 675, 8, 17, '近视', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (241, 717, 7, 7, '糖尿病', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (258, 755, 13, 13, '牙周炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (268, 784, 14, 64, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-08 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (276, 816, 7, 51, '近视', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-09 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (280, 829, 3, 69, '近视', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (288, 852, 4, 33, '近视', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (292, 868, 2, 67, '胃炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-09 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (293, 869, 2, 68, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-09 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (294, 870, 9, 69, '牙周炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-08 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (295, 879, 3, 11, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-08 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (302, 903, 1, 55, '感冒', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-09 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (305, 917, 2, 11, '关节炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (307, 922, 4, 23, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (323, 968, 10, 23, '牙周炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (329, 978, 4, 43, '牙周炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (339, 1003, 9, 21, '皮肤病', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (352, 1030, 4, 10, '皮肤病', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (355, 1037, 12, 23, '关节炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (358, 1041, 7, 30, '胃炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (363, 1056, 12, 48, '关节炎', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-08 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (373, 1090, 4, 43, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (389, 1146, 6, 69, '感冒', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (404, 1183, 14, 55, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-11 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (417, 1217, 12, 44, '高血压', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-09 18:10:43', '2026-01-11 18:12:44');
INSERT INTO `medical_record` VALUES (423, 1233, 7, 70, '皮肤病', '根据病情开具相应药物', '定期复查，如有不适随诊', '2026-01-10 18:10:43', '2026-01-11 18:12:44');

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
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否启用(1启用,0禁用)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE,
  UNIQUE INDEX `id_card`(`id_card`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '患者信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of patient
-- ----------------------------
INSERT INTO `patient` VALUES (1, 'patient1', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵患者1', '13800138000', '110101199001011234', NULL, '2026-01-09 02:44:31', 1);
INSERT INTO `patient` VALUES (2, 'patient002', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '钱患者', '13900139000', '110101199505055678', NULL, '2026-01-09 02:44:31', 1);
INSERT INTO `patient` VALUES (3, 'wangwei', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王伟', '13800138001', '110101198501011234', NULL, '2026-01-11 10:00:00', 1);
INSERT INTO `patient` VALUES (4, 'liming', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李明', '13800138002', '110101199002022345', NULL, '2026-01-11 10:00:00', 1);
INSERT INTO `patient` VALUES (5, 'zhangwei', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张伟', '13800138003', '110101198803033456', NULL, '2026-01-11 10:00:00', 1);
INSERT INTO `patient` VALUES (6, 'liuyang', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '刘洋', '13800138004', '110101199504044567', NULL, '2026-01-11 10:00:00', 1);
INSERT INTO `patient` VALUES (7, 'chenmin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '陈敏', '13800138005', '110101198705055678', NULL, '2026-01-11 10:00:00', 1);
INSERT INTO `patient` VALUES (8, '张磊', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张磊', '13800138000', '110101198310151550', NULL, '2026-01-11 18:09:56', 1);
INSERT INTO `patient` VALUES (9, '李杰', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李杰', '13800138001', '110101198803100810', NULL, '2026-01-11 18:09:56', 1);
INSERT INTO `patient` VALUES (10, '赵洋', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵洋', '13800138002', '110101197001143685', NULL, '2026-01-11 18:09:56', 1);
INSERT INTO `patient` VALUES (11, '赵杰', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵杰', '13800138003', '110101200401190165', NULL, '2026-01-11 18:09:56', 1);
INSERT INTO `patient` VALUES (12, '王洋', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王洋', '13800138004', '110101196102115061', NULL, '2026-01-11 18:09:56', 1);
INSERT INTO `patient` VALUES (13, '刘娜', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '刘娜', '13800138005', '110101198402101623', NULL, '2026-01-11 18:09:56', 1);
INSERT INTO `patient` VALUES (14, '周洋', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '周洋', '13800138006', '110101198712035409', NULL, '2026-01-11 18:09:56', 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1690 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '医生排班表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of schedule
-- ----------------------------
INSERT INTO `schedule` VALUES (1, 1, '2026-01-09', '上午', 20, 20, '2026-01-09 02:44:31');
INSERT INTO `schedule` VALUES (2, 1, '2026-01-09', '下午', 20, 20, '2026-01-09 02:44:31');
INSERT INTO `schedule` VALUES (3, 2, '2026-01-10', '上午', 15, 15, '2026-01-09 02:44:31');
INSERT INTO `schedule` VALUES (4, 1, '2026-01-10', '上午', 20, 20, '2026-01-09 22:48:13');
INSERT INTO `schedule` VALUES (5, 2, '2026-01-10', '下午', 15, 15, '2026-01-09 22:48:13');
INSERT INTO `schedule` VALUES (6, 3, '2026-01-11', '全天', 10, 10, '2026-01-09 22:48:13');
INSERT INTO `schedule` VALUES (7, 1, '2026-01-12', '上午', 20, 19, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (8, 2, '2026-01-12', '上午', 20, 19, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (9, 3, '2026-01-12', '全天', 40, 39, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (10, 4, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (11, 5, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (12, 8, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (13, 10, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (14, 12, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (15, 13, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (16, 14, '2026-01-12', '上午', 20, 19, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (17, 16, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (18, 17, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (19, 18, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (20, 19, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (21, 20, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (22, 21, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (23, 22, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (24, 23, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (25, 24, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (26, 25, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (27, 26, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (28, 27, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (29, 28, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (30, 30, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (31, 31, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (32, 32, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (33, 33, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (34, 35, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (35, 36, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (36, 39, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (37, 40, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (38, 41, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (39, 42, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (40, 43, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (41, 44, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (42, 45, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (43, 46, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (44, 47, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (45, 48, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (46, 49, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (47, 50, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (48, 51, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (49, 52, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (50, 54, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (51, 55, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (52, 56, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (53, 57, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (54, 58, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (55, 59, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (56, 60, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (57, 61, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (58, 63, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (59, 64, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (60, 65, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (61, 66, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (62, 67, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (63, 68, '2026-01-12', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (64, 69, '2026-01-12', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (65, 70, '2026-01-12', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (66, 1, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (67, 2, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (68, 4, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (69, 5, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (70, 6, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (71, 7, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (72, 8, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (73, 9, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (74, 10, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (75, 14, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (76, 16, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (77, 17, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (78, 18, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (79, 19, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (80, 20, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (81, 21, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (82, 22, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (83, 23, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (84, 24, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (85, 25, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (86, 26, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (87, 27, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (88, 28, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (89, 29, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (90, 31, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (91, 32, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (92, 34, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (93, 36, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (94, 38, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (95, 40, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (96, 41, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (97, 42, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (98, 43, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (99, 44, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (100, 46, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (101, 47, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (102, 48, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (103, 49, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (104, 50, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (105, 51, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (106, 53, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (107, 56, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (108, 58, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (109, 59, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (110, 60, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (111, 61, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (112, 62, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (113, 63, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (114, 64, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (115, 65, '2026-01-13', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (116, 66, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (117, 67, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (118, 68, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (119, 69, '2026-01-13', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (120, 70, '2026-01-13', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (121, 1, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (122, 2, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (123, 3, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (124, 4, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (125, 6, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (126, 7, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (127, 8, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (128, 9, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (129, 10, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (130, 11, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (131, 12, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (132, 13, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (133, 14, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (134, 15, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (135, 16, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (136, 17, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (137, 18, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (138, 19, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (139, 20, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (140, 21, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (141, 22, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (142, 23, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (143, 25, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (144, 26, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (145, 27, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (146, 28, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (147, 29, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (148, 30, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (149, 31, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (150, 33, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (151, 34, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (152, 36, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (153, 37, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (154, 38, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (155, 40, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (156, 41, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (157, 42, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (158, 45, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (159, 47, '2026-01-14', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (160, 48, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (161, 49, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (162, 50, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (163, 52, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (164, 53, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (165, 54, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (166, 55, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (167, 56, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (168, 57, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (169, 58, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (170, 59, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (171, 62, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (172, 63, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (173, 64, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (174, 65, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (175, 66, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (176, 68, '2026-01-14', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (177, 69, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (178, 70, '2026-01-14', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (179, 2, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (180, 3, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (181, 4, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (182, 5, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (183, 6, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (184, 9, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (185, 10, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (186, 11, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (187, 12, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (188, 13, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (189, 16, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (190, 17, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (191, 19, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (192, 20, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (193, 21, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (194, 22, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (195, 24, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (196, 27, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (197, 28, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (198, 29, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (199, 30, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (200, 31, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (201, 32, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (202, 33, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (203, 34, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (204, 35, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (205, 37, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (206, 38, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (207, 39, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (208, 40, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (209, 41, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (210, 42, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (211, 43, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (212, 44, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (213, 45, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (214, 46, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (215, 47, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (216, 48, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (217, 49, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (218, 50, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (219, 51, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (220, 52, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (221, 53, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (222, 54, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (223, 56, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (224, 58, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (225, 59, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (226, 60, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (227, 61, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (228, 62, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (229, 63, '2026-01-15', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (230, 64, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (231, 65, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (232, 66, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (233, 67, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (234, 68, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (235, 69, '2026-01-15', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (236, 70, '2026-01-15', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (237, 1, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (238, 2, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (239, 3, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (240, 4, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (241, 5, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (242, 6, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (243, 8, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (244, 9, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (245, 10, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (246, 11, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (247, 12, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (248, 13, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (249, 14, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (250, 15, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (251, 16, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (252, 17, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (253, 18, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (254, 19, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (255, 20, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (256, 21, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (257, 23, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (258, 24, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (259, 25, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (260, 26, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (261, 27, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (262, 28, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (263, 29, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (264, 30, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (265, 31, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (266, 32, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (267, 33, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (268, 34, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (269, 35, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (270, 36, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (271, 37, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (272, 38, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (273, 39, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (274, 40, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (275, 41, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (276, 42, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (277, 43, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (278, 45, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (279, 46, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (280, 48, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (281, 51, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (282, 52, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (283, 53, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (284, 54, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (285, 56, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (286, 57, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (287, 58, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (288, 59, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (289, 60, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (290, 61, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (291, 62, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (292, 63, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (293, 64, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (294, 65, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (295, 66, '2026-01-16', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (296, 67, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (297, 69, '2026-01-16', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (298, 70, '2026-01-16', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (299, 2, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (300, 4, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (301, 5, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (302, 6, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (303, 7, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (304, 8, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (305, 9, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (306, 10, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (307, 13, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (308, 14, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (309, 16, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (310, 17, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (311, 18, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (312, 19, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (313, 20, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (314, 21, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (315, 22, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (316, 23, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (317, 24, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (318, 26, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (319, 27, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (320, 29, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (321, 30, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (322, 31, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (323, 32, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (324, 34, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (325, 35, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (326, 36, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (327, 37, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (328, 39, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (329, 40, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (330, 41, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (331, 42, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (332, 43, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (333, 44, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (334, 46, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (335, 47, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (336, 48, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (337, 49, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (338, 50, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (339, 51, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (340, 52, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (341, 57, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (342, 59, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (343, 61, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (344, 62, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (345, 63, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (346, 64, '2026-01-17', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (347, 66, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (348, 68, '2026-01-17', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (349, 70, '2026-01-17', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (350, 1, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (351, 3, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (352, 6, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (353, 11, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (354, 12, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (355, 13, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (356, 14, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (357, 15, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (358, 16, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (359, 17, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (360, 18, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (361, 20, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (362, 22, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (363, 23, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (364, 24, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (365, 26, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (366, 27, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (367, 28, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (368, 30, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (369, 33, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (370, 34, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (371, 35, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (372, 40, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (373, 41, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (374, 42, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (375, 43, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (376, 44, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (377, 46, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (378, 47, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (379, 48, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (380, 49, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (381, 51, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (382, 52, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (383, 54, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (384, 55, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (385, 56, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (386, 57, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (387, 60, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (388, 61, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (389, 62, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (390, 63, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (391, 65, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (392, 66, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (393, 67, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (394, 68, '2026-01-18', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (395, 69, '2026-01-18', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (396, 70, '2026-01-18', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (397, 2, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (398, 3, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (399, 4, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (400, 5, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (401, 6, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (402, 7, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (403, 8, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (404, 10, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (405, 12, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (406, 13, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (407, 14, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (408, 15, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (409, 16, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (410, 17, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (411, 19, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (412, 20, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (413, 21, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (414, 23, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (415, 24, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (416, 26, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (417, 27, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (418, 28, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (419, 30, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (420, 32, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (421, 33, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (422, 34, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (423, 36, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (424, 38, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (425, 39, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (426, 42, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (427, 43, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (428, 44, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (429, 45, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (430, 47, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (431, 48, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (432, 49, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (433, 50, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (434, 51, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (435, 52, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (436, 57, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (437, 58, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (438, 59, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (439, 61, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (440, 62, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (441, 63, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (442, 64, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (443, 66, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (444, 67, '2026-01-19', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (445, 68, '2026-01-19', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (446, 69, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (447, 70, '2026-01-19', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (448, 1, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (449, 2, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (450, 3, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (451, 4, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (452, 5, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (453, 7, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (454, 9, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (455, 10, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (456, 11, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (457, 12, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (458, 13, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (459, 14, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (460, 15, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (461, 17, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (462, 18, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (463, 19, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (464, 20, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (465, 21, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (466, 22, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (467, 25, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (468, 27, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (469, 28, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (470, 29, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (471, 30, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (472, 31, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (473, 34, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (474, 35, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (475, 36, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (476, 37, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (477, 38, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (478, 39, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (479, 40, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (480, 41, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (481, 42, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (482, 44, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (483, 46, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (484, 47, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (485, 48, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (486, 49, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (487, 50, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (488, 51, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (489, 52, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (490, 53, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (491, 54, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (492, 55, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (493, 56, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (494, 57, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (495, 59, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (496, 60, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (497, 61, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (498, 63, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (499, 66, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (500, 67, '2026-01-20', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (501, 68, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (502, 69, '2026-01-20', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (503, 70, '2026-01-20', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (504, 1, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (505, 2, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (506, 3, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (507, 4, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (508, 5, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (509, 8, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (510, 10, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (511, 11, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (512, 12, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (513, 15, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (514, 16, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (515, 17, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (516, 18, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (517, 21, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (518, 22, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (519, 23, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (520, 24, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (521, 25, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (522, 26, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (523, 28, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (524, 29, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (525, 30, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (526, 32, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (527, 33, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (528, 34, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (529, 35, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (530, 36, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (531, 38, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (532, 39, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (533, 40, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (534, 42, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (535, 43, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (536, 44, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (537, 45, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (538, 46, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (539, 48, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (540, 49, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (541, 50, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (542, 51, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (543, 54, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (544, 55, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (545, 56, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (546, 57, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (547, 58, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (548, 59, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (549, 60, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (550, 61, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (551, 62, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (552, 63, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (553, 66, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (554, 67, '2026-01-21', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (555, 68, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (556, 69, '2026-01-21', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (557, 70, '2026-01-21', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (558, 2, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (559, 3, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (560, 4, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (561, 5, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (562, 6, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (563, 7, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (564, 8, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (565, 9, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (566, 10, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (567, 11, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (568, 12, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (569, 14, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (570, 15, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (571, 16, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (572, 17, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (573, 19, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (574, 21, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (575, 22, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (576, 23, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (577, 24, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (578, 25, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (579, 26, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (580, 27, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (581, 28, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (582, 29, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (583, 30, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (584, 31, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (585, 32, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (586, 33, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (587, 34, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (588, 35, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (589, 36, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (590, 37, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (591, 38, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (592, 39, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (593, 40, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (594, 41, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (595, 42, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (596, 43, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (597, 44, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (598, 45, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (599, 46, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (600, 48, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (601, 49, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (602, 50, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (603, 52, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (604, 53, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (605, 55, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (606, 56, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (607, 59, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (608, 60, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (609, 61, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (610, 62, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (611, 64, '2026-01-22', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (612, 65, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (613, 66, '2026-01-22', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (614, 67, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (615, 70, '2026-01-22', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (616, 1, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (617, 3, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (618, 4, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (619, 5, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (620, 6, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (621, 7, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (622, 8, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (623, 9, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (624, 10, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (625, 11, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (626, 12, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (627, 14, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (628, 15, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (629, 17, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (630, 18, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (631, 20, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (632, 21, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (633, 22, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (634, 23, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (635, 24, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (636, 26, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (637, 27, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (638, 29, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (639, 31, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (640, 32, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (641, 33, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (642, 34, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (643, 35, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (644, 36, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (645, 37, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (646, 38, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (647, 40, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (648, 42, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (649, 44, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (650, 45, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (651, 46, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (652, 47, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (653, 51, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (654, 52, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (655, 54, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (656, 55, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (657, 56, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (658, 57, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (659, 58, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (660, 59, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (661, 60, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (662, 61, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (663, 62, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (664, 63, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (665, 64, '2026-01-23', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (666, 65, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (667, 66, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (668, 67, '2026-01-23', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (669, 68, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (670, 69, '2026-01-23', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (671, 1, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (672, 2, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (673, 4, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (674, 5, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (675, 6, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (676, 7, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (677, 8, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (678, 9, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (679, 10, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (680, 11, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (681, 12, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (682, 13, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (683, 14, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (684, 15, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (685, 17, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (686, 18, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (687, 19, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (688, 20, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (689, 21, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (690, 22, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (691, 23, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (692, 25, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (693, 27, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (694, 28, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (695, 29, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (696, 30, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (697, 31, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (698, 32, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (699, 33, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (700, 34, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (701, 35, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (702, 36, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (703, 37, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (704, 39, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (705, 40, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (706, 41, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (707, 43, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (708, 44, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (709, 45, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (710, 46, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (711, 47, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (712, 48, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (713, 49, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (714, 51, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (715, 52, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (716, 53, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (717, 55, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (718, 56, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (719, 57, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (720, 59, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (721, 60, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (722, 61, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (723, 62, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (724, 64, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (725, 65, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (726, 66, '2026-01-24', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (727, 67, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (728, 68, '2026-01-24', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (729, 69, '2026-01-24', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (730, 1, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (731, 3, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (732, 4, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (733, 5, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (734, 6, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (735, 7, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (736, 9, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (737, 11, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (738, 12, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (739, 13, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (740, 14, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (741, 15, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (742, 16, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (743, 18, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (744, 19, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (745, 21, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (746, 22, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (747, 23, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (748, 25, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (749, 26, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (750, 27, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (751, 30, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (752, 31, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (753, 32, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (754, 33, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (755, 34, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (756, 36, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (757, 37, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (758, 38, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (759, 39, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (760, 40, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (761, 41, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (762, 42, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (763, 43, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (764, 44, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (765, 45, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (766, 47, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (767, 48, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (768, 50, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (769, 51, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (770, 52, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (771, 53, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (772, 54, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (773, 56, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (774, 58, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (775, 59, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (776, 61, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (777, 62, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (778, 63, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (779, 64, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (780, 65, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (781, 66, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (782, 68, '2026-01-25', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (783, 69, '2026-01-25', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (784, 70, '2026-01-25', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (785, 1, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (786, 2, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (787, 3, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (788, 4, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (789, 5, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (790, 6, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (791, 7, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (792, 8, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (793, 9, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (794, 10, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (795, 11, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (796, 12, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (797, 13, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (798, 15, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (799, 16, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (800, 17, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (801, 18, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (802, 19, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (803, 20, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (804, 22, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (805, 23, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (806, 24, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (807, 26, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (808, 27, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (809, 28, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (810, 29, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (811, 30, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (812, 31, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (813, 32, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (814, 33, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (815, 34, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (816, 36, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (817, 38, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (818, 39, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (819, 41, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (820, 42, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (821, 43, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (822, 44, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (823, 45, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (824, 46, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (825, 48, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (826, 50, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (827, 52, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (828, 53, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (829, 54, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (830, 55, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (831, 57, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (832, 58, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (833, 59, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (834, 60, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (835, 61, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (836, 63, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (837, 64, '2026-01-26', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (838, 65, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (839, 66, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (840, 67, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (841, 69, '2026-01-26', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (842, 70, '2026-01-26', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (843, 1, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (844, 4, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (845, 5, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (846, 6, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (847, 7, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (848, 8, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (849, 9, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (850, 10, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (851, 11, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (852, 12, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (853, 15, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (854, 16, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (855, 17, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (856, 18, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (857, 19, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (858, 20, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (859, 21, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (860, 22, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (861, 23, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (862, 24, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (863, 25, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (864, 26, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (865, 27, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (866, 28, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (867, 31, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (868, 32, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (869, 33, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (870, 34, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (871, 35, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (872, 36, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (873, 37, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (874, 38, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (875, 40, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (876, 41, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (877, 42, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (878, 43, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (879, 46, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (880, 47, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (881, 48, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (882, 49, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (883, 50, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (884, 51, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (885, 52, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (886, 53, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (887, 55, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (888, 56, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (889, 58, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (890, 59, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (891, 60, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (892, 61, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (893, 62, '2026-01-27', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (894, 65, '2026-01-27', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (895, 66, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (896, 67, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (897, 68, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (898, 70, '2026-01-27', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (899, 1, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (900, 2, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (901, 3, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (902, 4, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (903, 5, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (904, 6, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (905, 7, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (906, 8, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (907, 9, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (908, 10, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (909, 11, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (910, 13, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (911, 14, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (912, 15, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (913, 16, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (914, 17, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (915, 18, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (916, 19, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (917, 21, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (918, 23, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (919, 24, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (920, 25, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (921, 26, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (922, 28, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (923, 29, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (924, 30, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (925, 31, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (926, 32, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (927, 33, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (928, 35, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (929, 36, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (930, 37, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (931, 38, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (932, 39, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (933, 40, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (934, 41, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (935, 42, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (936, 43, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (937, 44, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (938, 45, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (939, 46, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (940, 47, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (941, 48, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (942, 49, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (943, 50, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (944, 51, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (945, 53, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (946, 54, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (947, 55, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (948, 56, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (949, 57, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (950, 58, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (951, 59, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (952, 60, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (953, 61, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (954, 62, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (955, 63, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (956, 64, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (957, 65, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (958, 66, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (959, 67, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (960, 68, '2026-01-28', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (961, 69, '2026-01-28', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (962, 70, '2026-01-28', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (963, 2, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (964, 3, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (965, 4, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (966, 5, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (967, 6, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (968, 7, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (969, 8, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (970, 9, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (971, 10, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (972, 11, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (973, 12, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (974, 13, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (975, 14, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (976, 15, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (977, 17, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (978, 18, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (979, 19, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (980, 21, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (981, 22, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (982, 24, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (983, 25, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (984, 27, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (985, 28, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (986, 29, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (987, 30, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (988, 31, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (989, 34, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (990, 36, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (991, 37, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (992, 39, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (993, 40, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (994, 41, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (995, 42, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (996, 43, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (997, 46, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (998, 47, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (999, 48, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1000, 50, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1001, 51, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1002, 52, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1003, 53, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1004, 54, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1005, 55, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1006, 56, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1007, 59, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1008, 60, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1009, 61, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1010, 62, '2026-01-29', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1011, 63, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1012, 65, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1013, 66, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1014, 67, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1015, 68, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1016, 69, '2026-01-29', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1017, 70, '2026-01-29', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1018, 1, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1019, 2, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1020, 3, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1021, 4, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1022, 5, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1023, 6, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1024, 7, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1025, 8, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1026, 9, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1027, 10, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1028, 11, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1029, 12, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1030, 13, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1031, 14, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1032, 15, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1033, 17, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1034, 18, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1035, 21, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1036, 22, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1037, 23, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1038, 24, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1039, 25, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1040, 27, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1041, 28, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1042, 29, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1043, 30, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1044, 31, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1045, 32, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1046, 33, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1047, 34, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1048, 35, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1049, 36, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1050, 37, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1051, 38, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1052, 39, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1053, 40, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1054, 41, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1055, 42, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1056, 43, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1057, 44, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1058, 46, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1059, 49, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1060, 50, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1061, 51, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1062, 52, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1063, 53, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1064, 54, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1065, 55, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1066, 57, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1067, 58, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1068, 59, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1069, 60, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1070, 61, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1071, 62, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1072, 63, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1073, 64, '2026-01-30', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1074, 66, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1075, 67, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1076, 68, '2026-01-30', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1077, 69, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1078, 70, '2026-01-30', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1079, 1, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1080, 2, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1081, 3, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1082, 4, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1083, 5, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1084, 6, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1085, 8, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1086, 9, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1087, 10, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1088, 11, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1089, 13, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1090, 14, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1091, 15, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1092, 16, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1093, 17, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1094, 18, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1095, 19, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1096, 20, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1097, 21, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1098, 23, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1099, 24, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1100, 26, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1101, 28, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1102, 30, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1103, 31, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1104, 32, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1105, 33, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1106, 35, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1107, 36, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1108, 37, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1109, 39, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1110, 41, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1111, 42, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1112, 43, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1113, 45, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1114, 47, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1115, 48, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1116, 49, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1117, 50, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1118, 51, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1119, 52, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1120, 53, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1121, 54, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1122, 55, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1123, 56, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1124, 57, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1125, 58, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1126, 59, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1127, 60, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1128, 61, '2026-01-31', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1129, 62, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1130, 66, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1131, 67, '2026-01-31', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1132, 69, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1133, 70, '2026-01-31', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1134, 1, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1135, 2, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1136, 3, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1137, 4, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1138, 5, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1139, 6, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1140, 8, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1141, 9, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1142, 10, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1143, 11, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1144, 12, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1145, 13, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1146, 14, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1147, 15, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1148, 17, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1149, 18, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1150, 19, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1151, 20, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1152, 21, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1153, 22, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1154, 23, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1155, 24, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1156, 25, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1157, 26, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1158, 27, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1159, 28, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1160, 29, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1161, 31, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1162, 32, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1163, 33, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1164, 35, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1165, 36, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1166, 37, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1167, 38, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1168, 39, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1169, 41, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1170, 42, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1171, 45, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1172, 46, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1173, 48, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1174, 49, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1175, 50, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1176, 54, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1177, 55, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1178, 56, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1179, 57, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1180, 58, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1181, 59, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1182, 60, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1183, 61, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1184, 62, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1185, 63, '2026-02-01', '全天', 40, 41, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1186, 65, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1187, 66, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1188, 67, '2026-02-01', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1189, 68, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1190, 69, '2026-02-01', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1191, 70, '2026-02-01', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1192, 1, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1193, 2, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1194, 4, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1195, 5, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1196, 6, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1197, 7, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1198, 8, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1199, 10, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1200, 11, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1201, 12, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1202, 13, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1203, 16, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1204, 17, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1205, 18, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1206, 19, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1207, 20, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1208, 21, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1209, 23, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1210, 24, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1211, 25, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1212, 27, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1213, 28, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1214, 30, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1215, 33, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1216, 34, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1217, 35, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1218, 36, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1219, 37, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1220, 38, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1221, 39, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1222, 40, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1223, 43, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1224, 44, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1225, 45, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1226, 46, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1227, 47, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1228, 48, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1229, 49, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1230, 50, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1231, 51, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1232, 53, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1233, 54, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1234, 55, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1235, 60, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1236, 61, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1237, 62, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1238, 64, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1239, 65, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1240, 66, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1241, 67, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1242, 68, '2026-02-02', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1243, 69, '2026-02-02', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1244, 70, '2026-02-02', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1245, 1, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1246, 2, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1247, 3, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1248, 4, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1249, 5, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1250, 7, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1251, 9, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1252, 10, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1253, 11, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1254, 12, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1255, 13, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1256, 15, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1257, 17, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1258, 20, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1259, 21, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1260, 22, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1261, 23, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1262, 24, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1263, 26, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1264, 27, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1265, 28, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1266, 29, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1267, 30, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1268, 31, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1269, 33, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1270, 34, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1271, 35, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1272, 36, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1273, 37, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1274, 38, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1275, 39, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1276, 40, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1277, 41, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1278, 42, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1279, 43, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1280, 44, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1281, 46, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1282, 47, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1283, 48, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1284, 49, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1285, 50, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1286, 51, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1287, 52, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1288, 53, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1289, 54, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1290, 55, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1291, 56, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1292, 57, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1293, 58, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1294, 59, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1295, 60, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1296, 61, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1297, 62, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1298, 63, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1299, 65, '2026-02-03', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1300, 66, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1301, 68, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1302, 69, '2026-02-03', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1303, 70, '2026-02-03', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1304, 1, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1305, 2, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1306, 3, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1307, 4, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1308, 5, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1309, 6, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1310, 7, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1311, 8, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1312, 10, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1313, 12, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1314, 13, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1315, 14, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1316, 15, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1317, 16, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1318, 18, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1319, 19, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1320, 20, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1321, 21, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1322, 22, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1323, 23, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1324, 24, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1325, 25, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1326, 26, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1327, 27, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1328, 29, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1329, 33, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1330, 34, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1331, 35, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1332, 36, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1333, 37, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1334, 38, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1335, 40, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1336, 41, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1337, 42, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1338, 43, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1339, 44, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1340, 45, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1341, 46, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1342, 47, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1343, 48, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1344, 50, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1345, 51, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1346, 52, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1347, 53, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1348, 54, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1349, 55, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1350, 56, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1351, 57, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1352, 59, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1353, 60, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1354, 61, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1355, 64, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1356, 65, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1357, 66, '2026-02-04', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1358, 67, '2026-02-04', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1359, 68, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1360, 69, '2026-02-04', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1361, 1, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1362, 2, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1363, 3, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1364, 4, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1365, 5, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1366, 7, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1367, 8, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1368, 9, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1369, 10, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1370, 11, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1371, 12, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1372, 13, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1373, 15, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1374, 16, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1375, 17, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1376, 20, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1377, 21, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1378, 22, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1379, 23, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1380, 24, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1381, 25, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1382, 26, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1383, 29, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1384, 30, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1385, 31, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1386, 33, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1387, 34, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1388, 35, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1389, 38, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1390, 39, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1391, 41, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1392, 43, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1393, 44, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1394, 45, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1395, 47, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1396, 48, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1397, 51, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1398, 52, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1399, 53, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1400, 55, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1401, 56, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1402, 59, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1403, 60, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1404, 62, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1405, 63, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1406, 64, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1407, 65, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1408, 66, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1409, 67, '2026-02-05', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1410, 68, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1411, 69, '2026-02-05', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1412, 70, '2026-02-05', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1413, 1, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1414, 2, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1415, 4, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1416, 5, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1417, 6, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1418, 7, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1419, 10, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1420, 11, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1421, 12, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1422, 13, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1423, 15, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1424, 16, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1425, 18, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1426, 19, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1427, 20, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1428, 21, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1429, 23, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1430, 25, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1431, 26, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1432, 29, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1433, 30, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1434, 31, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1435, 32, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1436, 33, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1437, 34, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1438, 35, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1439, 36, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1440, 37, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1441, 38, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1442, 39, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1443, 40, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1444, 41, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1445, 42, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1446, 43, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1447, 44, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1448, 45, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1449, 47, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1450, 48, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1451, 50, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1452, 52, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1453, 53, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1454, 54, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1455, 55, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1456, 56, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1457, 57, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1458, 58, '2026-02-06', '上午', 20, 21, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1459, 59, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1460, 60, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1461, 61, '2026-02-06', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1462, 62, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1463, 63, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1464, 65, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1465, 67, '2026-02-06', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1466, 69, '2026-02-06', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1467, 1, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1468, 2, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1469, 3, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1470, 6, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1471, 7, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1472, 9, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1473, 10, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1474, 11, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1475, 13, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1476, 14, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1477, 16, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1478, 17, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1479, 18, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1480, 21, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1481, 22, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1482, 25, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1483, 26, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1484, 27, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1485, 28, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1486, 29, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1487, 30, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1488, 32, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1489, 33, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1490, 34, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1491, 35, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1492, 39, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1493, 40, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1494, 41, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1495, 42, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1496, 43, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1497, 44, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1498, 46, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1499, 47, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1500, 48, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1501, 49, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1502, 50, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1503, 51, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1504, 52, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1505, 54, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1506, 55, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1507, 56, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1508, 57, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1509, 58, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1510, 59, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1511, 61, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1512, 62, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1513, 63, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1514, 65, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1515, 67, '2026-02-07', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1516, 68, '2026-02-07', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1517, 69, '2026-02-07', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1518, 1, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1519, 2, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1520, 3, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1521, 4, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1522, 5, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1523, 6, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1524, 7, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1525, 8, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1526, 9, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1527, 11, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1528, 12, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1529, 13, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1530, 14, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1531, 16, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1532, 17, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1533, 19, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1534, 20, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1535, 21, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1536, 22, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1537, 24, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1538, 25, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1539, 26, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1540, 27, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1541, 29, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1542, 30, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1543, 31, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1544, 32, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1545, 33, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1546, 34, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1547, 35, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1548, 36, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1549, 37, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1550, 38, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1551, 39, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1552, 40, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1553, 41, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1554, 43, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1555, 45, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1556, 46, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1557, 47, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1558, 48, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1559, 49, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1560, 51, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1561, 52, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1562, 55, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1563, 56, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1564, 58, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1565, 59, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1566, 60, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1567, 62, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1568, 63, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1569, 64, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1570, 65, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1571, 66, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1572, 68, '2026-02-08', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1573, 69, '2026-02-08', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1574, 70, '2026-02-08', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1575, 1, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1576, 3, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1577, 4, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1578, 5, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1579, 6, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1580, 8, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1581, 9, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1582, 10, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1583, 11, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1584, 12, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1585, 14, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1586, 15, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1587, 16, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1588, 17, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1589, 18, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1590, 19, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1591, 20, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1592, 21, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1593, 23, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1594, 24, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1595, 26, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1596, 27, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1597, 28, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1598, 29, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1599, 31, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1600, 32, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1601, 33, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1602, 34, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1603, 35, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1604, 36, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1605, 37, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1606, 38, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1607, 39, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1608, 40, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1609, 42, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1610, 43, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1611, 44, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1612, 45, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1613, 46, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1614, 47, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1615, 48, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1616, 49, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1617, 50, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1618, 51, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1619, 52, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1620, 53, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1621, 54, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1622, 55, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1623, 56, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1624, 57, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1625, 58, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1626, 59, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1627, 60, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1628, 61, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1629, 62, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1630, 63, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1631, 65, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1632, 66, '2026-02-09', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1633, 69, '2026-02-09', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1634, 70, '2026-02-09', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1635, 2, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1636, 3, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1637, 4, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1638, 5, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1639, 6, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1640, 9, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1641, 10, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1642, 12, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1643, 13, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1644, 14, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1645, 17, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1646, 21, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1647, 22, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1648, 23, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1649, 24, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1650, 25, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1651, 26, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1652, 27, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1653, 28, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1654, 29, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1655, 30, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1656, 31, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1657, 32, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1658, 33, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1659, 35, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1660, 36, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1661, 37, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1662, 38, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1663, 39, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1664, 40, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1665, 41, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1666, 42, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1667, 43, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1668, 44, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1669, 45, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1670, 46, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1671, 48, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1672, 49, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1673, 50, '2026-02-10', '上午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1674, 51, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1675, 54, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1676, 55, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1677, 57, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1678, 59, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1679, 60, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1680, 61, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1681, 62, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1682, 63, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1683, 64, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1684, 65, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1685, 66, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1686, 67, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1687, 68, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1688, 69, '2026-02-10', '全天', 40, 40, '2026-01-11 18:10:33');
INSERT INTO `schedule` VALUES (1689, 70, '2026-02-10', '下午', 20, 20, '2026-01-11 18:10:33');

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
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '医院管理', 0, 10, 'hospital', NULL, NULL, '', '1', '0', 'M', '0', '0', '', 'hospital', 'admin', '2026-01-08 16:14:48', '', NULL, '医院管理系统菜单');
INSERT INTO `sys_menu` VALUES (2, '管理员管理', 1, 1, 'admin', 'hospital/admin/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:admin:list', 'user', 'admin', '2026-01-08 16:14:48', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3, '科室信息管理', 1, 2, 'department', 'hospital/department/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:department:list', 'tree', 'admin', '2026-01-08 16:14:48', '', NULL, '');
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
INSERT INTO `sys_menu` VALUES (14, '预约挂号', 1, 8, 'register', 'hospital/appointment/register', NULL, '', '1', '0', 'C', '0', '0', 'hospital:appointment:register', 'edit', 'admin', '2026-01-10 21:41:33', '', NULL, '');
INSERT INTO `sys_menu` VALUES (15, '医院信息管理', 1, 9, 'notice', 'hospital/notice/index', NULL, '', '1', '0', 'C', '0', '0', 'hospital:notice:list', 'message', 'admin', '2026-01-12 10:00:00', '', NULL, '');

-- ----------------------------
-- Procedure structure for GenerateAppointments
-- ----------------------------
DROP PROCEDURE IF EXISTS `GenerateAppointments`;
delimiter ;;
CREATE PROCEDURE `GenerateAppointments`()
BEGIN
    DECLARE schedule_count INT;
    DECLARE patient_count INT;
    DECLARE i INT DEFAULT 1;
    DECLARE patient_id_val INT;
    DECLARE schedule_id_val INT;
    DECLARE status_val ENUM('待就诊','已取消','已完成');
    
    SELECT MAX(id) INTO schedule_count FROM schedule;
    SELECT MAX(id) INTO patient_count FROM patient;
    
    WHILE i <= schedule_count DO
        -- 模拟号源被预约的概率（60%-90%）
        IF RAND() < (0.6 + RAND() * 0.3) THEN
            SET patient_id_val = FLOOR(1 + RAND() * patient_count);
            SET status_val = ELT(FLOOR(1 + RAND() * 3), '待就诊', '已取消', '已完成');
            
            -- 检查是否已经存在该排班的预约
            IF NOT EXISTS (SELECT 1 FROM appointment WHERE schedule_id = i) THEN
                INSERT INTO `appointment` (`patient_id`, `schedule_id`, `status`, `booked_at`)
                VALUES (patient_id_val, i, status_val, 
                       DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY));
            END IF;
        END IF;
        
        SET i = i + 1;
    END WHILE;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for GenerateDoctors
-- ----------------------------
DROP PROCEDURE IF EXISTS `GenerateDoctors`;
delimiter ;;
CREATE PROCEDURE `GenerateDoctors`()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE dept_count INT;
    DECLARE dept_id INT;
    DECLARE titles JSON DEFAULT '["主任医师", "副主任医师", "主治医师", "住院医师"]';
    
    SELECT COUNT(*) INTO dept_count FROM department;
    
    WHILE i <= dept_count DO
        -- 为每个科室生成3-5名医生
        SET @doctor_count = FLOOR(3 + RAND() * 3);
        SET @j = 1;
        
        WHILE @j <= @doctor_count DO
            SET @title_index = FLOOR(1 + RAND() * 4);
            SET @doctor_name = ELT(FLOOR(1 + RAND() * 10), '张', '王', '李', '赵', '刘', '陈', '杨', '黄', '周', '吴');
            SET @doctor_name = CONCAT(@doctor_name, ELT(FLOOR(1 + RAND() * 10), '伟', '勇', '敏', '静', '强', '磊', '洋', '娜', '杰', '婷'));
            
            INSERT INTO `doctor` (`dept_id`, `username`, `password_hash`, `name`, `title`, `is_active`) 
            VALUES (i, 
                   CONCAT('doc_', i, '_', @j), 
                   '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2',
                   @doctor_name,
                   JSON_EXTRACT(titles, CONCAT('$[', @title_index-1, ']')),
                   1);
            
            SET @j = @j + 1;
        END WHILE;
        
        SET i = i + 1;
    END WHILE;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for GenerateMedicalRecords
-- ----------------------------
DROP PROCEDURE IF EXISTS `GenerateMedicalRecords`;
delimiter ;;
CREATE PROCEDURE `GenerateMedicalRecords`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE appt_id INT;
    DECLARE pat_id INT;
    DECLARE doc_id INT;
    DECLARE visit_time_val DATETIME;
    
    -- 只处理状态为'已完成'的预约
    DECLARE cur CURSOR FOR 
    SELECT a.id, a.patient_id, s.doctor_id, a.booked_at
    FROM appointment a
    JOIN schedule s ON a.schedule_id = s.id
    WHERE a.status = '已完成';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO appt_id, pat_id, doc_id, visit_time_val;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- 生成诊断结果和处方
        SET @diagnosis = ELT(FLOOR(1 + RAND() * 10), 
            '上呼吸道感染', '高血压', '糖尿病', '胃炎', '关节炎', 
            '皮肤病', '近视', '牙周炎', '颈椎病', '感冒');
        
        SET @prescription = CASE @diagnosis
            WHEN '上呼吸道感染' THEN '阿莫西林胶囊 0.5g，每日三次，连续7天'
            WHEN '高血压' THEN '硝苯地平控释片 30mg，每日一次'
            WHEN '糖尿病' THEN '二甲双胍片 0.5g，每日两次'
            ELSE '根据病情开具相应药物'
        END;
        
        SET @notes = '定期复查，如有不适随诊';
        
        INSERT INTO `medical_record` (`appointment_id`, `patient_id`, `doctor_id`, 
                                    `diagnosis`, `prescription`, `notes`, `visit_time`)
        VALUES (appt_id, pat_id, doc_id, @diagnosis, @prescription, @notes, visit_time_val);
        
    END LOOP;
    
    CLOSE cur;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for GenerateMedicalRecords_Safe
-- ----------------------------
DROP PROCEDURE IF EXISTS `GenerateMedicalRecords_Safe`;
delimiter ;;
CREATE PROCEDURE `GenerateMedicalRecords_Safe`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE appt_id INT;
    DECLARE pat_id INT;
    DECLARE doc_id INT;
    DECLARE visit_time_val DATETIME;
    
    -- 只处理状态为'已完成'且尚未生成病历的预约
    DECLARE cur CURSOR FOR 
    SELECT a.id, a.patient_id, s.doctor_id, a.booked_at
    FROM appointment a
    JOIN schedule s ON a.schedule_id = s.id
    WHERE a.status = '已完成'
    AND NOT EXISTS (SELECT 1 FROM medical_record mr WHERE mr.appointment_id = a.id); -- 新增条件：检查病历不存在
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO appt_id, pat_id, doc_id, visit_time_val;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- ... (后续生成诊断和处方的逻辑保持不变)
        SET @diagnosis = ELT(FLOOR(1 + RAND() * 10), 
            '上呼吸道感染', '高血压', '糖尿病', '胃炎', '关节炎', 
            '皮肤病', '近视', '牙周炎', '颈椎病', '感冒');
        -- ... (设置 @prescription 和 @notes)
        
        INSERT INTO `medical_record` (`appointment_id`, `patient_id`, `doctor_id`, 
                                    `diagnosis`, `prescription`, `notes`, `visit_time`)
        VALUES (appt_id, pat_id, doc_id, @diagnosis, @prescription, @notes, visit_time_val);
        
    END LOOP;
    
    CLOSE cur;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for GeneratePatients
-- ----------------------------
DROP PROCEDURE IF EXISTS `GeneratePatients`;
delimiter ;;
CREATE PROCEDURE `GeneratePatients`(IN num INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE base_phone BIGINT DEFAULT 13800138000;
    DECLARE base_id_card BIGINT DEFAULT 110101199001010000;
    
    WHILE i < num DO
        SET @surname = ELT(FLOOR(1 + RAND() * 10), '张', '王', '李', '赵', '刘', '陈', '杨', '黄', '周', '吴');
        SET @name = ELT(FLOOR(1 + RAND() * 10), '伟', '勇', '敏', '静', '强', '磊', '洋', '娜', '杰', '婷');
        SET @fullname = CONCAT(@surname, @name);
        SET @birth_year = 1960 + FLOOR(RAND() * 50);
        SET @birth_month = LPAD(FLOOR(1 + RAND() * 12), 2, '0');
        SET @birth_day = LPAD(FLOOR(1 + RAND() * 28), 2, '0');
        SET @id_card = CONCAT('110101', @birth_year, @birth_month, @birth_day, LPAD(FLOOR(RAND() * 10000), 4, '0'));
        
        INSERT INTO `patient` (`username`, `password_hash`, `name`, `phone`, `id_card`) 
        VALUES (LOWER(@fullname), 
               '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2',
               @fullname,
               base_phone + i,
               @id_card);
        
        SET i = i + 1;
    END WHILE;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for GenerateSchedules
-- ----------------------------
DROP PROCEDURE IF EXISTS `GenerateSchedules`;
delimiter ;;
CREATE PROCEDURE `GenerateSchedules`()
BEGIN
    DECLARE doctor_count INT;
    DECLARE i INT DEFAULT 1;
    DECLARE j INT;
    DECLARE doctor_id_val INT;
    DECLARE work_date DATE;
    DECLARE time_slot_val ENUM('上午','下午','全天');
    
    SELECT MAX(id) INTO doctor_count FROM doctor;
    
    WHILE i <= 30 DO  -- 生成30天的排班
        SET work_date = DATE_ADD('2026-01-11', INTERVAL i DAY);
        SET j = 1;
        
        WHILE j <= doctor_count DO
            -- 模拟医生休息（约20%的医生某天不排班）
            IF RAND() > 0.2 THEN
                SET time_slot_val = ELT(FLOOR(1 + RAND() * 3), '上午', '下午', '全天');
                SET @capacity = CASE 
                    WHEN time_slot_val = '全天' THEN 40 
                    ELSE 20 
                END;
                
                INSERT INTO `schedule` (`doctor_id`, `work_date`, `time_slot`, `total_capacity`, `available_slots`)
                VALUES (j, work_date, time_slot_val, @capacity, @capacity);
            END IF;
            
            SET j = j + 1;
        END WHILE;
        
        SET i = i + 1;
    END WHILE;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
