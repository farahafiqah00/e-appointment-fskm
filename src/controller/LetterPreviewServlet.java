package controller;

import dao.AppointmentDAO;
import model.VivaAppointment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.sql.SQLException;

/**
 * Serves the letter preview page for two audiences on two URL patterns:
 *   /admin/appointment/letter/preview  — full admin view (send emails, manage approval)
 *   /appointment/letter/review          — Dean/signer read-only review and sign-off
 * Access is gated: non-admins can only view if they are the assigned signer or an internal panel member.
 */
@WebServlet(urlPatterns = {"/admin/appointment/letter/preview", "/appointment/letter/review"})
public class LetterPreviewServlet extends HttpServlet {

    private AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            // Preserve the intended URL so login can redirect back after authentication
            String requestUri = req.getRequestURI();
            String queryString = req.getQueryString();
            String returnUrl = requestUri + (queryString != null ? "?" + queryString : "");
            resp.sendRedirect(req.getContextPath() + "/login.jsp?returnUrl=" + URLEncoder.encode(returnUrl, "UTF-8"));
            return;
        }

        String roleName = String.valueOf(session.getAttribute("role_name"));
        boolean isAdminRoute = req.getServletPath() != null && req.getServletPath().startsWith("/admin/");
        boolean isAdmin = "Admin".equals(roleName) || "System Administrator".equals(roleName);

        if (isAdminRoute && !isAdmin) {
            // Non-admin hit the admin route — only assigned internal panel members may view it.
            // Everyone else (including the letter signer) must re-login as Admin.
            String sid0 = req.getParameter("id");
            boolean allowedAsPanelMember = false;
            if (sid0 != null) {
                try {
                    int tmpId = Integer.parseInt(sid0);
                    Integer currentUserId = session.getAttribute("user_id") instanceof Number
                            ? ((Number) session.getAttribute("user_id")).intValue() : null;
                    if (currentUserId != null && dao.isUserAssignedToAppointment(tmpId, currentUserId)) {
                        allowedAsPanelMember = true;
                    }
                } catch (NumberFormatException | SQLException ex) {
                    // fall through to login redirect
                }
            }
            if (!allowedAsPanelMember) {
                String requestUri = req.getRequestURI();
                String qs = req.getQueryString();
                String returnUrl = requestUri + (qs != null ? "?" + qs : "");
                resp.sendRedirect(req.getContextPath() + "/login.jsp?returnUrl="
                        + URLEncoder.encode(returnUrl, "UTF-8"));
                return;
            }
        }

        String sid = req.getParameter("id");
        if (sid == null) {
            resp.sendRedirect(req.getContextPath() + (isAdmin ? "/admin/appointments" : "/dean/deanDashboard"));
            return;
        }
        try {
            int id = Integer.parseInt(sid);

            if (!isAdmin) {
                Integer currentUserId = session.getAttribute("user_id") instanceof Number ? ((Number) session.getAttribute("user_id")).intValue() : null;
                if (currentUserId == null) {
                    resp.sendRedirect(req.getContextPath() + "/dean/deanDashboard");
                    return;
                }
                java.util.Map<String,Object> approval = dao.getLetterApprovalByAppointmentId(id);
                boolean isAssignedSigner = false;
                if (approval != null && approval.get("signer_user_id") instanceof Number) {
                    isAssignedSigner = ((Number) approval.get("signer_user_id")).intValue() == currentUserId;
                }
                boolean isAssignedPanelMember = false;
                try {
                    isAssignedPanelMember = dao.isUserAssignedToAppointment(id, currentUserId);
                } catch (java.sql.SQLException ex) {
                    // On error be conservative — do not allow
                    isAssignedPanelMember = false;
                }
                if (!isAssignedSigner && !isAssignedPanelMember) {
                    resp.sendRedirect(req.getContextPath() + "/dean/deanDashboard");
                    return;
                }
            }

            VivaAppointment va = dao.findById(id);
            if (va == null) {
                resp.sendRedirect(req.getContextPath() + (isAdmin ? "/admin/appointments" : "/dean/deanDashboard"));
                return;
            }
            req.setAttribute("eligibleSigners", dao.getEligibleLetterSigners(id));
            req.setAttribute("letterApproval", dao.getLetterApprovalByAppointmentId(id));
            req.setAttribute("isAdminView", isAdmin);
            req.setAttribute("letterSentCount", dao.getLetterSentCount(id));
            // Load the stored signature only when the current user is the assigned pending signer (Dean/TDA/TDB)
            Integer currentUid = session.getAttribute("user_id") instanceof Number
                ? ((Number) session.getAttribute("user_id")).intValue() : null;
            java.util.Map<?,?> _la = (java.util.Map<?,?>) req.getAttribute("letterApproval");
            boolean _isPendingSigner = currentUid != null && _la != null
                && "pending".equalsIgnoreCase(_la.get("status") != null ? _la.get("status").toString() : "")
                && _la.get("signer_user_id") instanceof Number
                && ((Number) _la.get("signer_user_id")).intValue() == currentUid;
            if (_isPendingSigner) {
                req.setAttribute("signerStoredSignature", dao.getUserSignatureImage(currentUid));
            }
            String msg = req.getParameter("approvalMsg");
            String err = req.getParameter("approvalError");
            if (msg != null && !msg.trim().isEmpty()) {
                req.setAttribute("approvalMsg", URLDecoder.decode(msg, "UTF-8"));
            }
            if (err != null && !err.trim().isEmpty()) {
                req.setAttribute("approvalError", URLDecoder.decode(err, "UTF-8"));
            }
            req.setAttribute("appointment", va);
            String listUrlParam = req.getParameter("listUrl");
            if (listUrlParam != null && !listUrlParam.isEmpty()) {
                req.setAttribute("listUrl", listUrlParam);
            }
            String jspPath = isAdmin
                ? "/admin/appointment/letterPreview.jsp"
                : "/dean/appointment/letterReview.jsp";
            req.getRequestDispatcher(jspPath).forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + (isAdmin ? "/admin/appointments" : "/dean/deanDashboard"));
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
