package controller;

import dao.AppointmentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;

/** Admin-only: corrects the email address on an external_examiner record so that panel letter emails can be (re)sent to the right address. */
@WebServlet("/admin/external-examiner/update-email")
public class UpdateExternalExaminerEmailServlet extends HttpServlet {

    private final AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String roleName = session != null ? String.valueOf(session.getAttribute("role_name")) : "";
        if ("Dean".equals(roleName) || "Academician".equals(roleName) || "".equals(roleName) || "null".equals(roleName)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String sEeId   = req.getParameter("external_examiner_id");
        String sApptId = req.getParameter("appointment_id");
        String email   = req.getParameter("email");

        String base = req.getContextPath() + "/admin/appointment/letter/preview?id=" + sApptId;

        if (sEeId == null || sApptId == null || email == null || email.trim().isEmpty()) {
            try {
                resp.sendRedirect(base + "&approvalError=" + URLEncoder.encode("Email address is required.", "UTF-8"));
            } catch (Exception e) { resp.sendRedirect(base); }
            return;
        }

        // Basic email format check
        if (!email.trim().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            try {
                resp.sendRedirect(base + "&approvalError=" + URLEncoder.encode("Invalid email address format.", "UTF-8"));
            } catch (Exception e) { resp.sendRedirect(base); }
            return;
        }

        try {
            dao.updateExternalExaminerEmail(Integer.parseInt(sEeId), email);
            resp.sendRedirect(base + "&approvalMsg=" + URLEncoder.encode("External examiner email updated to: " + email.trim(), "UTF-8"));
        } catch (NumberFormatException | SQLException e) {
            try {
                resp.sendRedirect(base + "&approvalError=" + URLEncoder.encode("Failed to update email: " + e.getMessage(), "UTF-8"));
            } catch (Exception ex) { throw new ServletException(e); }
        }
    }
}
