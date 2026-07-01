-- Migration 012: Supervisor FK on candidate + extended co_supervisor profile
-- Run in phpMyAdmin against e_appointment_fskm AFTER migrations 001-011.

USE e_appointment_fskm;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Add supervisor_id to candidate (nullable FK → academic_staff)
--    supervisor_name is kept for display / backward-compat fallback
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE `candidate`
  ADD COLUMN IF NOT EXISTS `supervisor_id` INT UNSIGNED NULL
    AFTER `supervisor_name`;

ALTER TABLE `candidate` DROP FOREIGN KEY IF EXISTS `fk_candidate_supervisor`;
ALTER TABLE `candidate`
  ADD CONSTRAINT `fk_candidate_supervisor`
    FOREIGN KEY (`supervisor_id`) REFERENCES `academic_staff`(`id`)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Extend co_supervisor with type + full profile for external co-supervisors
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE `co_supervisor`
  ADD COLUMN IF NOT EXISTS `cosv_type`         ENUM('internal','external') NOT NULL DEFAULT 'external' AFTER `name`,
  ADD COLUMN IF NOT EXISTS `internal_staff_id` INT UNSIGNED NULL AFTER `cosv_type`,
  ADD COLUMN IF NOT EXISTS `university_name`   VARCHAR(200)  NULL AFTER `internal_staff_id`,
  ADD COLUMN IF NOT EXISTS `faculty`           VARCHAR(200)  NULL AFTER `university_name`,
  ADD COLUMN IF NOT EXISTS `programme`         VARCHAR(200)  NULL AFTER `faculty`,
  ADD COLUMN IF NOT EXISTS `country`           VARCHAR(100)  NULL AFTER `programme`,
  ADD COLUMN IF NOT EXISTS `email`             VARCHAR(150)  NULL AFTER `country`;

ALTER TABLE `co_supervisor` DROP FOREIGN KEY IF EXISTS `fk_cosv_internal`;
ALTER TABLE `co_supervisor`
  ADD CONSTRAINT `fk_cosv_internal`
    FOREIGN KEY (`internal_staff_id`) REFERENCES `academic_staff`(`id`)
    ON DELETE SET NULL ON UPDATE CASCADE;
