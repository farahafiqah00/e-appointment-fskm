-- =============================================================================
-- 035_fix_user_autoincrement.sql
-- Fixes HTTP 500 in AddUserServlet: "Field 'id' doesn't have a default value"
-- Safe to run even if AUTO_INCREMENT is already set.
-- =============================================================================

USE e_appointment_fskm;

-- Step 1: Make id a plain NOT NULL column first (drops any conflicting constraint)
ALTER TABLE `user`
  MODIFY COLUMN `id` INT UNSIGNED NOT NULL;

-- Step 2: Add PRIMARY KEY (skip this step if phpmyadmin says "Duplicate key name")
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

-- Step 3: Enable AUTO_INCREMENT now that the key exists
ALTER TABLE `user`
  MODIFY COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT;
