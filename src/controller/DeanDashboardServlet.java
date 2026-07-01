package controller;

import dao.AppointmentDAO;
import dao.ReportsDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/** Loads dashboard data for the Dean role: stats, upcoming appointments, programme breakdown, and pending letter approvals. */
@WebServlet(name = "DeanDashboardServlet", urlPatterns = {"/DeanDashboardServlet"})
public class DeanDashboardServlet extends HttpServlet {

    private ReportsDAO dao = new ReportsDAO();
    private AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String roleName = (String) session.getAttribute("role_name");
        if (!"Dean".equals(roleName)) {
            resp.sendRedirect(req.getContextPath() + "/admin/adminDashboard.jsp");
            return;
        }
        try {
            int currentUserId = ((Number) session.getAttribute("user_id")).intValue();
            req.setAttribute("deanStats",         dao.getDeanDashboardStats());
            req.setAttribute("upcomingList",       dao.getUpcomingAppointmentsList(6));
            req.setAttribute("programmeBreakdown", dao.getCandidatesByProgramme());
            req.setAttribute("pendingApprovals",   appointmentDAO.getPendingLetterApprovalsForSigner(currentUserId, 8));
            // Signed approvals with sent-count — non-fatal: fall back to empty list on any SQL error
            try {
                req.setAttribute("signedApprovals", appointmentDAO.getSignedLetterApprovalsForSigner(currentUserId, 5));
            } catch (Exception _ignored) {
                req.setAttribute("signedApprovals", new java.util.ArrayList<>());
            }
            req.setAttribute("activeSection",      "dashboard");
            req.getRequestDispatcher("/dean/deanDashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
