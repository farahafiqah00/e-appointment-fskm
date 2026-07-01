-- =============================================================================
-- 030_nullable_scheduled_at.sql
-- Allow scheduled_at to be NULL so a viva_appointment row can be auto-created
-- when a candidate is added (status = 'pending'), before a date is set.
-- =============================================================================

USE e_appointment_fskm;

ALTER TABLE viva_appointment
  MODIFY COLUMN scheduled_at DATETIME NULL DEFAULT NULL;
