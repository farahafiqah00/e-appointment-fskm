-- Migration 017: Fix orphaned divisions and areas that lack expertise_id / division_id
-- The original eappointment_new.sql seeded divisions and areas with only specialization_id.
-- Migration 003 added the expertise_id / division_id columns but only for its own new rows.
-- These orphaned rows have NULL FKs → they show as data-expertise="0" / data-division="0"
-- in the cascade dropdowns and are therefore permanently invisible.
-- Run this AFTER all previous migrations.

USE e_appointment_fskm;

-- ── 1. Fix divisions that have specialization_id but no expertise_id ─────────
--    AI Division  →  Machine Learning expertise (under Artificial Intelligence spec)
UPDATE division
SET expertise_id = (
    SELECT id FROM expertise
    WHERE name = 'Machine Learning'
      AND specialization_id = (SELECT id FROM specialization WHERE name = 'Artificial Intelligence')
    LIMIT 1
)
WHERE name = 'AI Division'
  AND expertise_id IS NULL;

--    Network Division  →  Network Security expertise (under Networks spec)
UPDATE division
SET expertise_id = (
    SELECT id FROM expertise
    WHERE name = 'Network Security'
      AND specialization_id = (SELECT id FROM specialization WHERE name = 'Networks')
    LIMIT 1
)
WHERE name = 'Network Division'
  AND expertise_id IS NULL;

--    SE Division  →  Software Architecture expertise (under Software Engineering spec)
UPDATE division
SET expertise_id = (
    SELECT id FROM expertise
    WHERE name = 'Software Architecture'
      AND specialization_id = (SELECT id FROM specialization WHERE name = 'Software Engineering')
    LIMIT 1
)
WHERE name = 'SE Division'
  AND expertise_id IS NULL;

-- Catch-all: any remaining division with expertise_id IS NULL but with a valid specialization_id —
-- link to the first expertise that belongs to the same specialization.
UPDATE division d
JOIN (
    SELECT e.id AS exp_id, e.specialization_id
    FROM expertise e
    WHERE e.id = (
        SELECT MIN(e2.id) FROM expertise e2 WHERE e2.specialization_id = e.specialization_id
    )
) first_exp ON first_exp.specialization_id = d.specialization_id
SET d.expertise_id = first_exp.exp_id
WHERE d.expertise_id IS NULL
  AND d.specialization_id IS NOT NULL;


-- ── 2. Fix areas that have specialization_id but no division_id ──────────────
--    Natural Language Processing  →  Machine Learning division (under CS / AI spec)
UPDATE area
SET division_id = (
    SELECT id FROM division
    WHERE name = 'Machine Learning'
    LIMIT 1
)
WHERE name = 'Natural Language Processing'
  AND division_id IS NULL;

--    Routing & Switching  →  Network Security division (under Information Technology spec)
--    If that doesn't exist, fall back to Network Division.
UPDATE area
SET division_id = COALESCE(
    (SELECT id FROM division WHERE name = 'Network Security' LIMIT 1),
    (SELECT id FROM division WHERE name = 'Network Division' LIMIT 1)
)
WHERE name = 'Routing & Switching'
  AND division_id IS NULL;

--    Requirements Engineering area  →  Requirements Engineering division (003 created this)
--    Fall back to SE Division if the named division doesn't exist.
UPDATE area
SET division_id = COALESCE(
    (SELECT id FROM division WHERE name = 'Requirements Engineering' LIMIT 1),
    (SELECT id FROM division WHERE name = 'SE Division' LIMIT 1)
)
WHERE name = 'Requirements Engineering'
  AND division_id IS NULL;

-- Catch-all: any remaining area with division_id IS NULL but with a valid specialization_id —
-- link to the first division that belongs to the same specialization.
UPDATE area a
JOIN (
    SELECT d.id AS div_id, d.specialization_id
    FROM division d
    WHERE d.id = (
        SELECT MIN(d2.id) FROM division d2 WHERE d2.specialization_id = d.specialization_id
    )
) first_div ON first_div.specialization_id = a.specialization_id
SET a.division_id = first_div.div_id
WHERE a.division_id IS NULL
  AND a.specialization_id IS NOT NULL;


-- ── 3. Verify — these queries should return 0 rows after running the migration ─
-- SELECT id, name, specialization_id, expertise_id FROM division WHERE expertise_id IS NULL;
-- SELECT id, name, specialization_id, division_id  FROM area     WHERE division_id  IS NULL;
