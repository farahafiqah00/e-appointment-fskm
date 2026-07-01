package controller;

import dao.UserDAO;
import model.User;
import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Handles the user profile page: GET loads the form; POST saves name, email, phone, optional password, and academic staff fields. */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/ProfileServlet"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role_name");
        if (role == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");
        try {
            User user = userDAO.findById(userId);
            req.setAttribute("profileUser", user);
            loadAcademicData(req, userId);
            req.getRequestDispatcher("/academician/userProfile.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role_name");
        if (role == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");

        String fullName = req.getParameter("fullName");
        String email    = req.getParameter("email");
        String phone    = req.getParameter("phone");
        String currentPw = req.getParameter("currentPassword");
        String newPw     = req.getParameter("newPassword");
        String confirmPw = req.getParameter("confirmPassword");

        // Basic validation
        if (fullName == null || fullName.trim().isEmpty() ||
            email    == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Full name and email are required.");
            forwardBack(req, resp, userId);
            return;
        }
        fullName = fullName.trim();
        email    = email.trim();
        phone    = (phone != null) ? phone.trim() : "";

        try {
            // Check email not already used by someone else
            if (userDAO.emailTakenByOther(email, userId)) {
                req.setAttribute("error", "That email address is already in use by another account.");
                forwardBack(req, resp, userId);
                return;
            }

            // Read current user before update (for email-change detection and password check)
            User existing = userDAO.findById(userId);
            String oldEmail = existing != null ? existing.getEmail() : (String) session.getAttribute("email");

            // Password change — only if fields are filled
            String newHash = null;
            boolean changingPassword = newPw != null && !newPw.trim().isEmpty();
            if (changingPassword) {
                if (!util.PasswordUtil.verify(currentPw, existing.getPasswordHash())) {
                    req.setAttribute("error", "Current password is incorrect.");
                    forwardBack(req, resp, userId);
                    return;
                }
                if (!newPw.equals(confirmPw)) {
                    req.setAttribute("error", "New password and confirmation do not match.");
                    forwardBack(req, resp, userId);
                    return;
                }
                if (newPw.length() < 6) {
                    req.setAttribute("error", "New password must be at least 6 characters.");
                    forwardBack(req, resp, userId);
                    return;
                }
                newHash = util.PasswordUtil.hash(newPw);
            }

            userDAO.updateProfile(userId, fullName, email, phone, newHash);

            // Save user.title_id for Admin (Admin has no academic_staff record)
            if ("Admin".equals(role)) {
                String pfUserTitle = req.getParameter("pf_user_title");
                if (pfUserTitle != null) {
                    try (Connection conn = DBConnection.getConnection()) {
                        if (pfUserTitle.trim().isEmpty()) {
                            try (PreparedStatement ps = conn.prepareStatement(
                                    "UPDATE `user` SET title_id = NULL WHERE id = ?")) {
                                ps.setInt(1, userId);
                                ps.executeUpdate();
                            }
                            session.setAttribute("staff_title", null);
                        } else {
                            Integer titleId = null;
                            try (PreparedStatement ps = conn.prepareStatement(
                                    "SELECT id FROM title WHERE name = ? LIMIT 1")) {
                                ps.setString(1, pfUserTitle.trim());
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) titleId = rs.getInt("id");
                                }
                            }
                            if (titleId != null) {
                                try (PreparedStatement ps = conn.prepareStatement(
                                        "UPDATE `user` SET title_id = ? WHERE id = ?")) {
                                    ps.setInt(1, titleId);
                                    ps.setInt(2, userId);
                                    ps.executeUpdate();
                                }
                            }
                            session.setAttribute("staff_title", pfUserTitle.trim());
                        }
                    }
                }
            }

            // Save title if the user has an academic_staff record
            String pfTitle = req.getParameter("pf_title");
            if (pfTitle != null) {
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                         "UPDATE academic_staff SET title=? WHERE user_id=?")) {
                    setStrOrNull(ps, 1, pfTitle);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }
                session.setAttribute("staff_title", (!pfTitle.trim().isEmpty()) ? pfTitle.trim() : null);
            }

            // Save academic staff fields (if the user has a linked academic_staff record)
            String acProgram  = req.getParameter("ac_program");
            String acFaculty  = req.getParameter("ac_faculty");
            String acQual     = req.getParameter("ac_qualification");
            String acRank     = req.getParameter("ac_rank");
            String acYearsStr = req.getParameter("ac_years");
            String acSpecStr  = req.getParameter("ac_spec_id");
            String acExpStr   = req.getParameter("ac_expertise_id");
            String acDivStr   = req.getParameter("ac_division_id");
            String acAreaStr  = req.getParameter("ac_area_id");

            if (acProgram != null) { // academic section was present in the form
                int acYears = 0;
                try { acYears = Integer.parseInt(acYearsStr != null ? acYearsStr.trim() : ""); } catch (Exception ignored) {}
                Integer specId = parseNullableInt(acSpecStr);
                Integer expId  = parseNullableInt(acExpStr);
                Integer divId  = parseNullableInt(acDivStr);
                Integer areaId = parseNullableInt(acAreaStr);

                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                         "UPDATE academic_staff SET department=?, faculty=?, qualification=?, " +
                         "academic_rank=?, years_experience=?, specialization_id=?, expertise_id=?, " +
                         "division_id=?, area_id=? WHERE user_id=?")) {
                    setStrOrNull(ps, 1, acProgram);
                    setStrOrNull(ps, 2, acFaculty);
                    setStrOrNull(ps, 3, acQual);
                    setStrOrNull(ps, 4, acRank);
                    ps.setInt(5, acYears);
                    setIntOrNull(ps, 6, specId);
                    setIntOrNull(ps, 7, expId);
                    setIntOrNull(ps, 8, divId);
                    setIntOrNull(ps, 9, areaId);
                    ps.setInt(10, userId);
                    ps.executeUpdate();
                }
            }

            // Detect email change so the page can display a "re-login may be required" notice.
            boolean emailChanged = oldEmail != null && !email.equalsIgnoreCase(oldEmail);

            // Update session so topbar name and email reflect immediately
            session.setAttribute("full_name", fullName);
            session.setAttribute("email", email);

            if (emailChanged) {
                resp.sendRedirect(req.getContextPath() + "/ProfileServlet?emailChanged=1");
            } else {
                resp.sendRedirect(req.getContextPath() + "/ProfileServlet?success=1");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private void forwardBack(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws ServletException, IOException {
        try {
            req.setAttribute("profileUser", userDAO.findById(userId));
            loadAcademicData(req, userId);
        } catch (SQLException ignore) {}
        req.getRequestDispatcher("/academician/userProfile.jsp").forward(req, resp);
    }

    private void loadAcademicData(HttpServletRequest req, int userId) throws SQLException {
        // Load academic_staff record
        try (Connection conn = DBConnection.getConnection()) {
            // Load user's current title name from user.title_id (used for Admin profile title field)
            String userTitleName = "";
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT t.name FROM `user` u LEFT JOIN title t ON t.id = u.title_id WHERE u.id = ? LIMIT 1")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getString("name") != null) userTitleName = rs.getString("name");
                }
            }
            req.setAttribute("userTitleName", userTitleName);

            // Load all title options for the Admin title dropdown
            List<String> titleOpts = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT name FROM title ORDER BY id");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) titleOpts.add(rs.getString("name"));
            }
            req.setAttribute("titleOptions", titleOpts);
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT * FROM academic_staff WHERE user_id = ? LIMIT 1")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Map<String, Object> m = new LinkedHashMap<>();
                        m.put("department",        rs.getString("department"));
                        m.put("faculty",           rs.getString("faculty"));
                        m.put("qualification",     rs.getString("qualification"));
                        m.put("academic_rank",     rs.getString("academic_rank"));
                        m.put("years_experience",  rs.getObject("years_experience") != null ? rs.getInt("years_experience") : 0);
                        m.put("specialization_id", rs.getObject("specialization_id") != null ? rs.getInt("specialization_id") : null);
                        m.put("expertise_id",      rs.getObject("expertise_id")      != null ? rs.getInt("expertise_id")      : null);
                        m.put("division_id",       rs.getObject("division_id")       != null ? rs.getInt("division_id")       : null);
                        m.put("area_id",           rs.getObject("area_id")           != null ? rs.getInt("area_id")           : null);
                        m.put("title",             rs.getString("title"));
                        req.setAttribute("academicStaff", m);
                    }
                }
            }

            // Departments (specialization names — not student degree programs)
            List<String> programs = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT name FROM specialization ORDER BY name");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) programs.add(rs.getString("name"));
            }
            req.setAttribute("acPrograms", programs);

            // Faculties
            List<String> faculties = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT name FROM faculty ORDER BY name");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) faculties.add(rs.getString("name"));
            }
            req.setAttribute("acFaculties", faculties);

            // Specializations
            List<Map<String,Object>> specs = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM specialization ORDER BY name");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id")); m.put("name", rs.getString("name"));
                    specs.add(m);
                }
            }
            req.setAttribute("acSpecs", specs);

            // Expertise
            List<Map<String,Object>> expertise = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, specialization_id, name FROM expertise ORDER BY name");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id")); m.put("spec_id", rs.getInt("specialization_id")); m.put("name", rs.getString("name"));
                    expertise.add(m);
                }
            }
            req.setAttribute("acExpertise", expertise);

            // Divisions
            List<Map<String,Object>> divisions = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, expertise_id, name FROM division ORDER BY name");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id")); m.put("expertise_id", rs.getInt("expertise_id")); m.put("name", rs.getString("name"));
                    divisions.add(m);
                }
            }
            req.setAttribute("acDivisions", divisions);

            // Areas
            List<Map<String,Object>> areas = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, division_id, name FROM area ORDER BY name");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id")); m.put("division_id", rs.getInt("division_id")); m.put("name", rs.getString("name"));
                    areas.add(m);
                }
            }
            req.setAttribute("acAreas", areas);
        }
    }

    private Integer parseNullableInt(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    private void setStrOrNull(PreparedStatement ps, int idx, String val) throws SQLException {
        if (val != null && !val.trim().isEmpty()) ps.setString(idx, val.trim());
        else ps.setNull(idx, java.sql.Types.VARCHAR);
    }

    private void setIntOrNull(PreparedStatement ps, int idx, Integer val) throws SQLException {
        if (val != null) ps.setInt(idx, val);
        else ps.setNull(idx, java.sql.Types.INTEGER);
    }
}
