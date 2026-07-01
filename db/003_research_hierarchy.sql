-- Migration 003: Proper 4-level research hierarchy for academic staff
-- Specialization → Expertise → Division → Area
-- Run this in phpMyAdmin against e_appointment_fskm AFTER migration 002.

USE e_appointment_fskm;

-- ── Step 1: Link division under expertise (Level 3) ─────────────────────────
ALTER TABLE division ADD COLUMN IF NOT EXISTS expertise_id INT UNSIGNED;

-- ── Step 2: Link area under division (Level 4) ──────────────────────────────
ALTER TABLE area ADD COLUMN IF NOT EXISTS division_id INT UNSIGNED;

-- ── Step 3: academic_staff stores all 4 levels ──────────────────────────────
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS division_id INT UNSIGNED;
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS area_id     INT UNSIGNED;

-- ── Step 4: Seed comprehensive FSKM research hierarchy ──────────────────────
-- (All inserts are idempotent via ON DUPLICATE KEY UPDATE)

-- 4a: Specializations (Level 1)
INSERT INTO specialization (name, description) VALUES
  ('Computer Science',           'Core CS theory, AI, and systems'),
  ('Software Engineering',       'Software development methods and processes'),
  ('Information Technology',     'Networks, security, and information systems'),
  ('Mathematics',                'Pure and applied mathematics'),
  ('Artificial Intelligence',    'AI and Machine Learning'),
  ('Networks',                   'Computer Networks')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- 4b: Expertise (Level 2) — keyed under each specialization
-- Computer Science expertise
INSERT INTO expertise (specialization_id, name, description) VALUES
  ((SELECT id FROM specialization WHERE name='Computer Science'), 'Artificial Intelligence',         'AI, ML and intelligent systems'),
  ((SELECT id FROM specialization WHERE name='Computer Science'), 'Computer Systems',                'Architecture, parallel and distributed computing'),
  ((SELECT id FROM specialization WHERE name='Computer Science'), 'Data Science & Analytics',       'Big data, data mining and analytics'),
  ((SELECT id FROM specialization WHERE name='Computer Science'), 'Computer Security',              'Cybersecurity, cryptography and forensics')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Software Engineering expertise
INSERT INTO expertise (specialization_id, name, description) VALUES
  ((SELECT id FROM specialization WHERE name='Software Engineering'), 'Software Development',       'Software design, architecture and quality'),
  ((SELECT id FROM specialization WHERE name='Software Engineering'), 'Software Process & Methods', 'Agile, DevOps and requirements engineering'),
  ((SELECT id FROM specialization WHERE name='Software Engineering'), 'Human-Computer Interaction', 'UI/UX, usability and accessibility')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Information Technology expertise
INSERT INTO expertise (specialization_id, name, description) VALUES
  ((SELECT id FROM specialization WHERE name='Information Technology'), 'Computer Networks',        'Network infrastructure and protocols'),
  ((SELECT id FROM specialization WHERE name='Information Technology'), 'Information Systems',      'Enterprise IS and database systems'),
  ((SELECT id FROM specialization WHERE name='Information Technology'), 'Wireless & Mobile',        'Mobile computing, IoT, 5G')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Mathematics expertise
INSERT INTO expertise (specialization_id, name, description) VALUES
  ((SELECT id FROM specialization WHERE name='Mathematics'), 'Pure Mathematics',                    'Algebra, analysis and number theory'),
  ((SELECT id FROM specialization WHERE name='Mathematics'), 'Applied Mathematics',                 'Statistics, optimisation and computation'),
  ((SELECT id FROM specialization WHERE name='Mathematics'), 'Computational Mathematics',           'Numerical methods and mathematical modelling')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Legacy expertise rows (keep existing, update to link to correct specialization)
INSERT INTO expertise (specialization_id, name, description) VALUES
  ((SELECT id FROM specialization WHERE name='Artificial Intelligence'), 'Machine Learning',        'ML and statistical learning'),
  ((SELECT id FROM specialization WHERE name='Networks'),                'Network Security',        'Network & security'),
  ((SELECT id FROM specialization WHERE name='Software Engineering'),    'Software Architecture',   'Design & architecture')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- 4c: Division (Level 3) — each linked to an expertise
-- Under AI expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Machine Learning',          (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Artificial Intelligence' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1)),
  ('Knowledge & Reasoning',     (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Artificial Intelligence' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1)),
  ('Computer Vision',           (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Artificial Intelligence' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Computer Systems expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Parallel & Distributed Computing', (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Computer Systems' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1)),
  ('Computer Architecture',            (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Computer Systems' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Data Science expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Big Data & Cloud',    (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Data Science & Analytics' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1)),
  ('Data Mining',         (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Data Science & Analytics' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1)),
  ('Business Analytics',  (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Data Science & Analytics' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Computer Security expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Cryptography',         (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Computer Security' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1)),
  ('Cyber Forensics',      (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM expertise WHERE name='Computer Security' AND specialization_id=(SELECT id FROM specialization WHERE name='Computer Science') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Software Development expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Software Architecture & Design',  (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM expertise WHERE name='Software Development' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1)),
  ('Software Testing & Quality',      (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM expertise WHERE name='Software Development' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Software Process expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Agile & DevOps',             (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM expertise WHERE name='Software Process & Methods' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1)),
  ('Requirements Engineering',   (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM expertise WHERE name='Software Process & Methods' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under HCI expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('UI/UX Design',           (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM expertise WHERE name='Human-Computer Interaction' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1)),
  ('Usability & Evaluation', (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM expertise WHERE name='Human-Computer Interaction' AND specialization_id=(SELECT id FROM specialization WHERE name='Software Engineering') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Computer Networks expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Network Infrastructure',   (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM expertise WHERE name='Computer Networks' AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1)),
  ('Network Security',         (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM expertise WHERE name='Computer Networks' AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Information Systems expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Database Systems',         (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM expertise WHERE name='Information Systems' AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1)),
  ('Enterprise Systems',       (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM expertise WHERE name='Information Systems' AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Wireless & Mobile expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Mobile Computing',         (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM expertise WHERE name='Wireless & Mobile' AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1)),
  ('Internet of Things (IoT)', (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM expertise WHERE name='Wireless & Mobile' AND specialization_id=(SELECT id FROM specialization WHERE name='Information Technology') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Pure Mathematics expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Algebra',            (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM expertise WHERE name='Pure Mathematics' AND specialization_id=(SELECT id FROM specialization WHERE name='Mathematics') LIMIT 1)),
  ('Analysis',           (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM expertise WHERE name='Pure Mathematics' AND specialization_id=(SELECT id FROM specialization WHERE name='Mathematics') LIMIT 1)),
  ('Number Theory',      (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM expertise WHERE name='Pure Mathematics' AND specialization_id=(SELECT id FROM specialization WHERE name='Mathematics') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Applied Mathematics expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Statistics & Probability',   (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM expertise WHERE name='Applied Mathematics' AND specialization_id=(SELECT id FROM specialization WHERE name='Mathematics') LIMIT 1)),
  ('Operational Research',       (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM expertise WHERE name='Applied Mathematics' AND specialization_id=(SELECT id FROM specialization WHERE name='Mathematics') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- Under Computational Mathematics expertise
INSERT INTO division (name, specialization_id, expertise_id) VALUES
  ('Numerical Methods',          (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM expertise WHERE name='Computational Mathematics' AND specialization_id=(SELECT id FROM specialization WHERE name='Mathematics') LIMIT 1)),
  ('Mathematical Modelling',     (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM expertise WHERE name='Computational Mathematics' AND specialization_id=(SELECT id FROM specialization WHERE name='Mathematics') LIMIT 1))
ON DUPLICATE KEY UPDATE expertise_id = VALUES(expertise_id);

-- 4d: Area (Level 4) — each linked to a division
-- Machine Learning division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Deep Learning',              (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Machine Learning' LIMIT 1)),
  ('Natural Language Processing',(SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Machine Learning' LIMIT 1)),
  ('Reinforcement Learning',     (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Machine Learning' LIMIT 1)),
  ('Statistical Learning',       (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Machine Learning' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Knowledge & Reasoning division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Expert Systems',             (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Knowledge & Reasoning' LIMIT 1)),
  ('Ontology & Semantic Web',    (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Knowledge & Reasoning' LIMIT 1)),
  ('Fuzzy Logic',                (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Knowledge & Reasoning' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Computer Vision division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Image Processing',           (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Computer Vision' LIMIT 1)),
  ('Object Detection',           (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Computer Vision' LIMIT 1)),
  ('Pattern Recognition',        (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Computer Vision' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Big Data & Cloud division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Cloud Computing',            (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Big Data & Cloud' LIMIT 1)),
  ('Hadoop & Spark Ecosystems',  (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Big Data & Cloud' LIMIT 1)),
  ('Data Lakes & Warehousing',   (SELECT id FROM specialization WHERE name='Computer Science'), (SELECT id FROM division WHERE name='Big Data & Cloud' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Software Architecture & Design division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Design Patterns',            (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Software Architecture & Design' LIMIT 1)),
  ('Microservices',              (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Software Architecture & Design' LIMIT 1)),
  ('Service-Oriented Architecture', (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Software Architecture & Design' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Software Testing & Quality division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Unit & Integration Testing', (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Software Testing & Quality' LIMIT 1)),
  ('Performance Testing',        (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Software Testing & Quality' LIMIT 1)),
  ('Quality Assurance',          (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Software Testing & Quality' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Agile & DevOps division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Scrum & Kanban',             (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Agile & DevOps' LIMIT 1)),
  ('Continuous Integration/Delivery', (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Agile & DevOps' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Requirements Engineering division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Use Case Modelling',         (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Requirements Engineering' LIMIT 1)),
  ('Requirements Analysis',      (SELECT id FROM specialization WHERE name='Software Engineering'), (SELECT id FROM division WHERE name='Requirements Engineering' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Network Infrastructure division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('LAN & WAN',                  (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Network Infrastructure' LIMIT 1)),
  ('Routing Protocols',          (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Network Infrastructure' LIMIT 1)),
  ('Software-Defined Networking',(SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Network Infrastructure' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Network Security division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Firewall & Intrusion Detection', (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Network Security' LIMIT 1)),
  ('Cryptography',               (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Network Security' LIMIT 1)),
  ('Ethical Hacking & Pen Testing', (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Network Security' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Database Systems division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Relational Databases',       (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Database Systems' LIMIT 1)),
  ('NoSQL & Graph Databases',    (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Database Systems' LIMIT 1)),
  ('Database Performance Tuning',(SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Database Systems' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Internet of Things division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('IoT Protocols & Standards',  (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Internet of Things (IoT)' LIMIT 1)),
  ('Smart Systems',              (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Internet of Things (IoT)' LIMIT 1)),
  ('Embedded Systems',           (SELECT id FROM specialization WHERE name='Information Technology'), (SELECT id FROM division WHERE name='Internet of Things (IoT)' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Statistics & Probability division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Bayesian Statistics',        (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM division WHERE name='Statistics & Probability' LIMIT 1)),
  ('Statistical Modelling',      (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM division WHERE name='Statistics & Probability' LIMIT 1)),
  ('Probability Theory',         (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM division WHERE name='Statistics & Probability' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Algebra division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Linear Algebra',             (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM division WHERE name='Algebra' LIMIT 1)),
  ('Abstract Algebra',           (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM division WHERE name='Algebra' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Mathematical Modelling division
INSERT INTO area (name, specialization_id, division_id) VALUES
  ('Simulation & Optimisation',  (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM division WHERE name='Mathematical Modelling' LIMIT 1)),
  ('Differential Equations',     (SELECT id FROM specialization WHERE name='Mathematics'), (SELECT id FROM division WHERE name='Mathematical Modelling' LIMIT 1))
ON DUPLICATE KEY UPDATE division_id = VALUES(division_id);

-- Verify
-- SELECT s.name AS spec, e.name AS expertise, d.name AS division, a.name AS area
-- FROM area a
-- JOIN division d ON a.division_id = d.id
-- JOIN expertise e ON d.expertise_id = e.id
-- JOIN specialization s ON e.specialization_id = s.id
-- ORDER BY s.name, e.name, d.name, a.name;
