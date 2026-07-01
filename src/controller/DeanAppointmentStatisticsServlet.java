package controller;

import dao.ReportsDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;

/** Loads the Dean appointment-statistics report for a selected year (same dataset as the Admin view, but routed to the Dean JSP). */
@WebServlet("/dean/reports/appointments")
public class DeanAppointmentStatisticsServlet extends HttpServlet {

    private ReportsDAO dao = new ReportsDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String yearParam = req.getParameter("year");
        int year = (yearParam != null && !yearParam.isEmpty()) ? Integer.parseInt(yearParam) : Calendar.getInstance().get(Calendar.YEAR);
        try {
            req.setAttribute("selectedYear",    year);
            req.setAttribute("summary",         dao.getSummaryStats(year));
            req.setAttribute("roleFrequency",   dao.getRoleFrequencyPivoted());
            req.setAttribute("roleFreqByYear",  dao.getRoleFrequencyByYear(year));
            req.setAttribute("yearlyTrends",    dao.getYearlyTrends());
            req.setAttribute("deptStats",       dao.getDepartmentStatsFull());
            req.setAttribute("appointmentList", dao.getAppointmentsByYear(year));
            req.setAttribute("statusBreakdown", dao.getStatusBreakdown(year));
            req.setAttribute("availableYears",  dao.getAvailableYears());
            req.getRequestDispatcher("/dean/reports/appointmentStatistics.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
