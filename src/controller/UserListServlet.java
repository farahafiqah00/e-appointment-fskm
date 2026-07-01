package controller;

import dao.UserDAO;
import model.User;
import util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Loads the admin user list with optional search, role, and status filters, then forwards to the user list JSP. */
@WebServlet(name = "UserListServlet", urlPatterns = {"/UserListServlet"})
public class UserListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String q      = req.getParameter("q");
        String role   = req.getParameter("role");
        String status = req.getParameter("status");
        try {
            UserDAO dao = new UserDAO();
            List<User> users = dao.findAll(q, role, status);
            req.setAttribute("users", users);

            // Build map: userId → academic_staff.id (so the list page knows edit vs add)
            Map<Integer, Integer> staffByUser = new HashMap<>();
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT user_id, id FROM academic_staff WHERE user_id IS NOT NULL")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) staffByUser.put(rs.getInt("user_id"), rs.getInt("id"));
                }
            }
            req.setAttribute("staffByUser", staffByUser);

            req.getRequestDispatcher("/admin/userList.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
