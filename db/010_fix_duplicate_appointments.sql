-- Migration 010: Remove duplicate viva_appointment rows
-- Caused by running migration 009 more than once (INSERT IGNORE has no effect
-- without a UNIQUE constraint on candidate_id).
-- Keeps only the row with the highest id (latest insert) per candidate.

USE e_appointment_fskm;

-- Step 1: Remove orphaned appointment_panel rows whose appointment no longer exists
-- (not needed yet, but safe to keep as a guard)

-- Step 2: Delete duplicate viva_appointments — keep only MAX(id) per candidate
DELETE FROM viva_appointment
WHERE id NOT IN (
  SELECT id FROM (
    SELECT MAX(id) AS id FROM viva_appointment GROUP BY candidate_id
  ) AS keep_latest
);
