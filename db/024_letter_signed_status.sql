-- Migration 024: Track whether each panel member's signed letter has been received.
-- letter_signed = 0 (pending), 1 (admin confirmed signed letter received).

ALTER TABLE appointment_panel
  ADD COLUMN letter_signed TINYINT(1) NOT NULL DEFAULT 0 AFTER is_chair;
