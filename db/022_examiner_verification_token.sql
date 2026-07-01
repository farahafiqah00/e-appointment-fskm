-- Migration 022: Examiner info verification via email token
-- Adds token-based verification flow so nominators can email examiners a link
-- to confirm their information is correct (no system login required).

ALTER TABLE external_examiner
    ADD COLUMN IF NOT EXISTS verification_token  VARCHAR(64)   DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS token_expires_at    DATETIME      DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS info_confirmed      TINYINT(1)    NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS confirmed_at        DATETIME      DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS discrepancy_notes   TEXT          DEFAULT NULL;

-- Unique index on token so lookups are O(1) and duplicates are impossible
ALTER TABLE external_examiner
    ADD UNIQUE INDEX IF NOT EXISTS uq_ee_verification_token (verification_token);
