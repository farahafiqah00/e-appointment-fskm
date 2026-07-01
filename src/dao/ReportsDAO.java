package dao;

import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Data-access methods for statistics and reports shown on admin/dean dashboards and export pages. */
public class ReportsDAO {

    public List<Map<String,Object>> getAppointmentCountByYear() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT YEAR(scheduled_at) AS year, COUNT(*) AS cnt FROM viva_appointment WHERE scheduled_at IS NOT NULL GROUP BY YEAR(scheduled_at) ORDER BY year DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new HashMap<>();
                row.put("year", rs.getObject("year"));
                row.put("count", rs.getInt("cnt"));
                out.add(row);
            }
        }
        return out;
    }

    public List<Map<String,Object>> getExaminerAppointmentFrequencyByYear() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT YEAR(va.scheduled_at) AS year, CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS examiner, COUNT(*) AS cnt FROM nomination n JOIN viva_appointment va ON va.nomination_id = n.id LEFT JOIN external_examiner ee ON n.external_examiner_id = ee.id WHERE va.scheduled_at IS NOT NULL GROUP BY year, examiner ORDER BY year DESC, cnt DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new HashMap<>();
                row.put("year", rs.getObject("year"));
                row.put("examiner", rs.getString("examiner"));
                row.put("count", rs.getInt("cnt"));
                out.add(row);
            }
        }
        return out;
    }

    public List<Map<String,Object>> getDepartmentStats() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT c.program AS department, COUNT(*) AS cnt FROM candidate c JOIN viva_appointment va ON va.candidate_id = c.id GROUP BY c.program ORDER BY cnt DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new HashMap<>();
                row.put("department", rs.getString("department"));
                row.put("count", rs.getInt("cnt"));
                out.add(row);
            }
        }
        return out;
    }

    /** Pivoted role frequency: per person, how many times as Chairperson / Recorder / Internal / External. */
    public List<Map<String,Object>> getRoleFrequencyPivoted() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT COALESCE(TRIM(CONCAT(COALESCE(CONCAT(ast.title, ' '), ''), COALESCE(ast.full_name, u.full_name, ''))), TRIM(CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name))) AS person_name, " +
            "  SUM(CASE WHEN ap.member_role = 'Chairperson'      THEN 1 ELSE 0 END) AS chair_cnt, " +
            "  SUM(CASE WHEN ap.member_role = 'Secretary'         THEN 1 ELSE 0 END) AS recorder_cnt, " +
            "  SUM(CASE WHEN ap.member_role = 'Internal Examiner' THEN 1 ELSE 0 END) AS internal_cnt, " +
            "  SUM(CASE WHEN ap.member_role = 'External Examiner' THEN 1 ELSE 0 END) AS external_cnt, " +
            "  COUNT(*) AS total " +
            "FROM appointment_panel ap " +
            "LEFT JOIN `user` u ON ap.internal_user_id = u.id " +
            "LEFT JOIN academic_staff ast ON ast.user_id = u.id " +
            "LEFT JOIN external_examiner ee ON ap.external_examiner_id = ee.id " +
            "GROUP BY person_name " +
            "ORDER BY total DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new LinkedHashMap<>();
                row.put("name",     rs.getString("person_name"));
                row.put("chair",    rs.getInt("chair_cnt"));
                row.put("recorder", rs.getInt("recorder_cnt"));
                row.put("internal", rs.getInt("internal_cnt"));
                row.put("external", rs.getInt("external_cnt"));
                row.put("total",    rs.getInt("total"));
                out.add(row);
            }
        }
        return out;
    }

    /** Yearly trends with PhD and Masters breakdown. */
    public List<Map<String,Object>> getYearlyTrends() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT YEAR(va.scheduled_at) AS year, COUNT(*) AS total, " +
            "  SUM(CASE WHEN COALESCE(p.name, c.program) LIKE '%PhD%' OR COALESCE(p.name, c.program) LIKE '%Doctor%' THEN 1 ELSE 0 END) AS phd_cnt, " +
            "  SUM(CASE WHEN COALESCE(p.name, c.program) LIKE '%Master%' THEN 1 ELSE 0 END) AS masters_cnt " +
            "FROM viva_appointment va " +
            "JOIN candidate c ON va.candidate_id = c.id " +
            "LEFT JOIN program p ON c.program_id = p.id " +
            "WHERE va.scheduled_at IS NOT NULL " +
            "GROUP BY YEAR(va.scheduled_at) ORDER BY year DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new LinkedHashMap<>();
                row.put("year",    rs.getObject("year"));
                row.put("total",   rs.getInt("total"));
                row.put("phd",     rs.getInt("phd_cnt"));
                row.put("masters", rs.getInt("masters_cnt"));
                out.add(row);
            }
        }
        return out;
    }

    /** Department stats with completed vs pending breakdown. */
    public List<Map<String,Object>> getDepartmentStatsFull() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT COALESCE(p.name, c.program) AS department, " +
            "  SUM(CASE WHEN va.status IN ('scheduled','letter_generated') THEN 1 ELSE 0 END) AS completed, " +
            "  SUM(CASE WHEN va.status = 'deferred'                       THEN 1 ELSE 0 END) AS pending, " +
            "  COUNT(*) AS total " +
            "FROM viva_appointment va " +
            "JOIN candidate c ON va.candidate_id = c.id " +
            "LEFT JOIN program p ON c.program_id = p.id " +
            "GROUP BY COALESCE(p.name, c.program) ORDER BY total DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new LinkedHashMap<>();
                row.put("department", rs.getString("department"));
                row.put("completed",  rs.getInt("completed"));
                row.put("pending",    rs.getInt("pending"));
                row.put("total",      rs.getInt("total"));
                out.add(row);
            }
        }
        return out;
    }

    /** Summary stats for a given year: total count, most active examiner, avg per month, active dept count. */
    public Map<String,Object> getSummaryStats(int year) throws SQLException {
        Map<String,Object> m = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            // Total for year
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM viva_appointment WHERE YEAR(scheduled_at) = ?")) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    m.put("totalYear", rs.next() ? rs.getInt("cnt") : 0);
                }
            }
            // Most active examiner in that year
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COALESCE(TRIM(CONCAT(COALESCE(CONCAT(ast.title, ' '), ''), COALESCE(ast.full_name, u.full_name, ''))), TRIM(CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name))) AS name, COUNT(*) AS cnt " +
                    "FROM appointment_panel ap " +
                    "LEFT JOIN `user` u ON ap.internal_user_id = u.id " +
                    "LEFT JOIN academic_staff ast ON ast.user_id = u.id " +
                    "LEFT JOIN external_examiner ee ON ap.external_examiner_id = ee.id " +
                    "JOIN viva_appointment va ON ap.appointment_id = va.id " +
                    "WHERE YEAR(va.scheduled_at) = ? " +
                    "GROUP BY name ORDER BY cnt DESC LIMIT 1")) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    m.put("mostActiveExaminer", rs.next() ? rs.getString("name") : "â€”");
                }
            }
            // Active departments
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(DISTINCT COALESCE(p.name, c.program)) AS cnt " +
                    "FROM viva_appointment va JOIN candidate c ON va.candidate_id = c.id " +
                    "LEFT JOIN program p ON c.program_id = p.id WHERE YEAR(va.scheduled_at) = ?")) {
                ps.setInt(1, year);
                try (ResultSet rs = ps.executeQuery()) {
                    m.put("activeDepts", rs.next() ? rs.getInt("cnt") : 0);
                }
            }
        }
        // Avg per month = total / 12
        int total = (Integer) m.getOrDefault("totalYear", 0);
        m.put("avgPerMonth", Math.round(total / 12.0 * 10) / 10.0);
        return m;
    }

    /** Collects recent activity from multiple tables; each source is queried independently so a missing table never blocks the rest. */
    public List<Map<String,Object>> getRecentActivity(int limit) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            // Nominations
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 'Nomination' AS type, CONCAT('Examiner nomination submitted by ', u.full_name) AS message, n.created_at AS created_at "
                    + "FROM nomination n JOIN `user` u ON n.nominator_user_id = u.id "
                    + "WHERE n.created_at IS NOT NULL ORDER BY n.created_at DESC LIMIT ?")) {
                ps.setInt(1, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) { out.add(actRow(rs)); }
                }
            } catch (SQLException ex) {
                System.err.println("[RecentActivity] nominations query failed: " + ex.getMessage());
            }
            // Viva appointments
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 'Appointment' AS type, CONCAT('Viva appointment scheduled for ', c.full_name, IF(va.scheduled_at IS NOT NULL, CONCAT(' at ', DATE_FORMAT(va.scheduled_at,'%Y-%m-%d %H:%i')), '')) AS message, va.created_at AS created_at "
                    + "FROM viva_appointment va JOIN candidate c ON va.candidate_id = c.id "
                    + "WHERE va.created_at IS NOT NULL ORDER BY va.created_at DESC LIMIT ?")) {
                ps.setInt(1, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) { out.add(actRow(rs)); }
                }
            } catch (SQLException ex) {
                System.err.println("[RecentActivity] appointments query failed: " + ex.getMessage());
            }
            // Appointment letters
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 'Letter' AS type, CONCAT('Appointment letter ', COALESCE(al.letter_number, CONCAT('#',al.id)), ' issued for appointment ID ', al.appointment_id) AS message, al.created_at AS created_at "
                    + "FROM appointment_letter al "
                    + "WHERE al.created_at IS NOT NULL ORDER BY al.created_at DESC LIMIT ?")) {
                ps.setInt(1, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) { out.add(actRow(rs)); }
                }
            } catch (SQLException ex) {
                System.err.println("[RecentActivity] letters query failed: " + ex.getMessage());
            }
            // New users
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 'User' AS type, CONCAT('New user created: ', full_name) AS message, created_at "
                    + "FROM `user` WHERE created_at IS NOT NULL ORDER BY created_at DESC LIMIT ?")) {
                ps.setInt(1, limit);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) { out.add(actRow(rs)); }
                }
            } catch (SQLException ex) {
                System.err.println("[RecentActivity] users query failed: " + ex.getMessage());
            }
        }
        // Sort combined results by created_at descending, keep top `limit`
        out.sort((a, b) -> {
            java.sql.Timestamp ta = (java.sql.Timestamp) a.get("created_at");
            java.sql.Timestamp tb = (java.sql.Timestamp) b.get("created_at");
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return tb.compareTo(ta);
        });
        return out.size() > limit ? out.subList(0, limit) : out;
    }

    private Map<String,Object> actRow(ResultSet rs) throws SQLException {
        Map<String,Object> row = new HashMap<>();
        row.put("type",       rs.getString("type"));
        row.put("message",    rs.getString("message"));
        row.put("created_at", rs.getTimestamp("created_at"));
        return row;
    }

    /** Dean dashboard stats: total candidates, upcoming appointments, completed this month, pending decisions. */
    public Map<String,Integer> getDeanDashboardStats() throws SQLException {
        Map<String,Integer> m = new java.util.LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM candidate")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("totalCandidates", rs.getInt("cnt")); }
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM viva_appointment WHERE scheduled_at >= NOW() AND status != 'cancelled'")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("upcomingAppointments", rs.getInt("cnt")); }
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM viva_appointment WHERE status IN ('scheduled','letter_generated') AND YEAR(scheduled_at)=YEAR(NOW()) AND MONTH(scheduled_at)=MONTH(NOW())")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("completedThisMonth", rs.getInt("cnt")); }
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM viva_appointment WHERE status = 'scheduled'")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("pendingDecisions", rs.getInt("cnt")); }
            }
        }
        m.putIfAbsent("totalCandidates", 0);
        m.putIfAbsent("upcomingAppointments", 0);
        m.putIfAbsent("completedThisMonth", 0);
        m.putIfAbsent("pendingDecisions", 0);
        return m;
    }

    /** Upcoming viva appointments list for dean dashboard. */
    public List<Map<String,Object>> getUpcomingAppointmentsList(int limit) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT c.full_name, COALESCE(p.name, c.program) AS programme, " +
            "  DATE(va.scheduled_at) AS viva_date, TIME_FORMAT(va.scheduled_at, '%h:%i %p') AS viva_time " +
            "FROM viva_appointment va " +
            "JOIN candidate c ON va.candidate_id = c.id " +
            "LEFT JOIN program p ON c.program_id = p.id " +
            "WHERE va.scheduled_at >= NOW() AND va.status != 'cancelled' " +
            "ORDER BY va.scheduled_at ASC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("name",      rs.getString("full_name"));
                    row.put("programme", rs.getString("programme"));
                    row.put("date",      rs.getString("viva_date"));
                    row.put("time",      rs.getString("viva_time"));
                    out.add(row);
                }
            }
        }
        return out;
    }

    /** Candidate count by programme for dean dashboard. */
    public List<Map<String,Object>> getCandidatesByProgramme() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT COALESCE(p.name, c.program) AS programme, COUNT(*) AS cnt " +
            "FROM candidate c " +
            "LEFT JOIN program p ON c.program_id = p.id " +
            "GROUP BY COALESCE(p.name, c.program) ORDER BY cnt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new LinkedHashMap<>();
                row.put("programme", rs.getString("programme"));
                row.put("count",     rs.getInt("cnt"));
                out.add(row);
            }
        }
        return out;
    }

    public Map<String,Integer> getDashboardStats() throws SQLException {
        Map<String,Integer> m = new HashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM candidate")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("totalCandidates", rs.getInt("cnt")); }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM nomination WHERE status IN ('pending','submitted')")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("pendingNominations", rs.getInt("cnt")); }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(DISTINCT external_examiner_id) AS cnt FROM nomination WHERE status = 'verified'")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("verifiedExaminers", rs.getInt("cnt")); }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS cnt FROM viva_appointment WHERE status = 'scheduled'")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("pendingAppointments", rs.getInt("cnt")); }
            }
        }
        m.putIfAbsent("totalCandidates", 0);
        m.putIfAbsent("pendingNominations", 0);
        m.putIfAbsent("verifiedExaminers", 0);
        m.putIfAbsent("pendingAppointments", 0);
        return m;
    }

    /** Counts for the three Action Alerts shown on the admin dashboard. */
    public Map<String,Integer> getAdminAlerts() throws SQLException {
        Map<String,Integer> m = new HashMap<>();
        try (Connection conn = DBConnection.getConnection()) {
            // Alert 1: nominations pending verification
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM nomination WHERE status IN ('pending','submitted')")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("pendingVerification", rs.getInt("cnt")); }
            }
            // Alert 2: verified nominations with no viva appointment scheduled yet
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM nomination n " +
                    "WHERE n.status = 'verified' " +
                    "AND NOT EXISTS (SELECT 1 FROM viva_appointment va WHERE va.nomination_id = n.id)")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("readyForAppointment", rs.getInt("cnt")); }
            }
            // Alert 3: appointments scheduled but letter not yet generated
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM viva_appointment WHERE status = 'scheduled'")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("letterNotGenerated", rs.getInt("cnt")); }
            }
            // Alert 4: external examiners who have not responded after 7 days
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM appointment_panel " +
                    "WHERE member_role = 'External Examiner' " +
                    "AND panel_response IS NULL " +
                    "AND letter_sent_at IS NOT NULL " +
                    "AND letter_sent_at < DATE_SUB(NOW(), INTERVAL 7 DAY)")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("overdueExternalResponse", rs.getInt("cnt")); }
            }
            // Alert 5: appointments declined by external examiner (need reassignment)
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM viva_appointment WHERE status = 'examiner_declined'")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("examinerDeclined", rs.getInt("cnt")); }
            }
            // Alert 6: letters approved (signed) by dean — emails need to be sent
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(DISTINCT va.id) AS cnt " +
                    "FROM viva_appointment va " +
                    "JOIN appointment_letter_approval ala ON ala.appointment_id = va.id AND ala.status = 'signed'")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) m.put("letterApprovedNotSent", rs.getInt("cnt")); }
            }
        }
        m.putIfAbsent("pendingVerification", 0);
        m.putIfAbsent("readyForAppointment", 0);
        m.putIfAbsent("letterNotGenerated", 0);
        m.putIfAbsent("overdueExternalResponse", 0);
        m.putIfAbsent("examinerDeclined", 0);
        m.putIfAbsent("letterApprovedNotSent", 0);
        return m;
    }

    /** Appointment status breakdown for a given year: list of {status, count}. */
    public List<Map<String,Object>> getStatusBreakdown(int year) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT COALESCE(status, 'unknown') AS status, COUNT(*) AS cnt " +
            "FROM viva_appointment " +
            "WHERE YEAR(scheduled_at) = ? " +
            "GROUP BY status ORDER BY cnt DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("status", rs.getString("status"));
                    row.put("count",  rs.getInt("cnt"));
                    out.add(row);
                }
            }
        }
        return out;
    }

    /** Full appointment detail for a specific year, including per-role panel responses. */
    public List<Map<String,Object>> getAppointmentsByYear(int year) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT c.full_name AS candidate_name, c.student_id AS matric_no, COALESCE(p.name, c.program) AS programme, " +
            "  c.thesis_title, " +
            "  DATE_FORMAT(va.scheduled_at, '%d %b %Y %H:%i') AS viva_date, va.status AS viva_status, " +
            "  MAX(CASE WHEN ap.member_role='Chairperson'       THEN TRIM(CONCAT(COALESCE(CONCAT(ast_2.title,' '),''), COALESCE(ast_2.full_name, u2.full_name))) END) AS chairperson, " +
            "  MAX(CASE WHEN ap.member_role='Secretary'          THEN TRIM(CONCAT(COALESCE(CONCAT(ast_2.title,' '),''), COALESCE(ast_2.full_name, u2.full_name))) END) AS recorder, " +
            "  MAX(CASE WHEN ap.member_role='Internal Examiner' THEN TRIM(CONCAT(COALESCE(CONCAT(ast_2.title,' '),''), COALESCE(ast_2.full_name, u2.full_name))) END) AS internal_examiner, " +
            "  MAX(CASE WHEN ap.member_role='External Examiner' THEN TRIM(CONCAT(COALESCE(CONCAT(ee.title,' '),''), ee.name))     END) AS external_examiner, " +
            "  MAX(CASE WHEN ap.member_role='Chairperson'       THEN ap.panel_response END) AS chair_response, " +
            "  MAX(CASE WHEN ap.member_role='Secretary'          THEN ap.panel_response END) AS recorder_response, " +
            "  MAX(CASE WHEN ap.member_role='Internal Examiner' THEN ap.panel_response END) AS internal_response, " +
            "  MAX(CASE WHEN ap.member_role='External Examiner' THEN ap.panel_response END) AS external_response, " +
            "  SUM(CASE WHEN ap.panel_response = 'accepted' THEN 1 ELSE 0 END) AS resp_accepted, " +
            "  SUM(CASE WHEN ap.panel_response = 'declined' THEN 1 ELSE 0 END) AS resp_declined, " +
            "  COUNT(ap.id) AS panel_total " +
            "FROM viva_appointment va " +
            "JOIN candidate c ON va.candidate_id = c.id " +
            "LEFT JOIN program p ON c.program_id = p.id " +
            "LEFT JOIN appointment_panel ap ON ap.appointment_id = va.id " +
            "LEFT JOIN `user` u2 ON ap.internal_user_id = u2.id " +
            "LEFT JOIN academic_staff ast_2 ON ast_2.user_id = u2.id " +
            "LEFT JOIN external_examiner ee ON ap.external_examiner_id = ee.id " +
            "WHERE YEAR(va.scheduled_at) = ? " +
            "GROUP BY va.id, c.full_name, c.student_id, programme, c.thesis_title, va.scheduled_at, va.status " +
            "ORDER BY va.scheduled_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("candidate",        rs.getString("candidate_name"));
                    row.put("matric",           rs.getString("matric_no"));
                    row.put("programme",        rs.getString("programme"));
                    row.put("thesis",           rs.getString("thesis_title"));
                    row.put("vivaDate",         rs.getString("viva_date"));
                    row.put("status",           rs.getString("viva_status"));
                    row.put("chairperson",      rs.getString("chairperson"));
                    row.put("recorder",         rs.getString("recorder"));
                    row.put("internalExaminer", rs.getString("internal_examiner"));
                    row.put("externalExaminer", rs.getString("external_examiner"));
                    row.put("chairResponse",    rs.getString("chair_response"));
                    row.put("recorderResponse", rs.getString("recorder_response"));
                    row.put("internalResponse", rs.getString("internal_response"));
                    row.put("externalResponse", rs.getString("external_response"));
                    row.put("respAccepted",     rs.getInt("resp_accepted"));
                    row.put("respDeclined",     rs.getInt("resp_declined"));
                    row.put("panelTotal",       rs.getInt("panel_total"));
                    out.add(row);
                }
            }
        }
        return out;
    }

    /** Role frequency pivoted, filtered to a specific year. */
    public List<Map<String,Object>> getRoleFrequencyByYear(int year) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT COALESCE(TRIM(CONCAT(COALESCE(CONCAT(ast.title, ' '), ''), COALESCE(ast.full_name, u.full_name, ''))), TRIM(CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name))) AS person_name, " +
            "  SUM(CASE WHEN ap.member_role = 'Chairperson'       THEN 1 ELSE 0 END) AS chair_cnt, " +
            "  SUM(CASE WHEN ap.member_role = 'Secretary'          THEN 1 ELSE 0 END) AS recorder_cnt, " +
            "  SUM(CASE WHEN ap.member_role = 'Internal Examiner' THEN 1 ELSE 0 END) AS internal_cnt, " +
            "  SUM(CASE WHEN ap.member_role = 'External Examiner' THEN 1 ELSE 0 END) AS external_cnt, " +
            "  COUNT(*) AS total " +
            "FROM appointment_panel ap " +
            "LEFT JOIN `user` u ON ap.internal_user_id = u.id " +
            "LEFT JOIN academic_staff ast ON ast.user_id = u.id " +
            "LEFT JOIN external_examiner ee ON ap.external_examiner_id = ee.id " +
            "JOIN viva_appointment va ON ap.appointment_id = va.id " +
            "WHERE YEAR(va.scheduled_at) = ? " +
            "GROUP BY person_name " +
            "ORDER BY total DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("name",     rs.getString("person_name"));
                    row.put("chair",    rs.getInt("chair_cnt"));
                    row.put("recorder", rs.getInt("recorder_cnt"));
                    row.put("internal", rs.getInt("internal_cnt"));
                    row.put("external", rs.getInt("external_cnt"));
                    row.put("total",    rs.getInt("total"));
                    out.add(row);
                }
            }
        }
        return out;
    }

    /** Distinct years present in viva_appointment (for year dropdown). */
    public List<Integer> getAvailableYears() throws SQLException {
        List<Integer> out = new ArrayList<>();
        String sql = "SELECT DISTINCT YEAR(scheduled_at) AS yr FROM viva_appointment WHERE scheduled_at IS NOT NULL ORDER BY yr DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(rs.getInt("yr"));
        }
        return out;
    }
}

