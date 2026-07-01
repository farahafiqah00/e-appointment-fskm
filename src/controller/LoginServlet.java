package controller;

import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/** Handles user authentication. GET redirects logged-in users to their dashboard; POST validates credentials. */
@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // If already logged in, redirect to the appropriate dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user_id") != null) {
            String role = (String) session.getAttribute("role_name");
            if ("Dean".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/dean/deanDashboard.jsp");
            } else if ("Academician".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/AcademicianDashboardServlet");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/adminDashboard.jsp");
            }
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.isEmpty() || password == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?error=1&msg=Missing+credentials");
            return;
        }

        try {
            User user = userDAO.findByEmail(email);
            if (user != null && util.PasswordUtil.verify(password, user.getPasswordHash())) {
                if ("inactive".equalsIgnoreCase(user.getStatus())) {
                    resp.sendRedirect(req.getContextPath() + "/login.jsp?error=1&msg=Account+is+disabled");
                    return;
                }
                HttpSession session = req.getSession(true);
                session.setAttribute("user_id", user.getId());
                session.setAttribute("full_name", user.getFullName());
                session.setAttribute("email", user.getEmail());
                session.setAttribute("role_id", user.getRoleId());
                session.setAttribute("role_name", user.getRoleName());
                // Load title for topbar display: prefer academic_staff.title, fall back to user.title_id
                try (java.sql.Connection conn = util.DBConnection.getConnection()) {
                    String titleVal = null;
                    try (java.sql.PreparedStatement ps2 = conn.prepareStatement(
                            "SELECT title FROM academic_staff WHERE user_id=? LIMIT 1")) {
                        ps2.setInt(1, user.getId());
                        try (java.sql.ResultSet rs2 = ps2.executeQuery()) {
                            if (rs2.next()) {
                                String t = rs2.getString("title");
                                if (t != null && !t.trim().isEmpty()) titleVal = t.trim();
                            }
                        }
                    }
                    if (titleVal == null) {
                        try (java.sql.PreparedStatement ps3 = conn.prepareStatement(
                                "SELECT t.name FROM `user` u LEFT JOIN title t ON t.id = u.title_id WHERE u.id=? LIMIT 1")) {
                            ps3.setInt(1, user.getId());
                            try (java.sql.ResultSet rs3 = ps3.executeQuery()) {
                                if (rs3.next() && rs3.getString("name") != null && !rs3.getString("name").trim().isEmpty()) {
                                    titleVal = rs3.getString("name").trim();
                                }
                            }
                        }
                    }
                    session.setAttribute("staff_title", titleVal);
                } catch (java.sql.SQLException ignored) {}
                String roleName = user.getRoleName();
                // Honor returnUrl (e.g. email action links) — must start with context path
                // and must not contain "://" to prevent open-redirect attacks.
                String returnUrl = req.getParameter("returnUrl");
                if (returnUrl != null && !returnUrl.trim().isEmpty()) {
                    try {
                        returnUrl = java.net.URLDecoder.decode(returnUrl, "UTF-8");
                    } catch (Exception ignored) {
                    }
                }
                String ctxPath   = req.getContextPath();
                String redirect;
                if (returnUrl != null && !returnUrl.trim().isEmpty()
                        && returnUrl.startsWith(ctxPath + "/")
                        && !returnUrl.contains("://")) {
                    // Safe local redirect — already contains context path
                    redirect = returnUrl;
                } else if ("Dean".equals(roleName)) {
                    redirect = ctxPath + "/DeanDashboardServlet";
                } else if ("Academician".equals(roleName)) {
                    redirect = ctxPath + "/AcademicianDashboardServlet";
                } else {
                    redirect = ctxPath + "/admin/adminDashboard.jsp";
                }
                resp.sendRedirect(redirect);
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp?error=1&msg=Invalid+email+or+password");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

}
