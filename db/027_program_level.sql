-- =============================================================================
-- 027_program_level.sql
-- Add `level` column to `program` table to distinguish PhD from Master's.
-- Compatible with MySQL 5.6+ (no IF NOT EXISTS on ADD COLUMN).
-- =============================================================================

USE e_appointment_fskm;

-- 1. Add level column (skip if it already exists)
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME   = 'program'
    AND COLUMN_NAME  = 'level'
);

SET @sql = IF(@col_exists = 0,
  'ALTER TABLE `program` ADD COLUMN `level` ENUM(''PhD'',''Master'') NOT NULL DEFAULT ''PhD'' AFTER `code`',
  'SELECT ''column already exists'' AS msg'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Backfill existing rows based on name / code patterns
UPDATE `program` SET `level` = 'Master'
WHERE LOWER(name)  LIKE '%master%'
   OR LOWER(code)  LIKE 'msc%'
   OR LOWER(code)  LIKE 'mast%'
   OR LOWER(name)  LIKE '%sarjana%';

-- 3. Ensure any remaining NULL values get the PhD default
UPDATE `program` SET `level` = 'PhD' WHERE `level` IS NULL;
