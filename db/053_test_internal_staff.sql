-- ============================================================
-- 053_test_internal_staff.sql
-- Adds 4 Academician accounts with NO login capability plus
-- their academic_staff records so they appear in the panel
-- member picker (Internal Examiner / Chairperson / Secretary).
--
-- Password strategy:
--   hash = Base64(16 zero bytes) : Base64(32 zero bytes)
--        = AAAAAAAAAAAAAAAAAAAAAA==:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
--   PBKDF2 of any real password ≠ 32 zero bytes → verify() always returns false.
--   No account lock-out risk — login simply fails.
--
-- One of the four is given administrative_position='TDA' so
-- getEligibleLetterSigners() has an alternate signer when the
-- Dean is also the student's supervisor (prevents "No eligible signer").
--
-- Safe: INSERT only — no existing rows are touched.
-- ============================================================

USE e_appointment_fskm;

-- Clean up any partial inserts from a previous failed run.
-- academic_staff rows cascade-delete when user is deleted (ON DELETE CASCADE).
DELETE FROM `user` WHERE username IN ('fadzil_hassan','norzahra_saat','aiman_zakaria','hasnah_yusof');

SET @no_login = 'AAAAAAAAAAAAAAAAAAAAAA==:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
SET @academician_role = (SELECT id FROM role WHERE name = 'Academician' LIMIT 1);

SET @cs = (SELECT id FROM specialization WHERE name = 'Computer Science'       LIMIT 1);
SET @mt = (SELECT id FROM specialization WHERE name = 'Mathematics'             LIMIT 1);
SET @it = (SELECT id FROM specialization WHERE name = 'Information Technology'  LIMIT 1);

SET @ai = (SELECT id FROM expertise WHERE name LIKE '%Artificial Intelligence%' AND specialization_id = @cs LIMIT 1);
SET @se = (SELECT id FROM expertise WHERE name LIKE '%Software Engineering%'    AND specialization_id = @cs LIMIT 1);
SET @am = (SELECT id FROM expertise WHERE name LIKE '%Applied Mathematics%'     AND specialization_id = @mt LIMIT 1);
SET @db = (SELECT id FROM expertise WHERE name LIKE '%Database%'                AND specialization_id = @it LIMIT 1);

-- ============================================================
-- 1. Dr. Mohd Fadzil bin Hassan  (Computer Science / AI)
--    administrative_position = 'TDA'  ← alternate letter signer
-- ============================================================

INSERT INTO `user` (username, password_hash, full_name, email, role_id, status)
VALUES ('fadzil_hassan', @no_login, 'Mohd Fadzil bin Hassan', 'fadzil@umt.edu.my', @academician_role, 'active');

INSERT INTO academic_staff (user_id, full_name, title, department,
    academic_rank, administrative_position, specialization_id, expertise_id, status)
VALUES (LAST_INSERT_ID(), 'Mohd Fadzil bin Hassan', 'Dr.',
    'Department of Computer Science',
    'Senior Lecturer', 'TDA', @cs, @ai, 'active');

-- ============================================================
-- 2. Dr. Siti Norzahra binti Mohd Saat  (Computer Science / SE)
-- ============================================================

INSERT INTO `user` (username, password_hash, full_name, email, role_id, status)
VALUES ('norzahra_saat', @no_login, 'Siti Norzahra binti Mohd Saat', 'norzahra@umt.edu.my', @academician_role, 'active');

INSERT INTO academic_staff (user_id, full_name, title, department,
    academic_rank, administrative_position, specialization_id, expertise_id, status)
VALUES (LAST_INSERT_ID(), 'Siti Norzahra binti Mohd Saat', 'Dr.',
    'Department of Computer Science',
    'Lecturer', NULL, @cs, @se, 'active');

-- ============================================================
-- 3. Dr. Aiman bin Zakaria  (Mathematics / Applied Mathematics)
-- ============================================================

INSERT INTO `user` (username, password_hash, full_name, email, role_id, status)
VALUES ('aiman_zakaria', @no_login, 'Aiman bin Zakaria', 'aiman@umt.edu.my', @academician_role, 'active');

INSERT INTO academic_staff (user_id, full_name, title, department,
    academic_rank, administrative_position, specialization_id, expertise_id, status)
VALUES (LAST_INSERT_ID(), 'Aiman bin Zakaria', 'Dr.',
    'Department of Mathematics',
    'Lecturer', NULL, @mt, @am, 'active');

-- ============================================================
-- 4. Dr. Hasnah binti Mohd Yusof  (Information Technology / Database)
-- ============================================================

INSERT INTO `user` (username, password_hash, full_name, email, role_id, status)
VALUES ('hasnah_yusof', @no_login, 'Hasnah binti Mohd Yusof', 'hasnah@umt.edu.my', @academician_role, 'active');

INSERT INTO academic_staff (user_id, full_name, title, department,
    academic_rank, administrative_position, specialization_id, expertise_id, status)
VALUES (LAST_INSERT_ID(), 'Hasnah binti Mohd Yusof', 'Dr.',
    'Department of Information Technology',
    'Senior Lecturer', NULL, @it, @db, 'active');

-- ── Confirmation query ───────────────────────────────────────────────────────
SELECT a.title, a.full_name, a.academic_rank, a.administrative_position,
       s.name AS specialization, u.email
FROM academic_staff a
JOIN `user` u ON u.id = a.user_id
LEFT JOIN specialization s ON s.id = a.specialization_id
WHERE u.email IN ('fadzil@umt.edu.my','norzahra@umt.edu.my','aiman@umt.edu.my','hasnah@umt.edu.my');
