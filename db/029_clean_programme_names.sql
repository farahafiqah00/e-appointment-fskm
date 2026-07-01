-- =============================================================================
-- 029_clean_programme_names.sql
-- Strip degree-level prefixes from programme names so the name holds only the
-- discipline (e.g. "Artificial Intelligence"), while the `level` column carries
-- "PhD" or "Master". This avoids redundancy in the UI and letters.
--
-- The letter templates use `degreeLabelMS`/`degreeLabelEN` (derived from `level`)
-- so removing the prefix from `name` does NOT affect letter output.
-- =============================================================================

USE e_appointment_fskm;

-- Strip "Doctor of Philosophy in " (24 chars: D-o-c-t-o-r- -o-f- -P-h-i-l-o-s-o-p-h-y- -i-n- )
UPDATE `program`
   SET `name` = TRIM(SUBSTRING(`name`, 25))
 WHERE `name` LIKE 'Doctor of Philosophy in %';

-- Strip "PhD " (4 chars)
UPDATE `program`
   SET `name` = TRIM(SUBSTRING(`name`, 5))
 WHERE `name` LIKE 'PhD %';

-- Strip "Master of Science in " (21 chars)
UPDATE `program`
   SET `name` = TRIM(SUBSTRING(`name`, 22))
 WHERE `name` LIKE 'Master of Science in %';

-- Strip "Master of " (10 chars)
UPDATE `program`
   SET `name` = TRIM(SUBSTRING(`name`, 11))
 WHERE `name` LIKE 'Master of %';

-- Strip "Sarjana Sains dalam " (20 chars)
UPDATE `program`
   SET `name` = TRIM(SUBSTRING(`name`, 21))
 WHERE `name` LIKE 'Sarjana Sains dalam %';

-- Strip "Sarjana " (8 chars)  – must come AFTER the longer patterns above
UPDATE `program`
   SET `name` = TRIM(SUBSTRING(`name`, 9))
 WHERE `name` LIKE 'Sarjana %'
   AND `name` NOT LIKE 'Sarjana Sains dalam %';
