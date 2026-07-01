package controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

/** Creates or updates an academic_staff record; ON DUPLICATE KEY UPDATE on staff_number makes this an upsert so the same form works for both Add and Edit flows. */
@WebServlet(name = "SaveAcademicServlet", urlPatterns = {"/SaveAcademicServlet"})
public class SaveAcademicServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String staffNumber     = req.getParameter("staffNumber");
        String title           = req.getParameter("title");
        String fullName        = req.getParameter("fullName");
        String department      = req.getParameter("department");
        String faculty         = req.getParameter("faculty");
        String specIdStr       = req.getParameter("specialization_id");
        String expertiseIdStr  = req.getParameter("expertise_id");
        String divisionIdStr   = req.getParameter("division_id");
        String areaIdStr       = req.getParameter("area_id");
        String qualification   = req.getParameter("qualification");
        String fromCtx         = req.getParameter("from") != null ? req.getParameter("from").trim() : "";
        String academicRank    = req.getParameter("academic_rank");
        String yearsExpStr     = req.getParameter("years_experience");
        String userIdStr       = req.getParameter("user_id");
        String statusParam     = req.getParameter("status");
        String status          = (statusParam != null && !statusParam.trim().isEmpty()) ? statusParam.trim() : "active";

        if (staffNumber == null || staffNumber.trim().isEmpty()
                || fullName == null || fullName.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath()
                    + "/admin/academician/addAcademicStaff.jsp?error=missing");
            return;
        }

        Integer specializationId = parseNullableInt(specIdStr);
        Integer expertiseId      = parseNullableInt(expertiseIdStr);
        Integer divisionId       = parseNullableInt(divisionIdStr);
        Integer areaId           = parseNullableInt(areaIdStr);
        Integer linkedUserId     = parseNullableInt(userIdStr);
        int yearsExp = 0;
        try { yearsExp = Integer.parseInt(yearsExpStr.trim()); } catch (Exception ignored) {}

        try (Connection conn = DBConnection.getConnection()) {
            String sql =
                "INSERT INTO academic_staff " +
                "  (staff_number, title, full_name, department, faculty, " +
                "   specialization_id, expertise_id, division_id, area_id, " +
                "   qualification, academic_rank, years_experience, user_id, status) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?) " +
                "ON DUPLICATE KEY UPDATE " +
                "  title=VALUES(title), full_name=VALUES(full_name), department=VALUES(department), " +
                "  faculty=VALUES(faculty), " +
                "  specialization_id=VALUES(specialization_id), " +
                "  expertise_id=VALUES(expertise_id), " +
                "  division_id=VALUES(division_id), " +
                "  area_id=VALUES(area_id), " +
                "  qualification=VALUES(qualification), " +
                "  academic_rank=VALUES(academic_rank), " +
                "  years_experience=VALUES(years_experience), " +
                "  user_id=VALUES(user_id), " +
                "  status=VALUES(status)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, staffNumber.trim());
                setStringOrNull(ps, 2, title);
                ps.setString(3, fullName.trim());
                setStringOrNull(ps, 4, department);
                setStringOrNull(ps, 5, faculty);
                setIntOrNull(ps, 6, specializationId);
                setIntOrNull(ps, 7, expertiseId);
                setIntOrNull(ps, 8, divisionId);
                setIntOrNull(ps, 9, areaId);
                setStringOrNull(ps, 10, qualification);
                setStringOrNull(ps, 11, academicRank);
                ps.setInt(12, yearsExp);
                setIntOrNull(ps, 13, linkedUserId);
                ps.setString(14, status);
                ps.executeUpdate();
            }
            resp.sendRedirect(req.getContextPath()
                    + ("userList".equals(fromCtx) ? "/UserListServlet?success=1" : "/admin/academician/academicStaffList.jsp?success=1"));
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    private Integer parseNullableInt(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    private void setStringOrNull(PreparedStatement ps, int idx, String val) throws SQLException {
        if (val != null && !val.trim().isEmpty()) ps.setString(idx, val.trim());
        else ps.setNull(idx, Types.VARCHAR);
    }

    private void setIntOrNull(PreparedStatement ps, int idx, Integer val) throws SQLException {
        if (val != null) ps.setInt(idx, val);
        else ps.setNull(idx, Types.INTEGER);
    }
}
