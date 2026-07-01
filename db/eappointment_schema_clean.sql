-- =============================================================================
-- eappointment_schema_clean.sql
-- Clean consolidated schema for e_appointment_fskm
-- Includes ALL columns from original schema + migrations 001-013
-- Safe to run on an existing database — does NOT drop anything
-- NO data inserted — run seed file separately after this
-- =============================================================================

CREATE DATABASE IF NOT EXISTS e_appointment_fskm
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE e_appointment_fskm;

-- =============================================================================
-- 1. ROLES
-- =============================================================================
CREATE TABLE IF NOT EXISTS role (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(50)  NOT NULL UNIQUE,
  description VARCHAR(255),
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =============================================================================
-- 2. TITLES
--    Covers all Malaysian academic title combinations (Mr, Dr, Assoc. Prof., etc.)
-- =============================================================================
CREATE TABLE IF NOT EXISTS title (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(50)  NOT NULL UNIQUE,
  description VARCHAR(255),
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =============================================================================
-- 3. PROGRAMS
-- =============================================================================
CREATE TABLE IF NOT EXISTS program (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code       VARCHAR(50)  NOT NULL UNIQUE,
  name       VARCHAR(150) NOT NULL,
  created_at DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =============================================================================
-- 4. USERS
-- =============================================================================
CREATE TABLE IF NOT EXISTS `user` (
  id            INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  role_id       INT UNSIGNED  NOT NULL,
  title_id      INT UNSIGNED,
  program_id    INT UNSIGNED,
  username      VARCHAR(100)  NOT NULL UNIQUE,
  password_hash VARCHAR(255)  NOT NULL,
  email         VARCHAR(150)  NOT NULL UNIQUE,
  full_name     VARCHAR(200)  NOT NULL,
  phone         VARCHAR(30),
  status        VARCHAR(20)   DEFAULT 'active',
  created_at    DATETIME      DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id)    REFERENCES role(id)    ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (title_id)   REFERENCES title(id)   ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (program_id) REFERENCES program(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- 5. RESEARCH HIERARCHY
--    4-level cascade: Specialization → Expertise → Division → Area
-- =============================================================================
CREATE TABLE IF NOT EXISTS specialization (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(150) NOT NULL UNIQUE,
  description VARCHAR(255),
  created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS expertise (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  specialization_id INT UNSIGNED NOT NULL,
  name              VARCHAR(150) NOT NULL,
  description       VARCHAR(255),
  created_at        DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (specialization_id) REFERENCES specialization(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS division (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name              VARCHAR(150) NOT NULL,
  specialization_id INT UNSIGNED,
  expertise_id      INT UNSIGNED,               -- added migration 003
  created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (specialization_id) REFERENCES specialization(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (expertise_id)      REFERENCES expertise(id)      ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS area (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name              VARCHAR(150) NOT NULL,
  specialization_id INT UNSIGNED,
  division_id       INT UNSIGNED,               -- added migration 003
  created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (specialization_id) REFERENCES specialization(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (division_id)       REFERENCES division(id)       ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- 6. ACADEMIC STAFF
--    Includes all columns from migrations 002 and 003
-- =============================================================================
CREATE TABLE IF NOT EXISTS academic_staff (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id          INT UNSIGNED,                              -- nullable (migration 002)
  staff_number     VARCHAR(50)  UNIQUE,
  full_name        VARCHAR(200),                             -- migration 002
  department       VARCHAR(150),
  faculty          VARCHAR(200) DEFAULT 'Faculty of Computer Science and Mathematics', -- migration 002
  program_id       INT UNSIGNED,
  specialization_id INT UNSIGNED,                           -- migration 002
  expertise_id     INT UNSIGNED,                            -- migration 002
  division_id      INT UNSIGNED,                            -- migration 003
  area_id          INT UNSIGNED,                            -- migration 003
  qualification    VARCHAR(50),                             -- migration 002
  academic_rank    VARCHAR(100),                            -- migration 002
  years_experience INT UNSIGNED DEFAULT 0,                  -- migration 002
  status           VARCHAR(20)  DEFAULT 'active',           -- migration 002
  created_at       DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)           REFERENCES `user`(id)         ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (program_id)        REFERENCES program(id)        ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (specialization_id) REFERENCES specialization(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (expertise_id)      REFERENCES expertise(id)      ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (division_id)       REFERENCES division(id)       ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (area_id)           REFERENCES area(id)           ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- 7. CANDIDATE
--    Includes all columns from migrations 001, 005, and 013
-- =============================================================================
CREATE TABLE IF NOT EXISTS candidate (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id      VARCHAR(50)  NOT NULL UNIQUE,
  full_name       VARCHAR(200) NOT NULL,
  program         VARCHAR(150),
  program_id      INT UNSIGNED,
  thesis_title    VARCHAR(500),                             -- migration 001/005
  supervisor_name VARCHAR(255),                            -- migration 001/005
  supervisor_id   INT UNSIGNED,                            -- migration 013 (FK → academic_staff)
  contact_email   VARCHAR(150),                            -- migration 005
  status          VARCHAR(30)  DEFAULT 'prepared',
  created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (program_id)    REFERENCES program(id)        ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (supervisor_id) REFERENCES academic_staff(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =============================================================================
-- 8. CO-SUPERVISOR  (migration 005)
-- =============================================================================
CREATE TABLE IF NOT EXISTS co_supervisor (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  candidate_id INT UNSIGNED NOT NULL,
  name         VARCHAR(200) NOT NULL,
  created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (candidate_id) REFERENCES candidate(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================================
-- 9. COUNTRY & UNIVERSITY
-- =============================================================================
CREATE TABLE IF NOT EXISTS country (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(150) NOT NULL UNIQUE,
  iso_code   VARCHAR(8),
  created_at DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS university (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(255) NOT NULL,
  country_id INT UNSIGNED,
  created_at DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (country_id) REFERENCES country(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- 10. EXTERNAL EXAMINER
--     Includes all columns from migrations 006 and 008
-- =============================================================================
CREATE TABLE IF NOT EXISTS external_examiner (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  -- Basic identity
  title             VARCHAR(50),                            -- migration 006
  name              VARCHAR(200) NOT NULL,
  gender            VARCHAR(20),                           -- migration 006
  nationality       VARCHAR(100),                          -- migration 006
  ic_passport       VARCHAR(100),                          -- migration 006
  -- Contact
  email             VARCHAR(150),
  phone             VARCHAR(30),
  -- Institution
  affiliation       VARCHAR(255),
  faculty           VARCHAR(255),                          -- migration 006
  university_id     INT UNSIGNED,
  country_id        INT UNSIGNED,
  country           VARCHAR(150),                          -- migration 006 (free-text legacy)
  -- Academic profile
  specialization    VARCHAR(255),                          -- migration 006 (free-text legacy)
  qualification     VARCHAR(100),                          -- migration 006
  position          VARCHAR(150),                          -- migration 006
  -- 4-level research hierarchy (migration 008)
  specialization_id INT UNSIGNED,
  expertise_id      INT UNSIGNED,
  division_id       INT UNSIGNED,
  area_id           INT UNSIGNED,
  -- Status
  status            VARCHAR(30)  DEFAULT 'active',
  created_at        DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (university_id)     REFERENCES university(id)     ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (country_id)        REFERENCES country(id)        ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (specialization_id) REFERENCES specialization(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (expertise_id)      REFERENCES expertise(id)      ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (division_id)       REFERENCES division(id)       ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (area_id)           REFERENCES area(id)           ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- 11. NOMINATION
--     candidate_id is nullable (migration 007 — can link candidate later)
-- =============================================================================
CREATE TABLE IF NOT EXISTS nomination (
  id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  candidate_id        INT UNSIGNED,                        -- nullable (migration 007)
  external_examiner_id INT UNSIGNED,
  nominator_user_id   INT UNSIGNED NOT NULL,
  nomination_date     DATETIME     DEFAULT CURRENT_TIMESTAMP,
  status              VARCHAR(30)  DEFAULT 'pending',
  remarks             VARCHAR(500),
  created_at          DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (candidate_id)         REFERENCES candidate(id)         ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (external_examiner_id) REFERENCES external_examiner(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (nominator_user_id)    REFERENCES `user`(id)            ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================================================
-- 12. VENUE  (migration 013)
-- =============================================================================
CREATE TABLE IF NOT EXISTS venue (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(200) NOT NULL UNIQUE,
  location   VARCHAR(255),
  capacity   INT          DEFAULT 20,
  is_active  TINYINT(1)   DEFAULT 1,
  created_at DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =============================================================================
-- 13. VIVA APPOINTMENT
-- =============================================================================
CREATE TABLE IF NOT EXISTS viva_appointment (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  candidate_id     INT UNSIGNED NOT NULL,
  nomination_id    INT UNSIGNED,
  scheduled_at     DATETIME     NULL DEFAULT NULL,
  venue            VARCHAR(255),
  duration_minutes INT          DEFAULT 90,
  status           VARCHAR(30)  DEFAULT 'scheduled',
  created_at       DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (candidate_id)  REFERENCES candidate(id)  ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (nomination_id) REFERENCES nomination(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- 14. APPOINTMENT PANEL
-- =============================================================================
CREATE TABLE IF NOT EXISTS appointment_panel (
  id                   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id       INT UNSIGNED NOT NULL,
  internal_user_id     INT UNSIGNED,
  external_examiner_id INT UNSIGNED,
  member_role          VARCHAR(100),
  is_chair             TINYINT(1)   DEFAULT 0,
  sequence_order       INT          DEFAULT 0,
  created_at           DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointment_id)       REFERENCES viva_appointment(id)  ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (internal_user_id)     REFERENCES `user`(id)            ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (external_examiner_id) REFERENCES external_examiner(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- 15. DOCUMENT
-- =============================================================================
CREATE TABLE IF NOT EXISTS document (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomination_id INT UNSIGNED,
  uploaded_by   INT UNSIGNED,
  filename      VARCHAR(255) NOT NULL,
  filepath      VARCHAR(1024),
  file_type     VARCHAR(100),
  uploaded_at   DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (nomination_id) REFERENCES nomination(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (uploaded_by)   REFERENCES `user`(id)     ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- 16. APPOINTMENT LETTER
-- =============================================================================
CREATE TABLE IF NOT EXISTS appointment_letter (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT UNSIGNED NOT NULL,
  letter_number  VARCHAR(150) UNIQUE,
  issued_date    DATETIME     DEFAULT CURRENT_TIMESTAMP,
  issued_by      INT UNSIGNED,
  content        VARCHAR(2000),
  status         VARCHAR(30)  DEFAULT 'issued',
  created_at     DATETIME     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (appointment_id) REFERENCES viva_appointment(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (issued_by)      REFERENCES `user`(id)           ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- 17. LOOKUP TABLES (examiner_category, examiner_group)
-- =============================================================================
CREATE TABLE IF NOT EXISTS examiner_category (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(150) NOT NULL UNIQUE,
  created_at DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS examiner_group (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(150) NOT NULL UNIQUE,
  created_at DATETIME     DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =============================================================================
-- 18. APPOINTMENT LETTER APPROVAL
--     Appointment-level signer routing before panel letter emails are sent
-- =============================================================================
CREATE TABLE IF NOT EXISTS appointment_letter_approval (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  appointment_id    INT UNSIGNED NOT NULL UNIQUE,
  signer_user_id    INT UNSIGNED NOT NULL,
  signer_label      VARCHAR(50)  NOT NULL,
  status            VARCHAR(20)  NOT NULL DEFAULT 'pending',
  requested_by      INT UNSIGNED,
  requested_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
  signed_by         INT UNSIGNED,
  signed_at         DATETIME     NULL,
  created_at        DATETIME     DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_approval_signer_status (signer_user_id, status),
  KEY idx_approval_status (status),
  FOREIGN KEY (appointment_id) REFERENCES viva_appointment(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (signer_user_id) REFERENCES `user`(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (requested_by)   REFERENCES `user`(id) ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (signed_by)      REFERENCES `user`(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =============================================================================
-- END OF SCHEMA
-- Next step: run eappointment_seed_users.sql to insert the initial accounts
-- =============================================================================
