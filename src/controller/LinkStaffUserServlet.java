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

/**
 * Links an existing academic_staff record to a user account.
 * Called when admin creates a user first, then wants to connect
 * an already-existing staff record instead of creating a new one.
 */
@WebServlet(name = "LinkStaffUserServlet", urlPatterns = {"/LinkStaffUserServlet"})
public class LinkStaffUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String staffIdStr = req.getParameter("staffId");
        String userIdStr  = req.getParameter("userId");

        if (staffIdStr == null || staffIdStr.trim().isEmpty()
                || userIdStr == null || userIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath()
                    + "/admin/academician/academicStaffList.jsp?error=missing");
            return;
        }

        int staffId, userId;
        try {
            staffId = Integer.parseInt(staffIdStr.trim());
            userId  = Integer.parseInt(userIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath()
                    + "/admin/academician/academicStaffList.jsp?error=invalid");
            return;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE academic_staff SET user_id = ? WHERE id = ? AND user_id IS NULL")) {
            ps.setInt(1, userId);
            ps.setInt(2, staffId);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                // Staff record already linked or not found — redirect with a warning
                resp.sendRedirect(req.getContextPath()
                        + "/admin/academician/academicStaffList.jsp?warn=already_linked");
                return;
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        resp.sendRedirect(req.getContextPath()
                + "/admin/academician/academicStaffList.jsp?success=1");
    }
}
