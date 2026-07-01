package controller;

import dao.CandidateDAO;
import model.Candidate;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/** Loads the viva candidate list; routes Dean users to the dean-specific JSP and Admin to the admin JSP. */
@WebServlet(name = "CandidateListServlet", urlPatterns = {"/CandidateListServlet"})
public class CandidateListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String q         = req.getParameter("q");
        String programId = req.getParameter("programId");
        String status    = req.getParameter("status");
        String level     = req.getParameter("level");
        boolean showArchived = "1".equals(req.getParameter("showArchived"));
        String roleNav = (String) req.getSession().getAttribute("role_name");
        String view = "Dean".equals(roleNav)
                ? "/dean/viva/vivaCandidateList.jsp"
                : "/admin/viva/vivaCandidateList.jsp";
        try {
            CandidateDAO dao = new CandidateDAO();
            List<Candidate> candidates = dao.findAll(q, programId, status, level, showArchived);
            req.setAttribute("candidates", candidates);
            req.setAttribute("programs",   dao.findAllPrograms());
            req.setAttribute("showArchived", showArchived);
            req.getRequestDispatcher(view).forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
