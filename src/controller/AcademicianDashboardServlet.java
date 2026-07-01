package controller;

import dao.AppointmentDAO;
import dao.NominationDAO;
import model.Nomination;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/** Loads dashboard data for the Academician role: nomination counts, corrections required, recent activity, and pending panel assignments. */
@WebServlet(name = "AcademicianDashboardServlet", urlPatterns = {"/AcademicianDashboardServlet"})
public class AcademicianDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String roleName = (String) session.getAttribute("role_name");
        if (!"Academician".equals(roleName)) {
            if ("Dean".equals(roleName)) {
                resp.sendRedirect(req.getContextPath() + "/dean/deanDashboard.jsp");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/adminDashboard.jsp");
            }
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        try {
            NominationDAO dao = new NominationDAO();
            int total      = dao.countByUserAndStatus(userId, null);
            // Combine 'submitted' and 'under_review' into a single "under review" count for the dashboard badge.
            int underReview = dao.countByUserAndStatus(userId, "submitted") + dao.countByUserAndStatus(userId, "under_review");
            int correction  = dao.countByUserAndStatus(userId, "needs_correction");
            int approved    = dao.countByUserAndStatus(userId, "verified");

            List<Nomination> corrections = dao.findCorrectionsRequired(userId);
            List<Nomination> recent      = dao.findRecentByUserId(userId, 5);

            AppointmentDAO apptDao = new AppointmentDAO();
            List<Map<String,Object>> pendingPanels = apptDao.getPendingPanelsForUser(userId);

            req.setAttribute("totalNominations",   total);
            req.setAttribute("underReview",        underReview);
            req.setAttribute("requiresCorrection", correction);
            req.setAttribute("approved",           approved);
            req.setAttribute("corrections",        corrections);
            req.setAttribute("recentActivity",     recent);
            req.setAttribute("pendingPanels",      pendingPanels);
            req.setAttribute("activeSection",      "dashboard");

            req.getRequestDispatcher("/academician/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
