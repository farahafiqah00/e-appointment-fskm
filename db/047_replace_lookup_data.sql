-- =============================================================================
-- Migration 047: Replace all lookup data - clean FSKM-specific values
--
-- Hierarchy: Specialization (4) -> Expertise (12) -> Division (24) -> Area (72)
--
-- Uses explicit IDs + DELETE instead of TRUNCATE to avoid phpMyAdmin
-- session-variable and AUTO_INCREMENT reset issues.
-- =============================================================================

USE e_appointment_fskm;

SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- STEP 1 - NULL out all hierarchy FKs in dependent tables
-- =============================================================================
UPDATE academic_staff    SET specialization_id = NULL, expertise_id = NULL, division_id = NULL, area_id = NULL;
UPDATE external_examiner SET specialization_id = NULL, expertise_id = NULL, division_id = NULL, area_id = NULL;

-- =============================================================================
-- STEP 2 - Clear hierarchy tables (dependency order) and reset counters
-- =============================================================================
DELETE FROM area;
DELETE FROM division;
DELETE FROM expertise;
DELETE FROM specialization;

ALTER TABLE area           AUTO_INCREMENT = 1;
ALTER TABLE division       AUTO_INCREMENT = 1;
ALTER TABLE expertise      AUTO_INCREMENT = 1;
ALTER TABLE specialization AUTO_INCREMENT = 1;

-- =============================================================================
-- STEP 3 - SPECIALIZATION (Level 1)
--   id  name
--   1   Computer Science
--   2   Software Engineering
--   3   Information Technology
--   4   Mathematics
-- =============================================================================
INSERT INTO specialization (id, name) VALUES
  (1, 'Computer Science'),
  (2, 'Software Engineering'),
  (3, 'Information Technology'),
  (4, 'Mathematics');

-- =============================================================================
-- STEP 4 - EXPERTISE (Level 2 - 3 per Specialization)
--   id   spec_id  name
--   1    1        Artificial Intelligence
--   2    1        Data Science
--   3    1        Computer Systems
--   4    2        Software Development
--   5    2        Human-Computer Interaction
--   6    2        Software Process
--   7    3        Computer Networks
--   8    3        Information Systems
--   9    3        Emerging Technologies
--   10   4        Applied Mathematics
--   11   4        Computational Mathematics
--   12   4        Financial Mathematics & Statistics
-- =============================================================================
INSERT INTO expertise (id, specialization_id, name) VALUES
  ( 1, 1, 'Artificial Intelligence'),
  ( 2, 1, 'Data Science'),
  ( 3, 1, 'Computer Systems'),
  ( 4, 2, 'Software Development'),
  ( 5, 2, 'Human-Computer Interaction'),
  ( 6, 2, 'Software Process'),
  ( 7, 3, 'Computer Networks'),
  ( 8, 3, 'Information Systems'),
  ( 9, 3, 'Emerging Technologies'),
  (10, 4, 'Applied Mathematics'),
  (11, 4, 'Computational Mathematics'),
  (12, 4, 'Financial Mathematics & Statistics');

-- =============================================================================
-- STEP 5 - DIVISION (Level 3 - 2 per Expertise)
--   id   spec_id  exp_id  name
--   1    1        1       Machine Learning
--   2    1        1       Computer Vision & NLP
--   3    1        2       Big Data & Analytics
--   4    1        2       Knowledge Discovery
--   5    1        3       Distributed Computing
--   6    1        3       Computer Architecture
--   7    2        4       Software Architecture
--   8    2        4       Software Testing & Quality
--   9    2        5       Interface Design
--   10   2        5       Usability Engineering
--   11   2        6       Agile & DevOps
--   12   2        6       Requirements Engineering
--   13   3        7       Network Infrastructure
--   14   3        7       Network Security & Cryptography
--   15   3        8       Enterprise Systems
--   16   3        8       Database Systems
--   17   3        9       Internet of Things
--   18   3        9       Blockchain & Digital Systems
--   19   4        10      Mathematical Modelling
--   20   4        10      Optimisation
--   21   4        11      Numerical Methods
--   22   4        11      Discrete Mathematics
--   23   4        12      Quantitative Finance
--   24   4        12      Statistical Analysis
-- =============================================================================
INSERT INTO division (id, specialization_id, expertise_id, name) VALUES
  ( 1, 1,  1, 'Machine Learning'),
  ( 2, 1,  1, 'Computer Vision & NLP'),
  ( 3, 1,  2, 'Big Data & Analytics'),
  ( 4, 1,  2, 'Knowledge Discovery'),
  ( 5, 1,  3, 'Distributed Computing'),
  ( 6, 1,  3, 'Computer Architecture'),
  ( 7, 2,  4, 'Software Architecture'),
  ( 8, 2,  4, 'Software Testing & Quality'),
  ( 9, 2,  5, 'Interface Design'),
  (10, 2,  5, 'Usability Engineering'),
  (11, 2,  6, 'Agile & DevOps'),
  (12, 2,  6, 'Requirements Engineering'),
  (13, 3,  7, 'Network Infrastructure'),
  (14, 3,  7, 'Network Security & Cryptography'),
  (15, 3,  8, 'Enterprise Systems'),
  (16, 3,  8, 'Database Systems'),
  (17, 3,  9, 'Internet of Things'),
  (18, 3,  9, 'Blockchain & Digital Systems'),
  (19, 4, 10, 'Mathematical Modelling'),
  (20, 4, 10, 'Optimisation'),
  (21, 4, 11, 'Numerical Methods'),
  (22, 4, 11, 'Discrete Mathematics'),
  (23, 4, 12, 'Quantitative Finance'),
  (24, 4, 12, 'Statistical Analysis');

-- =============================================================================
-- STEP 6 - AREA (Level 4 - 3 per Division, 72 total)
-- =============================================================================
INSERT INTO area (id, division_id, name) VALUES
  -- Division 1: Machine Learning
  ( 1,  1, 'Deep Learning'),
  ( 2,  1, 'Reinforcement Learning'),
  ( 3,  1, 'Statistical Learning'),
  -- Division 2: Computer Vision & NLP
  ( 4,  2, 'Image Processing'),
  ( 5,  2, 'Natural Language Processing'),
  ( 6,  2, 'Pattern Recognition'),
  -- Division 3: Big Data & Analytics
  ( 7,  3, 'Data Mining'),
  ( 8,  3, 'Business Intelligence'),
  ( 9,  3, 'Visual Analytics'),
  -- Division 4: Knowledge Discovery
  (10,  4, 'Knowledge Graphs'),
  (11,  4, 'Predictive Modelling'),
  (12,  4, 'Information Retrieval'),
  -- Division 5: Distributed Computing
  (13,  5, 'Cloud Computing'),
  (14,  5, 'Edge Computing'),
  (15,  5, 'Parallel Computing'),
  -- Division 6: Computer Architecture
  (16,  6, 'Embedded Systems'),
  (17,  6, 'GPU Computing'),
  (18,  6, 'Hardware Design'),
  -- Division 7: Software Architecture
  (19,  7, 'Design Patterns'),
  (20,  7, 'Microservices'),
  (21,  7, 'Service-Oriented Architecture'),
  -- Division 8: Software Testing & Quality
  (22,  8, 'Unit & Integration Testing'),
  (23,  8, 'Performance Testing'),
  (24,  8, 'Quality Assurance'),
  -- Division 9: Interface Design
  (25,  9, 'UI/UX Design'),
  (26,  9, 'Mobile Interface'),
  (27,  9, 'Web Design'),
  -- Division 10: Usability Engineering
  (28, 10, 'User Research'),
  (29, 10, 'Accessibility'),
  (30, 10, 'Interaction Design'),
  -- Division 11: Agile & DevOps
  (31, 11, 'Scrum & Kanban'),
  (32, 11, 'Continuous Integration/Delivery'),
  (33, 11, 'Automated Testing'),
  -- Division 12: Requirements Engineering
  (34, 12, 'Requirements Analysis'),
  (35, 12, 'Use Case Modelling'),
  (36, 12, 'Model-Driven Development'),
  -- Division 13: Network Infrastructure
  (37, 13, 'Wireless Networks'),
  (38, 13, 'Software-Defined Networking'),
  (39, 13, 'Network Protocols'),
  -- Division 14: Network Security & Cryptography
  (40, 14, 'Firewall & Intrusion Detection'),
  (41, 14, 'Cryptographic Algorithms'),
  (42, 14, 'Ethical Hacking'),
  -- Division 15: Enterprise Systems
  (43, 15, 'ERP Systems'),
  (44, 15, 'Knowledge Management'),
  (45, 15, 'Business Process Management'),
  -- Division 16: Database Systems
  (46, 16, 'Relational Databases'),
  (47, 16, 'NoSQL & Graph Databases'),
  (48, 16, 'Database Performance Tuning'),
  -- Division 17: Internet of Things
  (49, 17, 'Smart Devices & Sensors'),
  (50, 17, 'IoT Protocols'),
  (51, 17, 'Industrial IoT'),
  -- Division 18: Blockchain & Digital Systems
  (52, 18, 'Smart Contracts'),
  (53, 18, 'Decentralized Applications'),
  (54, 18, 'Digital Security'),
  -- Division 19: Mathematical Modelling
  (55, 19, 'Differential Equations'),
  (56, 19, 'Simulation & Modelling'),
  (57, 19, 'Control Theory'),
  -- Division 20: Optimisation
  (58, 20, 'Linear Programming'),
  (59, 20, 'Metaheuristic Algorithms'),
  (60, 20, 'Game Theory'),
  -- Division 21: Numerical Methods
  (61, 21, 'Numerical Analysis'),
  (62, 21, 'Scientific Computing'),
  (63, 21, 'Approximation Theory'),
  -- Division 22: Discrete Mathematics
  (64, 22, 'Graph Theory'),
  (65, 22, 'Combinatorics'),
  (66, 22, 'Logic & Formal Methods'),
  -- Division 23: Quantitative Finance
  (67, 23, 'Risk Modelling'),
  (68, 23, 'Portfolio Optimisation'),
  (69, 23, 'Derivatives Pricing'),
  -- Division 24: Statistical Analysis
  (70, 24, 'Bayesian Statistics'),
  (71, 24, 'Time Series Analysis'),
  (72, 24, 'Regression & Forecasting');

-- =============================================================================
-- STEP 7 - PROGRAMMES (research-only, 3 entries)
-- =============================================================================
UPDATE `user`      SET program_id = NULL;
UPDATE `candidate` SET program_id = NULL;
DELETE FROM program;
ALTER TABLE program AUTO_INCREMENT = 1;

INSERT INTO program (id, code, name) VALUES
  (1, 'MSC_R',  'Master of Science (by Research)'),
  (2, 'PHD_CS', 'Doctor of Philosophy (Computer Science)'),
  (3, 'PHD_MT', 'Doctor of Philosophy (Mathematics)');

-- =============================================================================
-- STEP 8 - FACULTY LOOKUP (external examiner faculty dropdown)
-- =============================================================================
CREATE TABLE IF NOT EXISTS faculty_lookup (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(200) NOT NULL UNIQUE,
  sort_order INT UNSIGNED DEFAULT 0
) ENGINE = InnoDB;

DELETE FROM faculty_lookup;
ALTER TABLE faculty_lookup AUTO_INCREMENT = 1;

INSERT INTO faculty_lookup (id, name, sort_order) VALUES
  (1, 'Faculty of Computing',                          1),
  (2, 'Faculty of Computer Science',                   2),
  (3, 'School of Computing',                           3),
  (4, 'School of Computer Sciences',                   4),
  (5, 'Faculty of Information Science and Technology', 5),
  (6, 'Faculty of Engineering',                        6);

-- =============================================================================
-- STEP 9 - VENUE (7 entries)
-- =============================================================================
DELETE FROM venue;
ALTER TABLE venue AUTO_INCREMENT = 1;

INSERT INTO venue (id, name, location, capacity) VALUES
  (1, 'Seminar Room 1',          'FSKM', 40),
  (2, 'Seminar Room 2',          'FSKM', 40),
  (3, 'Conference Room 1',       'FSKM', 30),
  (4, 'Conference Room 2',       'FSKM', 30),
  (5, 'Discussion Room 1',       'FSKM', 15),
  (6, 'Discussion Room 2',       'FSKM', 15),
  (7, 'Online (Microsoft Teams)', NULL,  999);

-- =============================================================================
-- STEP 10 - COUNTRY (add Thailand + New Zealand)
-- =============================================================================
INSERT INTO country (name, iso_code) VALUES
  ('Thailand',    'TH'),
  ('New Zealand', 'NZ')
ON DUPLICATE KEY UPDATE iso_code = VALUES(iso_code);

-- =============================================================================
-- STEP 11 - UNIVERSITY LOOKUP (19 entries)
-- =============================================================================
DELETE FROM university_lookup;
ALTER TABLE university_lookup AUTO_INCREMENT = 1;

INSERT INTO university_lookup (name, country, sort_order) VALUES
  ('Universiti Malaysia Terengganu (UMT)',                  'Malaysia',     1),
  ('Universiti Teknologi Malaysia (UTM)',                   'Malaysia',     2),
  ('Universiti Kebangsaan Malaysia (UKM)',                  'Malaysia',     3),
  ('Universiti Putra Malaysia (UPM)',                       'Malaysia',     4),
  ('Universiti Sains Malaysia (USM)',                       'Malaysia',     5),
  ('Universiti Teknologi MARA (UiTM)',                      'Malaysia',     6),
  ('Universiti Tun Hussein Onn Malaysia (UTHM)',            'Malaysia',     7),
  ('Universiti Malaysia Pahang Al-Sultan Abdullah (UMPSA)', 'Malaysia',     8),
  ('Universiti Malaysia Perlis (UniMAP)',                   'Malaysia',     9),
  ('Universiti Utara Malaysia (UUM)',                       'Malaysia',    10),
  ('National University of Singapore (NUS)',                'Singapore',   20),
  ('Nanyang Technological University (NTU)',                'Singapore',   21),
  ('Monash University',                                     'Australia',   22),
  ('The University of Melbourne',                           'Australia',   23),
  ('The University of Sydney',                              'Australia',   24),
  ('University of Auckland',                                'New Zealand', 25),
  ('Chulalongkorn University',                              'Thailand',    26),
  ('Institut Teknologi Bandung (ITB)',                      'Indonesia',   27),
  ('Universitas Indonesia (UI)',                            'Indonesia',   28);

-- =============================================================================
-- STEP 12 - UNIVERSITY normalized table (INSERT IGNORE keeps existing FKs)
-- =============================================================================
INSERT IGNORE INTO university (name, country_id) VALUES
  ('Universiti Malaysia Terengganu',
   (SELECT id FROM country WHERE name = 'Malaysia')),
  ('Universiti Tun Hussein Onn Malaysia',
   (SELECT id FROM country WHERE name = 'Malaysia')),
  ('Universiti Malaysia Pahang Al-Sultan Abdullah',
   (SELECT id FROM country WHERE name = 'Malaysia')),
  ('Universiti Malaysia Perlis',
   (SELECT id FROM country WHERE name = 'Malaysia')),
  ('The University of Sydney',
   (SELECT id FROM country WHERE name = 'Australia')),
  ('Monash University',
   (SELECT id FROM country WHERE name = 'Australia')),
  ('University of Auckland',
   (SELECT id FROM country WHERE name = 'New Zealand')),
  ('Chulalongkorn University',
   (SELECT id FROM country WHERE name = 'Thailand'));

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- SUMMARY
--   Specialization   :  4
--   Expertise        : 12  (3 per specialization)
--   Division         : 24  (2 per expertise)
--   Area             : 72  (3 per division)
--   Programme        :  3  (MSc by Research + PhD CS + PhD Mathematics)
--   faculty_lookup   :  6
--   Venue            :  7
--   university_lookup: 19  (10 MY + 9 international)
--   Countries added  :  2  (Thailand, New Zealand)
-- =============================================================================
