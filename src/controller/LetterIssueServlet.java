package controller;

import dao.AppointmentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/** Admin endpoint that marks an appointment letter as generated/issued, advancing the workflow so the approval-request step becomes available. */
@WebServlet("/admin/appointment/letter/issue")
public class LetterIssueServlet extends HttpServlet {

    private AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String sid = req.getParameter("id");
        if (sid == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
            return;
        }
        try {
            int id = Integer.parseInt(sid);
            dao.markLetterGenerated(id);
            resp.sendRedirect(req.getContextPath() + "/admin/appointment/decision?id=" + id);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/appointments");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
