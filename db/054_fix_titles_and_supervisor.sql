-- ============================================================
-- 054_fix_titles_and_supervisor.sql
-- Q1: Add "Dr." prefix to user.full_name for the 4 dummy
--     Academician accounts so User List shows titles.
-- Q2: Re-assign P0003's supervisor away from Dean.
--     Edit the WHERE clause name to pick a different supervisor.
-- ============================================================

USE e_appointment_fskm;

-- ── Q1: Fix display names in User List ──────────────────────
UPDATE `user` SET full_name = 'Dr. Mohd Fadzil bin Hassan'       WHERE username = 'fadzil_hassan';
UPDATE `user` SET full_name = 'Dr. Siti Norzahra binti Mohd Saat' WHERE username = 'norzahra_saat';
UPDATE `user` SET full_name = 'Dr. Aiman bin Zakaria'             WHERE username = 'aiman_zakaria';
UPDATE `user` SET full_name = 'Dr. Hasnah binti Mohd Yusof'       WHERE username = 'hasnah_yusof';

-- ── Q2: Change P0003 supervisor ─────────────────────────────
-- Available choices (run this SELECT first to see full_name values):
--   SELECT id, CONCAT(COALESCE(CONCAT(title,' '),''), full_name) AS display
--   FROM academic_staff WHERE status='active' ORDER BY full_name;
--
-- Default: Dr. Aisyah Najihah.  Change 'Aisyah Najihah' to any
-- other academic_staff.full_name (the clean name WITHOUT title).

UPDATE candidate
SET
  supervisor_id   = (SELECT id FROM academic_staff WHERE full_name = 'Aisyah Najihah' LIMIT 1),
  supervisor_name = 'Aisyah Najihah'
WHERE student_id = 'P0003';

-- Verify
SELECT student_id, supervisor_name, supervisor_id FROM candidate WHERE student_id = 'P0003';
