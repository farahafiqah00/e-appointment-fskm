-- =============================================================================
-- 036_panel_response.sql
-- Adds online response tracking for External Examiners.
-- External examiners receive a unique token link in their appointment email
-- and can Accept or Decline the appointment online.
-- The status 'examiner_declined' is added to viva_appointment.status vocabulary.
-- =============================================================================

USE e_appointment_fskm;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Add response columns to appointment_panel
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE appointment_panel
  ADD COLUMN IF NOT EXISTS response_token   VARCHAR(64)  DEFAULT NULL    AFTER letter_sent,
  ADD COLUMN IF NOT EXISTS panel_response   VARCHAR(20)  DEFAULT NULL    AFTER response_token,
  ADD COLUMN IF NOT EXISTS rejection_reason TEXT         DEFAULT NULL    AFTER panel_response,
  ADD COLUMN IF NOT EXISTS responded_at     DATETIME     DEFAULT NULL    AFTER rejection_reason,
  ADD COLUMN IF NOT EXISTS letter_sent_at   DATETIME     DEFAULT NULL    AFTER responded_at;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Unique index on response_token (ensures no collision + fast lookup)
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE appointment_panel
  ADD UNIQUE INDEX IF NOT EXISTS uq_ap_response_token (response_token);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Back-fill letter_sent_at for existing rows that already have letter_sent=1
--    (approximation: use created_at since actual send time is unknown)
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE appointment_panel
SET letter_sent_at = created_at
WHERE letter_sent = 1 AND letter_sent_at IS NULL;

-- NOTE: viva_appointment.status is a VARCHAR(30); 'examiner_declined' (17 chars)
-- is within range. No ALTER needed.
-- Valid status values after this migration:
--   pending | scheduled | decided | letter_generated | deferred | examiner_declined
