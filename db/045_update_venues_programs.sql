-- ============================================================
-- 045_update_venues_programs.sql
-- Targeted update: replace venue and program data with
-- real FSKM UMT values. Does NOT touch users, candidates,
-- nominations, appointments, or title data.
-- ============================================================

USE e_appointment_fskm;

-- ============================================================
-- 1. VENUES
-- Clear existing venues and insert real FSKM room names.
-- !! Update these names to match your actual faculty rooms !!
-- ============================================================
TRUNCATE TABLE venue;

INSERT INTO venue (name, location, capacity, is_active) VALUES
  ('Bilik Mesyuarat 1, FSKM',   'Aras 3, Bangunan FSKM',   15, 1),
  ('Bilik Mesyuarat 2, FSKM',   'Aras 3, Bangunan FSKM',   15, 1),
  ('Bilik Seminar 1, FSKM',     'Aras 2, Bangunan FSKM',   40, 1),
  ('Bilik Seminar 2, FSKM',     'Aras 2, Bangunan FSKM',   40, 1),
  ('Bilik Persidangan, FSKM',   'Aras 5, Bangunan FSKM',   30, 1),
  ('Bilik Dekan, FSKM',         'Pejabat Dekan, Aras 6',   12, 1),
  ('Dewan Kuliah A, FSKM',      'Aras 1, Bangunan FSKM',   80, 1),
  ('Online (Microsoft Teams)',   NULL,                      999, 1);

-- ============================================================
-- 2. PROGRAMMES
-- Clear existing programmes and insert real FSKM programmes.
-- !! Verify these against the official UMT programme list !!
-- ============================================================
-- First remove FK references in candidate (safe — column is nullable)
UPDATE candidate SET program_id = NULL WHERE program_id IS NOT NULL;
TRUNCATE TABLE program;

INSERT INTO program (code, name, level) VALUES
  -- PhD Programmes
  ('PHD-CS',  'Doctor of Philosophy (Computer Science)',        'PhD'),
  ('PHD-MT',  'Doctor of Philosophy (Mathematics)',             'PhD'),
  ('PHD-IT',  'Doctor of Philosophy (Information Technology)',  'PhD'),
  -- Master Programmes
  ('MSC-CS',  'Master of Science (Computer Science)',           'Master'),
  ('MSC-MT',  'Master of Science (Mathematics)',                'Master'),
  ('MSC-IT',  'Master of Science (Information Technology)',     'Master');
-- Add more rows above as needed based on actual FSKM programme offerings.

-- ============================================================
-- 3. SPECIALIZATION / RESEARCH HIERARCHY
-- Only run if you want to replace the existing research areas.
-- Safe to skip if current data is acceptable.
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE area;
TRUNCATE TABLE division;
TRUNCATE TABLE expertise;
TRUNCATE TABLE specialization;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO specialization (name, description) VALUES
  ('Computer Science',      'Computing, algorithms, software and systems'),
  ('Mathematics',           'Pure, applied and computational mathematics'),
  ('Information Technology','IT infrastructure, systems and management');

-- Computer Science expertise (spec id 1)
INSERT INTO expertise (specialization_id, name, description) VALUES
  (1, 'Artificial Intelligence & Machine Learning', 'AI, ML, deep learning and intelligent systems'),
  (1, 'Software Engineering',                       'Software design, development and quality'),
  (1, 'Data Science & Analytics',                   'Big data, mining and analytics'),
  (1, 'Cybersecurity & Networks',                   'Security, cryptography and networking'),
  (1, 'Human-Computer Interaction',                 'UX, usability and interface design');

-- Mathematics expertise (spec id 2)
INSERT INTO expertise (specialization_id, name, description) VALUES
  (2, 'Pure Mathematics',         'Algebra, analysis and topology'),
  (2, 'Applied Mathematics',      'Numerical methods, modelling and optimisation'),
  (2, 'Statistics & Probability', 'Statistical theory, inference and data analysis'),
  (2, 'Operations Research',      'Linear programming, simulation and graph theory');

-- Information Technology expertise (spec id 3)
INSERT INTO expertise (specialization_id, name, description) VALUES
  (3, 'Cloud & Distributed Systems',   'Cloud computing, virtualisation and distributed platforms'),
  (3, 'Database & Information Systems','Database design, management and information retrieval'),
  (3, 'Internet of Things',            'Embedded systems, sensors and IoT architectures');

-- Divisions under CS
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Deep Learning',                        1, 1),
  ('Natural Language Processing',          1, 1),
  ('Computer Vision',                      1, 1),
  ('Software Testing & Quality Assurance', 1, 2),
  ('Agile & DevOps',                       1, 2),
  ('Big Data Processing',                  1, 3),
  ('Data Mining & Knowledge Discovery',    1, 3),
  ('Network Security',                     1, 4),
  ('Cryptography & Blockchain',            1, 4),
  ('User Experience Design',               1, 5);

-- Divisions under Mathematics
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Algebra',                           2, 6),
  ('Mathematical Analysis',             2, 6),
  ('Numerical Analysis',                2, 7),
  ('Mathematical Modelling',            2, 7),
  ('Statistical Computing',             2, 8),
  ('Biostatistics',                     2, 8),
  ('Linear & Integer Programming',      2, 9),
  ('Graph & Network Theory',            2, 9);

-- Divisions under IT
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Cloud Infrastructure',              3, 10),
  ('Relational & NoSQL Databases',      3, 11),
  ('Sensor Networks & IoT',             3, 12);
