-- =============================================================================
-- Migration 048: Clear all transactional data, keep all lookup / reference data
--
-- Run this in phpMyAdmin BEFORE using /SetupServlet to create the first admin.
--
-- KEEPS: role, title, specialization, expertise, division, area,
--        program, venue, faculty_lookup, university_lookup, university, country
--
-- CLEARS: user, academic_staff, candidate, co_supervisor,
--         external_examiner, nomination, document,
--         viva_appointment, appointment_panel,
--         appointment_letter, appointment_letter_approval,
--         password_reset_token
-- =============================================================================

USE e_appointment_fskm;

SET FOREIGN_KEY_CHECKS = 0;

-- Transactional tables (most dependent first)
DELETE FROM appointment_letter_approval;
DELETE FROM appointment_letter;
DELETE FROM appointment_panel;
DELETE FROM viva_appointment;
DELETE FROM document;
DELETE FROM nomination;
DELETE FROM external_examiner;
DELETE FROM co_supervisor;
DELETE FROM password_reset_token;
DELETE FROM candidate;
DELETE FROM academic_staff;
DELETE FROM `user`;

-- Reset auto-increment counters
ALTER TABLE appointment_letter_approval AUTO_INCREMENT = 1;
ALTER TABLE appointment_letter          AUTO_INCREMENT = 1;
ALTER TABLE appointment_panel           AUTO_INCREMENT = 1;
ALTER TABLE viva_appointment            AUTO_INCREMENT = 1;
ALTER TABLE document                    AUTO_INCREMENT = 1;
ALTER TABLE nomination                  AUTO_INCREMENT = 1;
ALTER TABLE external_examiner           AUTO_INCREMENT = 1;
ALTER TABLE co_supervisor               AUTO_INCREMENT = 1;
ALTER TABLE password_reset_token        AUTO_INCREMENT = 1;
ALTER TABLE candidate                   AUTO_INCREMENT = 1;
ALTER TABLE academic_staff              AUTO_INCREMENT = 1;
ALTER TABLE `user`                      AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- NEXT STEPS:
--   1. Deploy / restart your Tomcat server
--   2. Navigate to: http://localhost:8080/<your-context>/SetupServlet
--   3. Enter the admin full name and a real email address
--   4. Password is emailed to that address
--      If email is not configured: check Tomcat logs (catalina.out) for
--      "[SetupServlet] TEMP PASSWORD" line with the credential
--   5. Log in, then go to Admin > User Management > Add User to create
--      Dean and Academician accounts (passwords emailed / logged same way)
-- =============================================================================
