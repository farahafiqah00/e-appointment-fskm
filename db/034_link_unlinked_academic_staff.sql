-- Link academic_staff records that have user_id = NULL to their corresponding
-- user account by matching full_name (case-insensitive, trimmed).
-- This is safe for typical datasets where names are unique.
-- Run this once to fix existing records; new records should always set user_id.

UPDATE academic_staff ast
JOIN `user` u
    ON TRIM(LOWER(u.full_name)) = TRIM(LOWER(ast.full_name))
   AND u.status = 'active'
SET ast.user_id = u.id
WHERE ast.user_id IS NULL;
