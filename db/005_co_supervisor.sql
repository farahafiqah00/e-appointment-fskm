-- Migration 005: Add co_supervisor table and contact_email to candidate
-- Run in phpMyAdmin against e_appointment_fskm AFTER migration 001.

USE e_appointment_fskm;

-- Co-supervisors as a separate table (one candidate can have multiple)
CREATE TABLE IF NOT EXISTS co_supervisor (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  candidate_id INT UNSIGNED NOT NULL,
  name        VARCHAR(200) NOT NULL,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (candidate_id) REFERENCES candidate(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- Add missing columns to candidate table (safe with IF NOT EXISTS)
ALTER TABLE candidate ADD COLUMN IF NOT EXISTS thesis_title    VARCHAR(500);
ALTER TABLE candidate ADD COLUMN IF NOT EXISTS supervisor_name VARCHAR(255);
ALTER TABLE candidate ADD COLUMN IF NOT EXISTS contact_email   VARCHAR(150);
ALTER TABLE candidate ADD COLUMN IF NOT EXISTS program_id      INT UNSIGNED;

-- Seed programmes used in the current seed data (idempotent)
INSERT INTO program (code, name) VALUES
  ('PHD-CS',  'PhD Computer Science'),
  ('PHD-SE',  'PhD Software Engineering'),
  ('PHD-IT',  'PhD Information Technology'),
  ('PHD-MATH','PhD Mathematics'),
  ('MAST-CS', 'Master of Computer Science'),
  ('MAST-SE', 'Master of Software Engineering'),
  ('MAST-IT', 'Master of Information Technology'),
  ('MAST-DS', 'Master of Data Science'),
  ('MAST-MATH','Master of Mathematics')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Verify
-- SELECT * FROM co_supervisor;
-- SELECT * FROM program ORDER BY code;
