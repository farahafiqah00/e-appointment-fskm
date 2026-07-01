package controller;

import dao.AcademicStaffDAO;
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

/** Lets an Academician edit an examiner they nominated; blocks editing by any other user (ownership enforced by checking the nomination's nominator_user_id). */
@WebServlet("/academician/examiner/edit")
public class EditExaminerServlet extends HttpServlet {

    private NominationDAO dao = new NominationDAO();
    private AcademicStaffDAO staffDao = new AcademicStaffDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer currentUserId = (Integer) req.getSession().getAttribute("user_id");
        if (currentUserId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String sid = req.getParameter("id");
        if (sid == null || sid.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/academician/examiners");
            return;
        }
        try {
            int examinerId = Integer.parseInt(sid.trim());
            Integer nominatorId = dao.getNominatorUserIdForExaminer(examinerId);
            if (!currentUserId.equals(nominatorId)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You did not nominate this examiner.");
                return;
            }
            Map<String,Object> examiner = dao.findExaminerById(examinerId);
            if (examiner == null) {
                resp.sendRedirect(req.getContextPath() + "/academician/examiners");
                return;
            }
            List<Map<String,Object>> specializations = staffDao.getSpecializations();
            List<Map<String,Object>> expertiseList   = staffDao.getExpertise();
            List<Map<String,Object>> divisionList    = staffDao.getDivisions();
            List<Map<String,Object>> areaList        = staffDao.getAreas();
            req.setAttribute("examiner", examiner);
            req.setAttribute("specializations", specializations);
            req.setAttribute("expertiseList",   expertiseList);
            req.setAttribute("divisionList",    divisionList);
            req.setAttribute("areaList",        areaList);
            req.getRequestDispatcher("/academician/examiner/editExaminer.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/academician/examiners");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer currentUserId = (Integer) req.getSession().getAttribute("user_id");
        if (currentUserId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String sid = req.getParameter("id");
        if (sid == null || sid.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/academician/examiners");
            return;
        }
        try {
            int examinerId = Integer.parseInt(sid.trim());
            Integer nominatorId = dao.getNominatorUserIdForExaminer(examinerId);
            if (!currentUserId.equals(nominatorId)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You did not nominate this examiner.");
                return;
            }
            String name        = req.getParameter("name");
            String affiliation = req.getParameter("affiliation");
            String email       = req.getParameter("email");
            String phone       = req.getParameter("phone");

            if (name == null || name.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/academician/examiners?error=missing_name");
                return;
            }

            Integer specializationId = parseNullableInt(req.getParameter("specializationId"));
            Integer expertiseId      = parseNullableInt(req.getParameter("expertiseId"));
            Integer divisionId       = parseNullableInt(req.getParameter("divisionId"));
            Integer areaId           = parseNullableInt(req.getParameter("areaId"));

            dao.updateExaminer(examinerId, name, affiliation, email, phone,
                               specializationId, expertiseId, divisionId, areaId);
            resp.sendRedirect(req.getContextPath() + "/academician/examiners?success=1");
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/academician/examiners");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private Integer parseNullableInt(String val) {
        if (val == null || val.trim().isEmpty()) return null;
        try { return Integer.parseInt(val.trim()); } catch (NumberFormatException e) { return null; }
    }
}
