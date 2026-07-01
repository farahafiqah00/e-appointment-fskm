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

/** Loads and saves candidate edits; blocks editing if the candidate has already been appointed. */
@WebServlet(name = "EditCandidateServlet", urlPatterns = {"/EditCandidateServlet"})
public class EditCandidateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null) { resp.sendRedirect(req.getContextPath() + "/CandidateListServlet"); return; }
        try {
            CandidateDAO dao = new CandidateDAO();
            Candidate c = dao.findById(Integer.parseInt(idStr));
            if (c == null) { resp.sendRedirect(req.getContextPath() + "/CandidateListServlet"); return; }
            // Only allow editing candidates that have not been appointed yet
            if (!"prepared".equalsIgnoreCase(c.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?error=noteditable");
                return;
            }
            req.setAttribute("candidate", c);
            req.setAttribute("programs", dao.findAllPrograms());
            req.getRequestDispatcher("/admin/viva/addVivaCandidate.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String idStr = req.getParameter("id");
        if (idStr == null) { resp.sendRedirect(req.getContextPath() + "/CandidateListServlet"); return; }
        int id = Integer.parseInt(idStr);
        String fullName        = req.getParameter("fullName");
        String studentId       = req.getParameter("studentId");
        String thesisTitle     = req.getParameter("thesisTitle");
        String supervisorName  = req.getParameter("supervisorName");
        String supervisorIdStr = req.getParameter("supervisorId");
        String contactEmail    = req.getParameter("contactEmail");
        String nationality     = req.getParameter("nationality");
        String status          = req.getParameter("status");
        String programIdStr    = req.getParameter("programId");

        if (fullName == null || fullName.trim().isEmpty()
                || studentId == null || studentId.trim().isEmpty()
                || thesisTitle == null || thesisTitle.trim().isEmpty()
                || programIdStr == null || programIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?error=missing_fields");
            return;
        }

        try {
            CandidateDAO dao = new CandidateDAO();
            Candidate c = dao.findById(id);
            if (c != null) {
                c.setFullName(fullName);
                c.setStudentId(studentId);
                c.setThesisTitle(thesisTitle);
                c.setSupervisorName(supervisorName);
                if (supervisorIdStr != null && !supervisorIdStr.isEmpty()) {
                    try { c.setSupervisorId(Integer.parseInt(supervisorIdStr)); } catch (NumberFormatException ignore) {}
                } else {
                    c.setSupervisorId(null);
                }
                c.setContactEmail(contactEmail);
                c.setNationality(nationality);
                // Status is never changed manually — preserved from existing record
                if (programIdStr != null && !programIdStr.isEmpty()) {
                    try { c.setProgramId(Integer.parseInt(programIdStr)); } catch (NumberFormatException ignore) {}
                } else {
                    c.setProgramId(null);
                }
                c.setCoSupervisors(AddCandidateServlet.parseCoSupervisors(req));
                dao.update(c);
            }
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?success=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
