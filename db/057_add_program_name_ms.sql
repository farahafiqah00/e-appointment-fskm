-- ============================================================
-- 057_add_program_name_ms.sql
-- Adds a Malay program name column to the program table.
-- Used by BM appointment letters so PROGRAM PENGAJIAN shows
-- the proper Malay name instead of the English DB value.
--
-- When adding a new program in the future, also set name_ms:
--   UPDATE program SET name_ms = 'Malay Name Here' WHERE code = 'NEW_CODE';
-- ============================================================

USE e_appointment_fskm;

ALTER TABLE program
    ADD COLUMN name_ms VARCHAR(255) NULL
        COMMENT 'Malay program name used in BM appointment letters'
        AFTER name;

UPDATE program SET name_ms = 'Doktor Falsafah (Sains Komputer)'  WHERE code = 'PHD_CS';
UPDATE program SET name_ms = 'Doktor Falsafah (Matematik)'       WHERE code = 'PHD_MT';
UPDATE program SET name_ms = 'Sarjana Sains (Penyelidikan)'      WHERE code = 'MSC_R';

-- Verify
SELECT code, name, name_ms FROM program ORDER BY level, name;
