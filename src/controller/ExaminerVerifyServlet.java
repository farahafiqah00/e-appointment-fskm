package controller;

import dao.NominationDAO;
import model.Document;
import model.ExternalExaminer;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

/**
 * Public (no-login) servlet for the examiner self-verification flow.
 *
 * GET  /ExaminerVerifyServlet?token=xxx
 *    → validates token → forwards to /examinerVerify.jsp with examiner data
 *
 * POST /ExaminerVerifyServlet?token=xxx
 *    → action=confirm   : marks info_confirmed = 1
 *    → action=report    : saves discrepancy_notes
 *    → redirects back with ?token=xxx&result=confirmed|reported
 */
@WebServlet(name = "ExaminerVerifyServlet", urlPatterns = {"/ExaminerVerifyServlet"})
public class ExaminerVerifyServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");

        if (token == null || token.trim().isEmpty() || !token.matches("[a-fA-F0-9]{32}")) {
            req.setAttribute("tokenStatus", "invalid");
            forward(req, resp);
            return;
        }

        try {
            NominationDAO dao = new NominationDAO();
            ExternalExaminer ee = dao.getExaminerByToken(token.trim());

            if (ee == null) {
                req.setAttribute("tokenStatus", "invalid");
                forward(req, resp);
                return;
            }

            Timestamp expires = ee.getTokenExpiresAt();
            if (expires != null && expires.before(new Timestamp(System.currentTimeMillis()))) {
                req.setAttribute("tokenStatus", "expired");
                req.setAttribute("examiner", ee);
                forward(req, resp);
                return;
            }

            if (ee.isInfoConfirmed()) {
                req.setAttribute("tokenStatus", "already_confirmed");
            } else if (ee.getDiscrepancyNotes() != null && !ee.getDiscrepancyNotes().isEmpty()) {
                req.setAttribute("tokenStatus", "discrepancy_reported");
            } else {
                req.setAttribute("tokenStatus", "pending");
            }

            req.setAttribute("examiner", ee);
            req.setAttribute("token", token.trim());

            // Load documents so examiner can download their uploaded files
            try {
                List<Document> docs = dao.getDocumentsByToken(token.trim());
                req.setAttribute("examinerDocs", docs);
            } catch (Exception ignored) {
                req.setAttribute("examinerDocs", new java.util.ArrayList<>());
            }

            // Flash message from a previous POST redirect
            String result = req.getParameter("result");
            if ("confirmed".equals(result)) req.setAttribute("flashResult", "confirmed");
            else if ("reported".equals(result)) req.setAttribute("flashResult", "reported");

            forward(req, resp);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token  = req.getParameter("token");
        String action = req.getParameter("action");

        if (token == null || token.trim().isEmpty() || !token.matches("[a-fA-F0-9]{32}")) {
            resp.sendRedirect(req.getContextPath() + "/ExaminerVerifyServlet");
            return;
        }

        try {
            NominationDAO dao = new NominationDAO();
            ExternalExaminer ee = dao.getExaminerByToken(token.trim());

            if (ee == null) {
                resp.sendRedirect(req.getContextPath() + "/ExaminerVerifyServlet?token=" + token);
                return;
            }

            Timestamp expires = ee.getTokenExpiresAt();
            if (expires != null && expires.before(new Timestamp(System.currentTimeMillis()))) {
                resp.sendRedirect(req.getContextPath() + "/ExaminerVerifyServlet?token=" + token);
                return;
            }

            if ("confirm".equals(action)) {
                dao.markInfoConfirmed(token.trim());

                // Notify nominator + admins that the examiner has confirmed
                try {
                    String examinerDisplayName = (ee.getTitle() != null && !ee.getTitle().isEmpty()
                            ? ee.getTitle() + " " : "") + ee.getName();
                    java.util.Map<String,String> nomInfo = dao.getNominatorEmailByExaminerId(ee.getId());
                    String nominatorName = nomInfo != null ? nomInfo.get("fullName") : null;

                    if (nomInfo != null && nomInfo.get("email") != null) {
                        EmailUtil.sendHtmlEmailAsync(
                            nomInfo.get("email"),
                            "Examiner Confirmed – " + examinerDisplayName,
                            buildExaminerConfirmedEmail(nominatorName, examinerDisplayName, ee.getEmail())
                        );
                    }
                    for (java.util.Map<String,String> admin : dao.getAdminEmails()) {
                        if (admin.get("email") != null) {
                            EmailUtil.sendHtmlEmailAsync(
                                admin.get("email"),
                                "Nomination Ready for Review – " + examinerDisplayName,
                                buildAdminReadyEmail(admin.get("fullName"), examinerDisplayName,
                                        ee.getEmail(), ee.getAffiliation(), nominatorName)
                            );
                        }
                    }
                } catch (Exception mailEx) {
                    getServletContext().log("Examiner-confirmed notification emails failed: " + mailEx.getMessage());
                }

                resp.sendRedirect(req.getContextPath() + "/ExaminerVerifyServlet?token=" + token + "&result=confirmed");

            } else if ("report".equals(action)) {
                String notes = req.getParameter("discrepancyNotes");
                if (notes == null || notes.trim().isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/ExaminerVerifyServlet?token=" + token);
                    return;
                }
                // Limit notes length to prevent abuse
                if (notes.length() > 1000) notes = notes.substring(0, 1000);
                dao.saveDiscrepancy(token.trim(), notes.trim());

                // Notify the academician (nominator) by email
                try {
                    java.util.Map<String,String> nomInfo = dao.getNominatorEmailByExaminerId(ee.getId());
                    if (nomInfo != null && nomInfo.get("email") != null) {
                        String examinerDisplayName = (ee.getTitle() != null && !ee.getTitle().isEmpty()
                                ? ee.getTitle() + " " : "") + ee.getName();
                        String subject = "Examiner Reported a Discrepancy - " + examinerDisplayName;
                        String body = buildDiscrepancyNotificationEmail(
                                nomInfo.get("fullName"), examinerDisplayName,
                                ee.getEmail(), notes.trim());
                        EmailUtil.sendHtmlEmailAsync(nomInfo.get("email"), subject, body);
                    }
                } catch (Exception mailEx) {
                    getServletContext().log("Discrepancy notification email failed: " + mailEx.getMessage());
                }

                resp.sendRedirect(req.getContextPath() + "/ExaminerVerifyServlet?token=" + token + "&result=reported");

            } else {
                resp.sendRedirect(req.getContextPath() + "/ExaminerVerifyServlet?token=" + token);
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void forward(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/examinerVerify.jsp").forward(req, resp);
    }

    private static String buildExaminerConfirmedEmail(String nominatorName, String examinerName, String examinerEmail) {
        String safeNom      = escapeHtml(nominatorName);
        String safeExaminer = escapeHtml(examinerName);
        String safeEmail    = escapeHtml(examinerEmail);
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
             + "<body style='margin:0;padding:0;background:#f3f4f6;font-family:Inter,Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'><tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#0f766e;padding:28px 36px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.4rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:6px 0 0;color:#a7f3d0;font-size:0.92rem;'>Examiner Profile Confirmed</p>"
             + "</td></tr>"
             + "<tr><td style='padding:32px 36px;'>"
             + "<p style='font-size:1rem;color:#374151;margin-top:0;'>Dear <strong>" + safeNom + "</strong>,</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Good news! The examiner you nominated, <strong>" + safeExaminer + "</strong> (" + safeEmail + "), "
             + "has reviewed and confirmed their profile information.</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Your nomination has been automatically advanced for administrator review. Please log in to track its status under <strong>My Nominations</strong>.</p>"
             + "<hr style='border:none;border-top:1px solid #f3f4f6;margin:24px 0;'>"
             + "<p style='font-size:0.8rem;color:#9ca3af;margin:0;'>This is an automated notification from the E-Appointment FSKM system.</p>"
             + "</td></tr></table></td></tr></table></body></html>";
    }

    private static String buildAdminReadyEmail(String adminName, String examinerName, String examinerEmail,
                                               String university, String nominatorName) {
        String safeAdmin    = escapeHtml(adminName);
        String safeExaminer = escapeHtml(examinerName);
        String safeEmail    = escapeHtml(examinerEmail);
        String safeUni      = escapeHtml(university);
        String safeNom      = escapeHtml(nominatorName);
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
             + "<body style='margin:0;padding:0;background:#f3f4f6;font-family:Inter,Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'><tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#1e3a5f;padding:28px 36px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.4rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:6px 0 0;color:#93c5fd;font-size:0.92rem;'>New Nomination Ready for Review</p>"
             + "</td></tr>"
             + "<tr><td style='padding:32px 36px;'>"
             + "<p style='font-size:1rem;color:#374151;margin-top:0;'>Dear <strong>" + safeAdmin + "</strong>,</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "A nomination submitted by <strong>" + safeNom + "</strong> is now ready for your review. "
             + "The examiner has confirmed their profile information.</p>"
             + "<div style='background:#eff6ff;border:1px solid #bfdbfe;border-radius:10px;padding:18px 20px;margin:20px 0;'>"
             + "<p style='font-weight:700;color:#1e3a5f;margin:0 0 10px;'>Examiner Details</p>"
             + "<p style='color:#374151;font-size:0.93rem;margin:4px 0;'><strong>Name:</strong> " + safeExaminer + "</p>"
             + "<p style='color:#374151;font-size:0.93rem;margin:4px 0;'><strong>Email:</strong> " + safeEmail + "</p>"
             + "<p style='color:#374151;font-size:0.93rem;margin:4px 0;'><strong>University:</strong> " + safeUni + "</p>"
             + "<p style='color:#374151;font-size:0.93rem;margin:4px 0;'><strong>Nominated by:</strong> " + safeNom + "</p>"
             + "</div>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>Please log in to the E-Appointment system and go to <strong>Examiner Nominations</strong> to review this nomination.</p>"
             + "<hr style='border:none;border-top:1px solid #f3f4f6;margin:24px 0;'>"
             + "<p style='font-size:0.8rem;color:#9ca3af;margin:0;'>This is an automated notification from the E-Appointment FSKM system.</p>"
             + "</td></tr></table></td></tr></table></body></html>";
    }

    private static String buildDiscrepancyNotificationEmail(
            String nominatorName, String examinerName, String examinerEmail, String notes) {
        String safeNominator = escapeHtml(nominatorName);
        String safeExaminer  = escapeHtml(examinerName);
        String safeEmail     = escapeHtml(examinerEmail);
        String safeNotes     = escapeHtml(notes).replace("\n", "<br>");
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
             + "<body style='margin:0;padding:0;background:#f3f4f6;font-family:Inter,Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'><tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#92400e;padding:28px 36px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.4rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:6px 0 0;color:#fde68a;font-size:0.92rem;'>Examiner Discrepancy Report</p>"
             + "</td></tr>"
             + "<tr><td style='padding:32px 36px;'>"
             + "<p style='font-size:1rem;color:#374151;margin-top:0;'>Dear <strong>" + safeNominator + "</strong>,</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "The examiner you nominated, <strong>" + safeExaminer + "</strong> (" + safeEmail + "), "
             + "has reviewed their profile and reported that some information is incorrect.</p>"
             + "<div style='background:#fffbeb;border:1px solid #fcd34d;border-radius:10px;padding:18px 20px;margin:20px 0;'>"
             + "<p style='font-weight:700;color:#92400e;margin:0 0 8px;'>Examiner's note:</p>"
             + "<p style='color:#374151;font-size:0.95rem;margin:0;line-height:1.6;'>" + safeNotes + "</p>"
             + "</div>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Please log in to the E-Appointment system, go to <strong>My Nominations</strong>, "
             + "and edit the examiner's information accordingly. You can then resend the verification email.</p>"
             + "<hr style='border:none;border-top:1px solid #f3f4f6;margin:24px 0;'>"
             + "<p style='font-size:0.8rem;color:#9ca3af;margin:0;'>This is an automated notification from the E-Appointment FSKM system.</p>"
             + "</td></tr></table></td></tr></table></body></html>";
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
