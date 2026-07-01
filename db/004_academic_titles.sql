-- Migration 004: Add comprehensive Malaysian academic title combinations
-- Run in phpMyAdmin against e_appointment_fskm

USE e_appointment_fskm;

-- Insert all title combinations; ON DUPLICATE KEY UPDATE is a no-op (safe to re-run)
INSERT INTO title (name) VALUES
  -- Basic courtesy
  ('Mr.'),
  ('Mrs.'),
  ('Ms.'),
  ('Miss'),

  -- Doctoral
  ('Dr.'),

  -- Technologist (Ts.) — Malaysian Board of Technologists
  ('Ts.'),
  ('Ts. Dr.'),

  -- Engineer (Ir.) — Board of Engineers Malaysia
  ('Ir.'),
  ('Ir. Dr.'),

  -- Professor variants
  ('Prof.'),
  ('Prof. Dr.'),
  ('Prof. Ts.'),
  ('Prof. Ts. Dr.'),
  ('Prof. Ir.'),
  ('Prof. Ir. Dr.'),

  -- Associate Professor variants
  ('Assoc. Prof.'),
  ('Assoc. Prof. Dr.'),
  ('Assoc. Prof. Ts.'),
  ('Assoc. Prof. Ts. Dr.'),
  ('Assoc. Prof. Ir.'),
  ('Assoc. Prof. Ir. Dr.')

ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Verify
-- SELECT id, name FROM title ORDER BY id;
