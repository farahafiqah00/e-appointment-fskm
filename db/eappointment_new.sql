-- eappointment_new.sql
-- Idempotent schema for e_appointment_fskm with lookup tables and seed data

CREATE DATABASE IF NOT EXISTS e_appointment_fskm;
USE e_appointment_fskm;

-- ROLES
CREATE TABLE IF NOT EXISTS role (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- TITLES (Mr, Dr, Assoc, Prof...)
CREATE TABLE IF NOT EXISTS title (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- PROGRAMS (degree programs)
CREATE TABLE IF NOT EXISTS program (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- USERS
CREATE TABLE IF NOT EXISTS `user` (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id INT UNSIGNED NOT NULL,
  title_id INT UNSIGNED,
  program_id INT UNSIGNED,
  username VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  full_name VARCHAR(200) NOT NULL,
  phone VARCHAR(30),
  status VARCHAR(20) DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES role(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (title_id) REFERENCES title(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (program_id) REFERENCES program(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Ensure `user` has the new columns if running against an older schema
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS title_id INT UNSIGNED;
ALTER TABLE `user` ADD COLUMN IF NOT EXISTS program_id INT UNSIGNED;

-- ACADEMIC STAFF
CREATE TABLE IF NOT EXISTS academic_staff (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL UNIQUE,
  staff_number VARCHAR(50) NOT NULL UNIQUE,
  department VARCHAR(150),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES `user`(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- Ensure `academic_staff` has program_id and staff_number on older schemas
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS program_id INT UNSIGNED;
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS staff_number VARCHAR(50);

 

-- CANDIDATE
CREATE TABLE IF NOT EXISTS candidate (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id VARCHAR(50) NOT NULL UNIQUE,
  full_name VARCHAR(200) NOT NULL,
  program VARCHAR(150),
  program_id INT UNSIGNED,
  contact_email VARCHAR(150),
  status VARCHAR(30) DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Ensure `candidate` has program_id on older schemas
ALTER TABLE candidate ADD COLUMN IF NOT EXISTS program_id INT UNSIGNED;
-- Add columns for thesis and supervisor if missing
ALTER TABLE candidate ADD COLUMN IF NOT EXISTS thesis_title VARCHAR(255);
ALTER TABLE candidate ADD COLUMN IF NOT EXISTS supervisor_name VARCHAR(255);

-- EXTERNAL EXAMINER
CREATE TABLE IF NOT EXISTS external_examiner (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  affiliation VARCHAR(255),
  email VARCHAR(150),
  phone VARCHAR(30),
  university_id INT UNSIGNED,
  country_id INT UNSIGNED,
  status VARCHAR(30) DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Ensure `external_examiner` has university_id and country_id on older schemas
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS university_id INT UNSIGNED;
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS country_id INT UNSIGNED;

-- NOMINATION
CREATE TABLE IF NOT EXISTS nomination (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  candidate_id INT UNSIGNED NOT NULL,
  external_examiner_id INT UNSIGNED,
  nominator_user_id INT UNSIGNED NOT NULL,
  nomination_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(30) DEFAULT 'pending',
  remarks VARCHAR(500),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (candidate_id) REFERENCES candidate(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (external_examiner_id) REFERENCES external_examiner(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (nominator_user_id) REFERENCES `user`(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- VIVA APPOINTMENT
CREATE TABLE IF NOT EXISTS viva_appointment (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  candidate_id INT UNSIGNED NOT NULL,
  nomination_id INT UNSIGNED,
  scheduled_at DATETIME NOT NULL,
  venue VARCHAR(255),
  duration_minutes INT DEFAULT 90,
  status VARCHAR(30) DEFAULT 'scheduled',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (candidate_id) REFERENCES candidate(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (nomination_id) REFERENCES nomination(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- APPOINTMENT PANEL
CREATE TABLE IF NOT EXISTS appointment_panel (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT UNSIGNED NOT NULL,
  internal_user_id INT UNSIGNED,
  external_examiner_id INT UNSIGNED,
  member_role VARCHAR(100),
  is_chair TINYINT(1) DEFAULT 0,
  sequence_order INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointment_id) REFERENCES viva_appointment(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (internal_user_id) REFERENCES `user`(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (external_examiner_id) REFERENCES external_examiner(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- DOCUMENT
CREATE TABLE IF NOT EXISTS document (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomination_id INT UNSIGNED,
  uploaded_by INT UNSIGNED,
  filename VARCHAR(255) NOT NULL,
  filepath VARCHAR(1024),
  file_type VARCHAR(100),
  uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (nomination_id) REFERENCES nomination(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (uploaded_by) REFERENCES `user`(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- APPOINTMENT LETTER
CREATE TABLE IF NOT EXISTS appointment_letter (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT UNSIGNED NOT NULL,
  letter_number VARCHAR(150) UNIQUE,
  issued_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  issued_by INT UNSIGNED,
  content VARCHAR(2000),
  status VARCHAR(30) DEFAULT 'issued',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointment_id) REFERENCES viva_appointment(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (issued_by) REFERENCES `user`(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- UNIVERSITY & COUNTRY (for examiner / staff metadata)
CREATE TABLE IF NOT EXISTS country (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  iso_code VARCHAR(8),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS university (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  country_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (country_id) REFERENCES country(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- SPECIALIZATION / EXPERTISE HIERARCHY FOR EXAMINERS
CREATE TABLE IF NOT EXISTS specialization (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  description VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS expertise (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  specialization_id INT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  description VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (specialization_id) REFERENCES specialization(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS division (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  specialization_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (specialization_id) REFERENCES specialization(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS examiner_category (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS examiner_group (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS area (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  specialization_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (specialization_id) REFERENCES specialization(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Seed data (idempotent)
-- Roles
INSERT INTO role (name, description) VALUES
  ('Admin','System administrator'),
  ('Academician','Academic staff / faculty member'),
  ('Dean','Dean of faculty – inherits Academician privileges')
ON DUPLICATE KEY UPDATE description=VALUES(description);

-- Titles
INSERT INTO title (name, description) VALUES
  ('Mr','Mister'),
  ('Dr','Doctor'),
  ('Assoc','Associate'),
  ('Prof','Professor')
ON DUPLICATE KEY UPDATE description=VALUES(description);

-- Programs
INSERT INTO program (code, name) VALUES
  ('SE','Software Engineering'),
  ('CS','Computer Science'),
  ('IS','Information Systems')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Specializations
INSERT INTO specialization (name, description) VALUES
  ('Artificial Intelligence','AI and Machine Learning'),
  ('Networks','Computer Networks'),
  ('Software Engineering','Software engineering and methodologies')
ON DUPLICATE KEY UPDATE description=VALUES(description);

-- Expertise
INSERT INTO expertise (specialization_id, name, description) VALUES
  ((SELECT id FROM specialization WHERE name='Artificial Intelligence'), 'Machine Learning', 'ML and statistical learning'),
  ((SELECT id FROM specialization WHERE name='Networks'), 'Network Security', 'Network & security'),
  ((SELECT id FROM specialization WHERE name='Software Engineering'), 'Software Architecture', 'Design & architecture')
ON DUPLICATE KEY UPDATE description=VALUES(description);

-- Divisions / categories / groups / areas
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('AI Division',
   (SELECT id FROM specialization WHERE name='Artificial Intelligence'),
   (SELECT id FROM expertise WHERE name='Machine Learning' AND specialization_id=(SELECT id FROM specialization WHERE name='Artificial Intelligence') LIMIT 1)),
  ('Network Division',
   (SELECT id FROM specialization WHERE name='Networks'),
   (SELECT id FROM expertise WHERE name='Network Security' AND specialization_id=(SELECT id FROM specialization WHERE name='Networks') LIMIT 1)),
  ('SE Division',
   (SELECT id FROM specialization WHERE name='Software Engineering'),
   (SELECT id FROM expertise WHERE name='Software Architecture' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id=VALUES(expertise_id);

INSERT INTO examiner_category (name) VALUES
  ('Internal'),('External'),('Adjunct')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO examiner_group (name) VALUES
  ('Senior'),('Mid'),('Junior')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Natural Language Processing',
   (SELECT id FROM specialization WHERE name='Artificial Intelligence'),
   (SELECT id FROM division WHERE name='AI Division' LIMIT 1)),
  ('Routing & Switching',
   (SELECT id FROM specialization WHERE name='Networks'),
   (SELECT id FROM division WHERE name='Network Division' LIMIT 1)),
  ('Requirements Engineering',
   (SELECT id FROM specialization WHERE name='Software Engineering'),
   (SELECT id FROM division WHERE name='SE Division' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id=VALUES(division_id);

-- Initial admin and sample user
-- Admin password: 'admin123' hashed with SHA2(...,256)
INSERT INTO `user` (role_id, title_id, program_id, username, password_hash, email, full_name, phone, status, created_at)
VALUES (
  (SELECT id FROM role WHERE name='Admin'),
  (SELECT id FROM title WHERE name='Prof'),
  (SELECT id FROM program WHERE code='SE'),
  'admin',
  SHA2('admin123',256),
  'admin@umt.edu',
  'System Administrator',
  '0123456789',
  'active',
  NOW()
)
ON DUPLICATE KEY UPDATE password_hash=VALUES(password_hash), role_id=VALUES(role_id);

-- Sample academician account (for login testing)
INSERT INTO `user` (role_id, title_id, program_id, username, password_hash, email, full_name, phone, status, created_at)
VALUES (
  (SELECT id FROM role WHERE name='Academician'),
  (SELECT id FROM title WHERE name='Dr'),
  (SELECT id FROM program WHERE code='SE'),
  'drx',
  SHA2('password123',256),
  'drx@umt.edu',
  'Dr. Example X',
  '0123000456',
  'active',
  NOW()
)
ON DUPLICATE KEY UPDATE password_hash=VALUES(password_hash);

-- Link academic_staff sample row with staff_number UMT00001
INSERT INTO academic_staff (user_id, staff_number, department)
VALUES (
  (SELECT id FROM `user` WHERE username='drx'),
  'UMT00001',
  'Software Engineering'
)
ON DUPLICATE KEY UPDATE staff_number=VALUES(staff_number);

-- Seed countries
INSERT INTO country (name, iso_code) VALUES
  ('Malaysia','MY'),
  ('United Kingdom','GB'),
  ('United States','US')
ON DUPLICATE KEY UPDATE iso_code=VALUES(iso_code);

-- Seed universities
INSERT INTO university (name, country_id) VALUES
  ('Universiti Malaysia Terengganu',(SELECT id FROM country WHERE name='Malaysia')),
  ('University of Kuala Lumpur',(SELECT id FROM country WHERE name='Malaysia')),
  ('Global University',(SELECT id FROM country WHERE name='United Kingdom'))
ON DUPLICATE KEY UPDATE country_id=VALUES(country_id);

-- Notes:
-- 1) Passwords are stored as SHA-256 hashes (via SHA2()) so the application must hash
--    login input using the same algorithm before comparing.
-- 2) This script is idempotent: run repeatedly it will not duplicate lookup entries.
-- Additional sample data for testing

-- Candidates
INSERT INTO candidate (student_id, full_name, program, program_id, contact_email)
VALUES
  ('S1001','Aminah Binti Ali','Software Engineering',(SELECT id FROM program WHERE code='SE'),'aminah@example.com'),
  ('S1002','Lee Wei','Software Engineering',(SELECT id FROM program WHERE code='SE'),'leew@example.com'),
  ('S1003','Kumar Raj','Computer Science',(SELECT id FROM program WHERE code='CS'),'kumar@example.com')
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name), contact_email=VALUES(contact_email), program_id=VALUES(program_id);

-- External examiners
INSERT IGNORE INTO external_examiner (name, affiliation, email, phone, university_id, country_id)
VALUES
  ('Prof. Ahmad','University of KL','ahmad@example.org','0190001111', (SELECT id FROM university WHERE name='University of Kuala Lumpur'), (SELECT id FROM country WHERE name='Malaysia')),
  ('Dr. Smith','Global Uni','smith@example.org','0190002222', (SELECT id FROM university WHERE name='Global University'), (SELECT id FROM country WHERE name='United Kingdom')),
  ('Dr. Chen','Tech Institute','chen@example.org','0190003333', NULL, (SELECT id FROM country WHERE name='United States'));

-- Create a few nominations (link candidates and external examiners)
INSERT IGNORE INTO nomination (candidate_id, external_examiner_id, nominator_user_id, remarks)
VALUES
  ((SELECT id FROM candidate WHERE student_id='S1001'), (SELECT id FROM external_examiner WHERE email='ahmad@example.org'), (SELECT id FROM `user` WHERE username='drx'), 'Nomination 1'),
  ((SELECT id FROM candidate WHERE student_id='S1002'), (SELECT id FROM external_examiner WHERE email='smith@example.org'), (SELECT id FROM `user` WHERE username='drx'), 'Nomination 2');

-- Viva appointments
INSERT IGNORE INTO viva_appointment (candidate_id, nomination_id, scheduled_at, venue, duration_minutes)
VALUES
  ((SELECT id FROM candidate WHERE student_id='S1001'), (SELECT id FROM nomination WHERE remarks='Nomination 1'), NOW() + INTERVAL 7 DAY, 'Room A', 90),
  ((SELECT id FROM candidate WHERE student_id='S1002'), (SELECT id FROM nomination WHERE remarks='Nomination 2'), NOW() + INTERVAL 14 DAY, 'Room B', 90);

-- Appointment panel entries
INSERT IGNORE INTO appointment_panel (appointment_id, internal_user_id, external_examiner_id, member_role, is_chair, sequence_order)
VALUES
  ((SELECT id FROM viva_appointment WHERE venue='Room A'), (SELECT id FROM `user` WHERE username='drx'), (SELECT id FROM external_examiner WHERE email='ahmad@example.org'), 'Examiner', 1, 1),
  ((SELECT id FROM viva_appointment WHERE venue='Room A'), (SELECT id FROM `user` WHERE username='admin'), (SELECT id FROM external_examiner WHERE email='ahmad@example.org'), 'Chair', 1, 0);

-- Documents
INSERT IGNORE INTO document (nomination_id, uploaded_by, filename, filepath, file_type)
VALUES
  ((SELECT id FROM nomination WHERE remarks='Nomination 1'), (SELECT id FROM `user` WHERE username='drx'), 'cv_aminah.pdf', '/uploads/cv_aminah.pdf', 'application/pdf'),
  ((SELECT id FROM nomination WHERE remarks='Nomination 2'), (SELECT id FROM `user` WHERE username='drx'), 'cv_lee.pdf', '/uploads/cv_lee.pdf', 'application/pdf');

-- Appointment letters
INSERT IGNORE INTO appointment_letter (appointment_id, letter_number, issued_by, content, status)
VALUES
  ((SELECT id FROM viva_appointment WHERE venue='Room A'), 'L-2026-0001', (SELECT id FROM `user` WHERE username='admin'), 'Appointment letter content for Aminah', 'issued'),
  ((SELECT id FROM viva_appointment WHERE venue='Room B'), 'L-2026-0002', (SELECT id FROM `user` WHERE username='admin'), 'Appointment letter content for Lee', 'issued');
