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

/** Handles the "Forgot Password" flow: GET shows the email form; POST generates a one-time reset token and emails it. */
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/ForgotPasswordServlet"})
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/forgotPassword.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/ForgotPasswordServlet?error=1");
            return;
        }
        email = email.trim().toLowerCase();

        try (Connection conn = DBConnection.getConnection()) {
            Integer userId   = null;
            String  fullName = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, full_name FROM `user` WHERE LOWER(email) = ? AND status = 'active' LIMIT 1")) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userId   = rs.getInt("id");
                        fullName = rs.getString("full_name");
                    }
                }
            }

            if (userId != null) {
                // Invalidate any previous unused tokens for this user so only one is active at a time
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE password_reset_token SET used = 1 WHERE user_id = ? AND used = 0")) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }

                // Generate 32-byte cryptographically random token → 64-char hex string
                byte[] bytes = new byte[32];
                new SecureRandom().nextBytes(bytes);
                StringBuilder sb = new StringBuilder(64);
                for (byte b : bytes) sb.append(String.format("%02x", b));
                String token = sb.toString();

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO password_reset_token (user_id, token, expires_at) VALUES (?, ?, NOW() + INTERVAL 30 MINUTE)")) {
                    ps.setInt(1, userId);
                    ps.setString(2, token);
                    ps.executeUpdate();
                }

                String baseUrl = req.getScheme() + "://" + req.getServerName()
                    + (req.getServerPort() == 80 || req.getServerPort() == 443
                        ? "" : ":" + req.getServerPort())
                    + req.getContextPath();
                String resetLink = baseUrl + "/ResetPasswordServlet?token=" + token;

                String subject = "Reset Your E-Appointment FSKM Password";
                String body = "Dear " + fullName + ",\n\n"
                    + "We received a request to reset your E-Appointment FSKM password.\n\n"
                    + "Click the link below to set a new password. This link expires in 30 minutes.\n\n"
                    + resetLink + "\n\n"
                    + "If you did not request a password reset, please ignore this email — "
                    + "your password will not be changed.\n\n"
                    + "This is an auto-generated email. Please do not reply.\n"
                    + "E-Appointment FSKM System";
                EmailUtil.sendEmailAsync(email, subject, body);
            }
            // Always show the same "sent" page whether the email exists or not to avoid account enumeration
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        resp.sendRedirect(req.getContextPath() + "/ForgotPasswordServlet?sent=1");
    }
}
