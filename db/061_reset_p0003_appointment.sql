-- Migration 061: Create a fresh viva appointment for P0003
--
-- After the appointment was deleted (to start over), the candidate
-- status was set to 'prepared' but no viva_appointment row existed,
-- so P0003 did not appear in the appointment list.
-- This migration creates a blank pending appointment so P0003 shows
-- up in the list ready for panel assignment.

USE e_appointment_fskm;

SET @cid = (SELECT id FROM candidate WHERE student_id = 'P0003' LIMIT 1);

INSERT INTO viva_appointment (candidate_id, status)
VALUES (@cid, 'pending');

UPDATE candidate SET status = 'pending' WHERE id = @cid;

-- Verify
SELECT c.student_id, c.full_name, c.status AS candidate_status,
       va.id AS appt_id, va.status AS appt_status
FROM   candidate c
JOIN   viva_appointment va ON va.candidate_id = c.id
WHERE  c.student_id = 'P0003';
