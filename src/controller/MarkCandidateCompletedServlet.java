package controller;

import dao.CandidateDAO;
import model.Candidate;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Marks an appointed viva candidate as completed.
 * Only callable by Admin after the viva session has been held.
 *
 * POST /MarkCandidateCompletedServlet
 *    id (required) — candidate id
 */
@WebServlet(name = "MarkCandidateCompletedServlet", urlPatterns = {"/MarkCandidateCompletedServlet"})
public class MarkCandidateCompletedServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role_name");
        if (!"Admin".equals(role) && !"System Administrator".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet");
            return;
        }

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet");
            return;
        }

        try {
            int candidateId = Integer.parseInt(idStr.trim());
            CandidateDAO dao = new CandidateDAO();
            Candidate c = dao.findById(candidateId);

            if (c == null) {
                resp.sendRedirect(req.getContextPath() + "/CandidateListServlet");
                return;
            }
            if (!"appointed".equalsIgnoreCase(c.getStatus())) {
                // Not appointed — cannot mark complete
                resp.sendRedirect(req.getContextPath()
                        + "/admin/viva/vivaCandidateView.jsp?id=" + candidateId + "&error=notappointed");
                return;
            }

            dao.markCompleted(candidateId);
            resp.sendRedirect(req.getContextPath()
                    + "/admin/viva/vivaCandidateView.jsp?id=" + candidateId + "&completed=1");

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet");
        } catch (SQLException e) {
            getServletContext().log("MarkCandidateCompletedServlet error: " + e.getMessage(), e);
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?error=1");
        }
    }
}
