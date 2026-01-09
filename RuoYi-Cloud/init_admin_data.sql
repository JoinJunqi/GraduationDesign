USE hospital_booking;

-- Insert admin user (Password: admin)
INSERT INTO admin (username, password_hash, name, is_active, created_at)
SELECT 'admin', '$2a$10$DrLa.5A4oxPIYZaQBaM8NuDawPnykglVkGHkUrhUauRFqgE7MjeWS', 'System Administrator', 1, NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM admin WHERE username = 'admin');

-- Assign admin role (role_id 1) to the new admin user
INSERT INTO sys_user_role (user_id, role_id)
SELECT id, 1 FROM admin WHERE username = 'admin'
AND NOT EXISTS (SELECT 1 FROM sys_user_role WHERE user_id = (SELECT id FROM admin WHERE username = 'admin') AND role_id = 1);
