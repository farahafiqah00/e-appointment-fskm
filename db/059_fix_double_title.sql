-- Migration 059: Remove duplicate title prefixes from name columns
--
-- Problem: two different seed paths left titles embedded in name columns,
-- but every display query ALSO prepends the title from ast.title or t.name,
-- causing "Dr. Dr. Fadzil" in nomination emails and appointment letters.
--
-- Affected rows after running seeds 001-058:
--   user.full_name  = 'Dr. Academician'       (seed_users.sql, title_id set)
--   user.full_name  = 'Dr. Dean'              (seed_users.sql, title_id set)
--   user.full_name  = 'Dr. Mohd Fadzil ...'  (054 added prefix, title_id NOT set)
--   user.full_name  = 'Dr. Siti Norzahra ...' (054 added prefix, title_id NOT set)
--   user.full_name  = 'Dr. Aiman ...'         (054 added prefix, title_id NOT set)
--   user.full_name  = 'Dr. Hasnah ...'        (054 added prefix, title_id NOT set)
--
-- Safe: only strips the exact title prefix when it matches — other rows untouched.
-- Idempotent: re-running after strip has no effect.

USE e_appointment_fskm;

-- ── Step 1: Clean academic_staff.full_name ────────────────────────────────
-- Display queries do CONCAT(ast.title, ' ', ast.full_name), so full_name must
-- be stored without a title prefix.
UPDATE academic_staff
SET    full_name = TRIM(SUBSTRING(full_name, LENGTH(title) + 2))
WHERE  title IS NOT NULL
  AND  full_name LIKE CONCAT(title, ' %');

-- ── Step 2a: Clean user.full_name via title_id ────────────────────────────
-- Covers: 'academician', 'dean', and any real user with title_id set.
UPDATE `user` u
JOIN   title  t ON t.id = u.title_id
SET    u.full_name = TRIM(SUBSTRING(u.full_name, LENGTH(t.name) + 2))
WHERE  u.title_id IS NOT NULL
  AND  u.full_name LIKE CONCAT(t.name, ' %');

-- ── Step 2b: Clean user.full_name via academic_staff.title ───────────────
-- Covers: fadzil_hassan / norzahra_saat / aiman_zakaria / hasnah_yusof —
-- seeded WITHOUT title_id in user, so Step 2a misses them.
UPDATE `user` u
JOIN   academic_staff ast ON ast.user_id = u.id
SET    u.full_name = TRIM(SUBSTRING(u.full_name, LENGTH(ast.title) + 2))
WHERE  ast.title IS NOT NULL
  AND  u.full_name LIKE CONCAT(ast.title, ' %');

-- ── Step 3: Backfill any NULL academic_staff.full_name ───────────────────
-- Ensures the COALESCE(ast.full_name, u.full_name) fallback path never
-- falls through to u.full_name (which the query also prepends title to).
UPDATE academic_staff ast
JOIN   `user` u ON u.id = ast.user_id
SET    ast.full_name = TRIM(u.full_name)
WHERE  ast.full_name IS NULL OR TRIM(ast.full_name) = '';

-- ── Verify ────────────────────────────────────────────────────────────────
-- Every row should show a single title prefix, not "Dr. Dr."
SELECT
    CONCAT(COALESCE(CONCAT(ast.title, ' '), ''),
           COALESCE(ast.full_name, u.full_name, ''))        AS display_name,
    ast.title,
    ast.full_name                                            AS staff_col,
    u.full_name                                              AS user_col
FROM   academic_staff ast
JOIN   `user` u ON u.id = ast.user_id
WHERE  ast.status = 'active'
ORDER  BY display_name;
