package controller;

import dao.AppointmentDAO;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Public (no-login) servlet for external examiners to respond to their
 * viva appointment invitation.
 *
 * GET  /PanelResponseServlet?token=xxx
 *   → validates token → forwards to /panelResponse.jsp with panel data
 *
 * POST /PanelResponseServlet?token=xxx
 *   → action=accept  : saves panel_response='accepted', notifies admin
 *   → action=decline : saves panel_response='declined', updates appointment
 *                      status to 'examiner_declined', notifies admin
 *   → redirects back to ?token=xxx&result=accepted|declined
 */
@WebServlet(name = "PanelResponseServlet", urlPatterns = {"/PanelResponseServlet"})
public class PanelResponseServlet extends HttpServlet {

    private static final String TOKEN_REGEX = "[a-fA-F0-9]{32}";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token = sanitizeToken(req.getParameter("token"));
        if (token == null) {
            req.setAttribute("tokenStatus", "invalid");
            forward(req, resp);
            return;
        }

        try {
            AppointmentDAO dao = new AppointmentDAO();
            Map<String,Object> detail = dao.getPanelDetailByResponseToken(token);
            if (detail == null) {
                req.setAttribute("tokenStatus", "invalid");
                forward(req, resp);
                return;
            }

            // If already responded, show the result page directly
            String existing = (String) detail.get("panel_response");
            if ("accepted".equals(existing) || "declined".equals(existing)) {
                req.setAttribute("tokenStatus", "already_responded");
            } else {
                req.setAttribute("tokenStatus", "pending");
            }

            req.setAttribute("panelDetail", detail);
            req.setAttribute("token", token);

            // Flash result from previous POST redirect
            String result = req.getParameter("result");
            if ("accepted".equals(result))  req.setAttribute("flashResult", "accepted");
            if ("declined".equals(result))  req.setAttribute("flashResult", "declined");

            forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String token  = sanitizeToken(req.getParameter("token"));
        String action = req.getParameter("action");

        if (token == null) {
            resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet");
            return;
        }

        try {
            AppointmentDAO dao = new AppointmentDAO();
            Map<String,Object> detail = dao.getPanelDetailByResponseToken(token);

            if (detail == null) {
                resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet?token=" + token);
                return;
            }

            // Prevent double-submission
            String existing = (String) detail.get("panel_response");
            if ("accepted".equals(existing) || "declined".equals(existing)) {
                resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet?token=" + token + "&result=" + existing);
                return;
            }

            if ("accept".equals(action)) {
                dao.savePanelResponseWithAudit(token, "accepted", null, "email", null, req.getRemoteAddr());
                notifyAdmin(dao, detail, "accepted", null, req);
                resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet?token=" + token + "&result=accepted");

            } else if ("decline".equals(action)) {
                String reason = req.getParameter("rejection_reason");
                if (reason == null || reason.trim().isEmpty()) {
                    // Missing reason — re-show form with error
                    req.setAttribute("tokenStatus", "pending");
                    req.setAttribute("panelDetail", detail);
                    req.setAttribute("token", token);
                    req.setAttribute("reasonError", "Please provide a reason for declining.");
                    forward(req, resp);
                    return;
                }
                if (reason.length() > 2000) reason = reason.substring(0, 2000);
                dao.savePanelResponseWithAudit(token, "declined", reason.trim(), "email", null, req.getRemoteAddr());
                notifyAdmin(dao, detail, "declined", reason.trim(), req);
                resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet?token=" + token + "&result=declined");

            } else {
                resp.sendRedirect(req.getContextPath() + "/PanelResponseServlet?token=" + token);
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static String sanitizeToken(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        String t = raw.trim();
        return t.matches(TOKEN_REGEX) ? t : null;
    }

    private void forward(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/panelResponse.jsp").forward(req, resp);
    }

    private void notifyAdmin(AppointmentDAO dao, Map<String,Object> detail,
                             String response, String reason,
                             HttpServletRequest req) {
        try {
            List<Map<String,Object>> admins = dao.getActiveAdminRecipients();
            if (admins.isEmpty()) return;

            String eeName      = str(detail.get("ee_name"));
            String eeTitle     = str(detail.get("ee_title"));
            String displayName = eeTitle.isEmpty() ? eeName : eeTitle + " " + eeName;
            String candidate   = str(detail.get("candidate_name"));
            String program     = str(detail.get("candidate_program"));
            String apptUrl     = req.getScheme() + "://" + req.getServerName()
                + (req.getServerPort() == 80 || req.getServerPort() == 443 ? "" : ":" + req.getServerPort())
                + req.getContextPath()
                + "/admin/appointment/decision?id=" + detail.get("appointment_id") + "#panel-responses";

            boolean accepted = "accepted".equals(response);
            String subject   = (accepted ? "Examiner Accepted Appointment — " : "Examiner DECLINED Appointment — ")
                             + candidate;
            String body      = buildAdminNotificationEmail(displayName, candidate, program, response, reason, apptUrl);

            for (Map<String,Object> admin : admins) {
                String adminEmail = str(admin.get("email"));
                if (!adminEmail.isEmpty()) {
                    EmailUtil.sendHtmlEmailAsync(adminEmail, subject, body);
                }
            }
        } catch (Exception ex) {
            getServletContext().log("PanelResponseServlet: admin notification failed: " + ex.getMessage());
        }
    }

    private String buildAdminNotificationEmail(String examinerName, String candidateName,
                                               String program, String response,
                                               String reason, String apptUrl) {
        boolean accepted = "accepted".equals(response);
        String statusColor  = accepted ? "#15803d" : "#b91c1c";
        String statusBg     = accepted ? "#dcfce7" : "#fee2e2";
        String statusLabel  = accepted ? "ACCEPTED" : "DECLINED";
        String icon         = accepted ? "✅" : "❌";

        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
             + "<body style='margin:0;padding:0;background:#f3f4f6;font-family:Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'>"
             + "<tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;"
             + "overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#105e60;padding:24px 32px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.3rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:4px 0 0;color:#a7f3d0;font-size:0.88rem;'>Panel Appointment Response Notification</p>"
             + "</td></tr>"
             + "<tr><td style='padding:28px 32px;'>"
             + "<div style='background:" + statusBg + ";border-radius:10px;padding:16px 20px;margin-bottom:24px;"
             + "text-align:center;'>"
             + "<p style='margin:0;font-size:1.15rem;font-weight:700;color:" + statusColor + ";'>"
             + icon + " Appointment " + statusLabel
             + "</p></div>"
             + "<p style='color:#374151;'>The following external examiner has responded to their appointment invitation:</p>"
             + "<table style='width:100%;border-collapse:collapse;margin-bottom:20px;font-size:14px;'>"
             + "<tr><td style='padding:6px 0;font-weight:700;width:40%;color:#374151;'>Examiner</td>"
             + "<td style='padding:6px 0;color:#111827;'>: " + esc(examinerName) + "</td></tr>"
             + "<tr><td style='padding:6px 0;font-weight:700;color:#374151;'>Candidate</td>"
             + "<td style='padding:6px 0;color:#111827;'>: " + esc(candidateName) + "</td></tr>"
             + "<tr><td style='padding:6px 0;font-weight:700;color:#374151;'>Programme</td>"
             + "<td style='padding:6px 0;color:#111827;'>: " + esc(program) + "</td></tr>"
             + "<tr><td style='padding:6px 0;font-weight:700;color:#374151;'>Response</td>"
             + "<td style='padding:6px 0;font-weight:700;color:" + statusColor + ";'>: " + statusLabel + "</td></tr>"
             + (reason != null && !reason.isEmpty()
                ? "<tr><td style='padding:6px 0;font-weight:700;color:#374151;vertical-align:top;'>Reason</td>"
                + "<td style='padding:6px 0;color:#111827;'>: " + esc(reason) + "</td></tr>"
                : "")
             + "</table>"
             + (!accepted
                ? "<div style='background:#fef3c7;border:1px solid #fbbf24;border-radius:8px;padding:12px 16px;margin-bottom:20px;'>"
                + "<p style='margin:0;font-size:14px;color:#92400e;font-weight:600;'>Action Required</p>"
                + "<p style='margin:6px 0 0;font-size:13px;color:#78350f;'>This appointment has been marked as "
                + "<strong>examiner_declined</strong>. Please reassign the external examiner from the appointment page.</p>"
                + "</div>"
                : "")
             + "<a href='" + esc(apptUrl) + "' style='display:inline-block;background:#0f766e;color:#fff;"
             + "font-weight:700;font-size:14px;padding:10px 24px;border-radius:8px;text-decoration:none;'>"
             + "View Appointment &rarr;</a>"
             + "</td></tr>"
             + "<tr><td style='background:#f9fafb;padding:16px 32px;border-top:1px solid #e5e7eb;'>"
             + "<p style='margin:0;font-size:12px;color:#9ca3af;'>This is an automated notification from E-Appointment FSKM.</p>"
             + "</td></tr>"
             + "</table></td></tr></table></body></html>";
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    private static String str(Object o) {
        return o != null ? o.toString().trim() : "";
    }
}
