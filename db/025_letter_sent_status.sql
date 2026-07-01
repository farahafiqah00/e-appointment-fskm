-- Migration 025: Track whether appointment letter email has been sent per panel member
ALTER TABLE appointment_panel
    ADD COLUMN letter_sent TINYINT(1) NOT NULL DEFAULT 0 AFTER letter_signed;
