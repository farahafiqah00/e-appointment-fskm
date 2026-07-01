-- Migration 009: Replace placeholder test data with realistic dummy data
-- Cleans up obvious test rows, adds 10 proper examiners with full hierarchy,
-- 7 more candidates, verified nominations, appointments and panel history.
-- Run in phpMyAdmin against e_appointment_fskm AFTER migration 008.
--
-- NOTE: Uses LIMIT 1 on all subqueries against university/expertise/division/area
--       because those tables lack UNIQUE constraints and may have duplicates if
--       earlier migrations were run more than once.

USE e_appointment_fskm;

-- Safety: ensure columns exist
ALTER TABLE area              ADD COLUMN IF NOT EXISTS division_id        INT UNSIGNED;
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS country            VARCHAR(100);
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS specialization_id  INT UNSIGNED;
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS expertise_id       INT UNSIGNED;
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS division_id        INT UNSIGNED;
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS area_id            INT UNSIGNED;
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS university_id      INT UNSIGNED;
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS country_id         INT UNSIGNED;
ALTER TABLE academic_staff    ADD COLUMN IF NOT EXISTS specialization_id  INT UNSIGNED;
ALTER TABLE academic_staff    ADD COLUMN IF NOT EXISTS expertise_id       INT UNSIGNED;
ALTER TABLE academic_staff    ADD COLUMN IF NOT EXISTS division_id        INT UNSIGNED;
ALTER TABLE academic_staff    ADD COLUMN IF NOT EXISTS area_id            INT UNSIGNED;

-- 1. Remove placeholder data
DELETE FROM appointment_panel WHERE external_examiner_id IN (SELECT id FROM external_examiner WHERE email='chen@example.org');
DELETE FROM nomination        WHERE external_examiner_id IN (SELECT id FROM external_examiner WHERE email='chen@example.org');
DELETE FROM external_examiner WHERE email='chen@example.org';
UPDATE appointment_panel SET member_role='Chairperson'       WHERE member_role='Chair';
UPDATE appointment_panel SET member_role='External Examiner' WHERE member_role='Examiner';

-- 2. Hierarchy data
INSERT INTO expertise (specialization_id, name, description) VALUES
  ((SELECT id FROM specialization WHERE name='Computer Science'),'Natural Language Processing','NLP, text mining, conversational AI')
ON DUPLICATE KEY UPDATE description=VALUES(description);

INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Deep Learning',    (SELECT id FROM specialization WHERE name='Computer Science'),       (SELECT id FROM expertise WHERE name='Artificial Intelligence'     AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science')      LIMIT 1)),
  ('Text Mining & NLP',(SELECT id FROM specialization WHERE name='Computer Science'),       (SELECT id FROM expertise WHERE name='Natural Language Processing' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science')      LIMIT 1)),
  ('Cybersecurity',    (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM expertise WHERE name='Computer Networks'           AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1)),
  ('IoT Systems',      (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM expertise WHERE name='Wireless & Mobile'           AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1)),
  ('UI/UX Research',   (SELECT id FROM specialization WHERE name='Software Engineering'),   (SELECT id FROM expertise WHERE name='Human-Computer Interaction'  AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering')  LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id=VALUES(expertise_id);

INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Sentiment Analysis',          (SELECT id FROM specialization WHERE name='Computer Science'),       (SELECT id FROM division WHERE name='Text Mining & NLP' LIMIT 1)),
  ('Convolutional Neural Networks',(SELECT id FROM specialization WHERE name='Computer Science'),      (SELECT id FROM division WHERE name='Deep Learning'     LIMIT 1)),
  ('Intrusion Detection',         (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Cybersecurity'     LIMIT 1)),
  ('Smart Home & Wearables',      (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='IoT Systems'       LIMIT 1)),
  ('Usability Evaluation',        (SELECT id FROM specialization WHERE name='Software Engineering'),   (SELECT id FROM division WHERE name='UI/UX Research'    LIMIT 1))
ON DUPLICATE KEY UPDATE division_id=VALUES(division_id);

-- 3. Countries & universities
INSERT INTO country (name, iso_code) VALUES
  ('Australia','AU'),('Japan','JP'),('Singapore','SG'),('Indonesia','ID'),('Germany','DE'),('Canada','CA')
ON DUPLICATE KEY UPDATE iso_code=VALUES(iso_code);

INSERT INTO university (name, country_id) VALUES
  ('Universiti Teknologi Malaysia',    (SELECT id FROM country WHERE name='Malaysia')),
  ('Universiti Putra Malaysia',        (SELECT id FROM country WHERE name='Malaysia')),
  ('Universiti Sains Malaysia',        (SELECT id FROM country WHERE name='Malaysia')),
  ('Universiti Malaya',                (SELECT id FROM country WHERE name='Malaysia')),
  ('National University of Singapore', (SELECT id FROM country WHERE name='Singapore')),
  ('University of Melbourne',          (SELECT id FROM country WHERE name='Australia')),
  ('Tokyo Institute of Technology',    (SELECT id FROM country WHERE name='Japan')),
  ('Universitas Indonesia',            (SELECT id FROM country WHERE name='Indonesia')),
  ('Technical University of Munich',   (SELECT id FROM country WHERE name='Germany')),
  ('University of Toronto',            (SELECT id FROM country WHERE name='Canada'))
ON DUPLICATE KEY UPDATE country_id=VALUES(country_id);

-- 4. Fix existing examiners
UPDATE external_examiner SET
  specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering'),
  expertise_id=(SELECT id FROM expertise WHERE name='Software Development'     AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering')   LIMIT 1),
  division_id =(SELECT id FROM division  WHERE name='Agile & DevOps'           LIMIT 1),
  area_id     =(SELECT id FROM area      WHERE name='Requirements Engineering' LIMIT 1),
  country='Malaysia'
WHERE email='ahmad@example.org';

UPDATE external_examiner SET
  specialization_id=(SELECT id FROM specialization WHERE name='Computer Science'),
  expertise_id=(SELECT id FROM expertise WHERE name='Artificial Intelligence'  AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1),
  division_id =(SELECT id FROM division  WHERE name='Machine Learning'         LIMIT 1),
  area_id     =(SELECT id FROM area      WHERE name='Reinforcement Learning'   LIMIT 1),
  country='United Kingdom'
WHERE email='smith@example.org';

UPDATE external_examiner SET name='Prof. Dr. Ahmad Faris Bin Ismail' WHERE email='ahmad@example.org';
UPDATE external_examiner SET name='Dr. Jonathan Smith'               WHERE email='smith@example.org';

-- 5. New external examiners
INSERT INTO external_examiner (name, affiliation, email, phone, university_id, country_id, country, specialization_id, expertise_id, division_id, area_id) VALUES

('Prof. Dr. Lim Kok Wai','National University of Singapore','limkw@nus.edu.sg','+6565162000',
 (SELECT id FROM university WHERE name='National University of Singapore' LIMIT 1),
 (SELECT id FROM country WHERE name='Singapore'),'Singapore',
 (SELECT id FROM specialization WHERE name='Computer Science'),
 (SELECT id FROM expertise WHERE name='Natural Language Processing' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1),
 (SELECT id FROM division WHERE name='Text Mining & NLP' LIMIT 1),
 (SELECT id FROM area WHERE name='Sentiment Analysis' LIMIT 1)),

('Assoc. Prof. Sarah Mitchell','University of Melbourne','s.mitchell@unimelb.edu.au','+61383445000',
 (SELECT id FROM university WHERE name='University of Melbourne' LIMIT 1),
 (SELECT id FROM country WHERE name='Australia'),'Australia',
 (SELECT id FROM specialization WHERE name='Computer Science'),
 (SELECT id FROM expertise WHERE name='Artificial Intelligence' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1),
 (SELECT id FROM division WHERE name='Deep Learning' LIMIT 1),
 (SELECT id FROM area WHERE name='Convolutional Neural Networks' LIMIT 1)),

('Dr. Nurul Huda Binti Zainal','Universiti Teknologi Malaysia','nurulhuda@utm.my','+6075532000',
 (SELECT id FROM university WHERE name='Universiti Teknologi Malaysia' LIMIT 1),
 (SELECT id FROM country WHERE name='Malaysia'),'Malaysia',
 (SELECT id FROM specialization WHERE name='Information Technology'),
 (SELECT id FROM expertise WHERE name='Computer Networks' AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1),
 (SELECT id FROM division WHERE name='Cybersecurity' LIMIT 1),
 (SELECT id FROM area WHERE name='Intrusion Detection' LIMIT 1)),

('Prof. Hiroshi Tanaka','Tokyo Institute of Technology','htanaka@titech.ac.jp','+81357342000',
 (SELECT id FROM university WHERE name='Tokyo Institute of Technology' LIMIT 1),
 (SELECT id FROM country WHERE name='Japan'),'Japan',
 (SELECT id FROM specialization WHERE name='Information Technology'),
 (SELECT id FROM expertise WHERE name='Wireless & Mobile' AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1),
 (SELECT id FROM division WHERE name='IoT Systems' LIMIT 1),
 (SELECT id FROM area WHERE name='Smart Home & Wearables' LIMIT 1)),

('Dr. Farah Nabilah Binti Mohd Nasir','Universiti Putra Malaysia','farah.nabilah@upm.edu.my','+60389472000',
 (SELECT id FROM university WHERE name='Universiti Putra Malaysia' LIMIT 1),
 (SELECT id FROM country WHERE name='Malaysia'),'Malaysia',
 (SELECT id FROM specialization WHERE name='Software Engineering'),
 (SELECT id FROM expertise WHERE name='Human-Computer Interaction' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1),
 (SELECT id FROM division WHERE name='UI/UX Research' LIMIT 1),
 (SELECT id FROM area WHERE name='Usability Evaluation' LIMIT 1)),

('Prof. David Okonkwo','University of Toronto','d.okonkwo@utoronto.ca','+14169782000',
 (SELECT id FROM university WHERE name='University of Toronto' LIMIT 1),
 (SELECT id FROM country WHERE name='Canada'),'Canada',
 (SELECT id FROM specialization WHERE name='Software Engineering'),
 (SELECT id FROM expertise WHERE name='Software Process & Methods' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1),
 (SELECT id FROM division WHERE name='Agile & DevOps' LIMIT 1),
 (SELECT id FROM area WHERE name='Requirements Engineering' LIMIT 1)),

('Dr. Amirul Hakim Bin Roslan','Universiti Sains Malaysia','amirul.hakim@usm.my','+6046534000',
 (SELECT id FROM university WHERE name='Universiti Sains Malaysia' LIMIT 1),
 (SELECT id FROM country WHERE name='Malaysia'),'Malaysia',
 (SELECT id FROM specialization WHERE name='Computer Science'),
 (SELECT id FROM expertise WHERE name='Data Science & Analytics' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1),
 (SELECT id FROM division WHERE name='Knowledge & Reasoning' LIMIT 1),
 (SELECT id FROM area WHERE name='Natural Language Processing' LIMIT 1)),

('Prof. Dr. Klaus Becker','Technical University of Munich','k.becker@tum.de','+4989289200',
 (SELECT id FROM university WHERE name='Technical University of Munich' LIMIT 1),
 (SELECT id FROM country WHERE name='Germany'),'Germany',
 (SELECT id FROM specialization WHERE name='Computer Science'),
 (SELECT id FROM expertise WHERE name='Computer Security' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1),
 (SELECT id FROM division WHERE name='Cybersecurity' LIMIT 1),
 (SELECT id FROM area WHERE name='Intrusion Detection' LIMIT 1)),

('Assoc. Prof. Reza Firmansyah','Universitas Indonesia','reza.firm@ui.ac.id','+62215640000',
 (SELECT id FROM university WHERE name='Universitas Indonesia' LIMIT 1),
 (SELECT id FROM country WHERE name='Indonesia'),'Indonesia',
 (SELECT id FROM specialization WHERE name='Computer Science'),
 (SELECT id FROM expertise WHERE name='Computer Systems' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1),
 (SELECT id FROM division WHERE name='Parallel & Distributed Computing' LIMIT 1),
 (SELECT id FROM area WHERE name='Natural Language Processing' LIMIT 1)),

('Dr. Siti Zawiah Binti Md Dawal','Universiti Malaya','siti.zawiah@um.edu.my','+60379672000',
 (SELECT id FROM university WHERE name='Universiti Malaya' LIMIT 1),
 (SELECT id FROM country WHERE name='Malaysia'),'Malaysia',
 (SELECT id FROM specialization WHERE name='Mathematics'),
 (SELECT id FROM expertise WHERE name='Applied Mathematics' AND specialization_id=(SELECT id FROM specialization WHERE name='Mathematics') LIMIT 1),
 NULL, NULL);

-- 6. New academician users
INSERT INTO `user` (role_id, title_id, program_id, username, password_hash, email, full_name, phone, status, created_at) VALUES
  ((SELECT id FROM role WHERE name='Academician'),(SELECT id FROM title WHERE name='Dr'),   (SELECT id FROM program WHERE code='CS'),'assoc_razali',   SHA2('password123',256),'razali@fskm.edu.my',    'Assoc. Prof. Dr. Razali Bin Mohd Yusof','0123451001','active',NOW()),
  ((SELECT id FROM role WHERE name='Academician'),(SELECT id FROM title WHERE name='Dr'),   (SELECT id FROM program WHERE code='SE'),'dr_hafizah',     SHA2('password123',256),'hafizah@fskm.edu.my',   'Dr. Hafizah Binti Hussain',             '0123451002','active',NOW()),
  ((SELECT id FROM role WHERE name='Academician'),(SELECT id FROM title WHERE name='Prof'), (SELECT id FROM program WHERE code='CS'),'prof_zulkarnain',SHA2('password123',256),'zulkarnain@fskm.edu.my','Prof. Dr. Zulkarnain Bin Khalid',       '0123451003','active',NOW()),
  ((SELECT id FROM role WHERE name='Academician'),(SELECT id FROM title WHERE name='Dr'),   (SELECT id FROM program WHERE code='IS'),'dr_norhidayah',  SHA2('password123',256),'norhidayah@fskm.edu.my','Dr. Norhidayah Binti Abdul Rahim',      '0123451004','active',NOW()),
  ((SELECT id FROM role WHERE name='Academician'),(SELECT id FROM title WHERE name='Assoc'),(SELECT id FROM program WHERE code='SE'),'assoc_shahrul',  SHA2('password123',256),'shahrul@fskm.edu.my',   'Assoc. Prof. Shahrul Nizam Bin Ahmad',  '0123451005','active',NOW())
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name), email=VALUES(email);

INSERT INTO academic_staff (user_id, department, specialization_id, expertise_id, division_id, area_id) VALUES
  ((SELECT id FROM `user` WHERE username='drx'),          'Software Engineering',   (SELECT id FROM specialization WHERE name='Software Engineering'),   (SELECT id FROM expertise WHERE name='Software Development'       AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering')   LIMIT 1),(SELECT id FROM division WHERE name='Agile & DevOps'   LIMIT 1),(SELECT id FROM area WHERE name='Requirements Engineering' LIMIT 1)),
  ((SELECT id FROM `user` WHERE username='assoc_razali'), 'Computer Science',       (SELECT id FROM specialization WHERE name='Computer Science'),       (SELECT id FROM expertise WHERE name='Artificial Intelligence'    AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science')      LIMIT 1),(SELECT id FROM division WHERE name='Machine Learning' LIMIT 1),(SELECT id FROM area WHERE name='Deep Learning'             LIMIT 1)),
  ((SELECT id FROM `user` WHERE username='dr_hafizah'),   'Software Engineering',   (SELECT id FROM specialization WHERE name='Software Engineering'),   (SELECT id FROM expertise WHERE name='Human-Computer Interaction' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering')   LIMIT 1),(SELECT id FROM division WHERE name='UI/UX Research'  LIMIT 1),(SELECT id FROM area WHERE name='Usability Evaluation'      LIMIT 1)),
  ((SELECT id FROM `user` WHERE username='prof_zulkarnain'),'Computer Science',     (SELECT id FROM specialization WHERE name='Computer Science'),       (SELECT id FROM expertise WHERE name='Computer Security'          AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science')      LIMIT 1),(SELECT id FROM division WHERE name='Cybersecurity'    LIMIT 1),(SELECT id FROM area WHERE name='Intrusion Detection'       LIMIT 1)),
  ((SELECT id FROM `user` WHERE username='dr_norhidayah'),'Information Technology', (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM expertise WHERE name='Information Systems'        AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1),(SELECT id FROM division WHERE name='Enterprise Systems' LIMIT 1),(SELECT id FROM area WHERE name='Routing & Switching'      LIMIT 1)),
  ((SELECT id FROM `user` WHERE username='assoc_shahrul'),'Software Engineering',   (SELECT id FROM specialization WHERE name='Software Engineering'),   (SELECT id FROM expertise WHERE name='Software Process & Methods' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering')   LIMIT 1),(SELECT id FROM division WHERE name='Agile & DevOps'   LIMIT 1),(SELECT id FROM area WHERE name='Scrum & Kanban'            LIMIT 1))
ON DUPLICATE KEY UPDATE specialization_id=VALUES(specialization_id),expertise_id=VALUES(expertise_id),division_id=VALUES(division_id),area_id=VALUES(area_id);

-- 7. Candidates
INSERT INTO candidate (student_id, full_name, program, program_id, contact_email, thesis_title, supervisor_name) VALUES
  ('S1004','Muhammad Haziq Bin Azlan',     'Computer Science',    (SELECT id FROM program WHERE code='CS'),'haziq@example.com',    'Deep Learning Framework for Real-Time Object Detection in Autonomous Vehicles','Prof. Dr. Ahmad Faris Bin Ismail'),
  ('S1005','Nur Aisyah Binti Kamarudin',   'Software Engineering',(SELECT id FROM program WHERE code='SE'),'aisyah@example.com',   'Usability Evaluation of Mobile Health Applications Among Elderly Users',       'Dr. Farah Nabilah Binti Mohd Nasir'),
  ('S1006','Chong Wei Liang',              'Computer Science',    (SELECT id FROM program WHERE code='CS'),'chongwl@example.com',  'Hybrid Intrusion Detection System Using Machine Learning on IoT Networks',     'Dr. Nurul Huda Binti Zainal'),
  ('S1007','Siti Hajar Binti Ramli',       'Information Systems', (SELECT id FROM program WHERE code='IS'),'sitihajar@example.com','Sentiment Analysis of Social Media Data for Public Health Monitoring',        'Prof. Dr. Lim Kok Wai'),
  ('S1008','Muhammad Izzat Bin Zulkifli',  'Software Engineering',(SELECT id FROM program WHERE code='SE'),'izzat@example.com',    'Automated Code Review Tool Using Static Analysis and NLP',                    'Prof. Dr. Ahmad Faris Bin Ismail'),
  ('S1009','Loh Jia Yi',                   'Computer Science',    (SELECT id FROM program WHERE code='CS'),'lohjy@example.com',    'Federated Learning for Privacy-Preserving Medical Image Classification',       'Dr. Jonathan Smith'),
  ('S1010','Nur Fatimah Binti Abdul Hamid','Information Systems', (SELECT id FROM program WHERE code='IS'),'fatimah@example.com',  'IoT-based Smart Energy Management System for Campus Buildings',               'Prof. Hiroshi Tanaka')
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name),thesis_title=VALUES(thesis_title),supervisor_name=VALUES(supervisor_name);

UPDATE candidate SET thesis_title='Agile Requirements Engineering for Large-Scale Enterprise Systems',supervisor_name='Prof. Dr. Ahmad Faris Bin Ismail' WHERE student_id='S1001';
UPDATE candidate SET thesis_title='Software Architecture Patterns for Cloud-Native Microservices',    supervisor_name='Dr. Jonathan Smith'               WHERE student_id='S1002';
UPDATE candidate SET thesis_title='Reinforcement Learning for Adaptive Game AI',                      supervisor_name='Assoc. Prof. Sarah Mitchell'       WHERE student_id='S1003';

-- 8. Verified nominations
UPDATE nomination SET status='verified' WHERE remarks IN ('Nomination 1','Nomination 2');

INSERT IGNORE INTO nomination (candidate_id, external_examiner_id, nominator_user_id, status, remarks) VALUES
  ((SELECT id FROM candidate WHERE student_id='S1003'),(SELECT id FROM external_examiner WHERE email='limkw@nus.edu.sg'),        (SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1003-limkw'),
  ((SELECT id FROM candidate WHERE student_id='S1004'),(SELECT id FROM external_examiner WHERE email='s.mitchell@unimelb.edu.au'),(SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1004-mitchell'),
  ((SELECT id FROM candidate WHERE student_id='S1005'),(SELECT id FROM external_examiner WHERE email='farah.nabilah@upm.edu.my'), (SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1005-farah'),
  ((SELECT id FROM candidate WHERE student_id='S1006'),(SELECT id FROM external_examiner WHERE email='nurulhuda@utm.my'),         (SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1006-nurul'),
  ((SELECT id FROM candidate WHERE student_id='S1007'),(SELECT id FROM external_examiner WHERE email='htanaka@titech.ac.jp'),     (SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1007-tanaka'),
  ((SELECT id FROM candidate WHERE student_id='S1008'),(SELECT id FROM external_examiner WHERE email='d.okonkwo@utoronto.ca'),    (SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1008-okonkwo'),
  ((SELECT id FROM candidate WHERE student_id='S1009'),(SELECT id FROM external_examiner WHERE email='amirul.hakim@usm.my'),      (SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1009-amirul'),
  ((SELECT id FROM candidate WHERE student_id='S1010'),(SELECT id FROM external_examiner WHERE email='k.becker@tum.de'),          (SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1010-becker'),
  ((SELECT id FROM candidate WHERE student_id='S1001'),(SELECT id FROM external_examiner WHERE email='reza.firm@ui.ac.id'),       (SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1001-reza'),
  ((SELECT id FROM candidate WHERE student_id='S1002'),(SELECT id FROM external_examiner WHERE email='siti.zawiah@um.edu.my'),    (SELECT id FROM `user` WHERE username='drx'),'verified','Nom-S1002-siti');

-- 9. Viva appointments (delete first to prevent duplicates on re-run)
DELETE FROM viva_appointment WHERE candidate_id IN (
  SELECT id FROM candidate WHERE student_id IN ('S1004','S1005','S1006','S1007','S1008')
);

INSERT INTO viva_appointment (candidate_id, nomination_id, scheduled_at, venue, duration_minutes, status) VALUES
  ((SELECT id FROM candidate WHERE student_id='S1004'),(SELECT id FROM nomination WHERE remarks='Nom-S1004-mitchell'),NOW() + INTERVAL 10 DAY,'Room C',90,'scheduled'),
  ((SELECT id FROM candidate WHERE student_id='S1005'),(SELECT id FROM nomination WHERE remarks='Nom-S1005-farah'),   NOW() + INTERVAL 12 DAY,'Room D',90,'scheduled'),
  ((SELECT id FROM candidate WHERE student_id='S1006'),(SELECT id FROM nomination WHERE remarks='Nom-S1006-nurul'),   NOW() + INTERVAL 15 DAY,'Room A',90,'scheduled'),
  ((SELECT id FROM candidate WHERE student_id='S1007'),(SELECT id FROM nomination WHERE remarks='Nom-S1007-tanaka'),  NOW() + INTERVAL 18 DAY,'Room B',90,'scheduled'),
  ((SELECT id FROM candidate WHERE student_id='S1008'),(SELECT id FROM nomination WHERE remarks='Nom-S1008-okonkwo'), NOW() + INTERVAL 20 DAY,'Room E',90,'scheduled');

-- 10. Seed panel history
DELETE FROM appointment_panel WHERE appointment_id IN (
  SELECT va.id FROM viva_appointment va JOIN candidate c ON va.candidate_id=c.id WHERE c.student_id IN ('S1001','S1002')
);

INSERT IGNORE INTO appointment_panel (appointment_id, internal_user_id, external_examiner_id, member_role, is_chair) VALUES
  ((SELECT va.id FROM viva_appointment va JOIN candidate c ON va.candidate_id=c.id WHERE c.student_id='S1001' LIMIT 1),(SELECT id FROM `user` WHERE username='drx'),  NULL,'Chairperson',1),
  ((SELECT va.id FROM viva_appointment va JOIN candidate c ON va.candidate_id=c.id WHERE c.student_id='S1001' LIMIT 1),(SELECT id FROM `user` WHERE username='admin'),NULL,'Recorder',0),
  ((SELECT va.id FROM viva_appointment va JOIN candidate c ON va.candidate_id=c.id WHERE c.student_id='S1001' LIMIT 1),NULL,(SELECT id FROM external_examiner WHERE email='ahmad@example.org'),'External Examiner',0),
  ((SELECT va.id FROM viva_appointment va JOIN candidate c ON va.candidate_id=c.id WHERE c.student_id='S1002' LIMIT 1),(SELECT id FROM `user` WHERE username='admin'),NULL,'Chairperson',1),
  ((SELECT va.id FROM viva_appointment va JOIN candidate c ON va.candidate_id=c.id WHERE c.student_id='S1002' LIMIT 1),(SELECT id FROM `user` WHERE username='drx'),  NULL,'Recorder',0),
  ((SELECT va.id FROM viva_appointment va JOIN candidate c ON va.candidate_id=c.id WHERE c.student_id='S1002' LIMIT 1),NULL,(SELECT id FROM external_examiner WHERE email='smith@example.org'),'External Examiner',0);
