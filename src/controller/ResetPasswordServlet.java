package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

/** Handles the password-reset form linked from the emailed token. GET validates the token; POST applies the new password. */
@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/ResetPasswordServlet"})
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            req.setAttribute("tokenError", "Invalid or missing reset link.");
            req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
            return;
        }
        try (Connection conn = DBConnection.getConnection()) {
            if (getValidUserId(conn, token) == null) {
                req.setAttribute("tokenError", "This reset link has expired or has already been used. Please request a new one.");
                req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
                return;
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        req.setAttribute("resetToken", token);
        req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token     = req.getParameter("token");
        String newPw     = req.getParameter("newPassword");
        String confirmPw = req.getParameter("confirmPassword");

        if (token == null || token.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/ForgotPasswordServlet");
            return;
        }

        if (newPw == null || newPw.trim().isEmpty()) {
            req.setAttribute("resetToken", token);
            req.setAttribute("formError", "Please enter a new password.");
            req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
            return;
        }
        if (!newPw.equals(confirmPw)) {
            req.setAttribute("resetToken", token);
            req.setAttribute("formError", "Passwords do not match.");
            req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
            return;
        }
        if (newPw.length() < 6) {
            req.setAttribute("resetToken", token);
            req.setAttribute("formError", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            Integer userId = getValidUserId(conn, token);
            if (userId == null) {
                req.setAttribute("tokenError", "This reset link has expired or has already been used. Please request a new one.");
                req.getRequestDispatcher("/resetPassword.jsp").forward(req, resp);
                return;
            }

            String newHash = util.PasswordUtil.hash(newPw);
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE `user` SET password_hash = ? WHERE id = ?")) {
                ps.setString(1, newHash);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE password_reset_token SET used = 1 WHERE token = ?")) {
                ps.setString(1, token);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        resp.sendRedirect(req.getContextPath() + "/login.jsp?reset=1");
    }

    private Integer getValidUserId(Connection conn, String token) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT user_id FROM password_reset_token WHERE token = ? AND used = 0 AND expires_at > NOW() LIMIT 1")) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("user_id") : null;
            }
        }
    }
}
