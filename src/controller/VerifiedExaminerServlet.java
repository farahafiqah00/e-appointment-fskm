package controller;

import util.DBConnection;
import model.ExternalExaminer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Admin view of all externally verified examiners; supports multi-dimensional filtering (specialization, expertise, division, area). */
@WebServlet(name = "VerifiedExaminerServlet", urlPatterns = {"/VerifiedExaminerServlet"})
public class VerifiedExaminerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String q      = req.getParameter("q");
        String specId = req.getParameter("spec_id");
        String expId  = req.getParameter("exp_id");
        String divId  = req.getParameter("div_id");
        String areaId = req.getParameter("area_id");

        // Reusable lambda avoids four separate try-with-resources blocks for the same SELECT id,name pattern.
        // Helper to load a simple id/name list
        java.util.function.Function<String, List<Map<String,Object>>> loadList = (sqlStr) -> {
            List<Map<String,Object>> list = new ArrayList<>();
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlStr);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id",   rs.getInt("id"));
                    m.put("name", rs.getString("name"));
                    list.add(m);
                }
            } catch (Exception ex) { throw new RuntimeException(ex); }
            return list;
        };

        List<Map<String,Object>> specializations, expertises, divisions, areas;
        try {
            specializations = loadList.apply("SELECT id, name FROM specialization ORDER BY name");
            expertises      = loadList.apply("SELECT id, name FROM expertise      ORDER BY name");
            divisions       = loadList.apply("SELECT id, name FROM division       ORDER BY name");
            areas           = loadList.apply("SELECT id, name FROM area           ORDER BY name");
        } catch (RuntimeException ex) { throw new ServletException(ex.getCause()); }

        // DISTINCT prevents duplicates when one examiner appears in multiple verified nominations.
        // Build examiner query with optional filters
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT ee.id, ee.title, ee.name, ee.affiliation, ee.email, ee.phone, ee.status, ee.country, " +
            "COALESCE(s.name, ee.specialization, '') AS specialization_name, " +
            "COALESCE(exp.name, '') AS expertise_name, " +
            "COALESCE(dv.name, '') AS division_name, " +
            "COALESCE(ar.name, '') AS area_name " +
            "FROM external_examiner ee " +
            "JOIN nomination n ON n.external_examiner_id = ee.id " +
            "LEFT JOIN specialization s   ON s.id   = ee.specialization_id " +
            "LEFT JOIN expertise      exp ON exp.id = ee.expertise_id " +
            "LEFT JOIN division       dv  ON dv.id  = ee.division_id " +
            "LEFT JOIN area           ar  ON ar.id  = ee.area_id " +
            "WHERE n.status = 'verified'");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (ee.name LIKE ? OR ee.affiliation LIKE ?)");
            params.add("%" + q.trim() + "%");
            params.add("%" + q.trim() + "%");
        }
        if (specId != null && !specId.trim().isEmpty()) {
            sql.append(" AND ee.specialization_id = ?");
            params.add(Integer.parseInt(specId.trim()));
        }
        if (expId != null && !expId.trim().isEmpty()) {
            sql.append(" AND ee.expertise_id = ?");
            params.add(Integer.parseInt(expId.trim()));
        }
        if (divId != null && !divId.trim().isEmpty()) {
            sql.append(" AND ee.division_id = ?");
            params.add(Integer.parseInt(divId.trim()));
        }
        if (areaId != null && !areaId.trim().isEmpty()) {
            sql.append(" AND ee.area_id = ?");
            params.add(Integer.parseInt(areaId.trim()));
        }
        sql.append(" ORDER BY ee.name");

        List<ExternalExaminer> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ExternalExaminer e = new ExternalExaminer();
                    e.setId(rs.getInt("id"));
                    e.setTitle(rs.getString("title"));
                    e.setName(rs.getString("name"));
                    e.setAffiliation(rs.getString("affiliation"));
                    e.setEmail(rs.getString("email"));
                    e.setPhone(rs.getString("phone"));
                    e.setStatus(rs.getString("status"));
                    e.setCountry(rs.getString("country"));
                    e.setSpecialization(rs.getString("specialization_name"));
                    e.setQualification(rs.getString("expertise_name"));
                    e.setFaculty(rs.getString("division_name"));
                    e.setIcPassport(rs.getString("area_name"));
                    out.add(e);
                }
            }
        } catch (Exception ex) { throw new ServletException(ex); }

        req.setAttribute("examiners",      out);
        req.setAttribute("specializations", specializations);
        req.setAttribute("expertises",      expertises);
        req.setAttribute("divisions",       divisions);
        req.setAttribute("areas",           areas);
        req.getRequestDispatcher("/admin/nomination/verifiedExaminers.jsp").forward(req, resp);
    }
}
