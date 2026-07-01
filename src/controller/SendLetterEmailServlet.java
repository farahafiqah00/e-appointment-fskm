package controller;

import dao.AppointmentDAO;
import model.VivaAppointment;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.Map;

/**
 * Admin-only: sends the appointment letter email to a specific panel member.
 * Generates a secure response token for external examiners; internal members get a login-redirect link.
 * Requires letter approval to be signed before sending.
 */
@WebServlet("/admin/appointment/letter/send")
public class SendLetterEmailServlet extends HttpServlet {

    private final AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String roleName = session != null ? String.valueOf(session.getAttribute("role_name")) : "";
        if ("Dean".equals(roleName) || "Academician".equals(roleName) || "".equals(roleName) || "null".equals(roleName)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String sPanelId = req.getParameter("panel_id");
        String sApptId  = req.getParameter("appointment_id");
        if (sPanelId == null || sApptId == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
            return;
        }
        try {
            int panelId = Integer.parseInt(sPanelId);
            int apptId  = Integer.parseInt(sApptId);

            VivaAppointment va = dao.findById(apptId);
            if (va == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/appointments");
                return;
            }

            // New workflow: panel emails can only be sent after signer approval is completed.
            if (!dao.isLetterApprovalSigned(apptId)) {
                resp.sendRedirect(req.getContextPath() + "/admin/appointment/letter/preview?id=" + apptId
                        + "&approvalError=" + URLEncoder.encode("Letter must be approved and signed before sending emails.", "UTF-8"));
                return;
            }

            // Find the specific panel member by panel_id
            Map<String,Object> target = null;
            for (Map<String,Object> m : va.getPanelMembers()) {
                if (m.get("panel_id") != null && ((Number) m.get("panel_id")).intValue() == panelId) {
                    target = m;
                    break;
                }
            }

            String redirectMsg = null;
            String redirectErr = null;

            if (target != null) {
                String email = (String) target.get("email");
                String name  = (String) target.get("name");
                String role  = (String) target.get("role");
                boolean alreadySent = Boolean.TRUE.equals(target.get("letter_sent"));

                if (email == null || email.trim().isEmpty()) {
                    redirectErr = "Cannot send email: " + (name != null ? name : "this panel member") +
                                  " has no email address on record.";
                } else {
                    // Fetch signer info for dynamic letter footer
                    Map<String,Object> approval = dao.getLetterApprovalByAppointmentId(apptId);

                    String prefix  = alreadySent ? "[REVISED] " : "";
                    String subject = prefix + "Viva Voce Appointment Letter - " + role + " | " +
                                     (va.getCandidateName() != null ? va.getCandidateName() : "Candidate");

                    String responseLink = null;
                    String baseUrl = req.getScheme() + "://" + req.getServerName()
                        + (req.getServerPort() == 80 || req.getServerPort() == 443 ? "" : ":" + req.getServerPort())
                        + req.getContextPath();
                    if ("External Examiner".equals(role)) {
                        try {
                            String token = dao.generateAndSaveExternalResponseToken(panelId);
                            responseLink = baseUrl + "/PanelResponseServlet?token=" + token;
                        } catch (Exception tokenEx) {
                            getServletContext().log("Could not generate response token for panel " + panelId + ": " + tokenEx.getMessage());
                        }
                    } else {
                        String returnPath = req.getContextPath() + "/panel/member/preview?appointment_id=" + apptId + "&panel_id=" + panelId;
                        responseLink = baseUrl + "/login.jsp?returnUrl=" + URLEncoder.encode(returnPath, "UTF-8");
                    }

                    // Find the signature image file (for CID inline attachment)
                    File sigFile = null;
                    if (approval != null && approval.get("signature_image") != null) {
                        String sigFn = approval.get("signature_image").toString().trim();
                        if (!sigFn.isEmpty()) {
                            File f = new File(getServletContext().getRealPath("/uploads/signatures"), sigFn);
                            if (f.exists()) sigFile = f;
                        }
                    }

                    EmailUtil.sendHtmlEmailAsync(email, subject, buildBody(va, name, role, alreadySent, approval, responseLink, sigFile != null), sigFile);
                    dao.markLetterSent(panelId);
                    redirectMsg = "Email sent to " + (name != null ? name : role) + " (" + email.trim() + ").";
                }
            } else {
                redirectErr = "Panel member not found.";
            }

            String base = req.getContextPath() + "/admin/appointment/letter/preview?id=" + apptId;
            if (redirectErr != null) {
                resp.sendRedirect(base + "&approvalError=" + URLEncoder.encode(redirectErr, "UTF-8"));
            } else if (redirectMsg != null) {
                resp.sendRedirect(base + "&approvalMsg=" + URLEncoder.encode(redirectMsg, "UTF-8"));
            } else {
                resp.sendRedirect(base);
            }
        } catch (NumberFormatException | SQLException e) {
            throw new ServletException(e);
        }
    }

    private String buildBody(VivaAppointment va, String recipientName, String role, boolean isRevised, Map<String,Object> approval, String responseLink, boolean hasSignature) {
        String today    = new java.text.SimpleDateFormat("dd MMMM yyyy").format(new java.util.Date());
        String vivaDate = va.getScheduledAt() != null
            ? new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(va.getScheduledAt()) : "—";
        String revisedNote = isRevised
            ? "<div style='background:#fef3c7;border:1px solid #fbbf24;border-radius:6px;"
            + "padding:10px 16px;margin-bottom:20px;font-size:14px;color:#92400e;'>"
            + "<strong>Note:</strong> This is a revised appointment letter. Please disregard any previous version.</div>"
            : "";

        // Dynamic signer block
        String signerName  = "DEAN";
        String signerRole  = "Dean";
        String signerEmail = "fskm@umt.edu.my";
        String signerDate  = "";
        if (approval != null) {
            String acTitle = approval.get("signer_academic_title") != null ? approval.get("signer_academic_title").toString().trim() : "";
            String sName   = approval.get("signer_name")           != null ? approval.get("signer_name").toString().trim()           : "";
            String sLabel  = approval.get("signer_label")          != null ? approval.get("signer_label").toString().trim()          : "";
            String sEmail  = approval.get("signer_email")          != null ? approval.get("signer_email").toString().trim()          : "";
            if (!sName.isEmpty()) {
                signerName = (acTitle.isEmpty() ? "" : acTitle.toUpperCase() + " ") + sName.toUpperCase();
            }
            if (!sEmail.isEmpty()) signerEmail = sEmail;
            if ("Dean".equalsIgnoreCase(sLabel)) {
                signerRole = "Dean";
            } else if ("TDA".equalsIgnoreCase(sLabel)) {
                signerRole = "Deputy Dean (Academic and Student Affairs)";
            } else if ("TDB".equalsIgnoreCase(sLabel)) {
                signerRole = "Deputy Dean (Research and Innovation)";
            } else if (!sLabel.isEmpty()) {
                signerRole = sLabel;
            }
            if (approval.get("signed_at") != null) {
                signerDate = new java.text.SimpleDateFormat("dd MMMM yyyy").format(approval.get("signed_at"));
            }
        }

        String sigImgHtml = hasSignature
            ? "<img src='cid:signature' alt='Signature' style='max-height:70px;max-width:200px;display:block;margin-bottom:4px;'>"
            : "<div style='border-top:1px solid #111;width:200px;margin-bottom:4px;padding-top:4px;'>&nbsp;</div>";

        return "<!doctype html><html><body style='font-family:\"Times New Roman\",Times,serif;"
             + "font-size:16px;line-height:1.8;color:#111;max-width:700px;margin:0 auto;padding:40px;'>"
             + "<div style='text-align:center;margin-bottom:24px;'>"
             + "<strong style='font-size:18px;'>UNIVERSITI MALAYSIA TERENGGANU</strong><br>"
             + "FAKULTI SAINS KOMPUTER DAN MATEMATIK<br>"
             + "<small style='color:#555;'>21030 Kuala Nerus, Terengganu Darul Iman</small>"
             + "<hr style='margin:16px 0;'></div>"
             + revisedNote
             + "<p>Date: " + esc(today) + "</p>"
             + "<h2 style='text-align:center;font-size:18px;font-weight:bold;'>"
             + "LETTER OF APPOINTMENT &mdash; " + esc(role.toUpperCase()) + "</h2>"
             + "<p>Dear " + esc(recipientName) + ",</p>"
             + "<p>We are pleased to appoint you as <strong>" + esc(role) + "</strong> "
             + "for the viva voce examination of the following candidate:</p>"
             + "<table style='width:100%;border-collapse:collapse;margin-bottom:24px;'>"
             + "<tr><td style='width:42%;padding:4px 0;font-weight:bold;'>Candidate Name</td>"
             + "<td>: " + esc(va.getCandidateName()) + "</td></tr>"
             + "<tr><td style='padding:4px 0;font-weight:bold;'>Matric Number</td>"
             + "<td>: " + esc(va.getCandidateStudentId()) + "</td></tr>"
             + "<tr><td style='padding:4px 0;font-weight:bold;'>Programme</td>"
             + "<td>: " + esc(va.getCandidateProgram()) + "</td></tr>"
             + (va.getThesisTitle() != null && !va.getThesisTitle().trim().isEmpty()
                ? "<tr><td style='padding:4px 0;font-weight:bold;'>Thesis Title</td><td>: "
                + esc(va.getThesisTitle()) + "</td></tr>" : "")
             + "<tr><td style='padding:4px 0;font-weight:bold;'>Supervisor</td>"
             + "<td>: " + esc(va.getSupervisorName()) + "</td></tr>"
             + "<tr><td style='padding:4px 0;font-weight:bold;'>Viva Date &amp; Time</td>"
             + "<td>: " + esc(vivaDate) + "</td></tr>"
             + "<tr><td style='padding:4px 0;font-weight:bold;'>Venue</td>"
             + "<td>: " + esc(va.getVenue()) + "</td></tr>"
             + "</table>"
             + (responseLink != null
                ? "<p>Please confirm your acceptance or decline this appointment by clicking the button below. "
                + "Your response is required within <strong>seven (7) working days</strong>.</p>"
                + "<div style='margin:24px 0;'>"
                + "<a href='" + esc(responseLink) + "' style='display:inline-block;background:#0f766e;color:#fff;"
                + "font-weight:700;font-size:15px;padding:12px 28px;border-radius:8px;text-decoration:none;"
                + "font-family:Arial,sans-serif;'>Respond to Appointment &rarr;</a></div>"
                + "<p style='font-size:13px;color:#6b7280;'>This link is personal and unique to you. "
                + "Please do not forward it to others.</p>"
                : "<p>Please confirm your acceptance of this appointment within "
                + "<strong>seven (7) working days</strong>.</p>")
             + "<p>We look forward to your kind participation.</p>"
             + "<p>Thank you.</p>"
             + "<div style='margin-top:48px;'><p>Yours sincerely,</p><br>"
             + sigImgHtml
             + "<strong>" + esc(signerName) + "</strong><br>"
             + esc(signerRole) + "<br>"
             + (!signerDate.isEmpty() ? esc(signerDate) + "<br>" : "")
             + "Faculty of Computer and Mathematical Sciences<br>"
             + "Universiti Malaysia Terengganu<br>"
             + "<a href='mailto:" + esc(signerEmail) + "'>" + esc(signerEmail) + "</a>"
             + "</div></body></html>";
    }

    private String esc(String s) {
        if (s == null) return "&mdash;";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
