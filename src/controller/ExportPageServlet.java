package controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/** Forwards Admin users to the CSV export selection page; non-Admin users are redirected to the Dean dashboard. */
@WebServlet("/admin/reports/exportPage")
public class ExportPageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String _role = (String) session.getAttribute("role_name");
        if ("Dean".equals(_role) || "Academician".equals(_role)) {
            resp.sendRedirect(req.getContextPath() + "/dean/deanDashboard");
            return;
        }
        req.getRequestDispatcher("/admin/reports/exportReports.jsp").forward(req, resp);
    }
}
