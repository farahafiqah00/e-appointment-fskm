package controller;

import dao.NominationDAO;
import model.Nomination;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/** Loads the admin nomination list with optional text search, status filter, and archived toggle. */
@WebServlet(name = "NominationListServlet", urlPatterns = {"/NominationListServlet"})
public class NominationListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String q = req.getParameter("q");
        String status = req.getParameter("status");
        boolean showArchived = "1".equals(req.getParameter("showArchived"));
        try {
            NominationDAO dao = new NominationDAO();
            List<Nomination> nominations = dao.findAll(q, status, showArchived);
            req.setAttribute("nominations", nominations);
            req.setAttribute("showArchived", showArchived);
            req.getRequestDispatcher("/admin/nomination/nominationList.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
