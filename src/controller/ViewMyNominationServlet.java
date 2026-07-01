package controller;

import dao.NominationDAO;
import model.Document;
import model.Nomination;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import util.DBConnection;

/** Loads the read-only detail view of a single nomination for the nominator; includes full examiner profile and attached documents. */
@WebServlet(name = "ViewMyNominationServlet", urlPatterns = {"/ViewMyNominationServlet"})
public class ViewMyNominationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role_name");
        if (!"Academician".equals(role) && !"Dean".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/admin/adminDashboard.jsp");
            return;
        }
        int userId = (int) session.getAttribute("user_id");

        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet");
            return;
        }

        try {
            int nominationId = Integer.parseInt(idStr.trim());
            NominationDAO dao = new NominationDAO();
            Nomination nom = dao.findById(nominationId);

            if (nom == null) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?error=notfound");
                return;
            }
            // Only the nominator may view their own nomination through this servlet
            if (nom.getNominatorUserId() != userId) {
                resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet?error=forbidden");
                return;
            }

            // Load full examiner row (all columns including text fields)
            Map<String,Object> examiner = null;
            if (nom.getExternalExaminerId() != null) {
                examiner = loadFullExaminer(nom.getExternalExaminerId());
            }

            // Candidate name (not in findById — fetch separately)
            String candidateName = loadCandidateName(nominationId);

            List<Document> docs = dao.getDocumentsForNomination(nominationId);

            req.setAttribute("nomination",     nom);
            req.setAttribute("examiner",       examiner);
            req.setAttribute("documents",      docs);
            req.setAttribute("candidateName",  candidateName);
            req.getRequestDispatcher("/academician/nomination/viewMyNomination.jsp")
               .forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/MyNominationsServlet");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private Map<String,Object> loadFullExaminer(int examinerId) throws SQLException {
        String sql =
            "SELECT ee.id, ee.name, ee.affiliation, ee.email, ee.phone, " +
            "ee.title, ee.gender, ee.nationality, ee.ic_passport, ee.faculty, ee.country, " +
            "ee.specialization, ee.specialization_id, ee.expertise_id, ee.division_id, ee.area_id, " +
            "ee.qualification, ee.position, " +
            "COALESCE(s.name,  ee.specialization, '') AS specialization_name, " +
            "COALESCE(exp.name, '') AS expertise_name, " +
            "COALESCE(dv.name,  '') AS division_name, " +
            "COALESCE(ar.name,  '') AS area_name " +
            "FROM external_examiner ee " +
            "LEFT JOIN specialization s   ON s.id   = ee.specialization_id " +
            "LEFT JOIN expertise      exp ON exp.id = ee.expertise_id " +
            "LEFT JOIN division       dv  ON dv.id  = ee.division_id " +
            "LEFT JOIN area           ar  ON ar.id  = ee.area_id " +
            "WHERE ee.id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, examinerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id",                  rs.getInt("id"));
                    m.put("name",                rs.getString("name"));
                    m.put("affiliation",         rs.getString("affiliation"));
                    m.put("email",               rs.getString("email"));
                    m.put("phone",               rs.getString("phone"));
                    m.put("title",               rs.getString("title"));
                    m.put("gender",              rs.getString("gender"));
                    m.put("nationality",         rs.getString("nationality"));
                    m.put("ic_passport",         rs.getString("ic_passport"));
                    m.put("faculty",             rs.getString("faculty"));
                    m.put("country",             rs.getString("country"));
                    m.put("specialization_id",   rs.getObject("specialization_id"));
                    m.put("expertise_id",        rs.getObject("expertise_id"));
                    m.put("division_id",         rs.getObject("division_id"));
                    m.put("area_id",             rs.getObject("area_id"));
                    m.put("specialization_name", rs.getString("specialization_name"));
                    m.put("expertise_name",      rs.getString("expertise_name"));
                    m.put("division_name",       rs.getString("division_name"));
                    m.put("area_name",           rs.getString("area_name"));
                    m.put("qualification",       rs.getString("qualification"));
                    m.put("position",            rs.getString("position"));
                    return m;
                }
            }
        }
        return null;
    }

    private String loadCandidateName(int nominationId) throws SQLException {
        // Candidate name is only revealed once the examiner has been formally
        // placed on an appointment panel — NOT from nomination.candidate_id alone.
        String sql =
            "SELECT c.full_name " +
            "FROM nomination n " +
            "JOIN appointment_panel ap ON ap.external_examiner_id = n.external_examiner_id " +
            "JOIN viva_appointment  va ON va.id = ap.appointment_id " +
            "JOIN candidate         c  ON c.id  = va.candidate_id " +
            "WHERE n.id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nominationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("full_name");
            }
        }
        return null;
    }
}
