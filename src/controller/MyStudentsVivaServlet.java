package controller;

import dao.AppointmentDAO;
import model.VivaAppointment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/** Shows viva appointments for candidates supervised by the logged-in user; serves both Academician and Dean roles with role-specific JSP views. */
@WebServlet(urlPatterns = {"/academician/my-students-viva", "/dean/my-students-viva"})
public class MyStudentsVivaServlet extends HttpServlet {

    private AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer userId = (Integer) req.getSession().getAttribute("user_id");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        try {
            List<VivaAppointment> appointments = dao.findBySupervisorUserId(userId);
            req.setAttribute("appointments", appointments);
            String role = (String) req.getSession().getAttribute("role_name");
            String view = "Dean".equals(role)
                ? "/dean/viva/myStudentsViva.jsp"
                : "/academician/viva/myStudentsViva.jsp";
            req.getRequestDispatcher(view).forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
