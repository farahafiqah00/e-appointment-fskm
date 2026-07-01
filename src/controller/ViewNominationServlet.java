package controller;

import dao.NominationDAO;
import model.Document;
import model.Nomination;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/** Loads a single nomination with its supporting documents for the admin detail view. */
@WebServlet(name = "ViewNominationServlet", urlPatterns = {"/ViewNominationServlet"})
public class ViewNominationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendRedirect(req.getContextPath() + "/NominationListServlet");
            return;
        }
        int id = Integer.parseInt(idStr);
        try {
            NominationDAO dao = new NominationDAO();
            Nomination n = dao.findById(id);
            List<Document> docs = dao.getDocumentsForNomination(id);
            req.setAttribute("nomination", n);
            req.setAttribute("documents", docs);
            req.getRequestDispatcher("/admin/nomination/nominationView.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
