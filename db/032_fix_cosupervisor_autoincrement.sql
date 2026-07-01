-- Migration 032: Fix co_supervisor.id missing AUTO_INCREMENT
-- Symptom: BatchUpdateException "Field 'id' doesn't have a default value"
--           when inserting co-supervisors via EditCandidateServlet.
-- Root cause: id column lost AUTO_INCREMENT (possibly from a manual recreate
--             or a CREATE TABLE IF NOT EXISTS that ran on an existing table
--             that was previously altered to drop AUTO_INCREMENT).
-- Fix: Restore AUTO_INCREMENT on the primary key column.

USE e_appointment_fskm;

ALTER TABLE `co_supervisor`
  MODIFY COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT;
