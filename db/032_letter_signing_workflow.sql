-- =============================================================================
-- 032_letter_signing_workflow.sql
-- Adds appointment-level signer routing (Dean/TDA/TDB) before panel letters are sent.
-- =============================================================================

USE e_appointment_fskm;

-- Drop existing table if it exists
DROP TABLE IF EXISTS appointment_letter_approval;

-- Create simple table without any constraints first
CREATE TABLE appointment_letter_approval (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id    INT UNSIGNED NOT NULL,
  signer_user_id    INT UNSIGNED NOT NULL,
  signer_label      VARCHAR(50) NOT NULL,
  status            VARCHAR(20) NOT NULL DEFAULT 'pending',
  requested_by      INT UNSIGNED,
  requested_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
  signed_by         INT UNSIGNED,
  signed_at         DATETIME NULL,
  created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_approval_appointment (appointment_id),
  KEY idx_approval_signer_status (signer_user_id, status),
  KEY idx_approval_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
