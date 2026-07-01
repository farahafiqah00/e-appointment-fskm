-- =============================================================================
-- eappointment_seed_users.sql
-- Initial user accounts for e_appointment_fskm
-- Run AFTER eappointment_schema_clean.sql
-- =============================================================================

USE e_appointment_fskm;

-- Required roles
INSERT INTO role (name, description) VALUES
  ('Admin',        'System administrator'),
  ('Academician',  'Academic staff / faculty member'),
  ('Dean',         'Dean of faculty')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Required title
INSERT INTO title (name) VALUES ('Dr.')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Initial user accounts (passwords SHA-256 hashed)
INSERT INTO `user` (role_id, title_id, username, password_hash, email, full_name, status)
VALUES
  (
    (SELECT id FROM role WHERE name = 'Admin'),
    (SELECT id FROM title WHERE name = 'Dr.'),
    'admin',
    SHA2('admin123', 256),
    'admin@fskm.edu.my',
    'System Administrator',
    'active'
  ),
  (
    (SELECT id FROM role WHERE name = 'Academician'),
    (SELECT id FROM title WHERE name = 'Dr.'),
    'academician',
    SHA2('academician123', 256),
    'academician@fskm.edu.my',
    'Dr. Academician',
    'active'
  ),
  (
    (SELECT id FROM role WHERE name = 'Dean'),
    (SELECT id FROM title WHERE name = 'Dr.'),
    'dean',
    SHA2('dean123', 256),
    'dean@fskm.edu.my',
    'Dr. Dean',
    'active'
  )
ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash);

-- Log in with:
--   admin        / admin123
--   academician  / academician123
--   dean         / dean123
