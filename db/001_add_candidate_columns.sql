-- Migration: Add thesis_title and supervisor_name to candidate table
-- Run this against the `e_appointment_fskm` database.
-- Note: `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` requires MySQL 8+. If your MySQL is older,
-- run the equivalent safe commands shown below or upgrade.

ALTER TABLE candidate ADD COLUMN IF NOT EXISTS thesis_title VARCHAR(255);
ALTER TABLE candidate ADD COLUMN IF NOT EXISTS supervisor_name VARCHAR(255);
ALTER TABLE candidate MODIFY COLUMN status VARCHAR(30) DEFAULT 'prepared';

-- If your MySQL version does NOT support `IF NOT EXISTS`, use these commands instead (run each safely):
-- ALTER TABLE candidate ADD COLUMN thesis_title VARCHAR(255);
-- ALTER TABLE candidate ADD COLUMN supervisor_name VARCHAR(255);
-- ALTER TABLE candidate MODIFY COLUMN status VARCHAR(30) DEFAULT 'prepared';

-- Verify:
-- SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
--  WHERE TABLE_SCHEMA = 'e_appointment_fskm' AND TABLE_NAME = 'candidate';
