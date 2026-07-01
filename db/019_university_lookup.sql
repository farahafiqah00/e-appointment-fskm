-- Migration 019: University lookup table for nomination form typeahead
-- Used in examiner nomination forms (university/organisation field).

USE e_appointment_fskm;

CREATE TABLE IF NOT EXISTS university_lookup (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(255) NOT NULL UNIQUE,
  country    VARCHAR(100) NOT NULL DEFAULT 'Malaysia',
  sort_order INT UNSIGNED DEFAULT 0
) ENGINE=InnoDB;

INSERT INTO university_lookup (name, country, sort_order) VALUES
  -- ── Malaysian Public Universities ──────────────────────────────────────────
  ('Universiti Teknologi MARA (UiTM)',                                     'Malaysia',  1),
  ('Universiti Malaya (UM)',                                                'Malaysia',  2),
  ('Universiti Kebangsaan Malaysia (UKM)',                                  'Malaysia',  3),
  ('Universiti Putra Malaysia (UPM)',                                       'Malaysia',  4),
  ('Universiti Sains Malaysia (USM)',                                       'Malaysia',  5),
  ('Universiti Teknologi Malaysia (UTM)',                                   'Malaysia',  6),
  ('Universiti Islam Antarabangsa Malaysia (UIAM)',                         'Malaysia',  7),
  ('Universiti Utara Malaysia (UUM)',                                       'Malaysia',  8),
  ('Universiti Malaysia Perlis (UniMAP)',                                   'Malaysia',  9),
  ('Universiti Malaysia Kelantan (UMK)',                                    'Malaysia', 10),
  ('Universiti Malaysia Pahang (UMP)',                                      'Malaysia', 11),
  ('Universiti Malaysia Sabah (UMS)',                                       'Malaysia', 12),
  ('Universiti Malaysia Sarawak (UNIMAS)',                                  'Malaysia', 13),
  ('Universiti Malaysia Terengganu (UMT)',                                  'Malaysia', 14),
  ('Universiti Pendidikan Sultan Idris (UPSI)',                             'Malaysia', 15),
  ('Universiti Teknikal Malaysia Melaka (UTeM)',                            'Malaysia', 16),
  ('Universiti Tun Hussein Onn Malaysia (UTHM)',                            'Malaysia', 17),
  ('Universiti Sultan Zainal Abidin (UniSZA)',                              'Malaysia', 18),
  ('Universiti Malaysia Kelantan (UMK)',                                    'Malaysia', 19),
  -- ── Malaysian Private Universities ─────────────────────────────────────────
  ('Multimedia University (MMU)',                                           'Malaysia', 30),
  ('Taylor''s University',                                                  'Malaysia', 31),
  ('HELP University',                                                       'Malaysia', 32),
  ('Sunway University',                                                     'Malaysia', 33),
  ('UCSI University',                                                       'Malaysia', 34),
  ('Heriot-Watt University Malaysia',                                       'Malaysia', 35),
  ('Asia Pacific University of Technology & Innovation (APU)',              'Malaysia', 36),
  ('Universiti Tunku Abdul Rahman (UTAR)',                                  'Malaysia', 37),
  ('INTI International University',                                         'Malaysia', 38),
  ('Universiti Teknologi Petronas (UTP)',                                   'Malaysia', 39),
  ('Cyberjaya University College of Medical Sciences (CUCMS)',              'Malaysia', 40),
  ('Infrastructure University Kuala Lumpur (IUKL)',                         'Malaysia', 41),
  -- ── United Kingdom ─────────────────────────────────────────────────────────
  ('University of Oxford',                                                  'United Kingdom', 50),
  ('University of Cambridge',                                               'United Kingdom', 51),
  ('Imperial College London',                                               'United Kingdom', 52),
  ('University College London (UCL)',                                       'United Kingdom', 53),
  ('University of Edinburgh',                                               'United Kingdom', 54),
  ('University of Manchester',                                              'United Kingdom', 55),
  ('University of Nottingham',                                              'United Kingdom', 56),
  ('University of Southampton',                                             'United Kingdom', 57),
  ('University of Birmingham',                                              'United Kingdom', 58),
  ('University of Sheffield',                                               'United Kingdom', 59),
  ('University of Bristol',                                                 'United Kingdom', 60),
  ('King''s College London',                                                'United Kingdom', 61),
  -- ── Australia ──────────────────────────────────────────────────────────────
  ('University of Melbourne',                                               'Australia', 70),
  ('Australian National University (ANU)',                                  'Australia', 71),
  ('University of Sydney',                                                  'Australia', 72),
  ('University of New South Wales (UNSW)',                                  'Australia', 73),
  ('Monash University',                                                     'Australia', 74),
  ('University of Queensland',                                              'Australia', 75),
  ('University of Western Australia',                                       'Australia', 76),
  ('University of Adelaide',                                                'Australia', 77),
  -- ── United States ──────────────────────────────────────────────────────────
  ('Massachusetts Institute of Technology (MIT)',                           'United States', 80),
  ('Stanford University',                                                   'United States', 81),
  ('Harvard University',                                                    'United States', 82),
  ('Carnegie Mellon University',                                            'United States', 83),
  ('University of California, Berkeley',                                    'United States', 84),
  ('California Institute of Technology (Caltech)',                          'United States', 85),
  ('Princeton University',                                                  'United States', 86),
  ('Columbia University',                                                   'United States', 87),
  ('University of Michigan',                                                'United States', 88),
  ('University of Texas at Austin',                                         'United States', 89),
  -- ── Singapore ──────────────────────────────────────────────────────────────
  ('National University of Singapore (NUS)',                                'Singapore', 90),
  ('Nanyang Technological University (NTU)',                                'Singapore', 91),
  ('Singapore Management University (SMU)',                                 'Singapore', 92),
  -- ── Indonesia ──────────────────────────────────────────────────────────────
  ('Universitas Indonesia',                                                 'Indonesia', 100),
  ('Institut Teknologi Bandung (ITB)',                                      'Indonesia', 101),
  ('Universitas Gadjah Mada',                                               'Indonesia', 102),
  -- ── Japan ──────────────────────────────────────────────────────────────────
  ('University of Tokyo',                                                   'Japan', 110),
  ('Kyoto University',                                                      'Japan', 111),
  ('Osaka University',                                                      'Japan', 112),
  -- ── Other ──────────────────────────────────────────────────────────────────
  ('Peking University',                                                     'China', 120),
  ('Tsinghua University',                                                   'China', 121),
  ('University of Toronto',                                                 'Canada', 130),
  ('McGill University',                                                     'Canada', 131),
  ('University of British Columbia',                                        'Canada', 132),
  ('ETH Zurich',                                                            'Switzerland', 140),
  ('Technical University of Munich (TUM)',                                  'Germany', 150),
  ('Delft University of Technology (TU Delft)',                             'Netherlands', 160),
  ('Other',                                                                 'Other', 999)
ON DUPLICATE KEY UPDATE sort_order = VALUES(sort_order);
