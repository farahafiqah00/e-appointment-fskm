package controller;

import dao.AppointmentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/** Admin endpoint to toggle the physical-signature flag on an individual panel member's letter (action=sign or action=unsign). */
@WebServlet("/admin/appointment/letter/sign")
public class LetterSignedServlet extends HttpServlet {

    private AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String panelIdStr    = req.getParameter("panel_id");
        String appointmentId = req.getParameter("appointment_id");
        String action        = req.getParameter("action"); // "sign" or "unsign"

        if (panelIdStr == null || appointmentId == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
            return;
        }
        try {
            int panelId = Integer.parseInt(panelIdStr);
            boolean signed = "sign".equals(action);
            dao.markLetterSigned(panelId, signed);
            resp.sendRedirect(req.getContextPath() + "/admin/appointment/letter/preview?id=" + appointmentId);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
