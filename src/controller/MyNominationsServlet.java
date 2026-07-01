package controller;

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

/** Lists nominations submitted by the logged-in Academician (or Dean) with optional text and status filters. */
@WebServlet(name = "MyNominationsServlet", urlPatterns = {"/MyNominationsServlet"})
public class MyNominationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String roleName = (String) session.getAttribute("role_name");
        if (!"Academician".equals(roleName) && !"Dean".equals(roleName)) {
            resp.sendRedirect(req.getContextPath() + "/admin/adminDashboard.jsp");
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        String q      = req.getParameter("q")      != null ? req.getParameter("q").trim()      : "";
        String status = req.getParameter("status")  != null ? req.getParameter("status").trim() : "";

        try {
            NominationDAO dao = new NominationDAO();
            List<Nomination> nominations = dao.findByUserId(userId, q.isEmpty() ? null : q, status.isEmpty() ? null : status);
            req.setAttribute("nominations", nominations);
            req.getRequestDispatcher("/academician/nomination/myNominations.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
