-- Migration 020: Add title column to academic_staff
-- Allows storing the academic title separately from the full name.

ALTER TABLE academic_staff
    ADD COLUMN IF NOT EXISTS title VARCHAR(50) NULL AFTER staff_number;
