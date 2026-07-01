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
 * Authenticated endpoint for internal panel members to accept/decline their appointment.
 */
@WebServlet(name = "PanelMemberResponseServlet", urlPatterns = {"/PanelMemberResponseServlet"})
public class PanelMemberResponseServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = null;
        if (req.getSession().getAttribute("user_id") instanceof Number) {
            userId = ((Number) req.getSession().getAttribute("user_id")).intValue();
        }
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String sid = req.getParameter("panel_id");
        String action = req.getParameter("action");
        String returnTo = req.getParameter("return_to");
        if (sid == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
            return;
        }

        try {
            int panelId = Integer.parseInt(sid);
            AppointmentDAO dao = new AppointmentDAO();
            Map<String,Object> detail = dao.getPanelDetailById(panelId);
            if (detail == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/appointments");
                return;
            }

            Object internalUidObj = detail.get("internal_user_id");
            Integer assignedUserId = internalUidObj instanceof Number ? ((Number) internalUidObj).intValue() : null;
            if (assignedUserId == null || !assignedUserId.equals(userId)) {
                // Not authorized to respond for this panel row
                resp.sendRedirect(req.getContextPath() + "/admin/appointment/letter/preview?id=" + detail.get("appointment_id"));
                return;
            }

            String existing = detail.get("panel_response") != null ? detail.get("panel_response").toString() : null;
            if ("accepted".equals(existing) || "declined".equals(existing)) {
                if ("member".equals(returnTo)) {
                    resp.sendRedirect(req.getContextPath() + "/panel/member/preview?appointment_id=" + detail.get("appointment_id") + "&panel_id=" + panelId);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/appointment/letter/preview?id=" + detail.get("appointment_id"));
                }
                return;
            }

            if ("accept".equals(action)) {
                dao.savePanelResponseByPanelIdWithAudit(panelId, "accepted", null, "web", userId, req.getRemoteAddr());
                notifyAdmin(detail, "accepted", null, req);
            } else if ("decline".equals(action)) {
                String reason = req.getParameter("rejection_reason");
                if (reason == null || reason.trim().isEmpty()) {
                    if ("member".equals(returnTo)) {
                        resp.sendRedirect(req.getContextPath() + "/panel/member/preview?appointment_id=" + detail.get("appointment_id") + "&panel_id=" + panelId + "&error=needReason");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/admin/appointment/letter/preview?id=" + detail.get("appointment_id") + "&error=needReason");
                    }
                    return;
                }
                dao.savePanelResponseByPanelIdWithAudit(panelId, "declined", reason.trim(), "web", userId, req.getRemoteAddr());
                notifyAdmin(detail, "declined", reason.trim(), req);
            }

            if ("member".equals(returnTo)) {
                resp.sendRedirect(req.getContextPath() + "/panel/member/preview?appointment_id=" + detail.get("appointment_id") + "&panel_id=" + panelId + "&result=ok");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/appointment/letter/preview?id=" + detail.get("appointment_id") + "&result=ok");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void notifyAdmin(Map<String,Object> detail, String response, String reason, HttpServletRequest req) {
        try {
            AppointmentDAO dao = new AppointmentDAO();
            List<Map<String,Object>> admins = dao.getActiveAdminRecipients();
            if (admins.isEmpty()) return;

            String memberName = str(detail.get("name"));
            String candidate  = str(detail.get("candidate_name"));
            String program    = str(detail.get("candidate_program"));
            String role       = str(detail.get("role"));
            String apptUrl    = req.getScheme() + "://" + req.getServerName()
                    + (req.getServerPort() == 80 || req.getServerPort() == 443 ? "" : ":" + req.getServerPort())
                    + req.getContextPath() + "/admin/appointment/decision?id=" + detail.get("appointment_id")
                    + "#panel-responses";

            boolean accepted    = "accepted".equals(response);
            String subject      = (accepted ? "Panel Member Accepted Appointment — " : "Panel Member DECLINED Appointment — ") + candidate;
            String statusColor  = accepted ? "#15803d" : "#b91c1c";
            String statusBg     = accepted ? "#dcfce7" : "#fee2e2";
            String statusLabel  = accepted ? "ACCEPTED" : "DECLINED";
            String icon         = accepted ? "✅" : "❌";
            String roleLabel    = role.isEmpty() ? "Internal Panel Member" : role;

            String body = "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
                + "<body style='margin:0;padding:0;background:#f3f4f6;font-family:Arial,sans-serif;'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'>"
                + "<tr><td align='center'>"
                + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
                + "<tr><td style='background:#105e60;padding:24px 32px;'>"
                + "<h1 style='margin:0;color:#fff;font-size:1.3rem;font-weight:700;'>E-Appointment FSKM</h1>"
                + "<p style='margin:4px 0 0;color:#a7f3d0;font-size:0.88rem;'>Panel Appointment Response Notification</p>"
                + "</td></tr>"
                + "<tr><td style='padding:28px 32px;'>"
                + "<div style='background:" + statusBg + ";border-radius:10px;padding:16px 20px;margin-bottom:24px;text-align:center;'>"
                + "<p style='margin:0;font-size:1.15rem;font-weight:700;color:" + statusColor + ";'>" + icon + " Appointment " + statusLabel + "</p>"
                + "</div>"
                + "<p style='color:#374151;'>The following internal panel member has responded to their appointment invitation:</p>"
                + "<table style='width:100%;border-collapse:collapse;margin-bottom:20px;font-size:14px;'>"
                + "<tr><td style='padding:6px 0;font-weight:700;width:40%;color:#374151;'>Panel Member</td>"
                + "<td style='padding:6px 0;color:#111827;'>: " + esc(memberName) + "</td></tr>"
                + "<tr><td style='padding:6px 0;font-weight:700;color:#374151;'>Role</td>"
                + "<td style='padding:6px 0;color:#111827;'>: " + esc(roleLabel) + "</td></tr>"
                + "<tr><td style='padding:6px 0;font-weight:700;color:#374151;'>Candidate</td>"
                + "<td style='padding:6px 0;color:#111827;'>: " + esc(candidate) + "</td></tr>"
                + "<tr><td style='padding:6px 0;font-weight:700;color:#374151;'>Programme</td>"
                + "<td style='padding:6px 0;color:#111827;'>: " + esc(program) + "</td></tr>"
                + "<tr><td style='padding:6px 0;font-weight:700;color:#374151;'>Response</td>"
                + "<td style='padding:6px 0;font-weight:700;color:" + statusColor + ";'>: " + statusLabel + "</td></tr>"
                + (reason != null && !reason.isEmpty()
                    ? "<tr><td style='padding:6px 0;font-weight:700;color:#374151;vertical-align:top;'>Reason</td>"
                    + "<td style='padding:6px 0;color:#111827;'>: " + esc(reason) + "</td></tr>" : "")
                + "</table>"
                + "<a href='" + esc(apptUrl) + "' style='display:inline-block;background:#0f766e;color:#fff;"
                + "font-weight:700;font-size:14px;padding:10px 24px;border-radius:8px;text-decoration:none;'>"
                + "View Panel Responses &rarr;</a>"
                + "</td></tr>"
                + "<tr><td style='background:#f9fafb;padding:16px 32px;border-top:1px solid #e5e7eb;'>"
                + "<p style='margin:0;font-size:12px;color:#9ca3af;'>This is an automated notification from E-Appointment FSKM.</p>"
                + "</td></tr>"
                + "</table></td></tr></table></body></html>";

            for (Map<String,Object> admin : admins) {
                String adminEmail = admin.get("email") != null ? admin.get("email").toString() : null;
                if (adminEmail != null && !adminEmail.isEmpty()) {
                    EmailUtil.sendHtmlEmailAsync(adminEmail, subject, body);
                }
            }
        } catch (Exception ex) {
            getServletContext().log("PanelMemberResponseServlet: admin notification failed: " + ex.getMessage());
        }
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    private static String str(Object o) {
        return o != null ? o.toString().trim() : "";
    }
}
