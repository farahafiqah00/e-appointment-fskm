-- Idempotent: Add audit and bank details to appointment_panel only if missing.
-- Safe to run multiple times. Uses information_schema checks and dynamic ALTERs.
-- Run in the target database (it uses DATABASE()).

-- Add columns one by one if they do not exist
SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'response_source');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN response_source VARCHAR(20) DEFAULT NULL',
  'SELECT "response_source exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'responded_by_user_id');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN responded_by_user_id INT DEFAULT NULL',
  'SELECT "responded_by_user_id exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'responded_ip');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN responded_ip VARCHAR(45) DEFAULT NULL',
  'SELECT "responded_ip exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'bank_account_name');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN bank_account_name VARCHAR(255) DEFAULT NULL',
  'SELECT "bank_account_name exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'bank_account_number');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN bank_account_number VARCHAR(255) DEFAULT NULL',
  'SELECT "bank_account_number exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'bank_name');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN bank_name VARCHAR(255) DEFAULT NULL',
  'SELECT "bank_name exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'bank_iban');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN bank_iban VARCHAR(255) DEFAULT NULL',
  'SELECT "bank_iban exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'bank_swift');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN bank_swift VARCHAR(255) DEFAULT NULL',
  'SELECT "bank_swift exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'bank_country');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN bank_country VARCHAR(100) DEFAULT NULL',
  'SELECT "bank_country exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

SET @c := (SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'appointment_panel'
              AND COLUMN_NAME = 'bank_provided_at');
SET @stmt = IF(@c = 0,
  'ALTER TABLE appointment_panel ADD COLUMN bank_provided_at TIMESTAMP NULL DEFAULT NULL',
  'SELECT "bank_provided_at exists"');
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;

-- Optional: add index on response_token if missing
SET @idx := (
  SELECT COUNT(*) FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'appointment_panel'
    AND INDEX_NAME = 'idx_response_token'
);
SET @stmt = IF(@idx = 0,
  'ALTER TABLE appointment_panel ADD INDEX idx_response_token (response_token(32))',
  'SELECT "idx_response_token exists"'
);
PREPARE ps FROM @stmt; EXECUTE ps; DEALLOCATE PREPARE ps;
