-- ============================================================
-- 056_test_candidates.sql
-- Adds 4 new postgraduate candidates in 'prepared' status.
-- ============================================================

USE e_appointment_fskm;

-- ── DIAGNOSTIC: run just these SELECTs first to verify all IDs
--    resolve before inserting. All columns must be non-NULL.
-- ────────────────────────────────────────────────────────────
SELECT
  (SELECT id FROM academic_staff WHERE full_name = 'Academician'                   LIMIT 1) AS sv_academician,
  (SELECT id FROM academic_staff WHERE full_name = 'Ahmad Faris'                   LIMIT 1) AS sv_faris,
  (SELECT id FROM academic_staff WHERE full_name = 'Mohd Fadzil bin Hassan'        LIMIT 1) AS sv_fadzil,
  (SELECT id FROM academic_staff WHERE full_name = 'Siti Norzahra binti Mohd Saat' LIMIT 1) AS sv_norzahra,
  (SELECT id FROM program WHERE code = 'PHD_CS' LIMIT 1) AS phd_cs,
  (SELECT id FROM program WHERE code = 'PHD_MT' LIMIT 1) AS phd_mt,
  (SELECT id FROM program WHERE code = 'MSC_R'  LIMIT 1) AS msc_r;

-- ── If any value above is NULL, fix it before running the INSERTs:
--    sv_academician NULL → run:
--      SELECT id, full_name FROM academic_staff WHERE user_id = (SELECT id FROM `user` WHERE email = 'rosooji@gmail.com');
--    msc_cs / msc_mt NULL → run:
--      SELECT id, code, name FROM program ORDER BY level, name;
-- ────────────────────────────────────────────────────────────

-- ── Resolve IDs ──────────────────────────────────────────────
SET @sv_academician = (SELECT id FROM academic_staff WHERE full_name = 'Academician'                   LIMIT 1);
SET @sv_faris       = (SELECT id FROM academic_staff WHERE full_name = 'Ahmad Faris'                   LIMIT 1);
SET @sv_fadzil      = (SELECT id FROM academic_staff WHERE full_name = 'Mohd Fadzil bin Hassan'        LIMIT 1);
SET @sv_norzahra    = (SELECT id FROM academic_staff WHERE full_name = 'Siti Norzahra binti Mohd Saat' LIMIT 1);

SET @phd_cs = (SELECT id FROM program WHERE code = 'PHD_CS' LIMIT 1);
SET @phd_mt = (SELECT id FROM program WHERE code = 'PHD_MT' LIMIT 1);
SET @msc_r  = (SELECT id FROM program WHERE code = 'MSC_R'  LIMIT 1);

-- ── Find the next free student_id before running: ────────────
--    SELECT student_id FROM candidate ORDER BY student_id;
-- Then replace P0011/P0012/P0013/P0014 below with the actual
-- next available numbers.
-- ─────────────────────────────────────────────────────────────

-- ============================================================
-- P0011 — PhD CS, supervised by Dr. Academician
-- ============================================================
INSERT INTO candidate (student_id, full_name, program, program_id,
  thesis_title, supervisor_name, supervisor_id, contact_email, nationality, status)
VALUES (
  'P0011', 'Nurul Hidayah binti Hamdan',
  'Doctor of Philosophy (Computer Science)', @phd_cs,  -- PHD_CS
  'Explainable Artificial Intelligence Framework for Clinical Decision Support in Oncology',
  'Academician', @sv_academician,
  'hidayah.hamdan@student.test', 'Malaysian', 'prepared'
);
SET @c11 = LAST_INSERT_ID();
INSERT INTO viva_appointment (candidate_id, status) VALUES (@c11, 'pending');

-- ============================================================
-- P0012 — PhD IT, supervised by Prof. Dr. Ahmad Faris
-- ============================================================
INSERT INTO candidate (student_id, full_name, program, program_id,
  thesis_title, supervisor_name, supervisor_id, contact_email, nationality, status)
VALUES (
  'P0012', 'Faris Al-Amin bin Zulkifli',
  'Doctor of Philosophy (Computer Science)', @phd_cs,  -- PHD_CS (no IT PhD in your programs)
  'A Blockchain-Based Framework for Secure and Auditable Electronic Health Record Sharing',
  'Ahmad Faris', @sv_faris,
  'farisalamin@student.test', 'Malaysian', 'prepared'
);
SET @c12 = LAST_INSERT_ID();
INSERT INTO viva_appointment (candidate_id, status) VALUES (@c12, 'pending');

-- ============================================================
-- P0013 — MSc CS, supervised by Dr. Mohd Fadzil (TDA dummy)
-- ============================================================
INSERT INTO candidate (student_id, full_name, program, program_id,
  thesis_title, supervisor_name, supervisor_id, contact_email, nationality, status)
VALUES (
  'P0013', 'Yong Jun Wei',
  'Master of Science (by Research)', @msc_r,  -- MSC_R
  'Federated Learning for Privacy-Preserving Intrusion Detection in Smart Grid Networks',
  'Mohd Fadzil bin Hassan', @sv_fadzil,
  'yongjunwei@student.test', 'Malaysian', 'prepared'
);
SET @c13 = LAST_INSERT_ID();
INSERT INTO viva_appointment (candidate_id, status) VALUES (@c13, 'pending');

-- ============================================================
-- P0014 — MSc Mathematics, supervised by Dr. Siti Norzahra (dummy)
-- ============================================================
INSERT INTO candidate (student_id, full_name, program, program_id,
  thesis_title, supervisor_name, supervisor_id, contact_email, nationality, status)
VALUES (
  'P0014', 'Siti Rahmah binti Othman',
  'Master of Science (by Research)', @msc_r,  -- MSC_R
  'Multi-Objective Optimisation of Resource Allocation in Cloud Computing Using Metaheuristic Algorithms',
  'Siti Norzahra binti Mohd Saat', @sv_norzahra,
  'sitirahmahotman@student.test', 'Malaysian', 'prepared'
);
SET @c14 = LAST_INSERT_ID();
INSERT INTO viva_appointment (candidate_id, status) VALUES (@c14, 'pending');

-- ── Confirmation ─────────────────────────────────────────────
SELECT c.student_id, c.full_name,
       CONCAT(COALESCE(CONCAT(ast.title,' '),''), COALESCE(ast.full_name, '(no academic_staff)')) AS supervisor,
       p.name AS program, c.status,
       (SELECT va.status FROM viva_appointment va WHERE va.candidate_id = c.id LIMIT 1) AS appt_status
FROM candidate c
LEFT JOIN academic_staff ast ON ast.id = c.supervisor_id
LEFT JOIN program p ON p.id = c.program_id
WHERE c.student_id IN ('P0011','P0012','P0013','P0014');
