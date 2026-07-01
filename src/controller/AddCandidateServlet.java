package controller;

import dao.CandidateDAO;
import model.Candidate;
import model.CoSupervisor;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Handles submission of the "Add Viva Candidate" form; always sets initial status to 'prepared'. */
@WebServlet(name = "AddCandidateServlet", urlPatterns = {"/AddCandidateServlet"})
public class AddCandidateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String fullName       = req.getParameter("fullName");
        String studentId      = req.getParameter("studentId");
        String thesisTitle    = req.getParameter("thesisTitle");
        String supervisorName = req.getParameter("supervisorName");
        String supervisorIdStr = req.getParameter("supervisorId");
        String contactEmail   = req.getParameter("contactEmail");
        String nationality    = req.getParameter("nationality");
        String status         = req.getParameter("status");
        String programIdStr   = req.getParameter("programId");

        if (fullName == null || fullName.trim().isEmpty()
                || studentId == null || studentId.trim().isEmpty()
                || thesisTitle == null || thesisTitle.trim().isEmpty()
                || programIdStr == null || programIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?error=missing_fields");
            return;
        }

        Candidate c = new Candidate();
        c.setFullName(fullName);
        c.setStudentId(studentId);
        c.setThesisTitle(thesisTitle);
        c.setSupervisorName(supervisorName);
        if (supervisorIdStr != null && !supervisorIdStr.isEmpty()) {
            try { c.setSupervisorId(Integer.parseInt(supervisorIdStr)); } catch (NumberFormatException ignore) {}
        }
        c.setContactEmail(contactEmail);
        c.setNationality(nationality);
        c.setStatus("prepared"); // always prepared on initial add; changed automatically by the system
        if (programIdStr != null && !programIdStr.isEmpty()) {
            try { c.setProgramId(Integer.parseInt(programIdStr)); } catch (NumberFormatException ignore) {}
        }
        c.setCoSupervisors(parseCoSupervisors(req));

        try {
            new CandidateDAO().insert(c);
            resp.sendRedirect(req.getContextPath() + "/CandidateListServlet?success=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    // Static so EditCandidateServlet can reuse the same parsing logic without duplication.
    static List<CoSupervisor> parseCoSupervisors(HttpServletRequest req) {
        List<CoSupervisor> list = new ArrayList<>();
        String countStr = req.getParameter("cosvCount");
        if (countStr == null || countStr.isEmpty()) return list;
        int count;
        try { count = Integer.parseInt(countStr); } catch (NumberFormatException e) { return list; }
        for (int i = 0; i < count; i++) {
            String type = req.getParameter("cosv_type_" + i);
            String name = req.getParameter("cosv_name_" + i);
            if (name == null || name.trim().isEmpty()) continue;
            CoSupervisor cs = new CoSupervisor();
            cs.setCosvType(type != null ? type : "external");
            cs.setName(name.trim());
            if ("internal".equals(type)) {
                String sid = req.getParameter("cosv_internal_id_" + i);
                if (sid != null && !sid.isEmpty()) {
                    try { cs.setInternalStaffId(Integer.parseInt(sid)); } catch (NumberFormatException ignore) {}
                }
            } else {
                cs.setUniversityName(req.getParameter("cosv_university_" + i));
                cs.setFaculty(req.getParameter("cosv_faculty_" + i));
                cs.setProgramme(req.getParameter("cosv_programme_" + i));
                cs.setCountry(req.getParameter("cosv_country_" + i));
                cs.setEmail(req.getParameter("cosv_email_" + i));
            }
            list.add(cs);
        }
        return list;
    }
}
