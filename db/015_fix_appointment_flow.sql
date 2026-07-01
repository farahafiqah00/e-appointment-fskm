-- Migration 015: Fix appointment creation flow + supervisor linkage
-- Run in phpMyAdmin against e_appointment_fskm AFTER migrations 001-014.
--
-- Fixes three issues:
--   1. viva_appointment.scheduled_at was NOT NULL – makes it nullable so an
--      appointment record can be created from a verified nomination before
--      the admin has picked a date.
--   2. The default 'academician' test user had no academic_staff row, so
--      supervisors who log in as 'academician' couldn't see their students.
--   3. Candidates S1011-S1013 (from 014) had supervisor_name set but
--      supervisor_id = NULL, breaking the supervisor's My-Students-Viva view.
--   4. Viva appointments from migration 009 use ad-hoc venue strings
--      ("Room A"-"Room E") that don't match the venue lookup table.
--      Map them to real venue names so they show pre-selected in the dropdown.

USE e_appointment_fskm;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Make scheduled_at nullable (appointments start unscheduled)
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE viva_appointment
  MODIFY COLUMN scheduled_at DATETIME NULL DEFAULT NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Ensure the default 'academician' user has an academic_staff row
--    (idempotent: INSERT IGNORE skips if user_id already exists)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT IGNORE INTO academic_staff (user_id, full_name, department, status)
SELECT u.id, u.full_name, 'Computer Science', 'active'
FROM `user` u
JOIN role r ON u.role_id = r.id
WHERE u.username = 'academician'
  AND r.name = 'Academician'
LIMIT 1;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Link candidates S1011-S1013 to the academician's academic_staff record
--    (only sets supervisor_id where it is still NULL)
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE candidate c
SET c.supervisor_id = (
    SELECT a.id
    FROM academic_staff a
    JOIN `user` u ON a.user_id = u.id
    WHERE u.username = 'academician'
    LIMIT 1
)
WHERE c.student_id IN ('S1011', 'S1012', 'S1013')
  AND c.supervisor_id IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Remap 009 ad-hoc venue strings to real venue table entries
--    (only updates rows that still use the old ad-hoc names)
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE viva_appointment SET venue = 'Meeting Room 1' WHERE venue = 'Room A';
UPDATE viva_appointment SET venue = 'Meeting Room 2' WHERE venue = 'Room B';
UPDATE viva_appointment SET venue = 'Meeting Room 3' WHERE venue = 'Room C';
UPDATE viva_appointment SET venue = 'Meeting Room 4' WHERE venue = 'Room D';
UPDATE viva_appointment SET venue = 'Conference Room A' WHERE venue = 'Room E';
