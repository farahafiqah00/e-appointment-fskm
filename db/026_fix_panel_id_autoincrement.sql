-- Fix: appointment_panel.id missing AUTO_INCREMENT
ALTER TABLE appointment_panel MODIFY id INT NOT NULL AUTO_INCREMENT;

-- Fix: remove duplicate panel rows (keep the lowest id for each appointment+member combination)
DELETE ap FROM appointment_panel ap
INNER JOIN appointment_panel ap2
  ON ap.appointment_id = ap2.appointment_id
  AND ap.member_role   = ap2.member_role
  AND (
    (ap.internal_user_id IS NOT NULL AND ap.internal_user_id = ap2.internal_user_id)
    OR
    (ap.external_examiner_id IS NOT NULL AND ap.external_examiner_id = ap2.external_examiner_id)
  )
  AND ap.id > ap2.id;

-- Fix: remove duplicate academic_staff rows per user_id (keep the lowest id)
DELETE ast FROM academic_staff ast
INNER JOIN academic_staff ast2
  ON ast.user_id = ast2.user_id
  AND ast.id > ast2.id;

-- Prevent future duplicates
ALTER TABLE academic_staff ADD UNIQUE KEY uq_academic_staff_user (user_id);
