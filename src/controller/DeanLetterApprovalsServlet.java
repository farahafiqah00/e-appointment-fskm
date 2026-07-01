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

/** Loads all letter approvals assigned to the logged-in Dean/TDA/TDB user for the approval inbox page. */
@WebServlet("/dean/appointment/letter/approvals")
public class DeanLetterApprovalsServlet extends HttpServlet {

    private AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String roleName = (String) session.getAttribute("role_name");
        if (!"Dean".equals(roleName) && !"Admin".equals(roleName) && !"System Administrator".equals(roleName)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        int userId = ((Number) session.getAttribute("user_id")).intValue();
        try {
            req.setAttribute("approvals", dao.getAllLetterApprovalsForSigner(userId));
            req.getRequestDispatcher("/dean/appointment/letterApprovals.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
