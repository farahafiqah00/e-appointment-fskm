package controller;

import dao.AppointmentDAO;

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

/** Loads the "My Appointments" page for an Academician or Dean panel member, showing both pending-response panels and the full appointment history. */
@WebServlet(urlPatterns = {"/academician/my-appointments"})
public class MemberAppointmentsServlet extends HttpServlet {

    private final AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role_name");
        if (!"Academician".equals(role) && !"Dean".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        int userId = ((Number) session.getAttribute("user_id")).intValue();
        try {
            List<Map<String,Object>> pending = dao.getPendingPanelsForUser(userId);
            List<Map<String,Object>> all     = dao.getAllAppointmentsForUser(userId);
            req.setAttribute("pendingPanels", pending);
            req.setAttribute("allPanels", all);
            req.setAttribute("activeSection", "myAppointments");
            req.getRequestDispatcher("/academician/myAppointments.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
