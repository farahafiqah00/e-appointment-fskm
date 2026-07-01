package controller;

import util.DBConnection;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.*;

/**
 * One-time setup endpoint — creates the first System Administrator account.
 * Only works when no users exist in the database (safe to leave deployed).
 * Access: GET /SetupServlet  →  shows form
 *         POST /SetupServlet →  creates admin and emails temporary password
 */
@WebServlet(name = "SetupServlet", urlPatterns = {"/SetupServlet"})
public class SetupServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (hasUsers()) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        req.getRequestDispatcher("/setup.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (hasUsers()) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String fullName = req.getParameter("fullName");
        String email    = req.getParameter("email");

        if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Full name and email are required.");
            req.getRequestDispatcher("/setup.jsp").forward(req, resp);
            return;
        }

        String rawPassword = generatePassword();
        String hash        = util.PasswordUtil.hash(rawPassword);
        String username    = email.split("@")[0];

        try (Connection conn = DBConnection.getConnection()) {
            Integer roleId = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM role WHERE name = 'System Administrator' LIMIT 1")) {
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) roleId = rs.getInt("id");
                }
            }
            if (roleId == null) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO role (name) VALUES ('System Administrator')")) {
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT id FROM role WHERE name = 'System Administrator' LIMIT 1")) {
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) roleId = rs.getInt("id");
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO `user` (role_id, username, password_hash, email, full_name, status) VALUES (?,?,?,?,?,'active')")) {
                ps.setInt(1, roleId);
                ps.setString(2, username);
                ps.setString(3, hash);
                ps.setString(4, email.trim());
                ps.setString(5, fullName.trim());
                ps.executeUpdate();
            }

            String baseUrl = req.getScheme() + "://" + req.getServerName()
                + (req.getServerPort() == 80 || req.getServerPort() == 443
                    ? "" : ":" + req.getServerPort())
                + req.getContextPath();

            try {
                EmailUtil.sendEmailAsync(email.trim(),
                    "E-Appointment FSKM — Your Administrator Account",
                    "Dear " + fullName.trim() + ",\n\n"
                    + "Your System Administrator account has been created.\n\n"
                    + "Login here: " + baseUrl + "/login.jsp\n\n"
                    + "Email:    " + email.trim() + "\n"
                    + "Password: " + rawPassword + "\n\n"
                    + "Please change your password after first login.\n\n"
                    + "E-Appointment FSKM System");
            } catch (Exception mailEx) {
                // If email fails, log credentials to server log so developer can retrieve them
                getServletContext().log("[SetupServlet] TEMP PASSWORD (email delivery failed) — "
                    + "email=" + email.trim() + " password=" + rawPassword);
            }

        } catch (SQLException e) {
            throw new ServletException(e);
        }

        resp.sendRedirect(req.getContextPath() + "/login.jsp?setup=1");
    }

    private boolean hasUsers() {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM `user`");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() && rs.getInt(1) > 0;
        } catch (Exception e) {
            return false;
        }
    }

    private String generatePassword() {
        final String chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789@#$%";
        SecureRandom rng = new SecureRandom();
        char[] pw = new char[12];
        for (int i = 0; i < 12; i++) pw[i] = chars.charAt(rng.nextInt(chars.length()));
        return new String(pw);
    }
}
