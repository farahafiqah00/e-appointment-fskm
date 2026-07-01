-- Migration 060: Assign staff numbers + fix expertise/division/area for 4 internal staff
--
-- Problems fixed:
--   1. fadzil/norzahra/aiman/hasnah have no staff_number (shows "–" in Staff List)
--   2. norzahra_saat seeded as CS/NULL expertise (053 LIKE '%Software Engineering%' under
--      CS found nothing — SE is a separate specialization in 047)
--   3. hasnah_yusof seeded as IT/NULL expertise (053 LIKE '%Database%' under IT found
--      nothing — correct expertise is Information Systems → Database Systems division)
--   4. All 4 are missing division_id and area_id
--   5. candidate.supervisor_name stores mixed formats ("Dr. Academician" vs "Academician")
--      because old seeds stored the display name with title embedded
--
-- All IDs are hardcoded from 047_replace_lookup_data.sql to avoid name-lookup fragility.
--
--   Specialization: 1=CS, 2=SE, 3=IT, 4=Mathematics
--   Expertise:      1=AI(CS), 4=SoftDev(SE), 8=InfoSys(IT), 10=AppMath(MT)
--   Division:       1=MachineLearning, 7=SoftwareArchitecture,
--                   16=DatabaseSystems, 19=MathematicalModelling
--   Area:           1=DeepLearning, 20=Microservices, 46=RelationalDatabases,
--                   56=Simulation&Modelling

USE e_appointment_fskm;

-- ── Step 1: Assign staff_number ────────────────────────────────────────────────
UPDATE academic_staff SET staff_number = 'UMT00005'
WHERE user_id = (SELECT id FROM `user` WHERE username = 'fadzil_hassan'  LIMIT 1);

UPDATE academic_staff SET staff_number = 'UMT00006'
WHERE user_id = (SELECT id FROM `user` WHERE username = 'norzahra_saat'  LIMIT 1);

UPDATE academic_staff SET staff_number = 'UMT00007'
WHERE user_id = (SELECT id FROM `user` WHERE username = 'aiman_zakaria'  LIMIT 1);

UPDATE academic_staff SET staff_number = 'UMT00008'
WHERE user_id = (SELECT id FROM `user` WHERE username = 'hasnah_yusof'   LIMIT 1);

-- ── Step 2: Fix Dr. Mohd Fadzil — CS / AI / Machine Learning / Deep Learning ──
UPDATE academic_staff SET
  specialization_id = 1,   -- Computer Science
  expertise_id      = 1,   -- Artificial Intelligence
  division_id       = 1,   -- Machine Learning
  area_id           = 1    -- Deep Learning
WHERE user_id = (SELECT id FROM `user` WHERE username = 'fadzil_hassan' LIMIT 1);

-- ── Step 3: Fix Dr. Siti Norzahra — SE / SoftDev / SoftwareArch / Microservices
--    053 incorrectly looked for 'Software Engineering' expertise under CS (none exists).
--    SE is its own specialization (id=2); SoftDev is expertise id=4.
UPDATE academic_staff SET
  specialization_id = 2,   -- Software Engineering
  expertise_id      = 4,   -- Software Development
  division_id       = 7,   -- Software Architecture
  area_id           = 20   -- Microservices
WHERE user_id = (SELECT id FROM `user` WHERE username = 'norzahra_saat' LIMIT 1);

-- ── Step 4: Fix Dr. Aiman — Mathematics / AppMath / MathModelling / Simulation ─
UPDATE academic_staff SET
  specialization_id = 4,   -- Mathematics
  expertise_id      = 10,  -- Applied Mathematics
  division_id       = 19,  -- Mathematical Modelling
  area_id           = 56   -- Simulation & Modelling
WHERE user_id = (SELECT id FROM `user` WHERE username = 'aiman_zakaria' LIMIT 1);

-- ── Step 5: Fix Dr. Hasnah — IT / InfoSys / DatabaseSystems / RelationalDB ────
--    053 incorrectly looked for 'Database' expertise under IT (none exists).
--    Correct path: IT → Information Systems → Database Systems → Relational Databases.
UPDATE academic_staff SET
  specialization_id = 3,   -- Information Technology
  expertise_id      = 8,   -- Information Systems
  division_id       = 16,  -- Database Systems
  area_id           = 46   -- Relational Databases
WHERE user_id = (SELECT id FROM `user` WHERE username = 'hasnah_yusof' LIMIT 1);

-- ── Step 6: Normalize candidate.supervisor_name ────────────────────────────────
-- Old seeds stored the display name with title ("Dr. Academician", "Prof. Dr. Ahmad Faris").
-- New seeds (056) store just the clean name ("Academician", "Ahmad Faris").
-- Normalize all to academic_staff.full_name (clean, no title prefix).
-- The display query in AppointmentDAO always reconstructs CONCAT(ast.title, ast.full_name)
-- via JOIN, so supervisor_name is only a fallback for unlinked (external) supervisors.
UPDATE candidate c
JOIN   academic_staff ast ON ast.id = c.supervisor_id
SET    c.supervisor_name = ast.full_name
WHERE  c.supervisor_id IS NOT NULL
  AND  c.supervisor_name != ast.full_name;

-- ── Verify ────────────────────────────────────────────────────────────────────
SELECT
    ast.staff_number,
    CONCAT(COALESCE(CONCAT(ast.title,' '),''), ast.full_name)  AS display_name,
    s.name   AS specialization,
    e.name   AS expertise,
    d.name   AS division,
    a.name   AS area
FROM   academic_staff ast
JOIN   `user`         u ON u.id = ast.user_id
LEFT JOIN specialization s ON s.id = ast.specialization_id
LEFT JOIN expertise      e ON e.id = ast.expertise_id
LEFT JOIN division       d ON d.id = ast.division_id
LEFT JOIN area           a ON a.id = ast.area_id
WHERE  ast.status = 'active'
ORDER  BY ast.staff_number;
