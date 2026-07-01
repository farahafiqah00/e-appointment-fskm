-- Migration 016: Backfill viva_appointment rows for candidates that were added
-- before the auto-create logic existed in AddCandidateServlet.
-- Safe to run multiple times (WHERE NOT EXISTS guard).

INSERT INTO viva_appointment (candidate_id, status)
SELECT c.id, 'scheduled'
FROM candidate c
WHERE NOT EXISTS (
    SELECT 1 FROM viva_appointment va WHERE va.candidate_id = c.id
);
