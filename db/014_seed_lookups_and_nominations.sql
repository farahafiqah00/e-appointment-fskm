-- =============================================================================
-- 014_seed_lookups_and_nominations.sql
-- Comprehensive lookup data + 5 pending nominations by 'academician' user
--   • Programs (10 PhD + 4 Masters)
--   • Titles (extended)
--   • Countries & Universities (more)
--   • Venue (additional rooms)
--   • Research hierarchy (more areas)
--   • 5 new external examiners with 'submitted' nominations
--   • 3 new candidates, including one with an external co-supervisor
-- Run AFTER all migrations 001-013 and seed files.
-- =============================================================================

USE e_appointment_fskm;

-- =============================================================================
-- 0. SAFETY: ensure migration 012 columns exist on co_supervisor
--    (idempotent — no effect if 012 was already run)
-- =============================================================================
ALTER TABLE `co_supervisor`
  ADD COLUMN IF NOT EXISTS `cosv_type`         ENUM('internal','external') NOT NULL DEFAULT 'external',
  ADD COLUMN IF NOT EXISTS `internal_staff_id` INT UNSIGNED NULL,
  ADD COLUMN IF NOT EXISTS `university_name`   VARCHAR(200) NULL,
  ADD COLUMN IF NOT EXISTS `faculty`           VARCHAR(200) NULL,
  ADD COLUMN IF NOT EXISTS `programme`         VARCHAR(200) NULL,
  ADD COLUMN IF NOT EXISTS `country`           VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS `email`             VARCHAR(150) NULL;

-- =============================================================================
-- 1. PROGRAMS  (at least 10 entries)
-- =============================================================================
INSERT INTO program (code, name) VALUES
  ('CS',     'Doctor of Philosophy in Computer Science'),
  ('SE',     'Doctor of Philosophy in Software Engineering'),
  ('IS',     'Doctor of Philosophy in Information Systems'),
  ('IT',     'Doctor of Philosophy in Information Technology'),
  ('MT',     'Doctor of Philosophy in Mathematics'),
  ('AI',     'Doctor of Philosophy in Artificial Intelligence'),
  ('DS',     'Doctor of Philosophy in Data Science'),
  ('CY',     'Doctor of Philosophy in Cybersecurity'),
  ('NS',     'Doctor of Philosophy in Network Security'),
  ('HCI',    'Doctor of Philosophy in Human-Computer Interaction'),
  ('MSC_CS', 'Master of Science in Computer Science'),
  ('MSC_SE', 'Master of Science in Software Engineering'),
  ('MSC_IS', 'Master of Science in Information Systems'),
  ('MSC_IT', 'Master of Science in Information Technology')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- =============================================================================
-- 2. TITLES  (fill any gaps)
-- =============================================================================
INSERT INTO title (name) VALUES
  ('Mr.'), ('Mrs.'), ('Ms.'), ('Miss'), ('Dr.'), ('Ts.'), ('Ts. Dr.'),
  ('Ir.'), ('Ir. Dr.'),
  ('Prof.'), ('Prof. Dr.'), ('Prof. Ts.'), ('Prof. Ts. Dr.'),
  ('Prof. Ir.'), ('Prof. Ir. Dr.'),
  ('Assoc. Prof.'), ('Assoc. Prof. Dr.'), ('Assoc. Prof. Ts.'),
  ('Assoc. Prof. Ts. Dr.'), ('Assoc. Prof. Ir.'), ('Assoc. Prof. Ir. Dr.')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- =============================================================================
-- 3. COUNTRIES (additional)
-- =============================================================================
INSERT INTO country (name, iso_code) VALUES
  ('Malaysia',        'MY'),
  ('United Kingdom',  'GB'),
  ('United States',   'US'),
  ('Australia',       'AU'),
  ('Japan',           'JP'),
  ('Singapore',       'SG'),
  ('Indonesia',       'ID'),
  ('Germany',         'DE'),
  ('Canada',          'CA'),
  ('New Zealand',     'NZ'),
  ('Saudi Arabia',    'SA'),
  ('China',           'CN'),
  ('South Korea',     'KR'),
  ('Netherlands',     'NL'),
  ('France',          'FR')
ON DUPLICATE KEY UPDATE iso_code = VALUES(iso_code);

-- =============================================================================
-- 4. UNIVERSITIES (additional)
-- =============================================================================
INSERT INTO university (name, country_id) VALUES
  -- Malaysian public universities
  ('Universiti Teknologi Malaysia',          (SELECT id FROM country WHERE name='Malaysia')),
  ('Universiti Putra Malaysia',              (SELECT id FROM country WHERE name='Malaysia')),
  ('Universiti Sains Malaysia',              (SELECT id FROM country WHERE name='Malaysia')),
  ('Universiti Malaya',                      (SELECT id FROM country WHERE name='Malaysia')),
  ('Universiti Kebangsaan Malaysia',         (SELECT id FROM country WHERE name='Malaysia')),
  ('Universiti Teknologi MARA',              (SELECT id FROM country WHERE name='Malaysia')),
  ('Multimedia University',                  (SELECT id FROM country WHERE name='Malaysia')),
  ('Universiti Utara Malaysia',              (SELECT id FROM country WHERE name='Malaysia')),
  -- International
  ('National University of Singapore',       (SELECT id FROM country WHERE name='Singapore')),
  ('Nanyang Technological University',       (SELECT id FROM country WHERE name='Singapore')),
  ('University of Melbourne',               (SELECT id FROM country WHERE name='Australia')),
  ('University of Queensland',              (SELECT id FROM country WHERE name='Australia')),
  ('Auckland University of Technology',     (SELECT id FROM country WHERE name='New Zealand')),
  ('Tokyo Institute of Technology',         (SELECT id FROM country WHERE name='Japan')),
  ('Osaka University',                      (SELECT id FROM country WHERE name='Japan')),
  ('Universitas Indonesia',                 (SELECT id FROM country WHERE name='Indonesia')),
  ('Technical University of Munich',        (SELECT id FROM country WHERE name='Germany')),
  ('University of Toronto',                 (SELECT id FROM country WHERE name='Canada')),
  ('Imperial College London',              (SELECT id FROM country WHERE name='United Kingdom')),
  ('University of Edinburgh',              (SELECT id FROM country WHERE name='United Kingdom')),
  ('Massachusetts Institute of Technology',(SELECT id FROM country WHERE name='United States')),
  ('Carnegie Mellon University',           (SELECT id FROM country WHERE name='United States')),
  ('King Abdulaziz University',            (SELECT id FROM country WHERE name='Saudi Arabia')),
  ('Peking University',                    (SELECT id FROM country WHERE name='China')),
  ('Korea Advanced Institute of Science and Technology',(SELECT id FROM country WHERE name='South Korea')),
  ('Delft University of Technology',       (SELECT id FROM country WHERE name='Netherlands'))
ON DUPLICATE KEY UPDATE country_id = VALUES(country_id);

-- =============================================================================
-- 5. VENUE (additional rooms beyond migration 013)
-- =============================================================================
INSERT IGNORE INTO venue (name, location, capacity) VALUES
  ('Meeting Room 1',         'Level 3, FSKM Building',  15),
  ('Meeting Room 2',         'Level 3, FSKM Building',  15),
  ('Meeting Room 3',         'Level 4, FSKM Building',  20),
  ('Meeting Room 4',         'Level 4, FSKM Building',  20),
  ('Conference Room A',      'Level 5, FSKM Building',  30),
  ('Conference Room B',      'Level 5, FSKM Building',  30),
  ('Seminar Room 1',         'Level 2, FSKM Building',  40),
  ('Seminar Room 2',         'Level 2, FSKM Building',  40),
  ('Dean''s Meeting Room',   'Dean''s Office, Level 6', 12),
  ('Online (Microsoft Teams)',NULL,                      999),
  ('Meeting Room 5',         'Level 3, FSKM Building',  15),
  ('Lab Meeting Room',       'Level 1, FSKM Building',  10),
  ('Lecture Hall 1',         'Block A, FSKM',           80),
  ('Lecture Hall 2',         'Block B, FSKM',           80);

-- =============================================================================
-- 6. RESEARCH HIERARCHY — additional areas under existing divisions
-- =============================================================================
-- More areas under Machine Learning division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Deep Learning',
   (SELECT id FROM specialization WHERE name='Computer Science'),
   (SELECT id FROM division WHERE name='Machine Learning' LIMIT 1)),
  ('Transfer Learning',
   (SELECT id FROM specialization WHERE name='Computer Science'),
   (SELECT id FROM division WHERE name='Machine Learning' LIMIT 1)),
  ('Natural Language Processing',
   (SELECT id FROM specialization WHERE name='Computer Science'),
   (SELECT id FROM division WHERE name='Knowledge & Reasoning' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Areas under Software Architecture division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Microservices Architecture',
   (SELECT id FROM specialization WHERE name='Software Engineering'),
   (SELECT id FROM division WHERE name='Software Architecture & Design' LIMIT 1)),
  ('Design Patterns',
   (SELECT id FROM specialization WHERE name='Software Engineering'),
   (SELECT id FROM division WHERE name='Software Architecture & Design' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Areas under Cybersecurity division (IT specialization)
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Network Forensics',
   (SELECT id FROM specialization WHERE name='Information Technology'),
   (SELECT id FROM division WHERE name='Cybersecurity' LIMIT 1)),
  ('Malware Analysis',
   (SELECT id FROM specialization WHERE name='Information Technology'),
   (SELECT id FROM division WHERE name='Cybersecurity' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Areas under IoT Systems
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Edge Computing',
   (SELECT id FROM specialization WHERE name='Information Technology'),
   (SELECT id FROM division WHERE name='IoT Systems' LIMIT 1)),
  ('Embedded Systems',
   (SELECT id FROM specialization WHERE name='Information Technology'),
   (SELECT id FROM division WHERE name='IoT Systems' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Areas under Applied Mathematics
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Fuzzy Logic',
   (SELECT id FROM specialization WHERE name='Mathematics'),
   (SELECT id FROM division WHERE name='Machine Learning' LIMIT 1)),
  ('Optimisation Algorithms',
   (SELECT id FROM specialization WHERE name='Mathematics'),
   (SELECT id FROM division WHERE name='Machine Learning' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- =============================================================================
-- 7. THREE NEW CANDIDATES WITH CO-SUPERVISORS
--    (including external co-supervisors from other universities)
-- =============================================================================
INSERT INTO candidate (student_id, full_name, program, program_id, contact_email, thesis_title, supervisor_name, status)
VALUES
  ('S1011', 'Ahmad Syafiq Bin Zulkarnain',
   'Computer Science',
   (SELECT id FROM program WHERE code='CS'),
   'syafiq@student.fskm.edu.my',
   'Federated Deep Learning for Privacy-Preserving IoT Anomaly Detection',
   'Dr. Hafizah Binti Hussain',
   'prepared'),

  ('S1012', 'Nurul Ain Binti Mohd Fauzi',
   'Software Engineering',
   (SELECT id FROM program WHERE code='SE'),
   'nurulaim@student.fskm.edu.my',
   'Explainable AI Framework for Clinical Decision Support Systems',
   'Assoc. Prof. Dr. Razali Bin Mohd Yusof',
   'prepared'),

  ('S1013', 'Tan Wei Kang',
   'Information Technology',
   (SELECT id FROM program WHERE code='IT'),
   'wktan@student.fskm.edu.my',
   'Blockchain-Based Secure Data Sharing in Healthcare IoT Networks',
   'Dr. Norhidayah Binti Abdul Rahim',
   'prepared')
ON DUPLICATE KEY UPDATE thesis_title = VALUES(thesis_title), supervisor_name = VALUES(supervisor_name);

-- Co-supervisors: S1011 has an internal co-supervisor
INSERT INTO co_supervisor (candidate_id, name, cosv_type, internal_staff_id, university_name, faculty, programme, country, email)
VALUES
  ((SELECT id FROM candidate WHERE student_id='S1011'),
   'Dr. Hafizah Binti Hussain',
   'internal',
   (SELECT id FROM academic_staff WHERE user_id=(SELECT id FROM `user` WHERE username='dr_hafizah') LIMIT 1),
   NULL, NULL, NULL, NULL, NULL)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- S1012 has an EXTERNAL co-supervisor from National University of Singapore
INSERT INTO co_supervisor (candidate_id, name, cosv_type, internal_staff_id, university_name, faculty, programme, country, email)
VALUES
  ((SELECT id FROM candidate WHERE student_id='S1012'),
   'Dr. Lin Feng',
   'external',
   NULL,
   'National University of Singapore',
   'School of Computing',
   'Doctor of Philosophy in Computer Science',
   'Singapore',
   'lin.feng@comp.nus.edu.sg')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- S1013 has an EXTERNAL co-supervisor from Imperial College London
INSERT INTO co_supervisor (candidate_id, name, cosv_type, internal_staff_id, university_name, faculty, programme, country, email)
VALUES
  ((SELECT id FROM candidate WHERE student_id='S1013'),
   'Prof. Dr. James Whitfield',
   'external',
   NULL,
   'Imperial College London',
   'Department of Computing',
   'Doctor of Philosophy in Cybersecurity',
   'United Kingdom',
   'j.whitfield@imperial.ac.uk')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- =============================================================================
-- 8. FIVE NEW EXTERNAL EXAMINERS  (to be nominated, status will be 'submitted')
-- =============================================================================
INSERT INTO external_examiner
  (title, name, gender, nationality, email, phone,
   affiliation, faculty, university_id, country_id, country,
   specialization, qualification, position,
   specialization_id, expertise_id, division_id, area_id, status)
VALUES

-- Examiner 1: Malaysian, AI/ML
('Prof. Dr.',
 'Mohd Ridzuan Bin Mohd Nor',
 'Male', 'Malaysian',
 'ridzuan@ukm.edu.my', '+60389215000',
 'Universiti Kebangsaan Malaysia',
 'Faculty of Information Science and Technology',
 (SELECT id FROM university WHERE name='Universiti Kebangsaan Malaysia' LIMIT 1),
 (SELECT id FROM country WHERE name='Malaysia'),
 'Malaysia',
 'Machine Learning',
 'PhD',
 'Professor',
 (SELECT id FROM specialization WHERE name='Computer Science'),
 (SELECT id FROM expertise WHERE name='Artificial Intelligence' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1),
 (SELECT id FROM division WHERE name='Machine Learning' LIMIT 1),
 (SELECT id FROM area WHERE name='Deep Learning' LIMIT 1),
 'active'),

-- Examiner 2: UK, Software Engineering
('Dr.',
 'Catherine Hughes',
 'Female', 'British',
 'c.hughes@ed.ac.uk', '+441316509000',
 'University of Edinburgh',
 'School of Informatics',
 (SELECT id FROM university WHERE name='University of Edinburgh' LIMIT 1),
 (SELECT id FROM country WHERE name='United Kingdom'),
 'United Kingdom',
 'Software Engineering',
 'PhD',
 'Senior Lecturer',
 (SELECT id FROM specialization WHERE name='Software Engineering'),
 (SELECT id FROM expertise WHERE name='Software Development' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1),
 (SELECT id FROM division WHERE name='Software Architecture & Design' LIMIT 1),
 (SELECT id FROM area WHERE name='Microservices Architecture' LIMIT 1),
 'active'),

-- Examiner 3: Australian, Data Science
('Assoc. Prof.',
 'Dr. Wei Chen',
 'Male', 'Australian',
 'w.chen@uq.edu.au', '+61733652000',
 'University of Queensland',
 'School of Electrical Engineering and Computer Science',
 (SELECT id FROM university WHERE name='University of Queensland' LIMIT 1),
 (SELECT id FROM country WHERE name='Australia'),
 'Australia',
 'Data Science',
 'PhD',
 'Associate Professor',
 (SELECT id FROM specialization WHERE name='Computer Science'),
 (SELECT id FROM expertise WHERE name='Data Science & Analytics' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1),
 (SELECT id FROM division WHERE name='Big Data & Cloud' LIMIT 1),
 (SELECT id FROM area WHERE name='Sentiment Analysis' LIMIT 1),
 'active'),

-- Examiner 4: South Korean, IoT/Security
('Prof.',
 'Dr. Joon-Ho Park',
 'Male', 'South Korean',
 'jpark@kaist.ac.kr', '+82429503000',
 'Korea Advanced Institute of Science and Technology',
 'School of Computing',
 (SELECT id FROM university WHERE name='Korea Advanced Institute of Science and Technology' LIMIT 1),
 (SELECT id FROM country WHERE name='South Korea'),
 'South Korea',
 'Cybersecurity',
 'PhD',
 'Professor',
 (SELECT id FROM specialization WHERE name='Information Technology'),
 (SELECT id FROM expertise WHERE name='Computer Networks' AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1),
 (SELECT id FROM division WHERE name='Cybersecurity' LIMIT 1),
 (SELECT id FROM area WHERE name='Network Forensics' LIMIT 1),
 'active'),

-- Examiner 5: Dutch, HCI
('Dr.',
 'Anna van der Berg',
 'Female', 'Dutch',
 'a.vandenberg@tudelft.nl', '+31152786000',
 'Delft University of Technology',
 'Faculty of Industrial Design Engineering',
 (SELECT id FROM university WHERE name='Delft University of Technology' LIMIT 1),
 (SELECT id FROM country WHERE name='Netherlands'),
 'Netherlands',
 'Human-Computer Interaction',
 'PhD',
 'Assistant Professor',
 (SELECT id FROM specialization WHERE name='Software Engineering'),
 (SELECT id FROM expertise WHERE name='Human-Computer Interaction' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1),
 (SELECT id FROM division WHERE name='UI/UX Research' LIMIT 1),
 (SELECT id FROM area WHERE name='Usability Evaluation' LIMIT 1),
 'active');

-- =============================================================================
-- 9. FIVE 'submitted' NOMINATIONS  by the default 'academician' user
--    These simulate nominations waiting for admin review
-- =============================================================================
INSERT IGNORE INTO nomination
  (candidate_id, external_examiner_id, nominator_user_id, status, remarks)
VALUES

-- Nom 1: S1011 → Mohd Ridzuan (ML/AI expert matching IoT anomaly thesis)
((SELECT id FROM candidate WHERE student_id='S1011'),
 (SELECT id FROM external_examiner WHERE email='ridzuan@ukm.edu.my'),
 (SELECT id FROM `user` WHERE username='academician'),
 'submitted',
 'Nom-S1011-ridzuan'),

-- Nom 2: S1012 → Catherine Hughes (SE expert matching clinical XAI thesis)
((SELECT id FROM candidate WHERE student_id='S1012'),
 (SELECT id FROM external_examiner WHERE email='c.hughes@ed.ac.uk'),
 (SELECT id FROM `user` WHERE username='academician'),
 'submitted',
 'Nom-S1012-hughes'),

-- Nom 3: S1013 → Joon-Ho Park (Cybersecurity expert matching blockchain/IoT thesis)
((SELECT id FROM candidate WHERE student_id='S1013'),
 (SELECT id FROM external_examiner WHERE email='jpark@kaist.ac.kr'),
 (SELECT id FROM `user` WHERE username='academician'),
 'submitted',
 'Nom-S1013-park'),

-- Nom 4: S1011 second nomination → Wei Chen (data science / federated learning)
((SELECT id FROM candidate WHERE student_id='S1011'),
 (SELECT id FROM external_examiner WHERE email='w.chen@uq.edu.au'),
 (SELECT id FROM `user` WHERE username='academician'),
 'submitted',
 'Nom-S1011-weichen'),

-- Nom 5: S1012 second nomination → Anna van der Berg (HCI / explainable AI UI)
((SELECT id FROM candidate WHERE student_id='S1012'),
 (SELECT id FROM external_examiner WHERE email='a.vandenberg@tudelft.nl'),
 (SELECT id FROM `user` WHERE username='academician'),
 'submitted',
 'Nom-S1012-vandenberg');

-- =============================================================================
-- END
-- =============================================================================
-- Summary of what was inserted:
--   • Programs : 14 (CS, SE, IS, IT, MT, AI, DS, CY, NS, HCI + 4 MSc)
--   • Titles   : 21 Malaysian academic title variants
--   • Countries: 15  (MY, GB, US, AU, JP, SG, ID, DE, CA, NZ, SA, CN, KR, NL, FR)
--   • Universities: 26 (8 Malaysian + 18 international)
--   • Venues   : 14 rooms (incl. online)
--   • Areas    : 10 additional (Deep Learning, Transfer Learning, NLP, etc.)
--   • Candidates: 3 new (S1011, S1012, S1013)
--     - S1011 : internal co-supervisor (Dr. Hafizah)
--     - S1012 : external co-supervisor from NUS, Singapore
--     - S1013 : external co-supervisor from Imperial College London, UK
--   • External Examiners: 5 new (MY, UK, AU, KR, NL)
--   • Nominations: 5 with status='submitted' nominated by 'academician' user
-- =============================================================================
