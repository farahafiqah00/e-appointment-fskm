-- =============================================================================
-- 039_signature_image.sql
-- Adds signature_image column to appointment_letter_approval so dean/TDA/TDB
-- can upload their handwritten signature image at signing time.
-- =============================================================================

USE e_appointment_fskm;

ALTER TABLE appointment_letter_approval
  ADD COLUMN signature_image VARCHAR(255) NULL
    COMMENT 'Filename of the uploaded signature image (stored in uploads/signatures/)'
  AFTER signed_at;
