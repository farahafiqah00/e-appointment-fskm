-- Migration 007: Allow nomination to be submitted without selecting a candidate
-- (admin can link the candidate later)
ALTER TABLE nomination MODIFY COLUMN candidate_id INT UNSIGNED NULL;
