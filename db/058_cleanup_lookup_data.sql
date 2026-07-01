-- Migration 058: Remove unused lookup entries and orphaned table
--
-- 1. Removes 'Adjunct' from examiner_category (not used in FSKM viva process)
-- 2. Removes all examiner_group entries (Senior/Mid/Junior - not referenced in application)
-- 3. Drops appointment_letter table (orphaned - workflow uses appointment_letter_approval instead)

USE e_appointment_fskm;

DELETE FROM examiner_category WHERE name = 'Adjunct';

DELETE FROM examiner_group;

DROP TABLE IF EXISTS appointment_letter;
