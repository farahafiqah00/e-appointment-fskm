-- 050: Ensure all program rows have the correct level set

-- PhD programmes
UPDATE program SET level = 'PhD'
WHERE level IS NULL OR level = ''
  AND (LOWER(name) LIKE '%doctor of philosophy%'
    OR LOWER(name) LIKE '%phd%'
    OR LOWER(code) LIKE 'phd%');

-- Master programmes
UPDATE program SET level = 'Master'
WHERE (LOWER(name) LIKE '%master%'
    OR LOWER(code) LIKE 'msc%'
    OR LOWER(code) LIKE 'ms-%')
  AND (level IS NULL OR level != 'Master');

-- Verify — run this SELECT to confirm after migration:
-- SELECT id, code, name, level FROM program ORDER BY level, name;
