-- 插入测试数据
USE `hospital_booking`;

-- 管理员数据 (密码: admin123)
-- 已存在，无需插入
-- INSERT INTO `admin` VALUES (1, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnutj8iAt6.VwU/twMdKZHugy/alSS/rBO', '系统管理员', 1, NOW());

-- 科室数据
INSERT INTO `department` (`name`, `created_at`) VALUES 
('内科', NOW()),
('外科', NOW()),
('儿科', NOW()),
('妇科', NOW()),
('眼科', NOW());

-- 医生数据 (密码: 123456)
INSERT INTO `doctor` (`dept_id`, `username`, `password_hash`, `name`, `title`, `is_active`, `created_at`) VALUES 
(1, 'doc_internal', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张内科', '主任医师', 1, NOW()),
(2, 'doc_surgery', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李外科', '副主任医师', 1, NOW()),
(3, 'doc_pediatrics', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '王儿科', '主治医师', 1, NOW());

-- 患者数据 (密码: 123456)
INSERT INTO `patient` (`username`, `password_hash`, `name`, `phone`, `id_card`, `created_at`) VALUES 
('patient001', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '赵患者', '13800138000', '110101199001011234', NOW()),
('patient002', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '钱患者', '13900139000', '110101199505055678', NOW());

-- 排班数据
INSERT INTO `schedule` (`doctor_id`, `work_date`, `time_slot`, `total_capacity`, `available_slots`, `created_at`) VALUES 
(1, CURDATE(), '上午', 20, 20, NOW()),
(1, CURDATE(), '下午', 20, 20, NOW()),
(2, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '上午', 15, 15, NOW());

