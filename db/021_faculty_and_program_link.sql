-- Migration 021: Add faculty lookup table
-- Run in phpMyAdmin against e_appointment_fskm AFTER migration 020.

USE e_appointment_fskm;

-- Faculty lookup table (flexible — admin adds faculties via DB, not hardcoded)
CREATE TABLE IF NOT EXISTS faculty (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code       VARCHAR(30)  NOT NULL UNIQUE,
  name       VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Seed initial faculties (idempotent)
INSERT INTO faculty (code, name) VALUES
  ('FSKM',  'Faculty of Computer Science and Mathematics'),
  ('FKP',   'Faculty of Entrepreneurship and Business'),
  ('FIAT',  'Faculty of Innovative Design and Technology'),
  ('FPEND', 'Faculty of Education and Humanities'),
  ('FSG',   'Faculty of Science and Technology'),
  ('FSGM',  'Faculty of Applied Social Sciences'),
  ('FKPIK', 'Faculty of Health Sciences')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Verify
-- SELECT * FROM faculty ORDER BY code;
-- SELECT * FROM program ORDER BY code;
