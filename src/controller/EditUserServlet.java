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
import java.sql.ResultSet;
import java.sql.SQLException;

/** Updates an existing user's name, email, role, title, status, and optionally their password and administrative position. */
@WebServlet(name = "EditUserServlet", urlPatterns = {"/EditUserServlet"})
public class EditUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String roleName = req.getParameter("role");
        String titleName = req.getParameter("title");
        String status = req.getParameter("status");
        String password = req.getParameter("password");
        String adminPosition = req.getParameter("administrative_position"); // TDA, TDB or blank

        if (idStr == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/userList.jsp?error=1");
            return;
        }
        if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/userList.jsp?error=missing_fields");
            return;
        }

        int id = Integer.parseInt(idStr);

        try (Connection conn = DBConnection.getConnection()) {
            Integer roleId = null;
            Integer titleId = null;
            try (PreparedStatement rps = conn.prepareStatement("SELECT id FROM role WHERE name = ? LIMIT 1")) {
                rps.setString(1, roleName);
                try (ResultSet rs = rps.executeQuery()) { if (rs.next()) roleId = rs.getInt("id"); }
            }
            // If role not found, insert it so new roles (e.g. Dean) are auto-created
            if (roleId == null && roleName != null && !roleName.trim().isEmpty()) {
                try (PreparedStatement ins = conn.prepareStatement("INSERT IGNORE INTO role (name) VALUES (?)")) {
                    ins.setString(1, roleName);
                    ins.executeUpdate();
                }
                try (PreparedStatement rps = conn.prepareStatement("SELECT id FROM role WHERE name = ? LIMIT 1")) {
                    rps.setString(1, roleName);
                    try (ResultSet rs = rps.executeQuery()) { if (rs.next()) roleId = rs.getInt("id"); }
                }
            }

            try (PreparedStatement tps = conn.prepareStatement("SELECT id FROM title WHERE name = ? LIMIT 1")) {
                tps.setString(1, titleName != null ? titleName : "Mr");
                try (ResultSet rs = tps.executeQuery()) { if (rs.next()) titleId = rs.getInt("id"); }
            }

            String updateSql;
            if (password != null && !password.trim().isEmpty()) {
                updateSql = "UPDATE `user` SET full_name=?, email=?, role_id=?, title_id=?, status=?, password_hash=? WHERE id=?";
            } else {
                updateSql = "UPDATE `user` SET full_name=?, email=?, role_id=?, title_id=?, status=? WHERE id=?";
            }

            try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                ups.setString(1, fullName);
                ups.setString(2, email);
                ups.setInt(3, roleId != null ? roleId : 2);
                if (titleId != null) ups.setInt(4, titleId); else ups.setNull(4, java.sql.Types.INTEGER);
                ups.setString(5, status != null ? status : "active");
                if (password != null && !password.trim().isEmpty()) {
                    String ph = util.PasswordUtil.hash(password);
                    ups.setString(6, ph);
                    ups.setInt(7, id);
                } else {
                    ups.setInt(6, id);
                }
                ups.executeUpdate();
            }

            // Update administrative_position in academic_staff (if user has an academic_staff record)
            // Only TDA and TDB are valid; anything else clears the field.
            String posVal = ("TDA".equals(adminPosition) || "TDB".equals(adminPosition)) ? adminPosition : null;
            String upsertStaff =
                "UPDATE academic_staff SET administrative_position = ? WHERE user_id = ?";
            try (PreparedStatement sp = conn.prepareStatement(upsertStaff)) {
                if (posVal != null) sp.setString(1, posVal); else sp.setNull(1, java.sql.Types.VARCHAR);
                sp.setInt(2, id);
                sp.executeUpdate();
            }

            resp.sendRedirect(req.getContextPath() + "/UserListServlet");
            return;
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

}
