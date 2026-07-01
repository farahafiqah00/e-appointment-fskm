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
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/** Creates a new user account, auto-generates a secure password, and emails it to the new user. */
@WebServlet(name = "AddUserServlet", urlPatterns = {"/AddUserServlet"})
public class AddUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String roleName = req.getParameter("role");
        String titleName = req.getParameter("title");
        String active = req.getParameter("active");

        if (email == null || email.trim().isEmpty() || fullName == null || fullName.trim().isEmpty()
                || roleName == null || roleName.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/addUser.jsp?error=1&msg=Missing+required+fields");
            return;
        }

        // Auto-generate a secure random password — admin never sees it
        String rawPassword = generatePassword();
        String passwordHash = util.PasswordUtil.hash(rawPassword);
        String username = email != null ? email.split("@")[0] : fullName.replaceAll("\\s+","_").toLowerCase();
        String status = (active != null) ? "active" : "deactivated";

        try (Connection conn = DBConnection.getConnection()) {
            // find role id and title id
            Integer roleId = null;
            Integer titleId = null;
            try (PreparedStatement rps = conn.prepareStatement("SELECT id FROM role WHERE name = ? LIMIT 1")) {
                rps.setString(1, roleName);
                try (ResultSet rs = rps.executeQuery()) {
                    if (rs.next()) roleId = rs.getInt("id");
                }
            }
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

            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO `user` (role_id, title_id, username, password_hash, email, full_name, status) VALUES (?,?,?,?,?,?,?)",
                    PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, roleId != null ? roleId : 2);
                if (titleId != null) ps.setInt(2, titleId); else ps.setNull(2, java.sql.Types.INTEGER);
                ps.setString(3, username);
                ps.setString(4, passwordHash);
                ps.setString(5, email);
                ps.setString(6, fullName);
                ps.setString(7, status);
                ps.executeUpdate();

                int userId = -1;
                try (ResultSet gk = ps.getGeneratedKeys()) { if (gk.next()) userId = gk.getInt(1); }

                // Send the auto-generated password to the user's email
                try {
                    String baseUrl = req.getScheme() + "://" + req.getServerName()
                        + (req.getServerPort() == 80 || req.getServerPort() == 443
                            ? "" : ":" + req.getServerPort())
                        + req.getContextPath();
                    String loginLink = baseUrl + "/login.jsp";
                    String subject = "Your E-Appointment FSKM Account Has Been Created";
                    String body = "Dear " + fullName + ",\n\n"
                            + "An account has been created for you on the E-Appointment FSKM system.\n\n"
                            + "Your login credentials:\n"
                            + "  Email:    " + email + "\n"
                            + "  Password: " + rawPassword + "\n\n"
                            + "Login here: " + loginLink + "\n\n"
                            + "Please log in and change your password immediately from your profile page.\n\n"
                            + "This is an auto-generated email. Please do not reply.\n"
                            + "E-Appointment FSKM System";
                    EmailUtil.sendEmailAsync(email, subject, body);
                } catch (Throwable mailEx) {
                    // If email fails, log credentials to server log so developer can retrieve them
                    getServletContext().log("[AddUserServlet] TEMP PASSWORD (email delivery failed) — "
                        + "email=" + email + " password=" + rawPassword);
                }

                if (("Academician".equals(roleName) || "Dean".equals(roleName)) && userId != -1) {
                    resp.sendRedirect(req.getContextPath()
                            + "/admin/academician/addAcademicStaff.jsp?userId=" + userId);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/UserListServlet?msg=user_created");
                }
                return;
            }
        } catch (SQLException e) {
            // Duplicate username or email
            if (e.getErrorCode() == 1062) {
                resp.sendRedirect(req.getContextPath()
                        + "/admin/addUser.jsp?error=1&msg=A+user+with+that+email+already+exists");
                return;
            }
            throw new ServletException(e);
        }
    }

    /**
     * Generates a cryptographically secure random password of 12 characters
     * containing uppercase, lowercase, digits, and special characters.
     */
    private String generatePassword() {
        final String upper   = "ABCDEFGHJKLMNPQRSTUVWXYZ";
        final String lower   = "abcdefghjkmnpqrstuvwxyz";
        final String digits  = "23456789";
        final String special = "@#$%&!";
        final String all     = upper + lower + digits + special;

        SecureRandom rng = new SecureRandom();
        char[] password = new char[12];
        // Guarantee at least one character from each category
        password[0] = upper.charAt(rng.nextInt(upper.length()));
        password[1] = lower.charAt(rng.nextInt(lower.length()));
        password[2] = digits.charAt(rng.nextInt(digits.length()));
        password[3] = special.charAt(rng.nextInt(special.length()));
        for (int i = 4; i < 12; i++) {
            password[i] = all.charAt(rng.nextInt(all.length()));
        }
        // Shuffle to avoid predictable positions
        for (int i = 11; i > 0; i--) {
            int j = rng.nextInt(i + 1);
            char tmp = password[i]; password[i] = password[j]; password[j] = tmp;
        }
        return new String(password);
    }

}
