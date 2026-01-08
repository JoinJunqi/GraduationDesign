-- ----------------------------
-- 医院管理系统菜单 SQL 脚本
-- 请在 ruoyi-system 数据库中执行
-- ----------------------------

-- 1. 创建一级菜单 "医院管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('医院管理', 0, 10, 'hospital', NULL, 1, 0, 'M', '0', '0', '', 'hospital', 'admin', SYSDATE(), '', NULL, '医院管理系统菜单');

-- 获取刚插入的菜单ID (假设ID为 2000，实际执行时请根据数据库自增ID修改下方的 parent_id)
-- SET @parentId = LAST_INSERT_ID(); 
-- 为方便演示，这里假设 parent_id = 2000，请根据实际情况修改

-- 2. 创建二级菜单 "管理员管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('管理员管理', 2000, 1, 'admin', 'hospital/admin/index', 1, 0, 'C', '0', '0', 'hospital:admin:list', 'user', 'admin', SYSDATE(), '', NULL, '');

-- 3. 创建二级菜单 "科室管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('科室管理', 2000, 2, 'department', 'hospital/department/index', 1, 0, 'C', '0', '0', 'hospital:department:list', 'tree', 'admin', SYSDATE(), '', NULL, '');

-- 4. 创建二级菜单 "医生管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('医生管理', 2000, 3, 'doctor', 'hospital/doctor/index', 1, 0, 'C', '0', '0', 'hospital:doctor:list', 'peoples', 'admin', SYSDATE(), '', NULL, '');

-- 5. 创建二级菜单 "患者管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('患者管理', 2000, 4, 'patient', 'hospital/patient/index', 1, 0, 'C', '0', '0', 'hospital:patient:list', 'user', 'admin', SYSDATE(), '', NULL, '');

-- 6. 创建二级菜单 "排班管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('排班管理', 2000, 5, 'schedule', 'hospital/schedule/index', 1, 0, 'C', '0', '0', 'hospital:schedule:list', 'date', 'admin', SYSDATE(), '', NULL, '');

-- 7. 创建二级菜单 "预约管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('预约管理', 2000, 6, 'appointment', 'hospital/appointment/index', 1, 0, 'C', '0', '0', 'hospital:appointment:list', 'list', 'admin', SYSDATE(), '', NULL, '');

-- 8. 创建二级菜单 "病历管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('病历管理', 2000, 7, 'record', 'hospital/record/index', 1, 0, 'C', '0', '0', 'hospital:record:list', 'form', 'admin', SYSDATE(), '', NULL, '');
