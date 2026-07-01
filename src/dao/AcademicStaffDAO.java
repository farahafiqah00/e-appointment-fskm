package dao;

import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Data-access methods for academic staff, lookup tables (specialization, expertise, etc.), and related data. */
public class AcademicStaffDAO {

    public List<String> getDepartments() throws SQLException {
        List<String> out = new ArrayList<>();
        String sql = "SELECT DISTINCT program FROM candidate WHERE program IS NOT NULL ORDER BY program";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(rs.getString("program"));
        }
        return out;
    }

    public List<Map<String,Object>> getSpecializations() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT id, name FROM specialization ORDER BY name";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> r = new HashMap<>();
                r.put("id", rs.getInt("id"));
                r.put("name", rs.getString("name"));
                out.add(r);
            }
        }
        return out;
    }

    public List<Map<String,Object>> getExpertise() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT id, specialization_id, name FROM expertise ORDER BY name";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> r = new HashMap<>();
                r.put("id", rs.getInt("id"));
                r.put("specialization_id", rs.getInt("specialization_id"));
                r.put("name", rs.getString("name"));
                out.add(r);
            }
        }
        return out;
    }

    public List<Map<String,Object>> getDivisions() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT id, specialization_id, expertise_id, name FROM division ORDER BY name";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> r = new HashMap<>();
                r.put("id", rs.getInt("id"));
                r.put("specialization_id", rs.getObject("specialization_id") != null ? rs.getInt("specialization_id") : 0);
                r.put("expertise_id",      rs.getObject("expertise_id")      != null ? rs.getInt("expertise_id")      : 0);
                r.put("name", rs.getString("name"));
                out.add(r);
            }
        }
        return out;
    }

    public List<Map<String,Object>> getAreas() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT id, specialization_id, division_id, name FROM area ORDER BY name";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> r = new HashMap<>();
                r.put("id",          rs.getInt("id"));
                r.put("spec_id",     rs.getObject("specialization_id") != null ? rs.getInt("specialization_id") : 0);
                r.put("division_id", rs.getObject("division_id")       != null ? rs.getInt("division_id")       : 0);
                r.put("name",        rs.getString("name"));
                out.add(r);
            }
        }
        return out;
    }

    /** Returns the academic_staff.id for the given user.id, or -1 if not found. */
    public int getStaffIdByUserId(int userId) throws SQLException {
        String sql = "SELECT id FROM academic_staff WHERE user_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        }
        return -1;
    }

    public List<Map<String,Object>> getUserAccountsByRole(String roleName) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT u.id, u.full_name, u.email FROM `user` u " +
                     "JOIN role r ON u.role_id = r.id " +
                     "WHERE r.name = ? ORDER BY u.full_name";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> r = new HashMap<>();
                    r.put("id", rs.getInt("id"));
                    r.put("full_name", rs.getString("full_name"));
                    r.put("email", rs.getString("email"));
                    out.add(r);
                }
            }
        }
        return out;
    }

    private List<String> getLookupNames(String tableName) throws SQLException {
        List<String> out = new ArrayList<>();
        String sql = "SELECT name FROM `" + tableName + "` ORDER BY sort_order, name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(rs.getString("name"));
        } catch (SQLException e) {
            // Silently return empty list if table not yet created (run migration 018 to populate)
            return out;
        }
        return out;
    }

    public List<String> getExaminerTitles() throws SQLException {
        return getLookupNames("examiner_title");
    }

    public List<String> getQualifications() throws SQLException {
        return getLookupNames("qualification_lookup");
    }

    public List<String> getAcademicRanks() throws SQLException {
        return getLookupNames("academic_rank_lookup");
    }

    public List<String> getGenders() throws SQLException {
        return getLookupNames("gender_lookup");
    }

    public List<String> getNationalities() throws SQLException {
        return getLookupNames("nationality");
    }

    public List<String> getCountries() throws SQLException {
        List<String> out = new ArrayList<>();
        String sql = "SELECT name FROM country ORDER BY " +
                     "CASE WHEN name='Malaysia' THEN 0 ELSE 1 END, name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(rs.getString("name"));
        } catch (SQLException e) {
            return out;
        }
        return out;
    }

    public List<Map<String,Object>> getUniversities() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT name, country FROM university_lookup ORDER BY sort_order, name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> r = new HashMap<>();
                r.put("name",    rs.getString("name"));
                r.put("country", rs.getString("country"));
                out.add(r);
            }
        } catch (SQLException e) {
            // Silently return empty list if table not yet created (run migration 019)
            return out;
        }
        return out;
    }
}
