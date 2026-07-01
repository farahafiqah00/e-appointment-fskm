-- Migration 013: Venue lookup table + ensure candidate.supervisor_id exists
-- Run in phpMyAdmin against e_appointment_fskm AFTER migrations 001-012.

USE e_appointment_fskm;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Ensure candidate.supervisor_id column exists (idempotent, safe to re-run)
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE `candidate`
  ADD COLUMN IF NOT EXISTS `supervisor_id` INT UNSIGNED NULL
    AFTER `supervisor_name`;

ALTER TABLE `candidate` DROP FOREIGN KEY IF EXISTS `fk_candidate_supervisor`;
ALTER TABLE `candidate`
  ADD CONSTRAINT `fk_candidate_supervisor`
    FOREIGN KEY (`supervisor_id`) REFERENCES `academic_staff`(`id`)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Venue lookup table for viva scheduling
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS venue (
  id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL UNIQUE,
  location  VARCHAR(255),
  capacity  INT DEFAULT 20,
  is_active TINYINT(1) DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Seed default venues (idempotent)
INSERT IGNORE INTO venue (name, location, capacity) VALUES
  ('Meeting Room 1',      'Level 3, FSKM Building',  15),
  ('Meeting Room 2',      'Level 3, FSKM Building',  15),
  ('Meeting Room 3',      'Level 4, FSKM Building',  20),
  ('Meeting Room 4',      'Level 4, FSKM Building',  20),
  ('Conference Room A',   'Level 5, FSKM Building',  30),
  ('Conference Room B',   'Level 5, FSKM Building',  30),
  ('Seminar Room 1',      'Level 2, FSKM Building',  40),
  ('Seminar Room 2',      'Level 2, FSKM Building',  40),
  ('Dean''s Meeting Room','Dean''s Office, Level 6',  12),
  ('Online (Microsoft Teams)', NULL, 999);
