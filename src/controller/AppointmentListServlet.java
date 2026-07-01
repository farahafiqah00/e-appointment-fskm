package controller;

import dao.AppointmentDAO;
import model.VivaAppointment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/** Lists viva appointments with filters; Dean sees a read-only role-summary view, Admin sees the full workflow list. */
@WebServlet("/admin/appointments")
public class AppointmentListServlet extends HttpServlet {

    private AppointmentDAO dao = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String roleNav = (String) req.getSession().getAttribute("role_name");
        String view = "Dean".equals(roleNav)
                ? "/dean/viva/vivaAppointmentList.jsp"
                : "/admin/appointment/appointmentList.jsp";
        String q = req.getParameter("q");
        String statusFilter = req.getParameter("status");
        String level = req.getParameter("level");
        String letterApprovalFilter = req.getParameter("letterApproval");
        boolean overdueOnly = "1".equals(req.getParameter("overdue"));
        boolean showArchived = "1".equals(req.getParameter("showArchived"));
        try {
            // Dean uses findAllWithRoles (panel summary columns); Admin uses findAllReady (workflow + letter approval filters).
            List<VivaAppointment> list = "Dean".equals(roleNav)
                    ? dao.findAllWithRoles(q, statusFilter, level, showArchived)
                    : dao.findAllReady(q, statusFilter, level, showArchived, letterApprovalFilter, overdueOnly);
            req.setAttribute("appointments", list);
            req.setAttribute("showArchived", showArchived);
            req.setAttribute("letterApprovalFilter", letterApprovalFilter != null ? letterApprovalFilter : "");
            req.setAttribute("overdueOnly", overdueOnly);
            if (!"Dean".equals(roleNav)) {
                req.setAttribute("overdueCount",  dao.getOverdueExternalResponseCount());
                req.setAttribute("declinedCount", dao.getExaminerDeclinedCount());
            }
            req.getRequestDispatcher(view).forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
