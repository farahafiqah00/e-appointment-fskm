-- Retire the 'decided' status: merge it into 'scheduled'.
-- 'scheduled' now means the appointment has panel + date + venue confirmed.
-- Letter generation promotes status from 'scheduled' → 'letter_generated'.
UPDATE viva_appointment SET status = 'scheduled' WHERE status = 'decided';

-- Sync candidate.status to 'appointed' for any candidate whose appointment is already
-- scheduled or letter_generated but whose candidate record was never promoted from 'prepared'.
UPDATE candidate c
INNER JOIN viva_appointment va ON va.candidate_id = c.id
SET c.status = 'appointed'
WHERE va.status IN ('scheduled', 'letter_generated')
  AND c.status = 'prepared';
