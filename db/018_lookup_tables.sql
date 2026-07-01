-- Migration 018: Lookup tables for examiner nomination dropdowns
-- Creates DB-backed lists for Title, Qualification, Academic Rank, and Gender
-- so all dropdown values are managed in the database.

USE e_appointment_fskm;

-- ── 1. Examiner Title ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS examiner_title (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL UNIQUE,
  sort_order INT UNSIGNED DEFAULT 0
) ENGINE=InnoDB;

INSERT INTO examiner_title (name, sort_order) VALUES
  ('Dr.',             1),
  ('Prof. Dr.',       2),
  ('Assoc. Prof. Dr.',3),
  ('Prof.',           4),
  ('Mr.',             5),
  ('Mrs.',            6),
  ('Ms.',             7)
ON DUPLICATE KEY UPDATE sort_order = VALUES(sort_order);

-- ── 2. Qualification ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS qualification_lookup (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL UNIQUE,
  sort_order INT UNSIGNED DEFAULT 0
) ENGINE=InnoDB;

INSERT INTO qualification_lookup (name, sort_order) VALUES
  ('PhD',           1),
  ('Postdoctoral',  2),
  ('Master''s',     3),
  ('Bachelor''s',   4),
  ('Other',         5)
ON DUPLICATE KEY UPDATE sort_order = VALUES(sort_order);

-- ── 3. Academic Rank ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS academic_rank_lookup (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL UNIQUE,
  sort_order INT UNSIGNED DEFAULT 0
) ENGINE=InnoDB;

INSERT INTO academic_rank_lookup (name, sort_order) VALUES
  ('Professor',              1),
  ('Associate Professor',    2),
  ('Senior Lecturer',        3),
  ('Lecturer',               4),
  ('Research Fellow',        5),
  ('Postdoctoral Researcher',6)
ON DUPLICATE KEY UPDATE sort_order = VALUES(sort_order);

-- ── 4. Gender ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS gender_lookup (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(30) NOT NULL UNIQUE,
  sort_order INT UNSIGNED DEFAULT 0
) ENGINE=InnoDB;

INSERT INTO gender_lookup (name, sort_order) VALUES
  ('Male',   1),
  ('Female', 2),
  ('Other',  3)
ON DUPLICATE KEY UPDATE sort_order = VALUES(sort_order);
