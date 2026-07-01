package controller;

import dao.NominationDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/** Loads the admin report of nominations whose examiners have not yet confirmed (or have discrepancies in) their profile information. */
@WebServlet(name = "UnverifiedReportServlet", urlPatterns = {"/UnverifiedReportServlet"})
public class UnverifiedReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            NominationDAO dao = new NominationDAO();
            List<Map<String,Object>> rows = dao.getUnverifiedNominationsReport();
            req.setAttribute("reportRows", rows);
            req.getRequestDispatcher("/admin/nomination/unverifiedReport.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
