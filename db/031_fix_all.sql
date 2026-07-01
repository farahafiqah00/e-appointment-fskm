-- =============================================================================
-- 031_fix_all.sql  — RUN THIS ONE FILE IN YOUR DATABASE
-- Fixes everything: programme names, level column, AUTO_INCREMENT,
-- nullable scheduled_at, pending appointments for existing candidates,
-- and program_id backfill for existing candidates.
-- Safe to run multiple times (idempotent where possible).
-- =============================================================================

USE e_appointment_fskm;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Fix candidate.id AUTO_INCREMENT
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE `candidate`
  MODIFY COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- Also fix academic_staff.id AUTO_INCREMENT (required by SaveAcademicServlet insert)
ALTER TABLE `academic_staff`
  MODIFY COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Make viva_appointment.scheduled_at nullable
--    (required so a pending row can be created without a date yet)
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE viva_appointment
  MODIFY COLUMN scheduled_at DATETIME NULL DEFAULT NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Add level column to program (skip if already exists)
-- ─────────────────────────────────────────────────────────────────────────────
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME   = 'program'
    AND COLUMN_NAME  = 'level'
);
SET @sql = IF(@col_exists = 0,
  'ALTER TABLE `program` ADD COLUMN `level` ENUM(''PhD'',''Master'') NOT NULL DEFAULT ''PhD'' AFTER `code`',
  'SELECT 1'
);
PREPARE _stmt FROM @sql; EXECUTE _stmt; DEALLOCATE PREPARE _stmt;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Reset programme names and levels to known-correct values
--    (Undoes any previous bad strip, then applies correct discipline-only names)
-- ─────────────────────────────────────────────────────────────────────────────

-- PhD programmes (from migration 014 seed)
UPDATE `program` SET `name` = 'Computer Science',           `level` = 'PhD' WHERE `code` = 'CS';
UPDATE `program` SET `name` = 'Software Engineering',       `level` = 'PhD' WHERE `code` = 'SE';
UPDATE `program` SET `name` = 'Information Systems',        `level` = 'PhD' WHERE `code` = 'IS';
UPDATE `program` SET `name` = 'Information Technology',     `level` = 'PhD' WHERE `code` = 'IT';
UPDATE `program` SET `name` = 'Mathematics',                `level` = 'PhD' WHERE `code` = 'MT';
UPDATE `program` SET `name` = 'Artificial Intelligence',    `level` = 'PhD' WHERE `code` = 'AI';
UPDATE `program` SET `name` = 'Data Science',               `level` = 'PhD' WHERE `code` = 'DS';
UPDATE `program` SET `name` = 'Cybersecurity',              `level` = 'PhD' WHERE `code` = 'CY';
UPDATE `program` SET `name` = 'Network Security',           `level` = 'PhD' WHERE `code` = 'NS';
UPDATE `program` SET `name` = 'Human-Computer Interaction', `level` = 'PhD' WHERE `code` = 'HCI';

-- Master programmes (from migration 014 seed)
UPDATE `program` SET `name` = 'Computer Science',       `level` = 'Master' WHERE `code` = 'MSC_CS';
UPDATE `program` SET `name` = 'Software Engineering',   `level` = 'Master' WHERE `code` = 'MSC_SE';
UPDATE `program` SET `name` = 'Information Systems',    `level` = 'Master' WHERE `code` = 'MSC_IS';
UPDATE `program` SET `name` = 'Information Technology', `level` = 'Master' WHERE `code` = 'MSC_IT';

-- From migration 005 seed (PHD-* and MAST-* codes)
UPDATE `program` SET `name` = 'Computer Science',    `level` = 'PhD'    WHERE `code` = 'PHD-CS';
UPDATE `program` SET `name` = 'Software Engineering',`level` = 'PhD'    WHERE `code` = 'PHD-SE';
UPDATE `program` SET `name` = 'Information Technology',`level`= 'PhD'   WHERE `code` = 'PHD-IT';
UPDATE `program` SET `name` = 'Mathematics',         `level` = 'PhD'    WHERE `code` = 'PHD-MATH';
UPDATE `program` SET `name` = 'Computer Science',    `level` = 'Master' WHERE `code` = 'MAST-CS';
UPDATE `program` SET `name` = 'Software Engineering',`level` = 'Master' WHERE `code` = 'MAST-SE';
UPDATE `program` SET `name` = 'Information Technology',`level`= 'Master' WHERE `code` = 'MAST-IT';
UPDATE `program` SET `name` = 'Data Science',        `level` = 'Master' WHERE `code` = 'MAST-DS';
UPDATE `program` SET `name` = 'Mathematics',         `level` = 'Master' WHERE `code` = 'MAST-MATH';

-- For any remaining programs not covered above, infer level from remaining name patterns
UPDATE `program` SET `level` = 'Master'
WHERE `level` = 'PhD'
  AND (LOWER(`name`) LIKE '%master%' OR LOWER(`name`) LIKE '%sarjana%' OR LOWER(`code`) LIKE 'msc%' OR LOWER(`code`) LIKE 'mast%');

-- Strip any remaining long prefixes in case there are other programs in the DB
-- "Doctor of Philosophy in " = 24 chars → start at 25
UPDATE `program`
   SET `name` = TRIM(SUBSTRING(`name`, 25)), `level` = 'PhD'
 WHERE `name` LIKE 'Doctor of Philosophy in %';

-- "Master of Science in " = 21 chars → start at 22
UPDATE `program`
   SET `name` = TRIM(SUBSTRING(`name`, 22)), `level` = 'Master'
 WHERE `name` LIKE 'Master of Science in %';

-- "Master of " = 10 chars → start at 11
UPDATE `program`
   SET `name` = TRIM(SUBSTRING(`name`, 11)), `level` = 'Master'
 WHERE `name` LIKE 'Master of %'
   AND `name` NOT LIKE 'Master of Science in %';

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Backfill program_id on existing candidates that have no program_id
--    but whose program text matches a known programme name or code
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE `candidate` c
JOIN `program` p ON (
     p.code = c.program                          -- exact code match
  OR LOWER(p.name) = LOWER(c.program)            -- exact name match (cleaned)
  OR c.program LIKE CONCAT('%', p.name, '%')     -- name appears in old long program string
)
SET c.program_id = p.id
WHERE c.program_id IS NULL
  AND c.program IS NOT NULL AND c.program != '';

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. Create pending viva_appointment for existing candidates that have none
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO viva_appointment (candidate_id, status)
SELECT c.id, 'pending'
FROM candidate c
WHERE NOT EXISTS (
    SELECT 1 FROM viva_appointment va WHERE va.candidate_id = c.id
);

-- ─────────────────────────────────────────────────────────────────────────────
-- Done. Verify with:
--   SELECT code, level, name FROM program ORDER BY level, name;
--   SELECT c.full_name, c.program_id, va.status FROM candidate c LEFT JOIN viva_appointment va ON va.candidate_id = c.id;
-- ─────────────────────────────────────────────────────────────────────────────
