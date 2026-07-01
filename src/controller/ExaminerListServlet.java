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

/** Lists external examiners with optional text and specialization filters; routes Dean to the dean JSP and Academician to the academician JSP. */
@WebServlet(urlPatterns = {"/academician/examiners", "/dean/examiners"})
public class ExaminerListServlet extends HttpServlet {

    private NominationDAO dao = new NominationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String q = req.getParameter("q");
        String specIdStr = req.getParameter("specializationId");
        Integer specId = null;
        if (specIdStr != null && !specIdStr.trim().isEmpty()) {
            try { specId = Integer.parseInt(specIdStr.trim()); } catch (NumberFormatException ignore) {}
        }

        Integer currentUserId = (Integer) req.getSession().getAttribute("user_id");
        if (currentUserId == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            List<Map<String,Object>> examiners = dao.findAllExaminers(q, specId, currentUserId);
            List<Map<String,Object>> specializations = dao.getAllSpecializations();
            req.setAttribute("examiners", examiners);
            req.setAttribute("specializations", specializations);
            String role = (String) req.getSession().getAttribute("role_name");
            String view = "Dean".equals(role)
                ? "/dean/examiner/examinerList.jsp"
                : "/academician/examiner/examinerList.jsp";
            req.getRequestDispatcher(view).forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
