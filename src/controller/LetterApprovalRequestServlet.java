package controller;

import dao.AppointmentDAO;
import model.VivaAppointment;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.Map;

/** Admin-only: assigns a signer to a letter and sends them an email notification with a login-redirect preview link. */
@WebServlet("/admin/appointment/letter/approval/request")
public class LetterApprovalRequestServlet extends HttpServlet {

    private final AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Object userIdObj = session != null ? session.getAttribute("user_id") : null;
        String roleName = session != null ? String.valueOf(session.getAttribute("role_name")) : "";

        String sApptId = req.getParameter("appointment_id");
        String sSignerId = req.getParameter("signer_user_id");

        if (userIdObj == null || sApptId == null || sSignerId == null || "Dean".equals(roleName) || "Academician".equals(roleName) || "".equals(roleName) || "null".equals(roleName)) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
            return;
        }

        try {
            int appointmentId = Integer.parseInt(sApptId);
            int signerUserId = Integer.parseInt(sSignerId);
            int requestedBy = ((Number) userIdObj).intValue();

            VivaAppointment va = dao.findById(appointmentId);
            if (va == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/appointments");
                return;
            }

            dao.upsertLetterApprovalRequest(appointmentId, signerUserId, requestedBy);

            // Notify selected signer
            Map<String,Object> approval = dao.getLetterApprovalByAppointmentId(appointmentId);
            if (approval != null) {
                String signerEmail = approval.get("signer_email") != null ? String.valueOf(approval.get("signer_email")) : "";
                String signerName = approval.get("signer_name") != null ? String.valueOf(approval.get("signer_name")) : "Signer";
                String signerLabel = approval.get("signer_label") != null ? String.valueOf(approval.get("signer_label")) : "Signer";
                String signerAcademicTitle = approval.get("signer_academic_title") != null ? String.valueOf(approval.get("signer_academic_title")).trim() : "";
                if (!signerEmail.trim().isEmpty()) {
                        // Build a login-forwarding preview URL so clicking the email opens the login page
                        // (preserving the intended review URL) — this ensures the signer is asked to log in
                        // before viewing/signing the letter.
                        String reviewPath = req.getContextPath() + "/appointment/letter/review?id=" + appointmentId;
                        String encodedReturn = URLEncoder.encode(reviewPath, "UTF-8");
                        String previewUrl = req.getScheme() + "://" + req.getServerName()
                            + ((req.getServerPort() == 80 || req.getServerPort() == 443) ? "" : ":" + req.getServerPort())
                            + req.getContextPath() + "/login.jsp?returnUrl=" + encodedReturn;

                    String subject = "Approval Needed: Viva Appointment Letter (" + signerLabel + ")";
                    String body = buildApprovalRequestBody(signerAcademicTitle, signerName, va, previewUrl);
                    EmailUtil.sendHtmlEmailAsync(signerEmail, subject, body);
                }
            }

            resp.sendRedirect(req.getContextPath() + "/admin/appointment/letter/preview?id=" + appointmentId
                    + "&approvalMsg=" + URLEncoder.encode("Approval request has been sent.", "UTF-8"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private String buildApprovalRequestBody(String signerAcademicTitle, String signerName, VivaAppointment va, String previewUrl) {
        String candidate = va.getCandidateName() != null ? va.getCandidateName() : "Candidate";
        String programme = va.getCandidateProgram() != null ? va.getCandidateProgram() : "-";
        String vivaDate = va.getScheduledAt() != null
                ? new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(va.getScheduledAt()) : "To be confirmed";
        String greeting = signerAcademicTitle.isEmpty() ? signerName : signerAcademicTitle + " " + signerName;

        return "<!doctype html><html><body style='font-family:Arial,sans-serif;color:#111;line-height:1.6;'>"
                + "<p>Dear " + esc(greeting) + ",</p>"
                + "<p>You have been selected as the signer for a viva appointment letter. Please review and sign it in the system.</p>"
                + "<table style='border-collapse:collapse;margin:12px 0 18px 0;'>"
                + "<tr><td style='padding:4px 8px 4px 0;font-weight:bold;'>Candidate</td><td>: " + esc(candidate) + "</td></tr>"
                + "<tr><td style='padding:4px 8px 4px 0;font-weight:bold;'>Programme</td><td>: " + esc(programme) + "</td></tr>"
                + "<tr><td style='padding:4px 8px 4px 0;font-weight:bold;'>Viva Date</td><td>: " + esc(vivaDate) + "</td></tr>"
                + "</table>"
                + "<p><a href='" + esc(previewUrl) + "' style='background:#0f766e;color:#fff;padding:10px 16px;"
                + "text-decoration:none;border-radius:6px;display:inline-block;'>Open Letter Preview</a></p>"
                + "<p>After signing, the status will return to admin so they can send the letter to panel members.</p>"
                + "<p>Thank you.</p>"
                + "</body></html>";
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
