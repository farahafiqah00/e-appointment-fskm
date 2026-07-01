-- =============================================================================
-- 038_comprehensive_fix.sql
-- Run this ONCE in phpMyAdmin / MySQL CLI against e_appointment_fskm.
-- Fixes every known schema gap:
--   1. AUTO_INCREMENT lost on external_examiner, nomination, document,
--      viva_appointment, appointment_letter, user, candidate, academic_staff,
--      appointment_panel  (500 on nomination submit / saveFiles)
--   2. Missing columns: external_examiner extended fields + verification token cols
--      + research hierarchy FK cols
--   3. nomination.candidate_id must be nullable (migration 007)
--   4. viva_appointment.scheduled_at must be nullable (migration 030)
--   5. program.level column (migration 027)
--   6. appointment_panel: letter_signed → letter_sent → response columns → bank cols
--   7. academic_staff.administrative_position (migration 034)
--   8. appointment_letter_approval table (migration 032)
--   9. division.expertise_id and area.division_id (migration 003)
-- Safe to re-run; uses IF NOT EXISTS / MODIFY (idempotent where possible).
-- =============================================================================

USE e_appointment_fskm;

-- Disable FK checks so ALTER TABLE is not blocked by referencing tables.
-- Re-enabled at the end of this section.
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- AUTO_INCREMENT REPAIR  (4-step pattern per table)
--
--   Step 1 – MODIFY column to plain NOT NULL (strips AUTO_INCREMENT safely)
--   Step 2 – Reassign any rows where id <= 0 to sequential values > MAX(id).
--             Prevents error #1062 "Duplicate entry '0' for key 'PRIMARY'"
--             which fires when ADD PRIMARY KEY finds non-unique id values.
--   Step 3 – ADD PRIMARY KEY only if it is missing (dynamic SQL prevents
--             error "Duplicate key name 'PRIMARY'").
--   Step 4 – MODIFY column to add AUTO_INCREMENT (requires a key → step 3
--             guarantees one exists, preventing error #1075).
-- =============================================================================

-- ── external_examiner ─────────────────────────────────────────────────────────
ALTER TABLE external_examiner MODIFY COLUMN id INT UNSIGNED NOT NULL;
SET @_m = (SELECT COALESCE(MAX(id), 0) FROM external_examiner WHERE id > 0);
UPDATE external_examiner SET id = (@_m := @_m + 1) WHERE id <= 0;
SET @_pk = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='external_examiner' AND CONSTRAINT_TYPE='PRIMARY KEY');
SET @_sql = IF(@_pk=0,'ALTER TABLE external_examiner ADD PRIMARY KEY (id)','SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;
ALTER TABLE external_examiner MODIFY COLUMN id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- ── nomination ────────────────────────────────────────────────────────────────
ALTER TABLE nomination MODIFY COLUMN id INT UNSIGNED NOT NULL;
SET @_m = (SELECT COALESCE(MAX(id), 0) FROM nomination WHERE id > 0);
UPDATE nomination SET id = (@_m := @_m + 1) WHERE id <= 0;
SET @_pk = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='nomination' AND CONSTRAINT_TYPE='PRIMARY KEY');
SET @_sql = IF(@_pk=0,'ALTER TABLE nomination ADD PRIMARY KEY (id)','SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;
ALTER TABLE nomination MODIFY COLUMN id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- ── user ──────────────────────────────────────────────────────────────────────
ALTER TABLE `user` MODIFY COLUMN id INT UNSIGNED NOT NULL;
SET @_m = (SELECT COALESCE(MAX(id), 0) FROM `user` WHERE id > 0);
UPDATE `user` SET id = (@_m := @_m + 1) WHERE id <= 0;
SET @_pk = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='user' AND CONSTRAINT_TYPE='PRIMARY KEY');
SET @_sql = IF(@_pk=0,'ALTER TABLE `user` ADD PRIMARY KEY (id)','SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;
ALTER TABLE `user` MODIFY COLUMN id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- ── candidate ─────────────────────────────────────────────────────────────────
ALTER TABLE candidate MODIFY COLUMN id INT UNSIGNED NOT NULL;
SET @_m = (SELECT COALESCE(MAX(id), 0) FROM candidate WHERE id > 0);
UPDATE candidate SET id = (@_m := @_m + 1) WHERE id <= 0;
SET @_pk = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='candidate' AND CONSTRAINT_TYPE='PRIMARY KEY');
SET @_sql = IF(@_pk=0,'ALTER TABLE candidate ADD PRIMARY KEY (id)','SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;
ALTER TABLE candidate MODIFY COLUMN id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- ── academic_staff ────────────────────────────────────────────────────────────
ALTER TABLE academic_staff MODIFY COLUMN id INT UNSIGNED NOT NULL;
SET @_m = (SELECT COALESCE(MAX(id), 0) FROM academic_staff WHERE id > 0);
UPDATE academic_staff SET id = (@_m := @_m + 1) WHERE id <= 0;
SET @_pk = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='academic_staff' AND CONSTRAINT_TYPE='PRIMARY KEY');
SET @_sql = IF(@_pk=0,'ALTER TABLE academic_staff ADD PRIMARY KEY (id)','SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;
ALTER TABLE academic_staff MODIFY COLUMN id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- ── appointment_panel ─────────────────────────────────────────────────────────
ALTER TABLE appointment_panel MODIFY COLUMN id INT UNSIGNED NOT NULL;
SET @_m = (SELECT COALESCE(MAX(id), 0) FROM appointment_panel WHERE id > 0);
UPDATE appointment_panel SET id = (@_m := @_m + 1) WHERE id <= 0;
SET @_pk = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='appointment_panel' AND CONSTRAINT_TYPE='PRIMARY KEY');
SET @_sql = IF(@_pk=0,'ALTER TABLE appointment_panel ADD PRIMARY KEY (id)','SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;
ALTER TABLE appointment_panel MODIFY COLUMN id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- ── document ──────────────────────────────────────────────────────────────────
ALTER TABLE document MODIFY COLUMN id INT UNSIGNED NOT NULL;
SET @_m = (SELECT COALESCE(MAX(id), 0) FROM document WHERE id > 0);
UPDATE document SET id = (@_m := @_m + 1) WHERE id <= 0;
SET @_pk = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='document' AND CONSTRAINT_TYPE='PRIMARY KEY');
SET @_sql = IF(@_pk=0,'ALTER TABLE document ADD PRIMARY KEY (id)','SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;
ALTER TABLE document MODIFY COLUMN id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- ── viva_appointment ──────────────────────────────────────────────────────────
ALTER TABLE viva_appointment MODIFY COLUMN id INT UNSIGNED NOT NULL;
SET @_m = (SELECT COALESCE(MAX(id), 0) FROM viva_appointment WHERE id > 0);
UPDATE viva_appointment SET id = (@_m := @_m + 1) WHERE id <= 0;
SET @_pk = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='viva_appointment' AND CONSTRAINT_TYPE='PRIMARY KEY');
SET @_sql = IF(@_pk=0,'ALTER TABLE viva_appointment ADD PRIMARY KEY (id)','SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;
ALTER TABLE viva_appointment MODIFY COLUMN id INT UNSIGNED NOT NULL AUTO_INCREMENT;

-- ── appointment_letter ────────────────────────────────────────────────────────
ALTER TABLE appointment_letter MODIFY COLUMN id INT UNSIGNED NOT NULL;
SET @_m = (SELECT COALESCE(MAX(id), 0) FROM appointment_letter WHERE id > 0);
UPDATE appointment_letter SET id = (@_m := @_m + 1) WHERE id <= 0;
SET @_pk = (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='appointment_letter' AND CONSTRAINT_TYPE='PRIMARY KEY');
SET @_sql = IF(@_pk=0,'ALTER TABLE appointment_letter ADD PRIMARY KEY (id)','SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;
ALTER TABLE appointment_letter MODIFY COLUMN id INT UNSIGNED NOT NULL AUTO_INCREMENT;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- EXTERNAL EXAMINER — extended columns (migration 006)
-- =============================================================================
ALTER TABLE external_examiner
  ADD COLUMN IF NOT EXISTS title          VARCHAR(50)  NULL,
  ADD COLUMN IF NOT EXISTS gender         VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS nationality    VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS ic_passport    VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS faculty        VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS country        VARCHAR(150) NULL,
  ADD COLUMN IF NOT EXISTS specialization VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS qualification  VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS position       VARCHAR(150) NULL;

-- =============================================================================
-- EXTERNAL EXAMINER — verification token columns (migration 022)
-- Root cause of "Invalid Link": saveVerificationToken UPDATE finds 0 rows
-- because these columns are missing, so the token is never stored in the DB
-- even though the email is sent successfully.
-- =============================================================================
ALTER TABLE external_examiner
  ADD COLUMN IF NOT EXISTS verification_token  VARCHAR(64)  DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS token_expires_at    DATETIME     DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS info_confirmed      TINYINT(1)   NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS confirmed_at        DATETIME     DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS discrepancy_notes   TEXT         DEFAULT NULL;

-- Unique index on verification_token (safe dynamic SQL, works on all MySQL 5.7+)
SET @_idx3 = (SELECT COUNT(*) FROM information_schema.STATISTICS
              WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'external_examiner'
                AND INDEX_NAME = 'uq_ee_verification_token');
SET @_sql3 = IF(@_idx3 = 0,
  'ALTER TABLE external_examiner ADD UNIQUE INDEX uq_ee_verification_token (verification_token)',
  'SELECT 1');
PREPARE _s FROM @_sql3; EXECUTE _s; DEALLOCATE PREPARE _s;

-- =============================================================================
-- EXTERNAL EXAMINER — 4-level research hierarchy FK cols (migration 008)
-- =============================================================================
ALTER TABLE external_examiner
  ADD COLUMN IF NOT EXISTS specialization_id INT UNSIGNED NULL,
  ADD COLUMN IF NOT EXISTS expertise_id      INT UNSIGNED NULL,
  ADD COLUMN IF NOT EXISTS division_id       INT UNSIGNED NULL,
  ADD COLUMN IF NOT EXISTS area_id           INT UNSIGNED NULL;

-- =============================================================================
-- RESEARCH HIERARCHY — division.expertise_id and area.division_id (migration 003)
-- =============================================================================
ALTER TABLE division ADD COLUMN IF NOT EXISTS expertise_id INT UNSIGNED NULL;
ALTER TABLE area     ADD COLUMN IF NOT EXISTS division_id  INT UNSIGNED NULL;

-- =============================================================================
-- NOMINATION — make candidate_id nullable (migration 007)
-- =============================================================================
ALTER TABLE nomination MODIFY COLUMN candidate_id INT UNSIGNED NULL;

-- =============================================================================
-- VIVA_APPOINTMENT — make scheduled_at nullable (migration 030)
-- =============================================================================
ALTER TABLE viva_appointment MODIFY COLUMN scheduled_at DATETIME NULL DEFAULT NULL;

-- =============================================================================
-- PROGRAM — add level column (migration 027)
-- =============================================================================
SET @_col = (SELECT COUNT(*) FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'program' AND COLUMN_NAME = 'level');
SET @_sql = IF(@_col = 0,
  "ALTER TABLE `program` ADD COLUMN `level` ENUM('PhD','Master') NOT NULL DEFAULT 'PhD' AFTER `code`",
  'SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;

-- =============================================================================
-- ACADEMIC_STAFF — administrative_position (migration 034)
-- =============================================================================
ALTER TABLE academic_staff
  ADD COLUMN IF NOT EXISTS administrative_position VARCHAR(10) NULL
    COMMENT 'TDA = Timbalan Dekan Akademik, TDB = Timbalan Dekan Berkaitan';

-- =============================================================================
-- APPOINTMENT_PANEL — letter_signed (migration 024)
-- =============================================================================
ALTER TABLE appointment_panel
  ADD COLUMN IF NOT EXISTS letter_signed TINYINT(1) NOT NULL DEFAULT 0;

-- =============================================================================
-- APPOINTMENT_PANEL — letter_sent (migration 025)
-- =============================================================================
ALTER TABLE appointment_panel
  ADD COLUMN IF NOT EXISTS letter_sent TINYINT(1) NOT NULL DEFAULT 0;

-- =============================================================================
-- APPOINTMENT_PANEL — response + token columns (migration 036)
-- =============================================================================
ALTER TABLE appointment_panel
  ADD COLUMN IF NOT EXISTS response_token   VARCHAR(64)  NULL,
  ADD COLUMN IF NOT EXISTS panel_response   VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS rejection_reason TEXT         NULL,
  ADD COLUMN IF NOT EXISTS responded_at     DATETIME     NULL,
  ADD COLUMN IF NOT EXISTS letter_sent_at   DATETIME     NULL;

-- response_token unique index
SET @_idx = (SELECT COUNT(*) FROM information_schema.STATISTICS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'appointment_panel'
               AND INDEX_NAME = 'uq_ap_response_token');
SET @_sql = IF(@_idx = 0,
  'ALTER TABLE appointment_panel ADD UNIQUE INDEX uq_ap_response_token (response_token)',
  'SELECT 1');
PREPARE _s FROM @_sql; EXECUTE _s; DEALLOCATE PREPARE _s;

-- =============================================================================
-- APPOINTMENT_PANEL — audit & bank columns (migration 037)
-- =============================================================================
ALTER TABLE appointment_panel
  ADD COLUMN IF NOT EXISTS response_source      VARCHAR(20)  NULL,
  ADD COLUMN IF NOT EXISTS responded_by_user_id INT          NULL,
  ADD COLUMN IF NOT EXISTS responded_ip         VARCHAR(45)  NULL,
  ADD COLUMN IF NOT EXISTS bank_account_name    VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS bank_account_number  VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS bank_name            VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS bank_iban            VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS bank_swift           VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS bank_country         VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS bank_provided_at     TIMESTAMP    NULL DEFAULT NULL;

SET @_idx2 = (SELECT COUNT(*) FROM information_schema.STATISTICS
              WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'appointment_panel'
                AND INDEX_NAME = 'idx_response_token');
SET @_sql2 = IF(@_idx2 = 0,
  'ALTER TABLE appointment_panel ADD INDEX idx_response_token (response_token(32))',
  'SELECT 1');
PREPARE _s FROM @_sql2; EXECUTE _s; DEALLOCATE PREPARE _s;

-- =============================================================================
-- APPOINTMENT_LETTER_APPROVAL table (migration 032)
-- =============================================================================
CREATE TABLE IF NOT EXISTS appointment_letter_approval (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id   INT UNSIGNED NOT NULL,
  signer_user_id   INT UNSIGNED NOT NULL,
  signer_label     VARCHAR(50)  NOT NULL,
  status           VARCHAR(20)  NOT NULL DEFAULT 'pending',
  requested_by     INT UNSIGNED NULL,
  requested_at     DATETIME     DEFAULT CURRENT_TIMESTAMP,
  signed_by        INT UNSIGNED NULL,
  signed_at        DATETIME     NULL,
  created_at       DATETIME     DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_approval_appointment (appointment_id),
  KEY idx_approval_signer_status (signer_user_id, status),
  KEY idx_approval_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- BACKFILL — letter_sent_at for rows already having letter_sent=1
-- =============================================================================
UPDATE appointment_panel
SET letter_sent_at = created_at
WHERE letter_sent = 1 AND letter_sent_at IS NULL;

-- =============================================================================
-- CANDIDATE — ensure extended columns exist (migration 013)
-- =============================================================================
ALTER TABLE candidate
  ADD COLUMN IF NOT EXISTS thesis_title    VARCHAR(500) NULL,
  ADD COLUMN IF NOT EXISTS supervisor_name VARCHAR(255) NULL,
  ADD COLUMN IF NOT EXISTS supervisor_id   INT UNSIGNED NULL,
  ADD COLUMN IF NOT EXISTS contact_email   VARCHAR(150) NULL;

-- =============================================================================
-- ACADEMIC_STAFF — ensure all extended columns exist (migrations 002/003)
-- =============================================================================
ALTER TABLE academic_staff
  ADD COLUMN IF NOT EXISTS full_name         VARCHAR(200) NULL,
  ADD COLUMN IF NOT EXISTS faculty           VARCHAR(200) NULL DEFAULT 'Faculty of Computer Science and Mathematics',
  ADD COLUMN IF NOT EXISTS specialization_id INT UNSIGNED NULL,
  ADD COLUMN IF NOT EXISTS expertise_id      INT UNSIGNED NULL,
  ADD COLUMN IF NOT EXISTS division_id       INT UNSIGNED NULL,
  ADD COLUMN IF NOT EXISTS area_id           INT UNSIGNED NULL,
  ADD COLUMN IF NOT EXISTS qualification     VARCHAR(50)  NULL,
  ADD COLUMN IF NOT EXISTS academic_rank     VARCHAR(100) NULL,
  ADD COLUMN IF NOT EXISTS years_experience  INT UNSIGNED NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS status            VARCHAR(20)  NULL DEFAULT 'active';

-- =============================================================================
-- DONE. Verify with:
--   SELECT TABLE_NAME, AUTO_INCREMENT FROM information_schema.TABLES
--     WHERE TABLE_SCHEMA='e_appointment_fskm'
--     AND TABLE_NAME IN ('external_examiner','nomination','document',
--                        'viva_appointment','appointment_letter','user',
--                        'candidate','academic_staff','appointment_panel');
-- =============================================================================
