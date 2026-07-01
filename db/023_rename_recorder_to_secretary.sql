-- Migration 023: Rename member_role 'Recorder' → 'Secretary' in appointment_panel
-- Safe to re-run: UPDATE only affects rows that still have the old value.

UPDATE appointment_panel
SET member_role = 'Secretary'
WHERE member_role = 'Recorder';
