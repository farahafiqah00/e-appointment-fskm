package controller;

import dao.AcademicStaffDAO;
import dao.NominationDAO;
import model.Nomination;
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
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;
import util.DBConnection;

/**
 * Lets the nominator correct and resubmit a nomination (allowed when status is
 * 'pending_examiner', 'submitted', or 'needs_correction'). On save, a fresh
 * verification email is automatically sent to the examiner with the updated profile.
 */
@WebServlet(name = "EditNominationServlet", urlPatterns = {"/EditNominationServlet"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024) // 10 MB per file, 50 MB total
public class EditNominationServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads/nominations";

    /** GET — load the edit form pre-filled with existing nomination/examiner data. */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isAuthorised(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet");
            return;
        }

        try {
            int nominationId = Integer.parseInt(idStr.trim());
            NominationDAO dao = new NominationDAO();
            Nomination nom = dao.findById(nominationId);

            if (nom == null) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?error=notfound");
                return;
            }
            // Security: only the nominator may edit
            if (nom.getNominatorUserId() != userId) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?error=forbidden");
                return;
            }
            // Allow edit only when awaiting examiner, examiner confirmed but admin not yet acted, or flagged for correction
            boolean editAllowed = "pending_examiner".equals(nom.getStatus())
                    || "submitted".equals(nom.getStatus())
                    || "needs_correction".equals(nom.getStatus());
            if (!editAllowed) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?error=noteditable");
                return;
            }

            // Load all examiner fields for pre-filling the form
            Map<String,Object> examiner = null;
            if (nom.getExternalExaminerId() != null) {
                examiner = loadFullExaminer(nom.getExternalExaminerId());
            }

            // Load existing documents so the JSP can show what is already uploaded
            java.util.List<model.Document> existingDocs = dao.getDocumentsForNomination(nominationId);

            // Load hierarchy dropdowns
            AcademicStaffDAO staffDao = new AcademicStaffDAO();
            req.setAttribute("nomination",      nom);
            req.setAttribute("examiner",        examiner);
            req.setAttribute("existingDocs",    existingDocs);
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

            req.getRequestDispatcher("/academician/nomination/editNomination.jsp")
               .forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    /** POST — save the updated examiner data and resubmit the nomination. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isAuthorised(session)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        req.setCharacterEncoding("UTF-8");

        String nomIdStr = req.getParameter("nomination_id");
        if (nomIdStr == null || nomIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet");
            return;
        }

        try {
            int nominationId = Integer.parseInt(nomIdStr.trim());
            NominationDAO dao = new NominationDAO();
            Nomination nom = dao.findById(nominationId);

            if (nom == null || nom.getNominatorUserId() != userId) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?error=forbidden");
                return;
            }
            boolean editAllowed = "pending_examiner".equals(nom.getStatus())
                    || "submitted".equals(nom.getStatus())
                    || "needs_correction".equals(nom.getStatus());
            if (!editAllowed) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?error=forbidden");
                return;
            }

            // Admin correction: needs_correction set by admin (no examiner discrepancy_notes).
            // Examiner already confirmed their info — skip re-verification, go directly to submitted.
            boolean isAdminCorrection = "needs_correction".equals(nom.getStatus())
                    && (nom.getDiscrepancyNotes() == null || nom.getDiscrepancyNotes().isEmpty());

            // Read form fields
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
                req.setAttribute("error", "Please fill in all required fields (Name, University, Email).");
                doGet(req, resp);
                return;
            }

            Integer specId = parseIntOrNull(specializationIdStr);
            Integer expId  = parseIntOrNull(expertiseIdStr);
            Integer divId  = parseIntOrNull(divisionIdStr);
            Integer arId   = parseIntOrNull(areaIdStr);

            if (isAdminCorrection) {
                dao.updateNominationForAdminCorrection(
                    nominationId, nom.getExternalExaminerId(),
                    fullName.trim(), university.trim(), email.trim(),
                    phone != null ? phone.trim() : null,
                    title, gender, nationality, icPassport,
                    faculty, country, specialization,
                    specId, expId, divId, arId,
                    qualification, position
                );
            } else {
                dao.updateNominationAfterCorrection(
                    nominationId, nom.getExternalExaminerId(),
                    fullName.trim(), university.trim(), email.trim(),
                    phone != null ? phone.trim() : null,
                    title, gender, nationality, icPassport,
                    faculty, country, specialization,
                    specId, expId, divId, arId,
                    qualification, position
                );
            }

            // Optionally append new documents (files are not required on edit)
            String uploadPath = DownloadDocumentServlet.UPLOAD_BASE + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            // Delete documents marked for deletion by the user
            String[] deleteDocIds = req.getParameterValues("delete_doc_id");
            if (deleteDocIds != null) {
                for (String idStr : deleteDocIds) {
                    try {
                        int docId = Integer.parseInt(idStr.trim());
                        String relPath = dao.deleteDocumentById(docId, nominationId);
                        if (relPath != null) {
                            String rel = relPath.replace("/", java.io.File.separator);
                            java.io.File f = new java.io.File(DownloadDocumentServlet.UPLOAD_BASE, rel);
                            if (!f.exists()) f = new java.io.File(getServletContext().getRealPath(""), rel);
                            if (f.exists()) f.delete();
                        }
                    } catch (NumberFormatException ignored) {}
                }
            }

            try (Connection conn = DBConnection.getConnection()) {
                saveFiles(req, conn, nominationId, userId, uploadPath, "cv_file",   "cv");
                saveFiles(req, conn, nominationId, userId, uploadPath, "qual_file", "qualification");
            }

            // Notify admins when nominator resubmits after an admin correction (status → submitted directly).
            if (isAdminCorrection) try {
                java.util.Map<String,Object> examInfo = dao.getExaminerInfoByNominationId(nominationId);
                String examinerDisplayName = examInfo != null
                        ? ((examInfo.get("title") != null && !((String)examInfo.get("title")).isEmpty()
                              ? examInfo.get("title") + " " : "") + examInfo.get("name"))
                        : "the examiner";
                String nominatorDisplayName = (String) session.getAttribute("full_name");
                if (nominatorDisplayName == null) nominatorDisplayName = "The nominator";
                for (java.util.Map<String,String> admin : dao.getAdminEmails()) {
                    if (admin.get("email") != null) {
                        EmailUtil.sendHtmlEmailAsync(
                            admin.get("email"),
                            "Nomination Resubmitted – " + examinerDisplayName,
                            buildAdminResubmitEmail(admin.get("fullName"), examinerDisplayName, nominatorDisplayName)
                        );
                    }
                }
            } catch (Exception mailEx) {
                getServletContext().log("EditNominationServlet: admin resubmit notification failed: " + mailEx.getMessage());
            }

            // Auto-send a fresh verification email only for examiner-correction path.
            // For admin corrections the examiner already confirmed — no re-verification needed.
            if (!isAdminCorrection) try {
                java.util.Map<String,Object> examInfo = dao.getExaminerInfoByNominationId(nominationId);
                if (examInfo != null && examInfo.get("email") != null) {
                    int examinerId = (int) examInfo.get("id");
                    String examinerEmail = (String) examInfo.get("email");
                    String examinerName  = (String) examInfo.get("name");
                    String nominatorName = (String) session.getAttribute("full_name");
                    if (nominatorName == null) nominatorName = "Your Nominator";

                    // Generate a fresh token (7-day expiry)
                    String rawToken = java.util.UUID.randomUUID().toString().replace("-", "");
                    java.sql.Timestamp expiry = new java.sql.Timestamp(
                            System.currentTimeMillis() + 7L * 24 * 60 * 60 * 1000);
                    dao.saveVerificationToken(examinerId, rawToken, expiry);

                    String verifyLink = req.getScheme() + "://" + req.getServerName()
                            + ":" + req.getServerPort()
                            + req.getContextPath() + "/ExaminerVerifyServlet?token=" + rawToken;

                    String subject = "Updated: Please Verify Your Examiner Profile";
                    String body = buildVerificationEmail(examinerName, nominatorName, verifyLink);
                    EmailUtil.sendHtmlEmailAsync(examinerEmail, subject, body);
                }
            } catch (Exception mailEx) {
                getServletContext().log("EditNominationServlet: verification email failed: " + mailEx.getMessage());
            }

            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?resubmit=1");

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private boolean isAuthorised(HttpSession session) {
        if (session == null || session.getAttribute("user_id") == null) return false;
        String role = (String) session.getAttribute("role_name");
        return "Academician".equals(role) || "Dean".equals(role);
    }

    private static String buildAdminResubmitEmail(String adminName, String examinerName, String nominatorName) {
        String safeAdmin    = escapeHtml(adminName);
        String safeExaminer = escapeHtml(examinerName);
        String safeNom      = escapeHtml(nominatorName);
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
             + "<body style='margin:0;padding:0;background:#f3f4f6;font-family:Inter,Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'><tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#1e3a5f;padding:28px 36px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.4rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:6px 0 0;color:#93c5fd;font-size:0.92rem;'>Nomination Resubmitted for Review</p>"
             + "</td></tr>"
             + "<tr><td style='padding:32px 36px;'>"
             + "<p style='font-size:1rem;color:#374151;margin-top:0;'>Dear <strong>" + safeAdmin + "</strong>,</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "<strong>" + safeNom + "</strong> has corrected and resubmitted the nomination for "
             + "<strong>" + safeExaminer + "</strong>. The nomination is now ready for your review.</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "Please log in to the E-Appointment system and go to <strong>Examiner Nominations</strong> to review this submission.</p>"
             + "<hr style='border:none;border-top:1px solid #f3f4f6;margin:24px 0;'>"
             + "<p style='font-size:0.8rem;color:#9ca3af;margin:0;'>This is an automated notification from the E-Appointment FSKM system.</p>"
             + "</td></tr></table></td></tr></table></body></html>";
    }

    private static String buildVerificationEmail(String examinerName, String nominatorName, String verifyLink) {
        String safeName  = escapeHtml(examinerName);
        String safeNom   = escapeHtml(nominatorName);
        String safeLink  = escapeHtml(verifyLink);
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>"
             + "<body style='margin:0;padding:0;background:#f3f4f6;font-family:Inter,Arial,sans-serif;'>"
             + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f3f4f6;padding:32px 0;'><tr><td align='center'>"
             + "<table width='600' cellpadding='0' cellspacing='0' style='background:#fff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;'>"
             + "<tr><td style='background:#1e3a5f;padding:28px 36px;'>"
             + "<h1 style='margin:0;color:#fff;font-size:1.4rem;font-weight:700;'>E-Appointment FSKM</h1>"
             + "<p style='margin:6px 0 0;color:#93c5fd;font-size:0.92rem;'>Updated Examiner Profile Verification</p>"
             + "</td></tr>"
             + "<tr><td style='padding:32px 36px;'>"
             + "<p style='font-size:1rem;color:#374151;margin-top:0;'>Dear <strong>" + safeName + "</strong>,</p>"
             + "<p style='font-size:0.95rem;color:#374151;line-height:1.6;'>"
             + "<strong>" + safeNom + "</strong> has updated your examiner profile and requests that you review and confirm your information.</p>"
             + "<div style='margin:24px 0;text-align:center;'>"
             + "<a href='" + safeLink + "' style='display:inline-block;background:#1e3a5f;color:#fff;text-decoration:none;"
             + "padding:14px 32px;border-radius:10px;font-weight:700;font-size:1rem;'>Review &amp; Confirm My Info</a></div>"
             + "<p style='font-size:0.85rem;color:#6b7280;line-height:1.6;'>Or copy this link: <a href='" + safeLink + "' style='color:#1e3a5f;'>" + safeLink + "</a></p>"
             + "<p style='font-size:0.8rem;color:#9ca3af;margin:0;'>This link expires in 7 days.</p>"
             + "</td></tr></table></td></tr></table></body></html>";
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    private Integer parseIntOrNull(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    /** Loads ALL columns of external_examiner (including text fields) for the pre-fill form. */
    private Map<String,Object> loadFullExaminer(int examinerId) throws SQLException {
        String sql =
            "SELECT ee.id, ee.name, ee.affiliation, ee.email, ee.phone, " +
            "ee.title, ee.gender, ee.nationality, ee.ic_passport, ee.faculty, ee.country, " +
            "ee.specialization, ee.specialization_id, ee.expertise_id, ee.division_id, ee.area_id, " +
            "ee.qualification, ee.position " +
            "FROM external_examiner ee WHERE ee.id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, examinerId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",                rs.getInt("id"));
                    m.put("name",              rs.getString("name"));
                    m.put("affiliation",       rs.getString("affiliation"));
                    m.put("email",             rs.getString("email"));
                    m.put("phone",             rs.getString("phone"));
                    m.put("title",             rs.getString("title"));
                    m.put("gender",            rs.getString("gender"));
                    m.put("nationality",       rs.getString("nationality"));
                    m.put("ic_passport",       rs.getString("ic_passport"));
                    m.put("faculty",           rs.getString("faculty"));
                    m.put("country",           rs.getString("country"));
                    m.put("specialization",    rs.getString("specialization"));
                    m.put("specialization_id", rs.getObject("specialization_id"));
                    m.put("expertise_id",      rs.getObject("expertise_id"));
                    m.put("division_id",       rs.getObject("division_id"));
                    m.put("area_id",           rs.getObject("area_id"));
                    m.put("qualification",     rs.getString("qualification"));
                    m.put("position",          rs.getString("position"));
                    return m;
                }
            }
        }
        return null;
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
            String safeName = System.currentTimeMillis() + "_" + submittedName.replaceAll("[^a-zA-Z0-9._-]", "_");
            File dest = new File(uploadPath, safeName);
            try (java.io.InputStream is = part.getInputStream();
                 java.io.FileOutputStream fos = new java.io.FileOutputStream(dest)) {
                byte[] buf = new byte[8192]; int read;
                while ((read = is.read(buf)) != -1) fos.write(buf, 0, read);
            }
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
                return raw.contains("\\") ? raw.substring(raw.lastIndexOf('\\') + 1) : raw;
            }
        }
        return null;
    }
}
