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
import java.sql.SQLException;
import java.net.URLEncoder;

/** Serves the letter preview page for an internal panel member (Academician/Dean); verifies the user is actually assigned to the appointment before forwarding. */
@WebServlet(urlPatterns = {"/panel/member/preview"})
public class MemberLetterPreviewServlet extends HttpServlet {

    private AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            String returnUrl = req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "");
            resp.sendRedirect(req.getContextPath() + "/login.jsp?returnUrl=" + URLEncoder.encode(returnUrl, "UTF-8"));
            return;
        }

        String sPanelId = req.getParameter("panel_id");
        String sApptId = req.getParameter("appointment_id");
        if (sPanelId == null || sApptId == null) {
            // Missing parameters — send user to their My Appointments page
            resp.sendRedirect(req.getContextPath() + "/academician/my-appointments?notice=missingParams");
            return;
        }

        try {
            int panelId = Integer.parseInt(sPanelId);
            int apptId = Integer.parseInt(sApptId);
            int currentUserId = ((Number) session.getAttribute("user_id")).intValue();

            // Verify assignment
            if (!dao.isUserAssignedToAppointment(apptId, currentUserId)) {
                // Not assigned to this appointment — show user their pending appointments
                resp.sendRedirect(req.getContextPath() + "/academician/my-appointments?notice=notAssigned");
                return;
            }

            VivaAppointment va = dao.findById(apptId);
            if (va == null) {
                resp.sendRedirect(req.getContextPath() + "/academician/my-appointments?notice=apptNotFound");
                return;
            }

            // Fetch the specific panel member detail for rendering
            java.util.Map<String,Object> panelDetail = dao.getPanelDetailById(panelId);
            if (panelDetail == null) {
                resp.sendRedirect(req.getContextPath() + "/academician/my-appointments?notice=panelNotFound");
                return;
            }

            req.setAttribute("appointment", va);
            req.setAttribute("member", panelDetail);
            // Ensure the JSP resource exists before forwarding to avoid container 404
            try {
                if (getServletContext().getResource("/panel/memberPreview.jsp") == null) {
                    getServletContext().log("MemberLetterPreviewServlet: /panel/memberPreview.jsp not found in webapp");
                    resp.sendRedirect(req.getContextPath() + "/academician/my-appointments?notice=previewMissing");
                    return;
                }
            } catch (java.net.MalformedURLException ignored) {}
            req.getRequestDispatcher("/panel/memberPreview.jsp").forward(req, resp);

        } catch (NumberFormatException | SQLException e) {
            throw new ServletException(e);
        }
    }
}
