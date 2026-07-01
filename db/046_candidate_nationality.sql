-- 046: Add nationality field to candidate table
ALTER TABLE candidate
  ADD COLUMN IF NOT EXISTS nationality VARCHAR(100) NULL AFTER contact_email;
