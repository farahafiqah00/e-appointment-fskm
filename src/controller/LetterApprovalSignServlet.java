package controller;

import dao.AppointmentDAO;
import model.VivaAppointment;
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
import java.net.URLEncoder;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.UUID;

/** Dean/TDA/TDB endpoint to digitally sign a letter approval, optionally uploading a signature image. */
@MultipartConfig(maxFileSize = 3 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024) // 3 MB per signature image
@WebServlet("/appointment/letter/approval/sign")
public class LetterApprovalSignServlet extends HttpServlet {

    private final AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        Object userIdObj = session != null ? session.getAttribute("user_id") : null;

        String sApptId = req.getParameter("appointment_id");
        if (userIdObj == null || sApptId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int appointmentId = Integer.parseInt(sApptId);
            int actorUserId = ((Number) userIdObj).intValue();
            String actorName = session.getAttribute("full_name") != null
                    ? String.valueOf(session.getAttribute("full_name")) : "Assigned signer";

            // Handle optional signature image upload
            String signatureImageFilename = null;
            Part signaturePart = req.getPart("signature_image");
            if (signaturePart != null && signaturePart.getSize() > 0) {
                String submitted = signaturePart.getSubmittedFileName();
                if (submitted != null && !submitted.trim().isEmpty()) {
                    String original = Paths.get(submitted).getFileName().toString();
                    String ext = original.contains(".") ? original.substring(original.lastIndexOf('.')) : ".png";
                    signatureImageFilename = UUID.randomUUID().toString() + ext;
                    String uploadDir = req.getServletContext().getRealPath("/uploads/signatures");
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();
                    signaturePart.write(uploadDir + File.separator + signatureImageFilename);
                    // Persist new signature to user profile — only for Dean/TDA/TDB signers
                    String actorRole = session.getAttribute("role_name") != null ? String.valueOf(session.getAttribute("role_name")) : "";
                    if ("Dean".equals(actorRole)) {
                        dao.saveUserSignatureImage(actorUserId, signatureImageFilename);
                    }
                }
            }
            // Fall back to the user's previously stored signature if no new file was uploaded (Dean/TDA/TDB only)
            if (signatureImageFilename == null) {
                String actorRole2 = session.getAttribute("role_name") != null ? String.valueOf(session.getAttribute("role_name")) : "";
                if ("Dean".equals(actorRole2)) {
                    signatureImageFilename = dao.getUserSignatureImage(actorUserId);
                }
            }

            boolean ok = dao.markLetterApprovalSigned(appointmentId, actorUserId, signatureImageFilename);
            if (!ok) {
                resp.sendRedirect(req.getContextPath() + "/appointment/letter/review?id=" + appointmentId
                        + "&approvalError=" + URLEncoder.encode("You are not the assigned signer or approval is already completed.", "UTF-8"));
                return;
            }

            // Notify active admins that this appointment is now approved for panel email sending.
            VivaAppointment va = dao.findById(appointmentId);
            if (va != null) {
                String reviewUrl = req.getScheme() + "://" + req.getServerName()
                        + ((req.getServerPort() == 80 || req.getServerPort() == 443) ? "" : ":" + req.getServerPort())
                        + req.getContextPath() + "/admin/appointment/letter/preview?id=" + appointmentId;

                String subject = "Letter Approved: Panel emails can now be sent";
                String body = buildApprovalCompletedBody(actorName, va, reviewUrl);
                for (java.util.Map<String,Object> admin : dao.getActiveAdminRecipients()) {
                    Object em = admin.get("email");
                    if (em != null && !String.valueOf(em).trim().isEmpty()) {
                        EmailUtil.sendHtmlEmailAsync(String.valueOf(em), subject, body);
                    }
                }
            }

            resp.sendRedirect(req.getContextPath() + "/appointment/letter/review?id=" + appointmentId
                    + "&approvalMsg=" + URLEncoder.encode("Letter approval signed successfully.", "UTF-8"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/dean/deanDashboard");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private String buildApprovalCompletedBody(String signerName, VivaAppointment va, String adminUrl) {
        String candidate = va.getCandidateName() != null ? va.getCandidateName() : "Candidate";
        String studentId = va.getCandidateStudentId() != null ? va.getCandidateStudentId() : "-";
        String programme = va.getCandidateProgram() != null ? va.getCandidateProgram() : "-";
        String signedAt = new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(new java.util.Date());

        return "<!doctype html><html><body style='font-family:Arial,sans-serif;color:#111;line-height:1.6;'>"
                + "<p>Dear Admin,</p>"
                + "<p>The assigned signer has approved the appointment letter. You may now send panel member emails.</p>"
                + "<table style='border-collapse:collapse;margin:12px 0 18px 0;'>"
                + "<tr><td style='padding:4px 8px 4px 0;font-weight:bold;'>Candidate</td><td>: " + esc(candidate) + "</td></tr>"
                + "<tr><td style='padding:4px 8px 4px 0;font-weight:bold;'>Student ID</td><td>: " + esc(studentId) + "</td></tr>"
                + "<tr><td style='padding:4px 8px 4px 0;font-weight:bold;'>Programme</td><td>: " + esc(programme) + "</td></tr>"
                + "<tr><td style='padding:4px 8px 4px 0;font-weight:bold;'>Signed by</td><td>: " + esc(signerName) + "</td></tr>"
                + "<tr><td style='padding:4px 8px 4px 0;font-weight:bold;'>Signed at</td><td>: " + esc(signedAt) + "</td></tr>"
                + "</table>"
                + "<p><a href='" + esc(adminUrl) + "' style='background:#2563eb;color:#fff;padding:10px 16px;text-decoration:none;border-radius:6px;display:inline-block;'>"
                + "Open Letter Preview (Admin)</a></p>"
                + "</body></html>";
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
