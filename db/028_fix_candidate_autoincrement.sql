-- =============================================================================
-- 028_fix_candidate_autoincrement.sql
-- Ensure candidate.id has AUTO_INCREMENT so INSERT without explicit id works.
-- Safe to run even if AUTO_INCREMENT is already set.
-- =============================================================================

USE e_appointment_fskm;

ALTER TABLE `candidate`
  MODIFY COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT;
