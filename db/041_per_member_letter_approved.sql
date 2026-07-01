-- Track per-panel-member whether the dean has approved their specific letter.
-- Without this, replacing one declined member could bypass dean review because
-- the global approvalSigned flag from the previous approval remained true.
ALTER TABLE appointment_panel
  ADD COLUMN letter_approved TINYINT(1) NOT NULL DEFAULT 0
  AFTER letter_sent;

-- Backfill: any member belonging to an appointment whose letter_approval is
-- already 'signed' was reviewed under the old global flow — mark them approved.
UPDATE appointment_panel ap
  JOIN appointment_letter_approval ala
    ON ala.appointment_id = ap.appointment_id
   AND ala.status = 'signed'
SET ap.letter_approved = 1;
