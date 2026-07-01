package controller;

import dao.NominationDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Deletes a nomination (and its linked examiner + documents) owned by the logged-in user.
 * Only the nominator may delete their own nomination, and only when it is not yet verified.
 *
 * POST /DeleteNominationServlet
 *    nominationId (required)
 */
@WebServlet(name = "DeleteNominationServlet", urlPatterns = {"/DeleteNominationServlet"})
public class DeleteNominationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role_name");
        if (!"Academician".equals(role) && !"Dean".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        String nomIdStr = req.getParameter("nominationId");
        if (nomIdStr == null || nomIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?deleteError=1");
            return;
        }

        try {
            int nominationId = Integer.parseInt(nomIdStr.trim());
            NominationDAO dao = new NominationDAO();

            // Verify ownership
            Integer nominatorId = dao.getNominatorUserIdByNominationId(nominationId);
            if (nominatorId == null || !nominatorId.equals(userId)) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?deleteError=1");
                return;
            }

            // Block deletion of verified nominations
            dao.deleteNomination(nominationId);
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?deleted=1");

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?deleteError=1");
        } catch (Exception e) {
            getServletContext().log("DeleteNominationServlet error: " + e.getMessage(), e);
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?deleteError=1");
        }
    }
}
