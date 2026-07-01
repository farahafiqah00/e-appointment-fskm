package controller;

import dao.AppointmentDAO;
import dao.NominationDAO;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/** Admin action to advance or flag a nomination status (verify / needs_correction / under_review). */
@WebServlet(name = "VerifyNominationServlet", urlPatterns = {"/VerifyNominationServlet"})
public class VerifyNominationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr   = req.getParameter("id");
        String action  = req.getParameter("action");
        String remarks = req.getParameter("remarks");
        if (idStr == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/NominationListServlet");
            return;
        }
        int id = Integer.parseInt(idStr);
        String newStatus = "pending";
        if ("verify".equals(action))                newStatus = "verified";
        else if ("needs_correction".equals(action)) newStatus = "needs_correction";
        else if ("under_review".equals(action))     newStatus = "under_review";

        try {
            NominationDAO dao = new NominationDAO();

            // Fetch nominator + examiner info BEFORE updating (used for email below)
            java.util.Map<String,String> nomInfo = null;
            try { nomInfo = dao.getNominatorInfoByNominationId(id); } catch (Exception ignored) {}

            dao.updateStatus(id, newStatus, remarks);

            // When verified, link this nomination to the candidate's viva appointment
            if ("verified".equals(newStatus)) {
                int candidateId = dao.getCandidateIdByNominationId(id);
                if (candidateId > 0) {
                    AppointmentDAO apptDao = new AppointmentDAO();
                    if (apptDao.existsForCandidate(candidateId)) {
                        apptDao.linkNominationToAppointment(candidateId, id);
                    } else {
                        apptDao.createAppointment(candidateId, id);
                    }
                }
            }

            // Send email notification to nominator
            if (nomInfo != null && nomInfo.get("email") != null) {
                final String nominatorEmail = nomInfo.get("email");
                final String nominatorName  = nomInfo.get("fullName");
                final String examinerName   = nomInfo.get("examinerName");

                if ("verified".equals(newStatus)) {
                    try {
                        EmailUtil.sendHtmlEmailAsync(nominatorEmail,
                            "Your Nomination Has Been Verified – " + examinerName,
                            buildVerifiedEmail(nominatorName, examinerName));
                    } catch (Exception mailEx) {
                        getServletContext().log("Verified notification email failed: " + mailEx.getMessage());
                    }
                } else if ("needs_correction".equals(newStatus)
                        && remarks != null && !remarks.trim().isEmpty()) {
                    try {
                        EmailUtil.sendHtmlEmailAsync(nominatorEmail,
                            "Action Required: Your Nomination Needs Correction – " + examinerName,
                            buildNeedsCorrectionEmail(nominatorName, examinerName, remarks.trim()));
                    } catch (Exception mailEx) {
                        getServletContext().log("Needs-correction notification email failed: " + mailEx.getMessage());
                    }
                }
            }

            resp.sendRedirect(req.getContextPath() + "/NominationListServlet");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private static String buildVerifiedEmail(String nominatorName, String examinerName) {
        String safeName     = escapeHtml(nominatorName);
        String safeExaminer = escapeHtml(examinerName);
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
             + "<body style='margin:0;padding:0;background:#f3f4f6;font-family:Inter,Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'><tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#15803d;padding:28px 36px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.4rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:6px 0 0;color:#bbf7d0;font-size:0.92rem;'>Nomination Verified</p>"
             + "</td></tr>"
             + "<tr><td style='padding:32px 36px;'>"
             + "<p style='font-size:1rem;color:#374151;margin-top:0;'>Dear <strong>" + safeName + "</strong>,</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Great news! Your nomination for <strong>" + safeExaminer + "</strong> has been "
             + "<strong style='color:#15803d;'>verified</strong> by the administrator.</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Please log in to the E-Appointment system to view the updated nomination status.</p>"
             + "<hr style='border:none;border-top:1px solid #f3f4f6;margin:24px 0;'>"
             + "<p style='font-size:0.8rem;color:#9ca3af;margin:0;'>This is an automated notification from the E-Appointment FSKM system.</p>"
             + "</td></tr></table></td></tr></table></body></html>";
    }

    private static String buildNeedsCorrectionEmail(String nominatorName, String examinerName, String remarks) {
        String safeName     = escapeHtml(nominatorName);
        String safeExaminer = escapeHtml(examinerName);
        String safeRemarks  = escapeHtml(remarks).replace("\n", "<br>");
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
             + "<body style='margin:0;padding:0;background:#f3f4f6;font-family:Inter,Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'><tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#dc2626;padding:28px 36px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.4rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:6px 0 0;color:#fecaca;font-size:0.92rem;'>Nomination Requires Correction</p>"
             + "</td></tr>"
             + "<tr><td style='padding:32px 36px;'>"
             + "<p style='font-size:1rem;color:#374151;margin-top:0;'>Dear <strong>" + safeName + "</strong>,</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Your nomination for <strong>" + safeExaminer + "</strong> requires correction before it can be approved.</p>"
             + "<div style='background:#fef2f2;border:1px solid #fecaca;border-radius:10px;padding:18px 20px;margin:20px 0;'>"
             + "<p style='font-weight:700;color:#dc2626;margin:0 0 8px;'>Admin's note:</p>"
             + "<p style='color:#374151;font-size:0.95rem;margin:0;line-height:1.6;'>" + safeRemarks + "</p>"
             + "</div>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Please log in to the E-Appointment system, go to <strong>My Nominations</strong>, and edit the nomination accordingly.</p>"
             + "<hr style='border:none;border-top:1px solid #f3f4f6;margin:24px 0;'>"
             + "<p style='font-size:0.8rem;color:#9ca3af;margin:0;'>This is an automated notification from the E-Appointment FSKM system.</p>"
             + "</td></tr></table></td></tr></table></body></html>";
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
