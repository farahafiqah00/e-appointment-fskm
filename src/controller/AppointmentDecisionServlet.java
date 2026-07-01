package controller;

import dao.AppointmentDAO;
import model.VivaAppointment;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** Handles the appointment panel assignment form: GET loads the decision page; POST saves the panel, date, and venue. */
@WebServlet("/admin/appointment/decision")
public class AppointmentDecisionServlet extends HttpServlet {

    private AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String sid = req.getParameter("id");
        if (sid == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
            return;
        }
        try {
            int id = Integer.parseInt(sid);
            VivaAppointment va = dao.findById(id);
            if (va == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/appointments");
                return;
            }
            List<Map<String,Object>> internalStaff = dao.getInternalStaff();
            List<Map<String,Object>> verifiedExaminers = dao.getVerifiedExaminers();
            List<Map<String,Object>> roleStats = dao.getPanelRoleStats();
            List<Map<String,Object>> venues = dao.getVenues();
            req.setAttribute("appointment", va);
            req.setAttribute("internalStaff", internalStaff);
            req.setAttribute("verifiedExaminers", verifiedExaminers);
            req.setAttribute("roleStats", roleStats);
            req.setAttribute("venues", venues);
            // Pass back conflict/validation errors from redirect
            String conflictError = req.getParameter("conflictError");
            if (conflictError != null && !conflictError.isEmpty()) {
                req.setAttribute("conflictError", java.net.URLDecoder.decode(conflictError, "UTF-8"));
            }
            String validationError = req.getParameter("validationError");
            if (validationError != null && !validationError.isEmpty()) {
                req.setAttribute("validationError", java.net.URLDecoder.decode(validationError, "UTF-8"));
            }
            String listUrl = req.getParameter("listUrl");
            if (listUrl != null && !listUrl.isEmpty()) {
                req.setAttribute("listUrl", listUrl);
            }
            String roleNav = (String) req.getSession().getAttribute("role_name");
            String view = "Dean".equals(roleNav)
                    ? "/dean/viva/vivaAppointmentView.jsp"
                    : "/admin/appointment/appointmentDecision.jsp";
            req.getRequestDispatcher(view).forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String sid = req.getParameter("id");
        String decision = req.getParameter("decision");
        if (sid == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
            return;
        }
        try {
            int appointmentId = Integer.parseInt(sid);
            Integer chairId   = parseNullableInt(req.getParameter("chairperson_id"));
            Integer recorderId = parseNullableInt(req.getParameter("recorder_id"));

            // Collect multiple internal examiner IDs (internal_examiner_id[])
            List<Integer> internalIds  = parseIntArray(req.getParameterValues("internal_examiner_id"));
            // Collect multiple external examiner IDs (external_examiner_id[])
            List<Integer> externalIds  = parseIntArray(req.getParameterValues("external_examiner_id"));

            // Date/venue
            Timestamp scheduledAt = null;
            String scheduledAtStr = req.getParameter("scheduled_at");
            if (scheduledAtStr != null && !scheduledAtStr.trim().isEmpty()) {
                try {
                    LocalDateTime ldt = LocalDateTime.parse(scheduledAtStr.trim(),
                            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
                    scheduledAt = Timestamp.valueOf(ldt);
                } catch (Exception ignore) {}
            }
            String venue = req.getParameter("venue");
            int duration = 90;
            try {
                String durStr = req.getParameter("duration_minutes");
                if (durStr != null && !durStr.trim().isEmpty()) duration = Integer.parseInt(durStr.trim());
            } catch (NumberFormatException ignore) {}

            String listUrl = req.getParameter("listUrl");
            String listUrlParam = (listUrl != null && !listUrl.isEmpty())
                ? "&listUrl=" + java.net.URLEncoder.encode(listUrl, "UTF-8") : "";

            // Check venue/time conflict before saving
            if (scheduledAt != null && venue != null && !venue.trim().isEmpty() && !"defer".equals(decision)) {
                String conflict = dao.findVenueConflict(venue, scheduledAt, duration, appointmentId);
                if (conflict != null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/appointment/decision?id=" + appointmentId
                        + "&conflictError=" + java.net.URLEncoder.encode(conflict, "UTF-8") + listUrlParam);
                    return;
                }
            }

            String status;
            if ("defer".equals(decision)) {
                status = "deferred";
            } else {
                boolean hasChair    = chairId != null;
                boolean hasRecorder = recorderId != null;
                boolean hasDate     = scheduledAt != null;
                boolean hasVenue    = venue != null && !venue.trim().isEmpty();
                boolean hasPanel    = hasChair || hasRecorder || !internalIds.isEmpty() || !externalIds.isEmpty();

                if (!hasPanel && !hasDate && !hasVenue) {
                    resp.sendRedirect(req.getContextPath() + "/admin/appointment/decision?id=" + appointmentId
                        + "&validationError=" + URLEncoder.encode(
                            "Please fill in at least the panel members or schedule details before saving.", "UTF-8")
                        + listUrlParam);
                    return;
                }

                // All four required fields present → confirmed scheduled
                if (hasChair && hasRecorder && hasDate && hasVenue) {
                    status = "scheduled";
                } else {
                    // Partial — save what's there but keep as pending
                    status = "pending";
                }
            }
            dao.savePanel(appointmentId, chairId, recorderId, internalIds, externalIds, status, scheduledAt, venue);

            resp.sendRedirect(req.getContextPath() + "/admin/appointment/decision?id=" + appointmentId + "&saved=1" + listUrlParam);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private Integer parseNullableInt(String val) {
        if (val == null || val.trim().isEmpty()) return null;
        try { return Integer.parseInt(val.trim()); } catch (NumberFormatException e) { return null; }
    }

    private List<Integer> parseIntArray(String[] vals) {
        List<Integer> out = new ArrayList<>();
        if (vals == null) return out;
        for (String v : vals) {
            Integer i = parseNullableInt(v);
            if (i != null) out.add(i);
        }
        return out;
    }

    private void sendPanelEmails(VivaAppointment va) {
        for (Map<String,Object> member : va.getPanelMembers()) {
            String email = (String) member.get("email");
            String name  = (String) member.get("name");
            String role  = (String) member.get("role");
            if (email == null || email.trim().isEmpty()) continue;
            String subject = "Viva Voce Appointment Letter — " + role + " | " +
                             (va.getCandidateName() != null ? va.getCandidateName() : "Candidate");
            EmailUtil.sendHtmlEmailAsync(email, subject, buildLetterEmailBody(va, name, role));
        }
    }

    private String buildLetterEmailBody(VivaAppointment va, String recipientName, String role) {
        String today    = new java.text.SimpleDateFormat("dd MMMM yyyy").format(new java.util.Date());
        String vivaDate = va.getScheduledAt() != null
            ? new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(va.getScheduledAt()) : "—";
        return "<!doctype html><html><body style='font-family:\"Times New Roman\",Times,serif;"
             + "font-size:16px;line-height:1.8;color:#111;max-width:700px;margin:0 auto;padding:40px;'>"
             + "<div style='text-align:center;margin-bottom:24px;'>"
             + "<strong style='font-size:18px;'>UNIVERSITI MALAYSIA TERENGGANU</strong><br>"
             + "FAKULTI SAINS KOMPUTER DAN MATEMATIK<br>"
             + "<small style='color:#555;'>21030 Kuala Nerus, Terengganu Darul Iman</small>"
             + "<hr style='margin:16px 0;'>"
             + "</div>"
             + "<p>Date: " + esc(today) + "</p>"
             + "<h2 style='text-align:center;font-size:18px;font-weight:bold;'>"
             + "LETTER OF APPOINTMENT &mdash; " + esc(role.toUpperCase()) + "</h2>"
             + "<p>" + esc(recipientName) + ",</p>"
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
                ? "<tr><td style='padding:4px 0;font-weight:bold;'>Thesis Title</td><td>: " + esc(va.getThesisTitle()) + "</td></tr>" : "")
             + "<tr><td style='padding:4px 0;font-weight:bold;'>Supervisor</td>"
             + "<td>: " + esc(va.getSupervisorName()) + "</td></tr>"
             + "<tr><td style='padding:4px 0;font-weight:bold;'>Viva Date &amp; Time</td>"
             + "<td>: " + esc(vivaDate) + "</td></tr>"
             + "<tr><td style='padding:4px 0;font-weight:bold;'>Venue</td>"
             + "<td>: " + esc(va.getVenue()) + "</td></tr>"
             + "</table>"
             + "<p>[ Official letter body to be inserted once template is provided. ]</p>"
             + "<p>Please confirm your acceptance of this appointment within <strong>seven (7) working days</strong>.</p>"
             + "<p>We look forward to your kind participation.</p>"
             + "<p>Thank you.</p>"
             + "<div style='margin-top:48px;'><p>Yours sincerely,</p><br><br>"
             + "<div>_________________________________</div>"
             + "<strong>DEAN</strong><br>"
             + "Faculty of Computer and Mathematical Sciences<br>"
             + "Universiti Malaysia Terengganu"
             + "</div></body></html>";
    }

    private String esc(String s) {
        if (s == null) return "&mdash;";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
