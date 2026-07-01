-- ============================================================
-- 052_test_examiners_seed.sql
-- Adds external examiners with varied nomination statuses so
-- the admin dashboard and nomination list have meaningful data.
--
-- Examiner emails are realistic-looking but fake — delivery
-- fails silently (EmailUtil.sendHtmlEmailAsync swallows errors).
--
-- Results after running:
--   verifiedExaminers   = 6   (panel picker filled)
--   pendingNominations  = 5   (dashboard counter + alert)
--   rejected            = 2   (visible in nomination list)
--
-- Safe: INSERT only — no existing rows are touched.
-- ============================================================

USE e_appointment_fskm;

-- ── Nominators: pick the two existing Academicians ──────────────────────────
SET @nom1 = (
    SELECT u.id FROM `user` u JOIN role r ON r.id = u.role_id
    WHERE r.name = 'Academician' AND u.status = 'active' ORDER BY u.id ASC  LIMIT 1
);
SET @nom2 = (
    SELECT u.id FROM `user` u JOIN role r ON r.id = u.role_id
    WHERE r.name = 'Academician' AND u.status = 'active' ORDER BY u.id DESC LIMIT 1
);

-- ── Research hierarchy (resolved by name) ───────────────────────────────────
SET @cs = (SELECT id FROM specialization WHERE name = 'Computer Science'       LIMIT 1);
SET @mt = (SELECT id FROM specialization WHERE name = 'Mathematics'             LIMIT 1);
SET @it = (SELECT id FROM specialization WHERE name = 'Information Technology'  LIMIT 1);

SET @ai = (SELECT id FROM expertise WHERE name LIKE '%Artificial Intelligence%' AND specialization_id = @cs LIMIT 1);
SET @se = (SELECT id FROM expertise WHERE name LIKE '%Software Engineering%'    AND specialization_id = @cs LIMIT 1);
SET @ds = (SELECT id FROM expertise WHERE name LIKE '%Data Science%'            AND specialization_id = @cs LIMIT 1);
SET @cy = (SELECT id FROM expertise WHERE name LIKE '%Cybersecurity%'           AND specialization_id = @cs LIMIT 1);
SET @am = (SELECT id FROM expertise WHERE name LIKE '%Applied Mathematics%'     AND specialization_id = @mt LIMIT 1);
SET @db = (SELECT id FROM expertise WHERE name LIKE '%Database%'                AND specialization_id = @it LIMIT 1);

-- ============================================================
-- VERIFIED EXAMINERS (6) — appear in appointment panel picker
-- ============================================================

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,expertise_id,status)
VALUES ('Prof. Dr.','Hafizuddin bin Muhamad Nor','Male','Malaysian','hafizuddin@utm.edu.my','+6075530000','Universiti Teknologi Malaysia','School of Computing','Malaysia','Artificial Intelligence','PhD','Professor',@cs,@ai,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom1,'verified','AI & machine learning specialist');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,expertise_id,status)
VALUES ('Assoc. Prof. Dr.','Sarah Lim Mei Ling','Female','Australian','s.lim@unimelb.edu.au','+61383447000','University of Melbourne','School of Computing and Information Systems','Australia','Software Engineering','PhD','Associate Professor',@cs,@se,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom2,'verified','Software engineering & agile methods');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,expertise_id,status)
VALUES ('Dr.','Tan Wei Jie','Male','Singaporean','twj@comp.nus.edu.sg','+6565162000','National University of Singapore','School of Computing','Singapore','Data Science','PhD','Senior Lecturer',@cs,@ds,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom1,'verified','Data science & analytics');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,expertise_id,status)
VALUES ('Dr.','James Whitfield','Male','British','j.whitfield@imperial.ac.uk','+442075891000','Imperial College London','Department of Computing','United Kingdom','Cybersecurity','PhD','Lecturer',@cs,@cy,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom2,'verified','Cybersecurity & network security');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,expertise_id,status)
VALUES ('Prof. Dr.','Norhaiza binti Ahmad','Female','Malaysian','norhaiza@upm.edu.my','+60389468000','Universiti Putra Malaysia','Faculty of Science','Malaysia','Applied Mathematics','PhD','Professor',@mt,@am,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom1,'verified','Applied mathematics & numerical methods');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,expertise_id,status)
VALUES ('Dr.','Budi Santoso','Male','Indonesian','b.santoso@ui.ac.id','+62215656000','Universitas Indonesia','Faculty of Computer Science','Indonesia','Information Technology','PhD','Associate Professor',@it,@db,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom2,'verified','Database systems & information retrieval');

-- ============================================================
-- PENDING NOMINATIONS (5) — feeds dashboard pendingNominations
-- 3 × status='pending'  +  2 × status='submitted'
-- ============================================================

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,status)
VALUES ('Dr.','Amirul Haziq bin Ramli','Male','Malaysian','amirul@usm.edu.my','+604653000','Universiti Sains Malaysia','School of Computer Sciences','Malaysia','Machine Learning','PhD','Lecturer',@cs,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom1,'pending','Awaiting examiner verification form');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,status)
VALUES ('Dr.','Priya Ramachandran','Female','Indian','p.ramachandran@iit.ac.in','+914422570000','Indian Institute of Technology Madras','Dept of Computer Science','India','Natural Language Processing','PhD','Assistant Professor',@cs,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom2,'pending','Pending examiner contact confirmation');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,status)
VALUES ('Assoc. Prof. Dr.','Lim Kok Wai','Male','Malaysian','limkw@utar.edu.my','+60355438000','Universiti Tunku Abdul Rahman','Faculty of IT','Malaysia','Computer Vision','PhD','Associate Professor',@cs,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom1,'pending','Under initial review');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,status)
VALUES ('Dr.','Ahmed Al-Rashidi','Male','Saudi Arabian','a.rashidi@kfupm.edu.sa','+96638600000','King Fahd University of Petroleum and Minerals','Computer Science','Saudi Arabia','Optimisation','PhD','Lecturer',@mt,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom2,'submitted','Submitted — awaiting admin review');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,status)
VALUES ('Dr.','Chen Jing','Female','Chinese','chenjing@tsinghua.edu.cn','+861062781000','Tsinghua University','School of Software','China','Cloud Computing','PhD','Associate Professor',@it,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom1,'submitted','Documents submitted, pending approval');

-- ============================================================
-- REJECTED NOMINATIONS (2) — visible in nomination history
-- ============================================================

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,status)
VALUES ('Dr.','Maria Santos','Female','Filipino','m.santos@dlsu.edu.ph','+63524501500','De La Salle University','College of Computer Studies','Philippines','HCI','PhD','Assistant Professor',@cs,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom2,'rejected','Conflict of interest identified');

INSERT INTO external_examiner (title,name,gender,nationality,email,phone,affiliation,faculty,country,specialization,qualification,position,specialization_id,status)
VALUES ('Dr.','Rajesh Patel','Male','Indian','r.patel@iimb.ac.in','+918022630000','Indian Institute of Management Bangalore','Information Systems','India','Operations Research','PhD','Senior Lecturer',@mt,'active');
INSERT INTO nomination (external_examiner_id,nominator_user_id,status,remarks) VALUES (LAST_INSERT_ID(),@nom1,'rejected','Examiner declined to participate');

-- ── Confirmation query ───────────────────────────────────────────────────────
SELECT n.status, COUNT(*) AS count
FROM nomination n
JOIN external_examiner ee ON ee.id = n.external_examiner_id
WHERE ee.email NOT LIKE '%ocean.umt.edu.my%'
  AND ee.created_at >= NOW() - INTERVAL 1 MINUTE
GROUP BY n.status;
