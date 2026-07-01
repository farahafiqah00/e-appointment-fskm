-- Run each SELECT separately in phpMyAdmin to diagnose why Panel Role Reference is empty

USE e_appointment_fskm;

-- 1. Are there any rows in appointment_panel?
SELECT COUNT(*) AS appointment_panel_rows FROM appointment_panel;

-- 2. Are there active Academician/Dean users?
SELECT u.id, u.username, u.full_name, r.name AS role, u.status
FROM `user` u JOIN role r ON u.role_id = r.id
WHERE r.name IN ('Academician','Dean') AND u.status = 'active';

-- 3. Are there any external examiners?
SELECT id, name, email FROM external_examiner;

-- 4. Who is currently in appointment_panel?
SELECT ap.id, ap.internal_user_id, u.full_name AS internal_name,
       ap.external_examiner_id, ee.name AS external_name, ap.member_role
FROM appointment_panel ap
LEFT JOIN `user` u ON ap.internal_user_id = u.id
LEFT JOIN external_examiner ee ON ap.external_examiner_id = ee.id;
