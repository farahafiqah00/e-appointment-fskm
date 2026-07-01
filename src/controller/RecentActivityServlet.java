package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Legacy stub: redirects to the admin dashboard, which renders recent activity inline. Retained so old bookmarks do not 404. */
@WebServlet(name = "RecentActivityServlet", urlPatterns = {"/RecentActivityServlet"})
public class RecentActivityServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Simple redirect to the admin dashboard (dashboard already renders recent activity)
        resp.sendRedirect(req.getContextPath() + "/admin/adminDashboard.jsp");
    }
}
