-- Migration 034: Add administrative_position to academic_staff
-- This column distinguishes administrative roles (TDA/TDB) from academic_rank
-- (which stores Professor, Associate Professor, etc.)

ALTER TABLE academic_staff
  ADD COLUMN IF NOT EXISTS administrative_position VARCHAR(10) NULL
    COMMENT 'Administrative position: TDA (Timbalan Dekan Akademik), TDB (Timbalan Dekan Berkaitan), or NULL';
