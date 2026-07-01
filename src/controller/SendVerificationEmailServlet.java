package controller;

import dao.NominationDAO;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Map;

/**
 * Allows a logged-in nominator (or Admin) to send / resend the verification email
 * to an examiner linked to one of their nominations.
 *
 * POST /SendVerificationEmailServlet
 *    nominationId (required)
 *
 * Redirects back to MyNominationsServlet with ?emailSent=1 or ?emailError=1.
 */
@WebServlet(name = "SendVerificationEmailServlet", urlPatterns = {"/SendVerificationEmailServlet"})
public class SendVerificationEmailServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role_name");
        int userId  = (int) session.getAttribute("user_id");

        String nomIdStr = req.getParameter("nominationId");
        if (nomIdStr == null || nomIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?emailError=1");
            return;
        }

        try {
            int nominationId = Integer.parseInt(nomIdStr.trim());
            NominationDAO dao = new NominationDAO();

            // Security: only the nominator or Admin may trigger this
            Integer nominatorId = dao.getNominatorUserIdByNominationId(nominationId);
            if (nominatorId == null || (!nominatorId.equals(userId) && !"Admin".equals(role) && !"System Administrator".equals(role))) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?emailError=1");
                return;
            }

            Map<String,Object> info = dao.getExaminerInfoByNominationId(nominationId);
            if (info == null || info.get("email") == null) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?emailError=1");
                return;
            }

            int    examinerId    = (int)    info.get("id");
            String examinerEmail = (String) info.get("email");
            String examinerName  = (String) info.get("name");

            // Generate fresh token (7-day expiry)
            String token = java.util.UUID.randomUUID().toString().replace("-", "");
            Timestamp expires = new Timestamp(System.currentTimeMillis() + 7L * 24 * 60 * 60 * 1000);
            dao.saveVerificationToken(examinerId, token, expires);

            // Reset nomination status to pending_examiner so the UI shows "Awaiting Examiner"
            // and markInfoConfirmed can advance it to 'submitted' when the examiner confirms.
            dao.resetToPendingExaminer(nominationId);

            String nominatorName = (String) session.getAttribute("full_name");
            if (nominatorName == null) nominatorName = "the nominator";

            String baseUrl = req.getScheme() + "://" + req.getServerName()
                    + (req.getServerPort() == 80 || req.getServerPort() == 443
                        ? "" : ":" + req.getServerPort())
                    + req.getContextPath();
            String verifyLink = baseUrl + "/ExaminerVerifyServlet?token=" + token;
            String emailBody  = buildVerificationEmail(examinerName, nominatorName, verifyLink);

            EmailUtil.sendHtmlEmailAsync(examinerEmail,
                    "Please Verify Your Examination Profile - E-Appointment FSKM", emailBody);

            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?emailSent=1");

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?emailError=1");
        } catch (Exception e) {
            getServletContext().log("SendVerificationEmailServlet error: " + e.getMessage(), e);
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?emailError=1");
        }
    }

    private static String buildVerificationEmail(String examinerName, String nominatorName, String verifyLink) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head><body style='margin:0;padding:0;background:#f3f4f6;font-family:Inter,Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'><tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#105e60;padding:28px 36px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.4rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:6px 0 0;color:#a7f3d0;font-size:0.92rem;'>Faculty of Computer and Mathematical Sciences</p>"
             + "</td></tr>"
             + "<tr><td style='padding:32px 36px;'>"
             + "<p style='font-size:1rem;color:#374151;margin-top:0;'>Dear <strong>" + escapeHtml(examinerName) + "</strong>,</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "You have been nominated as an examiner for a postgraduate thesis viva examination at UMT by "
             + "<strong>" + escapeHtml(nominatorName) + "</strong>.</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Please review the information we have on file for you and confirm that it is accurate by clicking the button below.</p>"
             + "<div style='text-align:center;margin:32px 0;'>"
             + "<a href='" + verifyLink + "' style='background:#0f766e;color:#fff;text-decoration:none;"
             + "padding:14px 36px;border-radius:10px;font-size:1rem;font-weight:600;display:inline-block;'>"
             + "Review &amp; Confirm My Information</a></div>"
             + "<p style='font-size:0.85rem;color:#6b7280;'>This link will expire in <strong>7 days</strong>. "
             + "If the button above does not work, copy and paste this URL into your browser:</p>"
             + "<p style='font-size:0.82rem;color:#0f766e;word-break:break-all;'>" + verifyLink + "</p>"
             + "<hr style='border:none;border-top:1px solid #f3f4f6;margin:24px 0;'>"
             + "<p style='font-size:0.8rem;color:#9ca3af;margin:0;'>This email was sent automatically by the E-Appointment FSKM system. "
             + "If you were not expecting this, please disregard it.</p>"
             + "</td></tr></table>"
             + "</td></tr></table></body></html>";
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
