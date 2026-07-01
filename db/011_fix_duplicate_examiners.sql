-- Migration 011: Remove duplicate external_examiner rows
-- Caused by running migration 009 more than once.
-- Keeps only the row with the lowest id (original) per email address.

USE e_appointment_fskm;

-- Step 1: Remap any nomination/appointment_panel references to the duplicate ids
--         back to the original (lowest) id per email, then delete the duplicates.

-- Remap nomination references
UPDATE nomination n
JOIN external_examiner dup ON n.external_examiner_id = dup.id
JOIN (
  SELECT email, MIN(id) AS keep_id FROM external_examiner GROUP BY email
) orig ON dup.email = orig.email AND dup.id != orig.keep_id
SET n.external_examiner_id = orig.keep_id;

-- Remap appointment_panel references
UPDATE appointment_panel ap
JOIN external_examiner dup ON ap.external_examiner_id = dup.id
JOIN (
  SELECT email, MIN(id) AS keep_id FROM external_examiner GROUP BY email
) orig ON dup.email = orig.email AND dup.id != orig.keep_id
SET ap.external_examiner_id = orig.keep_id;

-- Step 2: Delete the duplicate rows (keep MIN(id) per email)
DELETE FROM external_examiner
WHERE id NOT IN (
  SELECT id FROM (
    SELECT MIN(id) AS id FROM external_examiner GROUP BY email
  ) AS keep_originals
);
