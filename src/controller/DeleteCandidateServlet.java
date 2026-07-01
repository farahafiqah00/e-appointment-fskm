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
 * Deletes a candidate record, but only if they are still in 'prepared' status
 * (i.e. no viva appointment has been assigned yet).
 *
 * POST /DeleteCandidateServlet
 *    id (required) — candidate id
 */
@WebServlet(name = "DeleteCandidateServlet", urlPatterns = {"/DeleteCandidateServlet"})
public class DeleteCandidateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        // Only Admin role may delete candidates
        String role = (String) session.getAttribute("role_name");
        if (!"Admin".equals(role) && !"System Administrator".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?error=forbidden");
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
                resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?deleteError=notfound");
                return;
            }
            if (!"prepared".equalsIgnoreCase(c.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?deleteError=notdeletable");
                return;
            }

            dao.delete(candidateId);
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?deleted=1");

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet");
        } catch (SQLException e) {
            getServletContext().log("DeleteCandidateServlet error: " + e.getMessage(), e);
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?deleteError=1");
        }
    }
}
