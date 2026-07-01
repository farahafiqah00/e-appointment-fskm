-- Migration 002: Extend academic_staff table with profile fields
-- Run this in phpMyAdmin against e_appointment_fskm before using the Academic Staff pages.

USE e_appointment_fskm;

-- Make user_id nullable so staff can be registered without a system user account
ALTER TABLE academic_staff MODIFY COLUMN user_id INT UNSIGNED NULL;

-- Staff display name (stored independently from the linked user account)
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS full_name VARCHAR(200);

-- Faculty name (usually "Faculty of Computer Science and Mathematics")
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS faculty VARCHAR(200) DEFAULT 'Faculty of Computer Science and Mathematics';

-- Link to specialization (for cascade dropdown + examiner matching)
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS specialization_id INT UNSIGNED;

-- Link to expertise (sub-category of specialization)
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS expertise_id INT UNSIGNED;

-- Academic profile fields
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS qualification VARCHAR(50);
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS academic_rank VARCHAR(100);
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS years_experience INT UNSIGNED DEFAULT 0;

-- Independent status for academic record (different from user login status)
ALTER TABLE academic_staff ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'active';

-- Update existing seeded row so full_name is populated from linked user
UPDATE academic_staff a
JOIN `user` u ON a.user_id = u.id
SET a.full_name = u.full_name
WHERE a.full_name IS NULL;

-- Verify
-- SELECT id, staff_number, full_name, department, specialization_id, qualification, status FROM academic_staff;
