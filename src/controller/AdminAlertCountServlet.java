package controller;

import dao.ReportsDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

/**
 * JSON endpoint for polling admin alert counts.
 * Used by the dashboard for real-time (periodic) notification refresh.
 * Returns: { pendingVerification, readyForAppointment, letterNotGenerated,
 *             overdueExternalResponse, examinerDeclined, letterApprovedNotSent }
 */
@WebServlet("/admin/alertCounts")
public class AdminAlertCountServlet extends HttpServlet {

    private final ReportsDAO rdao = new ReportsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String role = session != null ? String.valueOf(session.getAttribute("role_name")) : "";
        if ("Dean".equals(role) || "Academician".equals(role) || "".equals(role) || "null".equals(role)) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"unauthorized\"}");
            return;
        }

        Map<String, Integer> counts;
        try {
            counts = rdao.getAdminAlerts();
        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"db\"}");
            return;
        }

        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        resp.getWriter().write(
            "{" +
            "\"pendingVerification\":"   + counts.getOrDefault("pendingVerification",   0) + "," +
            "\"readyForAppointment\":"   + counts.getOrDefault("readyForAppointment",   0) + "," +
            "\"letterNotGenerated\":"    + counts.getOrDefault("letterNotGenerated",    0) + "," +
            "\"overdueExternalResponse\":" + counts.getOrDefault("overdueExternalResponse", 0) + "," +
            "\"examinerDeclined\":"      + counts.getOrDefault("examinerDeclined",      0) + "," +
            "\"letterApprovedNotSent\":" + counts.getOrDefault("letterApprovedNotSent", 0) +
            "}"
        );
    }
}
