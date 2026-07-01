-- Per-user signature image stored in academic_staff table.
-- When a dean/TDA/TDB uploads a signature while signing a letter,
-- it is saved here so future signings can reuse it automatically.
ALTER TABLE academic_staff
  ADD COLUMN signature_image VARCHAR(255) NULL
    COMMENT 'Filename of stored signature image in uploads/signatures/ — reused across letter signings'
  AFTER user_id;
