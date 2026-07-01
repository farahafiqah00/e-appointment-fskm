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

/** Toggles academic_staff.status between 'active' and 'inactive' for archive/restore actions. */
@WebServlet(name = "ArchiveStaffServlet", urlPatterns = {"/ArchiveStaffServlet"})
public class ArchiveStaffServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String staffIdStr = req.getParameter("staffId");
        String action     = req.getParameter("action"); // "archive" or "restore"

        if (staffIdStr == null || staffIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/academician/academicStaffList.jsp");
            return;
        }

        int staffId;
        try {
            staffId = Integer.parseInt(staffIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/academician/academicStaffList.jsp");
            return;
        }

        String newStatus = "restore".equals(action) ? "active" : "inactive";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE academic_staff SET status = ? WHERE id = ?")) {
            ps.setString(1, newStatus);
            ps.setInt(2, staffId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/academician/academicStaffList.jsp?success=1");
    }
}
