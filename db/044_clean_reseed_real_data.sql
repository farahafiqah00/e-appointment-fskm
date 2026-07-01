-- ============================================================
-- 044_clean_reseed_real_data.sql
-- Wipe all transactional & lookup data, then seed with
-- realistic FSKM UMT data for demo / production use.
--
-- HOW TO USE:
--   1. Run this file in phpMyAdmin or MySQL CLI
--   2. Deploy the app
--   3. Navigate to /SetupServlet to create the first admin account
--   4. Log in and add real users, candidates, and appointments
-- ============================================================

USE e_appointment_fskm;

-- ============================================================
-- STEP 1: Disable FK checks so truncation order doesn't matter
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE area;
TRUNCATE TABLE division;
TRUNCATE TABLE expertise;
TRUNCATE TABLE specialization;
TRUNCATE TABLE university_lookup;
TRUNCATE TABLE university;
TRUNCATE TABLE country;
TRUNCATE TABLE program;
TRUNCATE TABLE title;
TRUNCATE TABLE faculty;
TRUNCATE TABLE appointment_letter;
TRUNCATE TABLE appointment_letter_approval;
TRUNCATE TABLE appointment_panel;
TRUNCATE TABLE viva_appointment;
TRUNCATE TABLE nomination;
TRUNCATE TABLE document;
TRUNCATE TABLE co_supervisor;
TRUNCATE TABLE candidate;
TRUNCATE TABLE password_reset_token;
TRUNCATE TABLE academic_staff;
TRUNCATE TABLE `user`;
TRUNCATE TABLE role;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- STEP 2: Roles
-- ============================================================
INSERT INTO role (name) VALUES
  ('System Administrator'),
  ('Admin'),
  ('Academician'),
  ('Dean');

-- ============================================================
-- STEP 3: Titles (Malaysian academic titles)
-- ============================================================
INSERT INTO title (name) VALUES
  ('Mr'), ('Mrs'), ('Ms'), ('Miss'),
  ('Dr.'), ('Ts.'), ('Ts. Dr.'),
  ('Ir.'), ('Ir. Dr.'),
  ('Prof.'), ('Prof. Dr.'), ('Prof. Ts.'), ('Prof. Ts. Dr.'),
  ('Prof. Ir.'), ('Prof. Ir. Dr.'),
  ('Assoc. Prof.'), ('Assoc. Prof. Dr.'),
  ('Assoc. Prof. Ts.'), ('Assoc. Prof. Ts. Dr.'),
  ('Assoc. Prof. Ir.'), ('Assoc. Prof. Ir. Dr.');

-- ============================================================
-- STEP 4: Postgraduate programmes at FSKM UMT
-- Update these names to match the exact FSKM programme list.
-- ============================================================
INSERT INTO program (code, name, level) VALUES
  -- PhD Programmes
  ('PHD-CS',  'Doctor of Philosophy (Computer Science)',             'PhD'),
  ('PHD-MT',  'Doctor of Philosophy (Mathematics)',                  'PhD'),
  ('PHD-IT',  'Doctor of Philosophy (Information Technology)',       'PhD'),
  ('PHD-SE',  'Doctor of Philosophy (Software Engineering)',         'PhD'),
  ('PHD-DS',  'Doctor of Philosophy (Data Science)',                 'PhD'),
  ('PHD-AI',  'Doctor of Philosophy (Artificial Intelligence)',      'PhD'),
  ('PHD-CY',  'Doctor of Philosophy (Cybersecurity)',               'PhD'),
  -- Master Programmes
  ('MSC-CS',  'Master of Science (Computer Science)',                'Master'),
  ('MSC-MT',  'Master of Science (Mathematics)',                     'Master'),
  ('MSC-IT',  'Master of Science (Information Technology)',          'Master'),
  ('MSC-SE',  'Master of Science (Software Engineering)',            'Master'),
  ('MSC-CM',  'Master of Science (Computational Mathematics)',       'Master');

-- ============================================================
-- STEP 5: Research Specializations (FSKM — CS & Math)
-- ============================================================
INSERT INTO specialization (name, description) VALUES
  ('Computer Science',     'Computing, algorithms, software and systems'),
  ('Mathematics',          'Pure, applied and computational mathematics'),
  ('Information Technology','IT infrastructure, systems and management');

-- ── Computer Science expertise ──────────────────────────────
INSERT INTO expertise (specialization_id, name, description) VALUES
  (1, 'Artificial Intelligence & Machine Learning', 'AI, ML, deep learning and intelligent systems'),
  (1, 'Software Engineering',                       'Software design, development and quality'),
  (1, 'Data Science & Analytics',                   'Big data, mining and analytics'),
  (1, 'Cybersecurity & Networks',                   'Security, cryptography and networking'),
  (1, 'Human-Computer Interaction',                 'UX, usability and interface design');

-- ── Mathematics expertise ────────────────────────────────────
INSERT INTO expertise (specialization_id, name, description) VALUES
  (2, 'Pure Mathematics',      'Algebra, analysis and topology'),
  (2, 'Applied Mathematics',   'Numerical methods, modelling and optimisation'),
  (2, 'Statistics & Probability', 'Statistical theory, inference and data analysis'),
  (2, 'Operations Research',   'Linear programming, simulation and graph theory');

-- ── Information Technology expertise ────────────────────────
INSERT INTO expertise (specialization_id, name, description) VALUES
  (3, 'Cloud & Distributed Systems', 'Cloud computing, virtualisation and distributed platforms'),
  (3, 'Database & Information Systems', 'Database design, management and information retrieval'),
  (3, 'Internet of Things',    'Embedded systems, sensors and IoT architectures');

-- ── Divisions under Computer Science ─────────────────────────
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  -- AI & ML (expertise 1)
  ('Deep Learning',                        1, 1),
  ('Natural Language Processing',          1, 1),
  ('Computer Vision',                      1, 1),
  ('Reinforcement Learning',               1, 1),
  -- Software Engineering (expertise 2)
  ('Software Testing & Quality Assurance', 1, 2),
  ('Agile & DevOps',                       1, 2),
  ('Software Architecture',                1, 2),
  -- Data Science (expertise 3)
  ('Big Data Processing',                  1, 3),
  ('Data Mining & Knowledge Discovery',    1, 3),
  ('Business Intelligence',                1, 3),
  -- Cybersecurity (expertise 4)
  ('Network Security',                     1, 4),
  ('Cryptography & Blockchain',            1, 4),
  ('Digital Forensics',                    1, 4),
  -- HCI (expertise 5)
  ('User Experience Design',               1, 5),
  ('Accessibility & Inclusive Design',     1, 5);

-- ── Divisions under Mathematics ───────────────────────────────
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  -- Pure Math (expertise 6)
  ('Algebra',                              2, 6),
  ('Mathematical Analysis',                2, 6),
  ('Topology & Geometry',                  2, 6),
  -- Applied Math (expertise 7)
  ('Numerical Analysis',                   2, 7),
  ('Mathematical Modelling',               2, 7),
  ('Optimisation',                         2, 7),
  -- Statistics (expertise 8)
  ('Statistical Computing',                2, 8),
  ('Biostatistics',                        2, 8),
  ('Time Series Analysis',                 2, 8),
  -- Operations Research (expertise 9)
  ('Linear & Integer Programming',         2, 9),
  ('Simulation & Stochastic Modelling',    2, 9),
  ('Graph & Network Theory',               2, 9);

-- ── Divisions under Information Technology ───────────────────
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  -- Cloud (expertise 10)
  ('Cloud Infrastructure',                 3, 10),
  ('Edge & Fog Computing',                 3, 10),
  -- Database (expertise 11)
  ('Relational & NoSQL Databases',         3, 11),
  ('Information Retrieval',                3, 11),
  -- IoT (expertise 12)
  ('Sensor Networks',                      3, 12),
  ('Smart Systems & Automation',           3, 12);

-- ── Research Areas ────────────────────────────────────────────
-- (select a few representative areas under each division)
INSERT INTO area (name, specialization_id, division_id) VALUES
  -- Deep Learning (division 1)
  ('Convolutional Neural Networks',  1, 1),
  ('Transformer Models',             1, 1),
  -- NLP (division 2)
  ('Sentiment Analysis',             1, 2),
  ('Text Summarisation',             1, 2),
  -- Computer Vision (division 3)
  ('Object Detection',               1, 3),
  ('Medical Image Analysis',         1, 3),
  -- Software Testing (division 5)
  ('Automated Testing',              1, 5),
  ('Test-Driven Development',        1, 5),
  -- Big Data (division 8)
  ('Distributed Data Processing',    1, 8),
  ('Real-Time Stream Analytics',     1, 8),
  -- Network Security (division 11)
  ('Intrusion Detection Systems',    1, 11),
  ('Wireless Security',              1, 11),
  -- Algebra (division 16)
  ('Group Theory',                   2, 16),
  ('Ring Theory',                    2, 16),
  -- Mathematical Modelling (division 20)
  ('Fluid Dynamics Modelling',       2, 20),
  ('Epidemic Mathematical Models',   2, 20),
  -- Statistical Computing (division 22)
  ('Bayesian Methods',               2, 22),
  ('Monte Carlo Simulation',         2, 22),
  -- Graph Theory (division 27)
  ('Network Flow Problems',          2, 27),
  ('Combinatorial Optimisation',     2, 27),
  -- Cloud Infrastructure (division 28)
  ('Containerisation & Kubernetes',  3, 28),
  ('Serverless Architecture',        3, 28),
  -- IoT (division 33)
  ('Smart Healthcare Systems',       3, 33),
  ('Industrial IoT',                 3, 33);

-- ============================================================
-- STEP 6: Countries (common ones for external examiners)
-- ============================================================
INSERT INTO country (name, iso_code) VALUES
  ('Malaysia',        'MY'),
  ('Indonesia',       'ID'),
  ('Singapore',       'SG'),
  ('Thailand',        'TH'),
  ('Philippines',     'PH'),
  ('Brunei',          'BN'),
  ('Vietnam',         'VN'),
  ('United Kingdom',  'GB'),
  ('United States',   'US'),
  ('Australia',       'AU'),
  ('New Zealand',     'NZ'),
  ('Japan',           'JP'),
  ('South Korea',     'KR'),
  ('China',           'CN'),
  ('India',           'IN'),
  ('Egypt',           'EG'),
  ('Saudi Arabia',    'SA'),
  ('Germany',         'DE'),
  ('France',          'FR'),
  ('Canada',          'CA');

-- ============================================================
-- STEP 7: Universities (Malaysian + key international)
-- ============================================================
INSERT INTO university (name, country_id) VALUES
  -- Malaysian public universities
  ('Universiti Malaysia Terengganu (UMT)',            1),
  ('Universiti Teknologi Malaysia (UTM)',              1),
  ('Universiti Malaya (UM)',                           1),
  ('Universiti Kebangsaan Malaysia (UKM)',             1),
  ('Universiti Putra Malaysia (UPM)',                  1),
  ('Universiti Sains Malaysia (USM)',                  1),
  ('Universiti Utara Malaysia (UUM)',                  1),
  ('Universiti Teknologi MARA (UiTM)',                 1),
  ('Universiti Islam Antarabangsa Malaysia (UIAM)',    1),
  ('Universiti Malaysia Pahang (UMP)',                 1),
  ('Universiti Malaysia Sabah (UMS)',                  1),
  ('Universiti Malaysia Sarawak (UNIMAS)',             1),
  ('Universiti Pendidikan Sultan Idris (UPSI)',        1),
  ('Universiti Teknikal Malaysia Melaka (UTeM)',       1),
  ('Universiti Malaysia Perlis (UniMAP)',              1),
  -- Singapore
  ('National University of Singapore (NUS)',           3),
  ('Nanyang Technological University (NTU)',           3),
  -- Australia
  ('University of Melbourne',                         10),
  ('University of Queensland',                        10),
  ('Monash University',                               10),
  -- UK
  ('University of Oxford',                             8),
  ('University of Cambridge',                          8),
  ('Imperial College London',                          8),
  -- US
  ('Massachusetts Institute of Technology (MIT)',      9),
  ('Stanford University',                              9),
  -- Japan
  ('University of Tokyo',                             11),
  -- South Korea
  ('Seoul National University',                       12);

-- ============================================================
-- STEP 8: university_lookup (for nomination form search)
-- ============================================================
INSERT INTO university_lookup (name, country, sort_order) VALUES
  ('Universiti Malaysia Terengganu (UMT)', 'Malaysia', 1),
  ('Universiti Teknologi Malaysia (UTM)',  'Malaysia', 2),
  ('Universiti Malaya (UM)',               'Malaysia', 3),
  ('Universiti Kebangsaan Malaysia (UKM)','Malaysia', 4),
  ('Universiti Putra Malaysia (UPM)',      'Malaysia', 5),
  ('Universiti Sains Malaysia (USM)',      'Malaysia', 6),
  ('Universiti Utara Malaysia (UUM)',      'Malaysia', 7),
  ('Universiti Teknologi MARA (UiTM)',     'Malaysia', 8),
  ('Universiti Malaysia Pahang (UMP)',     'Malaysia', 9),
  ('Universiti Malaysia Sabah (UMS)',      'Malaysia', 10),
  ('National University of Singapore (NUS)',   'Singapore',  20),
  ('Nanyang Technological University (NTU)',   'Singapore',  21),
  ('University of Melbourne',             'Australia',  30),
  ('Monash University',                   'Australia',  31),
  ('University of Oxford',                'United Kingdom', 40),
  ('University of Cambridge',             'United Kingdom', 41),
  ('Imperial College London',             'United Kingdom', 42),
  ('Massachusetts Institute of Technology (MIT)', 'United States', 50),
  ('Stanford University',                 'United States', 51),
  ('University of Tokyo',                 'Japan', 60),
  ('Seoul National University',           'South Korea', 70);

-- ============================================================
-- NOTE: Do NOT insert users here.
-- After running this script, go to /SetupServlet in the browser
-- to create the first System Administrator account.
-- The password will be auto-generated and emailed to you.
-- ============================================================
