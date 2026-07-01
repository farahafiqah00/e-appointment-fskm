package controller;

import dao.ReportsDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;

/** Loads the Admin appointment-statistics report for a selected year; non-Admin users are forwarded to the equivalent Dean route. */
@WebServlet("/admin/reports/appointments")
public class AppointmentStatisticsServlet extends HttpServlet {

    private ReportsDAO dao = new ReportsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        // Dean and Academician users are redirected to the dean statistics route.
        String _role = (String) session.getAttribute("role_name");
        if ("Dean".equals(_role) || "Academician".equals(_role)) {
            resp.sendRedirect(req.getContextPath() + "/dean/reports/appointments");
            return;
        }
        String yearParam = req.getParameter("year");
        int year = (yearParam != null && !yearParam.isEmpty()) ? Integer.parseInt(yearParam) : Calendar.getInstance().get(Calendar.YEAR);
        try {
            req.setAttribute("selectedYear", year);
            req.setAttribute("summary",          dao.getSummaryStats(year));
            req.setAttribute("roleFrequency",    dao.getRoleFrequencyPivoted());
            req.setAttribute("roleFreqByYear",   dao.getRoleFrequencyByYear(year));
            req.setAttribute("yearlyTrends",     dao.getYearlyTrends());
            req.setAttribute("deptStats",        dao.getDepartmentStatsFull());
            req.setAttribute("appointmentList",  dao.getAppointmentsByYear(year));
            req.setAttribute("statusBreakdown",  dao.getStatusBreakdown(year));
            req.setAttribute("availableYears",   dao.getAvailableYears());
            req.getRequestDispatcher("/admin/reports/appointmentStatistics.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
