-- Migration 006: Add extended fields to external_examiner for nomination form
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS title          VARCHAR(50);
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS gender         VARCHAR(20);
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS nationality    VARCHAR(100);
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS ic_passport    VARCHAR(100);
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS faculty        VARCHAR(255);
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS country        VARCHAR(150);
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS specialization VARCHAR(255);
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS qualification  VARCHAR(100);
ALTER TABLE external_examiner ADD COLUMN IF NOT EXISTS position       VARCHAR(150);
