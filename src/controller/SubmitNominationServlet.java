package controller;

import dao.NominationDAO;
import dao.AcademicStaffDAO;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import util.DBConnection;

/**
 * Handles the Academician's examiner nomination submission form.
 * Upserts the external_examiner record (reuses existing if same email), inserts the nomination,
 * saves uploaded CV/qualification files, then sends a verification email to the examiner.
 */
@WebServlet(name = "SubmitNominationServlet", urlPatterns = {"/SubmitNominationServlet"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024) // 10 MB per file, 50 MB total
public class SubmitNominationServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads/nominations";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Prevent browser from caching this page so dropdowns are always fresh
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String roleNameG = (String) session.getAttribute("role_name");
        if (!"Academician".equals(roleNameG) && !"Dean".equals(roleNameG)) {
            resp.sendRedirect(req.getContextPath() + "/admin/adminDashboard.jsp");
            return;
        }
        try {
            AcademicStaffDAO staffDao = new AcademicStaffDAO();
            req.setAttribute("specializations", staffDao.getSpecializations());
            req.setAttribute("expertiseList",   staffDao.getExpertise());
            req.setAttribute("divisionList",    staffDao.getDivisions());
            req.setAttribute("areaList",        staffDao.getAreas());
            req.setAttribute("examinerTitles",  staffDao.getExaminerTitles());
            req.setAttribute("qualifications",  staffDao.getQualifications());
            req.setAttribute("academicRanks",   staffDao.getAcademicRanks());
            req.setAttribute("genders",         staffDao.getGenders());
            req.setAttribute("nationalities",   staffDao.getNationalities());
            req.setAttribute("countries",       staffDao.getCountries());
            req.setAttribute("universities",    staffDao.getUniversities());
            req.getRequestDispatcher("/academician/nomination/submitNomination.jsp").forward(req, resp);
        } catch (Exception e) {
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
        String roleNameP = (String) session.getAttribute("role_name");
        if (!"Academician".equals(roleNameP) && !"Dean".equals(roleNameP)) {
            resp.sendRedirect(req.getContextPath() + "/admin/adminDashboard.jsp");
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        req.setCharacterEncoding("UTF-8");

        // Nomination Info
        String candidateIdStr = req.getParameter("candidate_id");
        String remarks         = req.getParameter("remarks");

        // Examiner Info
        String title          = req.getParameter("title");
        String fullName       = req.getParameter("full_name");
        String gender         = req.getParameter("gender");
        String nationality    = req.getParameter("nationality");
        String icPassport     = req.getParameter("ic_passport");
        String university     = req.getParameter("university");
        String faculty        = req.getParameter("faculty");
        String country        = req.getParameter("country");
        String specialization = req.getParameter("specialization");
        String specializationIdStr = req.getParameter("specialization_id");
        String expertiseIdStr      = req.getParameter("expertise_id");
        String divisionIdStr       = req.getParameter("division_id");
        String areaIdStr           = req.getParameter("area_id");
        String qualification  = req.getParameter("qualification");
        String position       = req.getParameter("position");
        String email          = req.getParameter("email");
        String phone          = req.getParameter("phone");

        if (fullName == null || fullName.trim().isEmpty()
                || university == null || university.trim().isEmpty()
                || email == null || email.trim().isEmpty()) {
            req.setAttribute("error", "Please fill in all required fields.");
            doGet(req, resp);
            return;
        }

        // Upload directory: use persistent external dir so files survive Tomcat redeployment
        String uploadPath = DownloadDocumentServlet.UPLOAD_BASE + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Upsert external_examiner — reuse existing record if same email already
            //    in DB (external_examiner.email has a UNIQUE constraint); otherwise insert.
            //    This prevents duplicate-key HTTP 500 and ensures the token is always
            //    saved against the correct examiner row.
            int examinerId;
            int specializationId = (specializationIdStr != null && !specializationIdStr.trim().isEmpty())
                    ? Integer.parseInt(specializationIdStr.trim()) : 0;
            int expertiseId = (expertiseIdStr != null && !expertiseIdStr.trim().isEmpty())
                    ? Integer.parseInt(expertiseIdStr.trim()) : 0;
            int divisionId = (divisionIdStr != null && !divisionIdStr.trim().isEmpty())
                    ? Integer.parseInt(divisionIdStr.trim()) : 0;
            int areaId = (areaIdStr != null && !areaIdStr.trim().isEmpty())
                    ? Integer.parseInt(areaIdStr.trim()) : 0;

            // Check for existing examiner with same email
            try (PreparedStatement chk = conn.prepareStatement(
                    "SELECT id FROM external_examiner WHERE email = ? LIMIT 1")) {
                chk.setString(1, email.trim());
                try (ResultSet rs = chk.executeQuery()) {
                    if (rs.next()) {
                        // Existing record — update details so nominator can correct info
                        examinerId = rs.getInt(1);
                        try (PreparedStatement upd = conn.prepareStatement(
                                "UPDATE external_examiner SET name=?, affiliation=?, phone=?, title=?, gender=?," +
                                " nationality=?, ic_passport=?, faculty=?, country=?, specialization=?," +
                                " specialization_id=?, expertise_id=?, division_id=?, area_id=?," +
                                " qualification=?, position=? WHERE id=?")) {
                            upd.setString(1, fullName.trim());
                            upd.setString(2, university.trim());
                            upd.setString(3, phone != null ? phone.trim() : null);
                            upd.setString(4, title);
                            upd.setString(5, gender);
                            upd.setString(6, nationality);
                            upd.setString(7, icPassport);
                            upd.setString(8, faculty);
                            upd.setString(9, country);
                            upd.setString(10, specialization);
                            if (specializationId > 0) upd.setInt(11, specializationId); else upd.setNull(11, java.sql.Types.INTEGER);
                            if (expertiseId   > 0) upd.setInt(12, expertiseId);   else upd.setNull(12, java.sql.Types.INTEGER);
                            if (divisionId    > 0) upd.setInt(13, divisionId);    else upd.setNull(13, java.sql.Types.INTEGER);
                            if (areaId        > 0) upd.setInt(14, areaId);        else upd.setNull(14, java.sql.Types.INTEGER);
                            upd.setString(15, qualification);
                            upd.setString(16, position);
                            upd.setInt(17, examinerId);
                            upd.executeUpdate();
                        }
                    } else {
                        // New examiner — insert and get generated id
                        try (PreparedStatement ins = conn.prepareStatement(
                                "INSERT INTO external_examiner (name, affiliation, email, phone, title, gender," +
                                " nationality, ic_passport, faculty, country, specialization," +
                                " specialization_id, expertise_id, division_id, area_id, qualification, position)" +
                                " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                                PreparedStatement.RETURN_GENERATED_KEYS)) {
                            ins.setString(1, fullName.trim());
                            ins.setString(2, university.trim());
                            ins.setString(3, email.trim());
                            ins.setString(4, phone != null ? phone.trim() : null);
                            ins.setString(5, title);
                            ins.setString(6, gender);
                            ins.setString(7, nationality);
                            ins.setString(8, icPassport);
                            ins.setString(9, faculty);
                            ins.setString(10, country);
                            ins.setString(11, specialization);
                            if (specializationId > 0) ins.setInt(12, specializationId); else ins.setNull(12, java.sql.Types.INTEGER);
                            if (expertiseId   > 0) ins.setInt(13, expertiseId);   else ins.setNull(13, java.sql.Types.INTEGER);
                            if (divisionId    > 0) ins.setInt(14, divisionId);    else ins.setNull(14, java.sql.Types.INTEGER);
                            if (areaId        > 0) ins.setInt(15, areaId);        else ins.setNull(15, java.sql.Types.INTEGER);
                            ins.setString(16, qualification);
                            ins.setString(17, position);
                            ins.executeUpdate();
                            try (ResultSet gen = ins.getGeneratedKeys()) {
                                gen.next();
                                examinerId = gen.getInt(1);
                            }
                        }
                    }
                }
            }

            // 2. Insert nomination
            int nominationId;
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO nomination (candidate_id, external_examiner_id, nominator_user_id, remarks, status) VALUES (?,?,?,?,'pending_examiner')",
                    PreparedStatement.RETURN_GENERATED_KEYS)) {
                if (candidateIdStr != null && !candidateIdStr.trim().isEmpty()) {
                    ps.setInt(1, Integer.parseInt(candidateIdStr.trim()));
                } else {
                    ps.setNull(1, java.sql.Types.INTEGER);
                }
                ps.setInt(2, examinerId);
                ps.setInt(3, userId);
                ps.setString(4, remarks);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    rs.next();
                    nominationId = rs.getInt(1);
                }
            }

            // 3. Save uploaded files
            saveFiles(req, conn, nominationId, userId, uploadPath, "cv_file",   "cv");
            saveFiles(req, conn, nominationId, userId, uploadPath, "qual_file",  "qualification");

            conn.commit();

            // Send verification email to examiner (non-blocking — failure is silent)
            try {
                String token = java.util.UUID.randomUUID().toString().replace("-", "");
                java.sql.Timestamp expires = new java.sql.Timestamp(
                        System.currentTimeMillis() + 7L * 24 * 60 * 60 * 1000); // 7 days
                NominationDAO nomDao = new NominationDAO();
                nomDao.saveVerificationToken(examinerId, token, expires);

                String baseUrl = req.getScheme() + "://" + req.getServerName()
                        + (req.getServerPort() == 80 || req.getServerPort() == 443
                            ? "" : ":" + req.getServerPort())
                        + req.getContextPath();
                String verifyLink = baseUrl + "/ExaminerVerifyServlet?token=" + token;

                String nominatorName = (String) req.getSession(false).getAttribute("full_name");
                if (nominatorName == null) nominatorName = "the nominator";

                String emailBody = buildVerificationEmail(fullName.trim(), nominatorName, verifyLink);
                EmailUtil.sendHtmlEmailAsync(email.trim(),
                        "Please Verify Your Examination Profile - E-Appointment FSKM", emailBody);
            } catch (Exception emailEx) {
                // Email failure must not roll back the nomination
                getServletContext().log("Verification email could not be sent: " + emailEx.getMessage());
            }

            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?success=1");

        } catch (Exception e) {
            if (conn != null) { try { conn.rollback(); } catch (SQLException ignored) {} }
            throw new ServletException(e);
        } finally {
            if (conn != null) { try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {} }
        }
    }

    private void saveFiles(HttpServletRequest req, Connection conn, int nominationId, int userId,
                           String uploadPath, String fieldName, String fileType)
            throws ServletException, IOException, SQLException {

        Collection<Part> parts = new ArrayList<>();
        try { parts = req.getParts(); } catch (Exception ignore) {}

        for (Part part : parts) {
            if (!fieldName.equals(part.getName())) continue;
            String submittedName = getFileName(part);
            if (submittedName == null || submittedName.isEmpty()) continue;

            // Sanitize filename and make unique
            String safeName = System.currentTimeMillis() + "_" + submittedName.replaceAll("[^a-zA-Z0-9._-]", "_");
            File dest = new File(uploadPath, safeName);
            try (java.io.InputStream is = part.getInputStream();
                 java.io.FileOutputStream fos = new java.io.FileOutputStream(dest)) {
                byte[] buf = new byte[8192]; int read;
                while ((read = is.read(buf)) != -1) fos.write(buf, 0, read);
            }

            String mimeType = part.getContentType() != null ? part.getContentType() : "application/octet-stream";

            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO document (nomination_id, uploaded_by, filename, filepath, file_type) VALUES (?,?,?,?,?)")) {
                ps.setInt(1, nominationId);
                ps.setInt(2, userId);
                ps.setString(3, submittedName);
                ps.setString(4, UPLOAD_DIR + "/" + safeName);
                ps.setString(5, fileType);
                ps.executeUpdate();
            }
        }
    }

    private String getFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) return null;
        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename")) {
                String raw = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                // Handle IE full-path submission
                return raw.contains("\\") ? raw.substring(raw.lastIndexOf('\\') + 1) : raw;
            }
        }
        return null;
    }

    private static String buildVerificationEmail(String examinerName, String nominatorName, String verifyLink) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head><body style='margin:0;padding:0;background:#f3f4f6;font-family:Inter,Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'><tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#105e60;padding:28px 36px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.4rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:6px 0 0;color:#a7f3d0;font-size:0.92rem;'>Faculty of Computer and Mathematical Sciences</p>"
             + "</td></tr>"
             + "<tr><td style='padding:32px 36px;'>"
             + "<p style='font-size:1rem;color:#374151;margin-top:0;'>Dear <strong>" + escapeHtml(examinerName) + "</strong>,</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "You have been nominated as an examiner for a postgraduate thesis viva examination at UMT by "
             + "<strong>" + escapeHtml(nominatorName) + "</strong>.</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Please review the information we have on file for you and confirm that it is accurate by clicking the button below.</p>"
             + "<div style='text-align:center;margin:32px 0;'>"
             + "<a href='" + verifyLink + "' style='background:#0f766e;color:#fff;text-decoration:none;"
             + "padding:14px 36px;border-radius:10px;font-size:1rem;font-weight:600;display:inline-block;'>"
             + "Review &amp; Confirm My Information</a></div>"
             + "<p style='font-size:0.85rem;color:#6b7280;'>This link will expire in <strong>7 days</strong>. "
             + "If the button above does not work, copy and paste this URL into your browser:</p>"
             + "<p style='font-size:0.82rem;color:#0f766e;word-break:break-all;'>" + verifyLink + "</p>"
             + "<hr style='border:none;border-top:1px solid #f3f4f6;margin:24px 0;'>"
             + "<p style='font-size:0.8rem;color:#9ca3af;margin:0;'>This email was sent automatically by the E-Appointment FSKM system. "
             + "If you were not expecting this, please disregard it.</p>"
             + "</td></tr></table>"
             + "</td></tr></table></body></html>";
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
