package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/** Toggles a user account between active and inactive (deactivated) status. */
@WebServlet(name = "ToggleUserStatusServlet", urlPatterns = {"/ToggleUserStatusServlet"})
public class ToggleUserStatusServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        String newStatus = req.getParameter("newStatus");
        if (idStr == null || newStatus == null) {
            resp.sendRedirect(req.getContextPath() + "/UserListServlet?error=1");
            return;
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE `user` SET status=? WHERE id=?")) {
            ps.setString(1, newStatus);
            ps.setInt(2, Integer.parseInt(idStr));
            ps.executeUpdate();
            resp.sendRedirect(req.getContextPath() + "/UserListServlet");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
