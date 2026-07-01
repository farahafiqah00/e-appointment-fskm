-- ============================================================
-- 055_enrich_examiners.sql
-- Fills in missing expertise / division / area for the 6
-- verified examiners seeded in 052. Identified by email so
-- it is safe to re-run (UPDATE is idempotent).
--
-- Hierarchy used (from 003_research_hierarchy.sql):
--   CS  → Artificial Intelligence  → Machine Learning    → Deep Learning
--   SE  → Software Development     → Soft. Arch. & Design → Microservices
--   CS  → Data Science & Analytics → Big Data & Cloud   → Cloud Computing
--   CS  → Computer Security        → Cryptography       (no area seeded)
--   Mth → Applied Mathematics      → Statistics & Prob. → Statistical Modelling
--   IT  → Information Systems      → Database Systems   → Relational Databases
-- ============================================================

USE e_appointment_fskm;

-- ── Resolve hierarchy IDs once ───────────────────────────────
-- Specializations
SET @cs  = (SELECT id FROM specialization WHERE name = 'Computer Science'       LIMIT 1);
SET @se  = (SELECT id FROM specialization WHERE name = 'Software Engineering'   LIMIT 1);
SET @it  = (SELECT id FROM specialization WHERE name = 'Information Technology' LIMIT 1);
SET @mt  = (SELECT id FROM specialization WHERE name = 'Mathematics'            LIMIT 1);

-- Expertise
SET @ai  = (SELECT id FROM expertise WHERE name = 'Artificial Intelligence'  AND specialization_id = @cs LIMIT 1);
SET @sd  = (SELECT id FROM expertise WHERE name = 'Software Development'     AND specialization_id = @se LIMIT 1);
SET @ds  = (SELECT id FROM expertise WHERE name = 'Data Science & Analytics' AND specialization_id = @cs LIMIT 1);
SET @sec = (SELECT id FROM expertise WHERE name = 'Computer Security'        AND specialization_id = @cs LIMIT 1);
SET @am  = (SELECT id FROM expertise WHERE name = 'Applied Mathematics'      AND specialization_id = @mt LIMIT 1);
SET @is  = (SELECT id FROM expertise WHERE name = 'Information Systems'      AND specialization_id = @it LIMIT 1);

-- Divisions
SET @dml = (SELECT id FROM division WHERE name = 'Machine Learning'           LIMIT 1);
SET @dsa = (SELECT id FROM division WHERE name = 'Software Architecture & Design' LIMIT 1);
SET @bdc = (SELECT id FROM division WHERE name = 'Big Data & Cloud'           LIMIT 1);
SET @cry = (SELECT id FROM division WHERE name = 'Cryptography' AND specialization_id = @cs LIMIT 1);
SET @stp = (SELECT id FROM division WHERE name = 'Statistics & Probability'   LIMIT 1);
SET @dbs = (SELECT id FROM division WHERE name = 'Database Systems'           LIMIT 1);

-- Areas
SET @adl = (SELECT id FROM area WHERE name = 'Deep Learning'           LIMIT 1);
SET @ams = (SELECT id FROM area WHERE name = 'Microservices'           LIMIT 1);
SET @acc = (SELECT id FROM area WHERE name = 'Cloud Computing'         LIMIT 1);
-- No area seeded under Cryptography division — left NULL for Whitfield
SET @asm = (SELECT id FROM area WHERE name = 'Statistical Modelling'   LIMIT 1);
SET @ard = (SELECT id FROM area WHERE name = 'Relational Databases'    LIMIT 1);

-- ── 1. Prof. Dr. Hafizuddin — CS / AI ────────────────────────
UPDATE external_examiner
SET division_id = @dml, area_id = @adl
WHERE email = 'hafizuddin@utm.edu.my';

-- ── 2. Assoc. Prof. Dr. Sarah Lim — SE / Software Dev ────────
-- Also corrects specialization from CS → SE (AI expertise was NULL)
UPDATE external_examiner
SET specialization_id = @se, expertise_id = @sd,
    division_id = @dsa, area_id = @ams
WHERE email = 's.lim@unimelb.edu.au';

-- ── 3. Dr. Tan Wei Jie — CS / Data Science ───────────────────
UPDATE external_examiner
SET division_id = @bdc, area_id = @acc
WHERE email = 'twj@comp.nus.edu.sg';

-- ── 4. Dr. James Whitfield — CS / Computer Security ──────────
-- expertise_id was NULL (looked up 'Cybersecurity'; real name is 'Computer Security')
UPDATE external_examiner
SET expertise_id = @sec, division_id = @cry, area_id = NULL
WHERE email = 'j.whitfield@imperial.ac.uk';

-- ── 5. Prof. Dr. Norhaiza — Mathematics / Applied Maths ──────
UPDATE external_examiner
SET division_id = @stp, area_id = @asm
WHERE email = 'norhaiza@upm.edu.my';

-- ── 6. Dr. Budi Santoso — IT / Information Systems ───────────
-- expertise_id was NULL (looked up 'Database%'; real name is 'Information Systems')
UPDATE external_examiner
SET expertise_id = @is, division_id = @dbs, area_id = @ard
WHERE email = 'b.santoso@ui.ac.id';

-- ── Confirmation ─────────────────────────────────────────────
SELECT ee.name, s.name AS spec, e.name AS expertise, d.name AS division, a.name AS area
FROM external_examiner ee
LEFT JOIN specialization s ON s.id  = ee.specialization_id
LEFT JOIN expertise      e ON e.id  = ee.expertise_id
LEFT JOIN division       d ON d.id  = ee.division_id
LEFT JOIN area           a ON a.id  = ee.area_id
WHERE ee.email IN ('hafizuddin@utm.edu.my','s.lim@unimelb.edu.au','twj@comp.nus.edu.sg',
                   'j.whitfield@imperial.ac.uk','norhaiza@upm.edu.my','b.santoso@ui.ac.id')
ORDER BY ee.name;
