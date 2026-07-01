-- Migration 008: Link external_examiner to the full 4-level research hierarchy
-- (Specialization → Expertise → Division → Area)
-- Run this in phpMyAdmin against e_appointment_fskm AFTER migration 007.

USE e_appointment_fskm;

-- Level 1 & 2
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS specialization_id INT UNSIGNED;
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS expertise_id      INT UNSIGNED;

-- Level 3 & 4 (same 4-level structure as academic_staff)
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS division_id       INT UNSIGNED;
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS area_id           INT UNSIGNED;

-- Optional: backfill specialization_id from the legacy free-text column
-- where the text matches a known specialization name
UPDATE external_examiner ee
JOIN specialization s ON LOWER(TRIM(ee.specialization)) = LOWER(TRIM(s.name))
SET ee.specialization_id = s.id
WHERE ee.specialization_id IS NULL AND ee.specialization IS NOT NULL;
