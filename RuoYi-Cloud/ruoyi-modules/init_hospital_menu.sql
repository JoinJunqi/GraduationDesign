-- ----------------------------
-- 3. 菜单初始化脚本 (请在 ry-cloud 数据库中执行)
-- ----------------------------
USE `ry-cloud`;

-- 1. 创建一级菜单 "医院管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
VALUES ('医院管理', 0, 10, 'hospital', NULL, 1, 0, 'M', '0', '0', '', 'hospital', 'admin', SYSDATE(), '', NULL, '医院管理系统菜单');

-- 获取刚插入的菜单ID (在实际执行时，你需要手动查看上一条插入的ID，或者使用变量)
-- 这里为了脚本的可重复性，我们假设 parent_id 需要手动指定或者通过子查询获取
-- 实际上在 MySQL 脚本中很难跨会话获取 ID，建议手动确认 ID。
-- 假设 ID = 2000 (RuoYi 默认 ID 段通常预留了空间)

-- 2. 创建二级菜单 "管理员管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '管理员管理', menu_id, 1, 'admin', 'hospital/admin/index', 1, 0, 'C', '0', '0', 'hospital:admin:list', 'user', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医院管理' AND path = 'hospital' LIMIT 1;

-- 3. 创建二级菜单 "科室管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '科室管理', menu_id, 2, 'department', 'hospital/department/index', 1, 0, 'C', '0', '0', 'hospital:department:list', 'tree', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医院管理' AND path = 'hospital' LIMIT 1;

-- 4. 创建二级菜单 "医生管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '医生管理', menu_id, 3, 'doctor', 'hospital/doctor/index', 1, 0, 'C', '0', '0', 'hospital:doctor:list', 'peoples', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医院管理' AND path = 'hospital' LIMIT 1;

-- 5. 创建二级菜单 "患者管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '患者管理', menu_id, 4, 'patient', 'hospital/patient/index', 1, 0, 'C', '0', '0', 'hospital:patient:list', 'user', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医院管理' AND path = 'hospital' LIMIT 1;

-- 6. 创建二级菜单 "排班管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '排班管理', menu_id, 5, 'schedule', 'hospital/schedule/index', 1, 0, 'C', '0', '0', 'hospital:schedule:list', 'date', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医院管理' AND path = 'hospital' LIMIT 1;

-- 7. 创建二级菜单 "预约管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '预约管理', menu_id, 6, 'appointment', 'hospital/appointment/index', 1, 0, 'C', '0', '0', 'hospital:appointment:list', 'list', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医院管理' AND path = 'hospital' LIMIT 1;

-- 8. 创建二级菜单 "病历管理"
INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '病历管理', menu_id, 7, 'record', 'hospital/record/index', 1, 0, 'C', '0', '0', 'hospital:record:list', 'form', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医院管理' AND path = 'hospital' LIMIT 1;

-- ----------------------------
-- 4. 按钮权限初始化 (示例：医生管理增删改查)
-- ----------------------------
-- 先获取"医生管理"菜单ID
-- SET @menuId = (SELECT menu_id FROM sys_menu WHERE menu_name = '医生管理' LIMIT 1);

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '医生查询', menu_id, 1, '#', '', 1, 0, 'F', '0', '0', 'hospital:doctor:query', '#', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医生管理' LIMIT 1;

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '医生新增', menu_id, 2, '#', '', 1, 0, 'F', '0', '0', 'hospital:doctor:add', '#', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医生管理' LIMIT 1;

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '医生修改', menu_id, 3, '#', '', 1, 0, 'F', '0', '0', 'hospital:doctor:edit', '#', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医生管理' LIMIT 1;

INSERT INTO sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
SELECT '医生删除', menu_id, 4, '#', '', 1, 0, 'F', '0', '0', 'hospital:doctor:remove', '#', 'admin', SYSDATE(), '', NULL, ''
FROM sys_menu WHERE menu_name = '医生管理' LIMIT 1;

-- (其他模块的按钮权限依此类推，此处省略以保持脚本简洁)
