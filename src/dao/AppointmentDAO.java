package dao;

import model.VivaAppointment;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Data-access methods for viva appointments, panel members, and letter approval workflow. */
public class AppointmentDAO {

    /** Dean view: list with panel roles and viva date joined in. */
    public List<VivaAppointment> findAllWithRoles(String q, String statusFilter, String level, boolean showArchived) throws SQLException {
        List<VivaAppointment> out = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT va.id, va.candidate_id, c.student_id, c.full_name AS candidate_name, " +
            "COALESCE(p.name, c.program) AS candidate_program, p.level AS candidate_program_level, c.status AS candidate_viva_status, " +
            "va.status AS appointment_status, va.scheduled_at, " +
            "MAX(CASE WHEN ap.member_role='Chairperson'       THEN TRIM(CONCAT(COALESCE(CONCAT(ast_c.title,' '),''), COALESCE(ast_c.full_name, u_c.full_name))) END) AS chair_name, " +
            "MAX(CASE WHEN ap.member_role='Secretary'         THEN TRIM(CONCAT(COALESCE(CONCAT(ast_r.title,' '),''), COALESCE(ast_r.full_name, u_r.full_name))) END) AS rec_name, " +
            "MAX(CASE WHEN ap.member_role='Internal Examiner' THEN TRIM(CONCAT(COALESCE(CONCAT(ast_i.title,' '),''), COALESCE(ast_i.full_name, u_i.full_name))) END) AS int_name, " +
            "MAX(CASE WHEN ap.member_role='External Examiner' THEN TRIM(CONCAT(COALESCE(CONCAT(ee.title,' '),''), ee.name))  END) AS ext_name " +
            "FROM viva_appointment va " +
            "JOIN candidate c ON va.candidate_id = c.id " +
            "LEFT JOIN program p ON c.program_id = p.id " +
            "LEFT JOIN appointment_panel ap ON ap.appointment_id = va.id " +
            "LEFT JOIN `user` u_c ON ap.internal_user_id = u_c.id AND ap.member_role = 'Chairperson' " +
            "LEFT JOIN `user` u_r ON ap.internal_user_id = u_r.id AND ap.member_role = 'Secretary' " +
            "LEFT JOIN `user` u_i ON ap.internal_user_id = u_i.id AND ap.member_role = 'Internal Examiner' " +
            "LEFT JOIN external_examiner ee ON ap.external_examiner_id = ee.id AND ap.member_role = 'External Examiner' " +
            "LEFT JOIN academic_staff ast_c ON ast_c.user_id = u_c.id " +
            "LEFT JOIN academic_staff ast_r ON ast_r.user_id = u_r.id " +
            "LEFT JOIN academic_staff ast_i ON ast_i.user_id = u_i.id " +
            "WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (c.full_name LIKE ? OR c.student_id LIKE ? OR c.program LIKE ? OR p.name LIKE ?)");
            String like = "%" + q.trim() + "%";
            params.add(like); params.add(like); params.add(like); params.add(like);
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND va.status = ?");
            params.add(statusFilter.trim());
        } else if (!showArchived) {
            sql.append(" AND c.status != 'completed'");
        }
        if (level != null && !level.trim().isEmpty()) {
            sql.append(" AND p.level = ?"); params.add(level.trim());
        }
        sql.append(" GROUP BY va.id, va.candidate_id, c.student_id, candidate_name, candidate_program, candidate_program_level, candidate_viva_status, appointment_status, va.scheduled_at");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VivaAppointment va = new VivaAppointment();
                    va.setId(rs.getInt("id"));
                    va.setCandidateId(rs.getInt("candidate_id"));
                    va.setCandidateStudentId(rs.getString("student_id"));
                    va.setCandidateName(rs.getString("candidate_name"));
                    va.setCandidateProgram(rs.getString("candidate_program"));
                    va.setCandidateProgramLevel(rs.getString("candidate_program_level"));
                    va.setCandidateVivaStatus(rs.getString("candidate_viva_status"));
                    va.setStatus(rs.getString("appointment_status"));
                    va.setScheduledAt(rs.getTimestamp("scheduled_at"));
                    va.setChairpersonName(rs.getString("chair_name"));
                    va.setRecorderName(rs.getString("rec_name"));
                    va.setInternalExaminerName(rs.getString("int_name"));
                    va.setExternalExaminerName(rs.getString("ext_name"));
                    out.add(va);
                }
            }
        }
        return out;
    }

    public List<VivaAppointment> findAllReady(String q, String statusFilter, String level, boolean showArchived) throws SQLException {
        return findAllReady(q, statusFilter, level, showArchived, null, false);
    }

    public List<VivaAppointment> findAllReady(String q, String statusFilter, String level, boolean showArchived, String letterApprovalFilter, boolean overdueOnly) throws SQLException {
        List<VivaAppointment> out = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT va.id, va.candidate_id, c.student_id, c.full_name AS candidate_name, " +
            "COALESCE(p.name, c.program) AS candidate_program, p.level AS candidate_program_level, c.status AS candidate_viva_status, " +
            "va.status AS appointment_status, va.scheduled_at, va.venue " +
            "FROM viva_appointment va " +
            "JOIN candidate c ON va.candidate_id = c.id " +
            "LEFT JOIN program p ON c.program_id = p.id " +
            "LEFT JOIN appointment_letter_approval ala ON ala.appointment_id = va.id " +
            "WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (c.full_name LIKE ? OR c.student_id LIKE ? OR c.program LIKE ? OR p.name LIKE ?)");
            String like = "%" + q.trim() + "%";
            params.add(like); params.add(like); params.add(like); params.add(like);
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND va.status = ?");
            params.add(statusFilter.trim());
        } else if (!showArchived) {
            sql.append(" AND c.status != 'completed'");
        }
        if (level != null && !level.trim().isEmpty()) {
            sql.append(" AND p.level = ?"); params.add(level.trim());
        }
        if ("pending".equals(letterApprovalFilter)) {
            sql.append(" AND ala.status = 'pending'");
        } else if ("signed".equals(letterApprovalFilter)) {
            sql.append(" AND ala.status = 'signed'");
        } else if ("signed_unsent".equals(letterApprovalFilter)) {
            sql.append(" AND ala.status = 'signed'" +
                       " AND EXISTS (SELECT 1 FROM appointment_panel ap_us WHERE ap_us.appointment_id = va.id AND ap_us.letter_sent = 0)");
        }
        if (overdueOnly) {
            sql.append(" AND EXISTS (SELECT 1 FROM appointment_panel ap_od WHERE ap_od.appointment_id = va.id" +
                       " AND ap_od.member_role = 'External Examiner'" +
                       " AND ap_od.panel_response IS NULL" +
                       " AND ap_od.letter_sent_at IS NOT NULL" +
                       " AND ap_od.letter_sent_at < DATE_SUB(NOW(), INTERVAL 7 DAY))");
        }
        // Priority sort: declined and pending actions float to top; archived statuses sink to bottom.
        sql.append(" ORDER BY CASE va.status WHEN 'examiner_declined' THEN 0 WHEN 'pending' THEN 1 WHEN 'scheduled' THEN 2 WHEN 'letter_generated' THEN 3 WHEN 'deferred' THEN 4 ELSE 5 END, va.scheduled_at IS NULL DESC, va.scheduled_at ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VivaAppointment va = new VivaAppointment();
                    va.setId(rs.getInt("id"));
                    va.setCandidateId(rs.getInt("candidate_id"));
                    va.setCandidateStudentId(rs.getString("student_id"));
                    va.setCandidateName(rs.getString("candidate_name"));
                    va.setCandidateProgram(rs.getString("candidate_program"));
                    va.setCandidateProgramLevel(rs.getString("candidate_program_level"));
                    va.setCandidateVivaStatus(rs.getString("candidate_viva_status"));
                    va.setStatus(rs.getString("appointment_status"));
                    va.setScheduledAt(rs.getTimestamp("scheduled_at"));
                    va.setVenue(rs.getString("venue"));
                    out.add(va);
                }
            }
        }
        return out;
    }

    public VivaAppointment findById(int id) throws SQLException {
        String sql = "SELECT va.*, c.student_id, c.full_name AS candidate_name, " +
                     "COALESCE(p.name, c.program) AS candidate_program, p.name_ms AS candidate_program_ms, p.level AS candidate_program_level, " +
                 "c.thesis_title, TRIM(CONCAT(COALESCE(CONCAT(ast_sup.title, ' '), ''), COALESCE(ast_sup.full_name, c.supervisor_name))) AS supervisor_name, c.status AS candidate_viva_status, ast_sup.user_id AS supervisor_user_id " +
                     "FROM viva_appointment va " +
                     "JOIN candidate c ON va.candidate_id = c.id " +
                     "LEFT JOIN program p ON c.program_id = p.id " +
                 "LEFT JOIN academic_staff ast_sup ON ast_sup.id = c.supervisor_id " +
                     "WHERE va.id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    VivaAppointment va = new VivaAppointment();
                    va.setId(rs.getInt("id"));
                    va.setCandidateId(rs.getInt("candidate_id"));
                    va.setNominationId(rs.getObject("nomination_id") != null ? rs.getInt("nomination_id") : null);
                    va.setScheduledAt(rs.getTimestamp("scheduled_at"));
                    va.setVenue(rs.getString("venue"));
                    va.setDurationMinutes(rs.getObject("duration_minutes") != null ? rs.getInt("duration_minutes") : 0);
                    va.setStatus(rs.getString("status"));
                    va.setCreatedAt(rs.getTimestamp("created_at"));
                    va.setCandidateStudentId(rs.getString("student_id"));
                    va.setCandidateName(rs.getString("candidate_name"));
                    va.setCandidateProgram(rs.getString("candidate_program"));
                    va.setCandidateProgramMS(rs.getString("candidate_program_ms"));
                    va.setCandidateProgramLevel(rs.getString("candidate_program_level"));
                    va.setThesisTitle(rs.getString("thesis_title"));
                    va.setSupervisorName(rs.getString("supervisor_name"));
                    va.setSupervisorUserId(rs.getObject("supervisor_user_id") != null ? rs.getInt("supervisor_user_id") : null);
                    va.setCandidateVivaStatus(rs.getString("candidate_viva_status"));
                    String panelSql = "SELECT ap.id AS panel_id, ap.member_role, ap.internal_user_id, ap.external_examiner_id, ap.letter_signed, ap.letter_sent, ap.letter_approved, " +
                                      "ap.response_token, ap.panel_response, ap.rejection_reason, ap.responded_at, ap.letter_sent_at, " +
                                      "TRIM(CONCAT(COALESCE(CONCAT(ast.title, ' '), ''), COALESCE(ast.full_name, u.full_name))) AS user_name, u.email AS user_email, " +
                                      "COALESCE(ast.title, '') AS user_title, " +
                                      "COALESCE(ast.academic_rank, '') AS user_position, " +
                                      "CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS ee_name, ee.email AS ee_email, " +
                                      "ee.title AS ee_title, ee.affiliation AS ee_affiliation, " +
                                      "COALESCE(ee.country, cnt.name) AS ee_country " +
                                      "FROM appointment_panel ap " +
                                      "LEFT JOIN `user` u ON u.id = ap.internal_user_id " +
                                      "LEFT JOIN academic_staff ast ON ast.user_id = ap.internal_user_id " +
                                      "LEFT JOIN external_examiner ee ON ee.id = ap.external_examiner_id " +
                                      "LEFT JOIN country cnt ON cnt.id = ee.country_id " +
                                      "WHERE ap.appointment_id = ?";
                    try (PreparedStatement ps2 = conn.prepareStatement(panelSql)) {
                        ps2.setInt(1, id);
                        try (ResultSet rs2 = ps2.executeQuery()) {
                            List<Map<String,Object>> members = new ArrayList<>();
                            while (rs2.next()) {
                                String role = rs2.getString("member_role");
                                boolean isExternal = "External Examiner".equals(role);
                                Map<String,Object> m = new LinkedHashMap<>();
                                m.put("panel_id", rs2.getInt("panel_id"));
                                m.put("role", role);
                                m.put("internal_user_id",    rs2.getObject("internal_user_id"));
                                m.put("external_examiner_id", rs2.getObject("external_examiner_id"));
                                m.put("name", isExternal ? rs2.getString("ee_name") : rs2.getString("user_name"));
                                m.put("email", isExternal ? rs2.getString("ee_email") : rs2.getString("user_email"));
                                m.put("title", isExternal ? rs2.getString("ee_title") : rs2.getString("user_title"));
                                m.put("affiliation", isExternal ? rs2.getString("ee_affiliation") : null);
                                m.put("country", isExternal ? rs2.getString("ee_country") : null);
                                m.put("position", isExternal ? null : rs2.getString("user_position"));
                                m.put("letter_signed", rs2.getInt("letter_signed") == 1);
                                m.put("letter_sent", rs2.getInt("letter_sent") == 1);
                                m.put("letter_approved", rs2.getInt("letter_approved") == 1);
                                m.put("response_token", rs2.getString("response_token"));
                                m.put("panel_response", rs2.getString("panel_response"));
                                m.put("rejection_reason", rs2.getString("rejection_reason"));
                                m.put("responded_at", rs2.getTimestamp("responded_at"));
                                m.put("letter_sent_at", rs2.getTimestamp("letter_sent_at"));
                                members.add(m);
                                // backward-compat single-value fields
                                if ("Chairperson".equals(role)) {
                                    va.setChairpersonName(rs2.getString("user_name"));
                                    va.setChairpersonId(rs2.getObject("internal_user_id") != null ? rs2.getInt("internal_user_id") : null);
                                } else if ("Secretary".equals(role)) {
                                    va.setRecorderName(rs2.getString("user_name"));
                                    va.setRecorderId(rs2.getObject("internal_user_id") != null ? rs2.getInt("internal_user_id") : null);
                                } else if ("Internal Examiner".equals(role) && va.getInternalExaminerId() == null) {
                                    va.setInternalExaminerName(rs2.getString("user_name"));
                                    va.setInternalExaminerId(rs2.getObject("internal_user_id") != null ? rs2.getInt("internal_user_id") : null);
                                } else if ("External Examiner".equals(role) && va.getExternalExaminerId() == null) {
                                    va.setExternalExaminerName(rs2.getString("ee_name"));
                                    va.setExternalExaminerId(rs2.getObject("external_examiner_id") != null ? rs2.getInt("external_examiner_id") : null);
                                }
                            }
                            va.setPanelMembers(members);
                        }
                    }
                    va.setLetterApproval(getLetterApprovalByAppointmentId(id));
                    return va;
                }
            }
        }
        return null;
    }

    /** Returns internal academic staff users available for panel roles, with full 4-level hierarchy. */
    public List<Map<String, Object>> getInternalStaff() throws SQLException {
        List<Map<String, Object>> out = new ArrayList<>();
        String sql = "SELECT u.id, CONCAT(COALESCE(CONCAT(ast.title, ' '), ''), COALESCE(ast.full_name, u.full_name)) AS full_name, " +
                     "ast.id AS staff_id, " +
                     "COALESCE(s.name, '')  AS specialization_name, " +
                     "COALESCE(e.name, '')  AS expertise_name, " +
                     "COALESCE(dv.name, '') AS division_name, " +
                     "COALESCE(ar.name, '') AS area_name, " +
                     "COALESCE(ast.academic_rank, '') AS academic_rank " +
                     "FROM `user` u " +
                     "JOIN role r ON u.role_id = r.id " +
                     "LEFT JOIN academic_staff ast ON ast.user_id = u.id " +
                     "LEFT JOIN specialization s  ON s.id  = ast.specialization_id " +
                     "LEFT JOIN expertise e        ON e.id  = ast.expertise_id " +
                     "LEFT JOIN division dv        ON dv.id = ast.division_id " +
                     "LEFT JOIN area ar            ON ar.id = ast.area_id " +
                     "WHERE r.name IN ('Academician','Dean') AND u.status = 'active' " +
                     "ORDER BY full_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("full_name", rs.getString("full_name"));
                m.put("staff_id", rs.getObject("staff_id"));
                m.put("specialization_name", rs.getString("specialization_name"));
                m.put("expertise_name", rs.getString("expertise_name"));
                m.put("division_name", rs.getString("division_name"));
                m.put("area_name", rs.getString("area_name"));
                m.put("academic_rank", rs.getString("academic_rank"));
                out.add(m);
            }
        }
        return out;
    }

    /** Returns verified external examiners available for panel roles. */
    public List<Map<String, Object>> getVerifiedExaminers() throws SQLException {
        List<Map<String, Object>> out = new ArrayList<>();
        String sql = "SELECT DISTINCT ee.id, CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS name, ee.affiliation, " +
                     "COALESCE(s.name, ee.specialization, '') AS specialization_name, " +
                     "COALESCE(exp.name, '') AS expertise_name, ee.name AS sort_name " +
                     "FROM external_examiner ee " +
                     "JOIN nomination n ON n.external_examiner_id = ee.id " +
                     "LEFT JOIN specialization s   ON s.id   = ee.specialization_id " +
                     "LEFT JOIN expertise      exp ON exp.id = ee.expertise_id " +
                     "WHERE n.status = 'verified' ORDER BY sort_name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("name", rs.getString("name"));
                m.put("affiliation", rs.getString("affiliation"));
                m.put("specialization_name", rs.getString("specialization_name"));
                m.put("expertise_name", rs.getString("expertise_name"));
                out.add(m);
            }
        }
        return out;
    }

    /**
     * Returns a pivot table of everyone's role history (internal staff + external examiners),
     * including all 4 hierarchy levels. People with zero history are included with counts = 0.
     * Uses 3 separate queries merged in Java to avoid MySQL UNION subquery issues.
     */
    public List<Map<String, Object>> getPanelRoleStats() throws SQLException {
        List<Map<String, Object>> out = new ArrayList<>();
        java.util.Set<String> seen = new java.util.HashSet<>();

        try (Connection conn = DBConnection.getConnection()) {

            // Branch 1: people already assigned to at least one panel
            // CASE on internal_user_id avoids the COALESCE-empty-string bug:
            // when ap.internal_user_id is NULL, the internal branch evaluates to ''
            // and COALESCE('', ee_name) returns '' instead of ee_name.
            String sql1 =
                "SELECT CASE WHEN ap.internal_user_id IS NOT NULL " +
                "       THEN TRIM(CONCAT(COALESCE(CONCAT(ast.title,' '),''), COALESCE(ast.full_name, u.full_name,''))) " +
                "       ELSE TRIM(CONCAT(COALESCE(CONCAT(ee.title,' '),''), COALESCE(ee.name,''))) END AS person_name, " +
                "  COALESCE(s_u.name, s_e.name, COALESCE(ee.specialization,'')) AS specialization_name, " +
                "  COALESCE(exp_u.name, exp_e.name, '') AS expertise_name, " +
                "  COALESCE(dv_u.name,  dv_e.name,  '') AS division_name, " +
                "  COALESCE(ar_u.name,  ar_e.name,  '') AS area_name, " +
                "  SUM(CASE WHEN ap.member_role='Chairperson'       THEN 1 ELSE 0 END) AS chair_count, " +
                "  SUM(CASE WHEN ap.member_role='Secretary'         THEN 1 ELSE 0 END) AS recorder_count, " +
                "  SUM(CASE WHEN ap.member_role='Internal Examiner' THEN 1 ELSE 0 END) AS internal_count, " +
                "  SUM(CASE WHEN ap.member_role='External Examiner' THEN 1 ELSE 0 END) AS external_count, " +
                "  COUNT(*) AS total_count, " +
                "  CASE WHEN MAX(ap.internal_user_id) IS NOT NULL THEN 'internal' ELSE 'external' END AS type " +
                "FROM appointment_panel ap " +
                "LEFT JOIN `user` u           ON ap.internal_user_id    = u.id " +
                "LEFT JOIN academic_staff ast  ON ast.user_id            = u.id " +
                "LEFT JOIN specialization s_u  ON s_u.id  = ast.specialization_id " +
                "LEFT JOIN expertise      exp_u ON exp_u.id = ast.expertise_id " +
                "LEFT JOIN division       dv_u  ON dv_u.id  = ast.division_id " +
                "LEFT JOIN area           ar_u  ON ar_u.id  = ast.area_id " +
                "LEFT JOIN external_examiner ee ON ap.external_examiner_id = ee.id " +
                "LEFT JOIN specialization s_e  ON s_e.id  = ee.specialization_id " +
                "LEFT JOIN expertise      exp_e ON exp_e.id = ee.expertise_id " +
                "LEFT JOIN division       dv_e  ON dv_e.id  = ee.division_id " +
                "LEFT JOIN area           ar_e  ON ar_e.id  = ee.area_id " +
                "GROUP BY person_name, specialization_name, expertise_name, division_name, area_name " +
                "ORDER BY specialization_name, expertise_name, person_name";
            try (PreparedStatement ps = conn.prepareStatement(sql1);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name = rs.getString("person_name");
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("name",               name);
                    m.put("specialization_name", rs.getString("specialization_name"));
                    m.put("expertise_name",      rs.getString("expertise_name"));
                    m.put("division_name",       rs.getString("division_name"));
                    m.put("area_name",           rs.getString("area_name"));
                    m.put("chair_count",         rs.getInt("chair_count"));
                    m.put("recorder_count",      rs.getInt("recorder_count"));
                    m.put("internal_count",      rs.getInt("internal_count"));
                    m.put("external_count",      rs.getInt("external_count"));
                    m.put("total_count",         rs.getInt("total_count"));
                    m.put("type",                rs.getString("type"));
                    out.add(m);
                    if (name != null) seen.add(name);
                }
            }

            // Branch 2: active Academician/Dean users not yet on any panel
            String sql2 =
                "SELECT TRIM(CONCAT(COALESCE(CONCAT(ast.title, ' '), ''), COALESCE(ast.full_name, u.full_name, ''))) AS person_name, 'internal' AS type, " +
                "  COALESCE(s.name,'') AS specialization_name, " +
                "  COALESCE(exp.name,'') AS expertise_name, " +
                "  COALESCE(dv.name,'') AS division_name, " +
                "  COALESCE(ar.name,'') AS area_name " +
                "FROM `user` u " +
                "JOIN role r ON u.role_id = r.id " +
                "LEFT JOIN academic_staff ast ON ast.user_id = u.id " +
                "LEFT JOIN specialization s   ON s.id   = ast.specialization_id " +
                "LEFT JOIN expertise      exp ON exp.id = ast.expertise_id " +
                "LEFT JOIN division       dv  ON dv.id  = ast.division_id " +
                "LEFT JOIN area           ar  ON ar.id  = ast.area_id " +
                "WHERE r.name IN ('Academician','Dean') AND u.status = 'active' " +
                "ORDER BY u.full_name";
            try (PreparedStatement ps = conn.prepareStatement(sql2);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name = rs.getString("person_name");
                    if (name != null && seen.contains(name)) continue;
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("name",               name);
                    m.put("specialization_name", rs.getString("specialization_name"));
                    m.put("expertise_name",      rs.getString("expertise_name"));
                    m.put("division_name",       rs.getString("division_name"));
                    m.put("area_name",           rs.getString("area_name"));
                    m.put("chair_count",   0); m.put("recorder_count", 0);
                    m.put("internal_count",0); m.put("external_count", 0);
                    m.put("total_count",   0);
                    m.put("type",          rs.getString("type"));
                    out.add(m);
                    if (name != null) seen.add(name);
                }
            }

            // Branch 3: verified external examiners not yet on any panel
            String sql3 =
                "SELECT DISTINCT TRIM(CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), COALESCE(ee.name,''))) AS person_name, 'external' AS type, " +
                "  COALESCE(s.name, COALESCE(ee.specialization,'')) AS specialization_name, " +
                "  COALESCE(exp.name,'') AS expertise_name, " +
                "  COALESCE(dv.name,'') AS division_name, " +
                "  COALESCE(ar.name,'') AS area_name " +
                "FROM external_examiner ee " +
                "JOIN nomination n ON n.external_examiner_id = ee.id AND n.status = 'verified' " +
                "LEFT JOIN specialization s   ON s.id   = ee.specialization_id " +
                "LEFT JOIN expertise      exp ON exp.id = ee.expertise_id " +
                "LEFT JOIN division       dv  ON dv.id  = ee.division_id " +
                "LEFT JOIN area           ar  ON ar.id  = ee.area_id " +
                "ORDER BY ee.name";
            try (PreparedStatement ps = conn.prepareStatement(sql3);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name = rs.getString("person_name");
                    if (name != null && seen.contains(name)) continue;
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("name",               name);
                    m.put("specialization_name", rs.getString("specialization_name"));
                    m.put("expertise_name",      rs.getString("expertise_name"));
                    m.put("division_name",       rs.getString("division_name"));
                    m.put("area_name",           rs.getString("area_name"));
                    m.put("chair_count",   0); m.put("recorder_count", 0);
                    m.put("internal_count",0); m.put("external_count", 0);
                    m.put("total_count",   0);
                    m.put("type",          rs.getString("type"));
                    out.add(m);
                }
            }
        }
        return out;
    }

    /** Marks or unmarks a panel member's signed letter as received. */
    public void markLetterSigned(int panelMemberId, boolean signed) throws SQLException {
        String sql = "UPDATE appointment_panel SET letter_signed = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, signed ? 1 : 0);
            ps.setInt(2, panelMemberId);
            ps.executeUpdate();
        }
    }

    /** Marks that the appointment letter email has been sent to a panel member. */
    public void markLetterSent(int panelMemberId) throws SQLException {
        String sql = "UPDATE appointment_panel SET letter_sent = 1, letter_sent_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, panelMemberId);
            ps.executeUpdate();
        }
    }

    /** Returns one approval row for the appointment, or null if none assigned yet. */
    public Map<String,Object> getLetterApprovalByAppointmentId(int appointmentId) throws SQLException {
        String sql =
            "SELECT ala.id, ala.appointment_id, ala.signer_user_id, ala.signer_label, ala.status, " +
            "ala.requested_by, ala.requested_at, ala.signed_by, ala.signed_at, ala.signature_image, " +
            "COALESCE(u.full_name, '') AS signer_name, COALESCE(u.email, '') AS signer_email, COALESCE(u.phone, '') AS signer_phone, " +
            "COALESCE(ast.title, ast_nm.title, '') AS signer_academic_title, " +
            "COALESCE(ast.academic_rank, ast_nm.academic_rank, '') AS signer_academic_rank " +
            "FROM appointment_letter_approval ala " +
            "LEFT JOIN `user` u ON u.id = ala.signer_user_id " +
            "LEFT JOIN academic_staff ast    ON ast.user_id = ala.signer_user_id " +
            "LEFT JOIN academic_staff ast_nm ON ast.id IS NULL " +
            "                               AND ast_nm.user_id IS NULL " +
            "                               AND ast_nm.full_name = u.full_name " +
            "WHERE ala.appointment_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Map<String,Object> out = new LinkedHashMap<>();
                out.put("id", rs.getInt("id"));
                out.put("appointment_id", rs.getInt("appointment_id"));
                out.put("signer_user_id", rs.getInt("signer_user_id"));
                out.put("signer_label", rs.getString("signer_label"));
                out.put("status", rs.getString("status"));
                out.put("requested_by", rs.getObject("requested_by"));
                out.put("requested_at", rs.getTimestamp("requested_at"));
                out.put("signed_by", rs.getObject("signed_by"));
                out.put("signed_at", rs.getTimestamp("signed_at"));
                out.put("signature_image", rs.getString("signature_image"));
                out.put("signer_name", rs.getString("signer_name"));
                out.put("signer_email", rs.getString("signer_email"));
                out.put("signer_phone", rs.getString("signer_phone"));
                out.put("signer_academic_title", rs.getString("signer_academic_title"));
                out.put("signer_academic_rank", rs.getString("signer_academic_rank"));
                return out;
            }
        }
    }

    public boolean isLetterApprovalSigned(int appointmentId) throws SQLException {
        Map<String,Object> approval = getLetterApprovalByAppointmentId(appointmentId);
        return approval != null && "signed".equalsIgnoreCase(String.valueOf(approval.get("status")));
    }

    /** True if the user is the assigned signer for this appointment (pending or signed). */
    public boolean isUserAssignedLetterSigner(int appointmentId, int userId) throws SQLException {
        String sql =
            "SELECT 1 FROM appointment_letter_approval " +
            "WHERE appointment_id = ? AND signer_user_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Active admins used for signature-complete notification. */
    public List<Map<String,Object>> getActiveAdminRecipients() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT u.id, u.full_name, u.email " +
            "FROM `user` u " +
            "JOIN role r ON r.id = u.role_id " +
            "WHERE r.name = 'Admin' AND u.status = 'active' AND u.email IS NOT NULL AND u.email <> '' " +
            "ORDER BY u.id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("name", rs.getString("full_name"));
                m.put("email", rs.getString("email"));
                out.add(m);
            }
        }
        return out;
    }

    /** Returns pending letter approvals assigned to a signer, newest first. */
    public List<Map<String,Object>> getPendingLetterApprovalsForSigner(int signerUserId, int limit) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT ala.id, ala.appointment_id, ala.signer_label, ala.requested_at, " +
            "c.student_id, c.full_name AS candidate_name, COALESCE(p.name, c.program) AS candidate_program " +
            "FROM appointment_letter_approval ala " +
            "JOIN viva_appointment va ON va.id = ala.appointment_id " +
            "JOIN candidate c ON c.id = va.candidate_id " +
            "LEFT JOIN program p ON p.id = c.program_id " +
            "WHERE ala.signer_user_id = ? AND ala.status = 'pending' " +
            "ORDER BY ala.requested_at DESC " +
            "LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, signerUserId);
            ps.setInt(2, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("appointment_id", rs.getInt("appointment_id"));
                    m.put("signer_label", rs.getString("signer_label"));
                    m.put("requested_at", rs.getTimestamp("requested_at"));
                    m.put("student_id", rs.getString("student_id"));
                    m.put("candidate_name", rs.getString("candidate_name"));
                    m.put("candidate_program", rs.getString("candidate_program"));
                    out.add(m);
                }
            }
        }
        return out;
    }

    /** Returns ALL letter approvals (pending + signed) assigned to a signer, newest first. */
    public List<Map<String,Object>> getAllLetterApprovalsForSigner(int signerUserId) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT ala.id, ala.appointment_id, ala.signer_label, ala.status, " +
            "ala.requested_at, ala.signed_at, " +
            "c.student_id, c.full_name AS candidate_name, COALESCE(p.name, c.program) AS candidate_program, " +
            "va.scheduled_at " +
            "FROM appointment_letter_approval ala " +
            "JOIN viva_appointment va ON va.id = ala.appointment_id " +
            "JOIN candidate c ON c.id = va.candidate_id " +
            "LEFT JOIN program p ON p.id = c.program_id " +
            "WHERE ala.signer_user_id = ? " +
            "ORDER BY ala.status ASC, ala.requested_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, signerUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("appointment_id", rs.getInt("appointment_id"));
                    m.put("signer_label", rs.getString("signer_label"));
                    m.put("status", rs.getString("status"));
                    m.put("requested_at", rs.getTimestamp("requested_at"));
                    m.put("signed_at", rs.getTimestamp("signed_at"));
                    m.put("student_id", rs.getString("student_id"));
                    m.put("candidate_name", rs.getString("candidate_name"));
                    m.put("candidate_program", rs.getString("candidate_program"));
                    m.put("scheduled_at", rs.getTimestamp("scheduled_at"));
                    out.add(m);
                }
            }
        }
        return out;
    }

    /**
     * Returns eligible signers for the appointment.
     * - Dean users are primary signers.
     * - Academicians whose academic_rank contains TDA/TDB are alternates.
     * - If candidate is supervised by the dean, dean is excluded from this list.
     */
    public List<Map<String,Object>> getEligibleLetterSigners(int appointmentId) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        Integer supervisorUserId = null;
        Integer deanUserId = null;

        String lookupSql =
            "SELECT c.supervisor_id, ast.user_id AS supervisor_user_id, " +
            "(SELECT u2.id FROM `user` u2 JOIN role r2 ON r2.id = u2.role_id " +
            " WHERE r2.name = 'Dean' AND u2.status = 'active' ORDER BY u2.id LIMIT 1) AS dean_user_id " +
            "FROM viva_appointment va " +
            "JOIN candidate c ON c.id = va.candidate_id " +
            "LEFT JOIN academic_staff ast ON ast.id = c.supervisor_id " +
            "WHERE va.id = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(lookupSql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    supervisorUserId = rs.getObject("supervisor_user_id") != null ? rs.getInt("supervisor_user_id") : null;
                    deanUserId = rs.getObject("dean_user_id") != null ? rs.getInt("dean_user_id") : null;
                }
            }

            String signerSql =
                "SELECT u.id AS user_id, u.full_name, u.email, r.name AS role_name, " +
                "COALESCE(ast.administrative_position, ast_nm.administrative_position, '') AS administrative_position, " +
                "COALESCE(ast.title, ast_nm.title, '') AS title " +
                "FROM `user` u " +
                "JOIN role r ON r.id = u.role_id " +
                "LEFT JOIN academic_staff ast    ON ast.user_id = u.id " +
                "LEFT JOIN academic_staff ast_nm ON ast.id IS NULL " +
                "                               AND ast_nm.user_id IS NULL " +
                "                               AND ast_nm.full_name = u.full_name " +
                "WHERE u.status = 'active' AND (" +
                "  r.name = 'Dean' OR " +
                "  COALESCE(ast.administrative_position, ast_nm.administrative_position) = 'TDA' OR " +
                "  COALESCE(ast.administrative_position, ast_nm.administrative_position) = 'TDB'" +
                ") ORDER BY (r.name = 'Dean') DESC, u.full_name";

            try (PreparedStatement ps2 = conn.prepareStatement(signerSql);
                 ResultSet rs2 = ps2.executeQuery()) {
                while (rs2.next()) {
                    int userId = rs2.getInt("user_id");
                    String roleName = rs2.getString("role_name");
                    String adminPos = rs2.getString("administrative_position");
                    // administrative_position takes precedence so a Dean-role user
                    // who holds a TDA/TDB post is labelled correctly.
                    String label;
                    if ("TDA".equals(adminPos)) {
                        label = "TDA";
                    } else if ("TDB".equals(adminPos)) {
                        label = "TDB";
                    } else if ("Dean".equals(roleName)) {
                        label = "Dean";
                    } else {
                        label = "Alternate";
                    }

                    // If the candidate is the dean's student, dean cannot be the signer.
                    if (deanUserId != null && supervisorUserId != null && deanUserId.equals(supervisorUserId) && userId == deanUserId) {
                        continue;
                    }

                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("user_id", userId);
                    m.put("name", rs2.getString("full_name"));
                    m.put("email", rs2.getString("email"));
                    m.put("title", rs2.getString("title"));
                    m.put("label", label);
                    m.put("is_primary", "Dean".equals(label));
                    out.add(m);
                }
            }
        }
        return out;
    }

    public void upsertLetterApprovalRequest(int appointmentId, int signerUserId, int requestedBy) throws SQLException {
        Map<String,Object> signer = getSignerByUserId(appointmentId, signerUserId);
        if (signer == null) {
            throw new SQLException("Selected signer is not eligible for this appointment.");
        }
        String signerLabel = String.valueOf(signer.get("label"));

        // Read current signer BEFORE the upsert so we can detect whether the signer changed.
        Map<String,Object> prevApproval = getLetterApprovalByAppointmentId(appointmentId);
        boolean signerChanged = prevApproval == null
                || !(prevApproval.get("signer_user_id") instanceof Number)
                || ((Number) prevApproval.get("signer_user_id")).intValue() != signerUserId;

        String sql =
            "INSERT INTO appointment_letter_approval " +
            "(appointment_id, signer_user_id, signer_label, status, requested_by, requested_at, signed_by, signed_at) " +
            "VALUES (?, ?, ?, 'pending', ?, NOW(), NULL, NULL) " +
            "ON DUPLICATE KEY UPDATE " +
            "signer_user_id = VALUES(signer_user_id), signer_label = VALUES(signer_label), " +
            "status='pending', requested_by=VALUES(requested_by), requested_at=NOW(), signed_by=NULL, signed_at=NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, signerUserId);
            ps.setString(3, signerLabel);
            ps.setInt(4, requestedBy);
            ps.executeUpdate();
        }

        if (signerChanged) {
            // Signer changed — all letters now carry the wrong signatory name.
            // Reset sent + approved for every member so admin re-sends fresh copies.
            String resetAll = "UPDATE appointment_panel SET letter_sent = 0, letter_sent_at = NULL, letter_approved = 0 WHERE appointment_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(resetAll)) {
                ps.setInt(1, appointmentId);
                ps.executeUpdate();
            }
        } else {
            // Same signer, re-requesting for a replacement member.
            // Only reset the new/unapproved member — the others' sent status is unaffected.
            String resetNewOnly = "UPDATE appointment_panel SET letter_sent = 0, letter_sent_at = NULL WHERE appointment_id = ? AND letter_approved = 0";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(resetNewOnly)) {
                ps.setInt(1, appointmentId);
                ps.executeUpdate();
            }
        }
    }

    /** Assigned signer confirms approval in-system. */
    public boolean markLetterApprovalSigned(int appointmentId, int actorUserId) throws SQLException {
        return markLetterApprovalSigned(appointmentId, actorUserId, null);
    }

    /** Assigned signer confirms approval with an optional signature image filename. */
    public boolean markLetterApprovalSigned(int appointmentId, int actorUserId, String signatureImageFilename) throws SQLException {
        String sql =
            "UPDATE appointment_letter_approval " +
            "SET status='signed', signed_by=?, signed_at=NOW(), signature_image=? " +
            "WHERE appointment_id=? AND signer_user_id=? AND status='pending'";
        boolean updated;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, actorUserId);
            ps.setString(2, (signatureImageFilename != null && !signatureImageFilename.isEmpty()) ? signatureImageFilename : null);
            ps.setInt(3, appointmentId);
            ps.setInt(4, actorUserId);
            updated = ps.executeUpdate() > 0;
        }
        if (updated) {
            // Dean reviewed and approved this specific set of panel members — mark each one.
            // A new replacement member inserted after this point will have letter_approved=0
            // by default, requiring a fresh approval request before admin can send their email.
            String markApproved = "UPDATE appointment_panel SET letter_approved = 1 WHERE appointment_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(markApproved)) {
                ps.setInt(1, appointmentId);
                ps.executeUpdate();
            }
        }
        return updated;
    }

    /** Returns the stored signature filename for an academic staff user, or null if none. */
    public String getUserSignatureImage(int userId) throws SQLException {
        String sql = "SELECT signature_image FROM academic_staff WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("signature_image");
            }
        }
        return null;
    }

    /** Saves or updates the stored signature filename for an academic staff user. */
    public void saveUserSignatureImage(int userId, String filename) throws SQLException {
        String sql = "UPDATE academic_staff SET signature_image = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, filename);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    private Map<String,Object> getSignerByUserId(int appointmentId, int signerUserId) throws SQLException {
        List<Map<String,Object>> signers = getEligibleLetterSigners(appointmentId);
        for (Map<String,Object> s : signers) {
            if (s.get("user_id") != null && ((Number) s.get("user_id")).intValue() == signerUserId) {
                return s;
            }
        }
        return null;
    }

    public void savePanel(int appointmentId, Integer chairUserId, Integer recorderUserId,
                          List<Integer> internalUserIds, List<Integer> externalExaminerIds,
                          String decision, Timestamp scheduledAt, String venue) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Update appointment status, date, venue
                String apptStatus = decision != null ? decision : "scheduled";
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE viva_appointment SET status = ?, scheduled_at = COALESCE(?, scheduled_at), venue = COALESCE(?, venue) WHERE id = ?")) {
                    ps.setString(1, apptStatus);
                    if (scheduledAt != null) ps.setTimestamp(2, scheduledAt); else ps.setNull(2, java.sql.Types.TIMESTAMP);
                    if (venue != null && !venue.trim().isEmpty()) ps.setString(3, venue.trim()); else ps.setNull(3, java.sql.Types.VARCHAR);
                    ps.setInt(4, appointmentId);
                    ps.executeUpdate();
                }
                // Sync candidate.status to 'appointed' when a viva appointment is scheduled.
                // 'completed' is only set manually by the admin after the viva is held.
                if ("scheduled".equals(apptStatus) || "deferred".equals(apptStatus)) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE candidate SET status = 'appointed' WHERE id = (SELECT candidate_id FROM viva_appointment WHERE id = ?)")) {
                        ps.setInt(1, appointmentId);
                        ps.executeUpdate();
                    }
                }
                // Snapshot existing flags BEFORE wiping rows so we can restore them for unchanged members.
                // Key: "role:userId" for internal, "role:eeId" for external → [letter_sent, letter_approved, letter_signed]
                java.util.Map<String, int[]> prevInternalFlags = new java.util.HashMap<>();
                java.util.Map<String, int[]> prevExternalFlags = new java.util.HashMap<>();
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT member_role, internal_user_id, external_examiner_id, letter_sent, letter_approved, letter_signed FROM appointment_panel WHERE appointment_id = ?")) {
                    ps.setInt(1, appointmentId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String role = rs.getString("member_role");
                            Object uid  = rs.getObject("internal_user_id");
                            Object eid  = rs.getObject("external_examiner_id");
                            int[] flags = { rs.getInt("letter_sent"), rs.getInt("letter_approved"), rs.getInt("letter_signed") };
                            if (uid != null) prevInternalFlags.put(role + ":" + uid, flags);
                            if (eid != null) prevExternalFlags.put(role + ":" + eid, flags);
                        }
                    }
                }

                // Remove old panel entries
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM appointment_panel WHERE appointment_id = ?")) {
                    ps.setInt(1, appointmentId);
                    ps.executeUpdate();
                }
                String ins = "INSERT INTO appointment_panel (appointment_id, internal_user_id, external_examiner_id, member_role, is_chair) VALUES (?,?,?,?,?)";
                if (chairUserId != null) {
                    try (PreparedStatement ps = conn.prepareStatement(ins)) {
                        ps.setInt(1, appointmentId); ps.setInt(2, chairUserId);
                        ps.setNull(3, java.sql.Types.INTEGER);
                        ps.setString(4, "Chairperson"); ps.setInt(5, 1);
                        ps.executeUpdate();
                    }
                }
                if (recorderUserId != null) {
                    try (PreparedStatement ps = conn.prepareStatement(ins)) {
                        ps.setInt(1, appointmentId); ps.setInt(2, recorderUserId);
                        ps.setNull(3, java.sql.Types.INTEGER);
                        ps.setString(4, "Secretary"); ps.setInt(5, 0);
                        ps.executeUpdate();
                    }
                }
                if (internalUserIds != null) {
                    java.util.Set<Integer> seenInternal = new java.util.LinkedHashSet<>();
                    for (Integer uid : internalUserIds) {
                        if (uid == null || !seenInternal.add(uid)) continue;
                        try (PreparedStatement ps = conn.prepareStatement(ins)) {
                            ps.setInt(1, appointmentId); ps.setInt(2, uid);
                            ps.setNull(3, java.sql.Types.INTEGER);
                            ps.setString(4, "Internal Examiner"); ps.setInt(5, 0);
                            ps.executeUpdate();
                        }
                    }
                }
                if (externalExaminerIds != null) {
                    java.util.Set<Integer> seenExternal = new java.util.LinkedHashSet<>();
                    for (Integer eid : externalExaminerIds) {
                        if (eid == null || !seenExternal.add(eid)) continue;
                        try (PreparedStatement ps = conn.prepareStatement(ins)) {
                            ps.setInt(1, appointmentId);
                            ps.setNull(2, java.sql.Types.INTEGER);
                            ps.setInt(3, eid);
                            ps.setString(4, "External Examiner"); ps.setInt(5, 0);
                            ps.executeUpdate();
                        }
                    }
                }

                // Restore letter_sent / letter_approved / letter_signed for members that carried over
                // unchanged (same role + same person). Truly new or replaced members keep the default 0.
                String restoreInt = "UPDATE appointment_panel SET letter_sent=?, letter_approved=?, letter_signed=? WHERE appointment_id=? AND member_role=? AND internal_user_id=?";
                for (java.util.Map.Entry<String, int[]> e : prevInternalFlags.entrySet()) {
                    int[] f = e.getValue();
                    if (f[0] == 0 && f[1] == 0 && f[2] == 0) continue;
                    String[] kp = e.getKey().split(":", 2);
                    try (PreparedStatement ps = conn.prepareStatement(restoreInt)) {
                        ps.setInt(1, f[0]); ps.setInt(2, f[1]); ps.setInt(3, f[2]);
                        ps.setInt(4, appointmentId); ps.setString(5, kp[0]); ps.setInt(6, Integer.parseInt(kp[1]));
                        ps.executeUpdate(); // 0 rows if person was replaced — silently ignored
                    }
                }
                String restoreExt = "UPDATE appointment_panel SET letter_sent=?, letter_approved=?, letter_signed=? WHERE appointment_id=? AND member_role=? AND external_examiner_id=?";
                for (java.util.Map.Entry<String, int[]> e : prevExternalFlags.entrySet()) {
                    int[] f = e.getValue();
                    if (f[0] == 0 && f[1] == 0 && f[2] == 0) continue;
                    String[] kp = e.getKey().split(":", 2);
                    try (PreparedStatement ps = conn.prepareStatement(restoreExt)) {
                        ps.setInt(1, f[0]); ps.setInt(2, f[1]); ps.setInt(3, f[2]);
                        ps.setInt(4, appointmentId); ps.setString(5, kp[0]); ps.setInt(6, Integer.parseInt(kp[1]));
                        ps.executeUpdate(); // 0 rows if person was replaced — silently ignored
                    }
                }

                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * Returns viva appointments for candidates supervised by the given user.
     * Joins candidate.supervisor_id → academic_staff.id → user.id.
     */
    public List<VivaAppointment> findBySupervisorUserId(int userId) throws SQLException {
        List<VivaAppointment> out = new ArrayList<>();
        String sql =
            "SELECT va.id, va.candidate_id, c.student_id, c.full_name AS candidate_name, " +
            "COALESCE(p.name, c.program) AS candidate_program, p.level AS candidate_program_level, c.thesis_title, c.status AS candidate_viva_status, " +
            "va.scheduled_at, va.venue, va.status AS appointment_status, va.duration_minutes, " +
            "MAX(CASE WHEN ap.member_role='Chairperson'       THEN TRIM(CONCAT(COALESCE(CONCAT(ast_c.title,' '),''), COALESCE(ast_c.full_name, u_c.full_name))) END) AS chair_name, " +
            "MAX(CASE WHEN ap.member_role='Secretary'         THEN TRIM(CONCAT(COALESCE(CONCAT(ast_r.title,' '),''), COALESCE(ast_r.full_name, u_r.full_name))) END) AS rec_name, " +
            "GROUP_CONCAT(CASE WHEN ap.member_role='Internal Examiner' THEN TRIM(CONCAT(COALESCE(CONCAT(ast_i.title,' '),''), COALESCE(ast_i.full_name, u_i.full_name))) END ORDER BY ap.id SEPARATOR ', ') AS int_names, " +
            "GROUP_CONCAT(CASE WHEN ap.member_role='External Examiner' THEN TRIM(CONCAT(COALESCE(CONCAT(ee.title,' '),''), ee.name))  END ORDER BY ap.id SEPARATOR ', ') AS ext_names " +
            "FROM viva_appointment va " +
            "JOIN candidate c ON va.candidate_id = c.id " +
            "JOIN academic_staff ast ON ast.id = c.supervisor_id " +
            "LEFT JOIN program p ON c.program_id = p.id " +
            "LEFT JOIN appointment_panel ap ON ap.appointment_id = va.id " +
            "LEFT JOIN `user` u_c ON ap.internal_user_id = u_c.id AND ap.member_role = 'Chairperson' " +
            "LEFT JOIN `user` u_r ON ap.internal_user_id = u_r.id AND ap.member_role = 'Secretary' " +
            "LEFT JOIN `user` u_i ON ap.internal_user_id = u_i.id AND ap.member_role = 'Internal Examiner' " +
            "LEFT JOIN external_examiner ee ON ap.external_examiner_id = ee.id AND ap.member_role = 'External Examiner' " +
            "LEFT JOIN academic_staff ast_c ON ast_c.user_id = u_c.id " +
            "LEFT JOIN academic_staff ast_r ON ast_r.user_id = u_r.id " +
            "LEFT JOIN academic_staff ast_i ON ast_i.user_id = u_i.id " +
            "WHERE ast.user_id = ? " +
            "GROUP BY va.id, va.candidate_id, c.student_id, candidate_name, candidate_program, candidate_program_level, c.thesis_title, " +
            "candidate_viva_status, va.scheduled_at, va.venue, appointment_status, va.duration_minutes " +
            "ORDER BY va.scheduled_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VivaAppointment va = new VivaAppointment();
                    va.setId(rs.getInt("id"));
                    va.setCandidateId(rs.getInt("candidate_id"));
                    va.setCandidateStudentId(rs.getString("student_id"));
                    va.setCandidateName(rs.getString("candidate_name"));
                    va.setCandidateProgram(rs.getString("candidate_program"));
                    va.setCandidateProgramLevel(rs.getString("candidate_program_level"));
                    va.setThesisTitle(rs.getString("thesis_title"));
                    va.setCandidateVivaStatus(rs.getString("candidate_viva_status"));
                    va.setScheduledAt(rs.getTimestamp("scheduled_at"));
                    va.setVenue(rs.getString("venue"));
                    va.setStatus(rs.getString("appointment_status"));
                    va.setDurationMinutes(rs.getObject("duration_minutes") != null ? rs.getInt("duration_minutes") : 0);
                    va.setChairpersonName(rs.getString("chair_name"));
                    va.setRecorderName(rs.getString("rec_name"));
                    va.setInternalExaminerName(rs.getString("int_names"));
                    va.setExternalExaminerName(rs.getString("ext_names"));
                    out.add(va);
                }
            }
        }
        return out;
    }

    public void updateDecision(int appointmentId, String status) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE viva_appointment SET status = ? WHERE id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, appointmentId);
            ps.executeUpdate();
        }
    }

    /** Returns all active venues for the scheduling dropdown. */
    public List<Map<String,Object>> getVenues() throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT id, name, location, capacity FROM venue WHERE is_active = 1 ORDER BY name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("id",       rs.getInt("id"));
                m.put("name",     rs.getString("name"));
                m.put("location", rs.getString("location"));
                m.put("capacity", rs.getInt("capacity"));
                out.add(m);
            }
        } catch (SQLException e) {
            // venue table may not exist yet (migration not run); return empty list
            if (e.getMessage() != null && e.getMessage().contains("doesn't exist")) return out;
            throw e;
        }
        return out;
    }

    /**
     * Checks if the given venue is already booked for an overlapping time window.
     * Returns a descriptive string if there is a conflict, null otherwise.
     * @param venue          venue name to check
     * @param start          proposed start time
     * @param durationMin    duration in minutes (default 90)
     * @param excludeId      appointment id to exclude (the one being edited)
     */
    public String findVenueConflict(String venue, Timestamp start, int durationMin, int excludeId) throws SQLException {
        if (venue == null || venue.trim().isEmpty() || start == null) return null;
        String sql =
            "SELECT va.id, c.full_name AS candidate_name, va.scheduled_at " +
            "FROM viva_appointment va " +
            "JOIN candidate c ON va.candidate_id = c.id " +
            "WHERE va.venue = ? " +
            "  AND va.id != ? " +
            "  AND va.scheduled_at < DATE_ADD(?, INTERVAL ? MINUTE) " +
            "  AND DATE_ADD(va.scheduled_at, INTERVAL COALESCE(va.duration_minutes,90) MINUTE) > ? " +
            "LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, venue.trim());
            ps.setInt(2, excludeId);
            ps.setTimestamp(3, start);
            ps.setInt(4, durationMin);
            ps.setTimestamp(5, start);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String cname = rs.getString("candidate_name");
                    Timestamp existing = rs.getTimestamp("scheduled_at");
                    java.text.SimpleDateFormat fmt = new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a");
                    return venue.trim() + " is already booked for " + cname + " at " + fmt.format(existing);
                }
            }
        }
        return null;
    }

    public int insertAppointmentLetter(int appointmentId, int issuedBy, String content, String letterNumber) throws SQLException {        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO appointment_letter (appointment_id, letter_number, issued_by, content, status) VALUES (?,?,?,?,?)",
                     PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, appointmentId);
            ps.setString(2, letterNumber);
            ps.setInt(3, issuedBy);
            ps.setString(4, content);
            ps.setString(5, "issued");
            ps.executeUpdate();
            try (ResultSet gk = ps.getGeneratedKeys()) { if (gk.next()) return gk.getInt(1); }
        }
        return -1;
    }

    /**
     * Marks a viva appointment as letter_generated.
     * Candidate status remains 'appointed' — admin must manually mark as completed
     * after the viva session has been held.
     */
    public void markLetterGenerated(int appointmentId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE viva_appointment SET status = 'letter_generated' WHERE id = ? AND status = 'scheduled'")) {
            ps.setInt(1, appointmentId);
            ps.executeUpdate();
        }
    }

    /** Returns true if a viva appointment already exists for the given candidate. */
    public boolean existsForCandidate(int candidateId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT 1 FROM viva_appointment WHERE candidate_id = ? LIMIT 1")) {
            ps.setInt(1, candidateId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Sets nomination_id on the existing viva appointment for a candidate (only when currently NULL). */
    public void linkNominationToAppointment(int candidateId, int nominationId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE viva_appointment SET nomination_id = ? WHERE candidate_id = ? AND nomination_id IS NULL")) {
            ps.setInt(1, nominationId);
            ps.setInt(2, candidateId);
            ps.executeUpdate();
        }
    }

    /**
     * Creates a new unscheduled viva appointment linked to the given nomination.
     * Called automatically when a nomination is verified and no appointment exists yet.
     * scheduled_at is left NULL; the admin fills it in via the decision form.
     */
    public int createAppointment(int candidateId, Integer nominationId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int newId = -1;
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO viva_appointment (candidate_id, nomination_id, status) VALUES (?, ?, 'scheduled')",
                        PreparedStatement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, candidateId);
                    if (nominationId != null) ps.setInt(2, nominationId); else ps.setNull(2, java.sql.Types.INTEGER);
                    ps.executeUpdate();
                    try (ResultSet gk = ps.getGeneratedKeys()) {
                        if (gk.next()) newId = gk.getInt(1);
                    }
                }
                // Sync candidate status to 'appointed' now that an appointment exists
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE candidate SET status = 'appointed' WHERE id = ?")) {
                    ps.setInt(1, candidateId);
                    ps.executeUpdate();
                }
                conn.commit();
                return newId;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * Returns recently-signed letter approvals for a signer, with sent/total counts.
     * Used by dean dashboard to track admin's sending progress.
     */
    public List<Map<String,Object>> getSignedLetterApprovalsForSigner(int signerUserId, int limit) throws SQLException {
        List<Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT ala.id, ala.appointment_id, ala.signer_label, ala.signed_at, " +
            "c.student_id, c.full_name AS candidate_name, COALESCE(p.name, c.program) AS candidate_program, " +
            "(SELECT COUNT(*) FROM appointment_panel WHERE appointment_id = va.id) AS total_panel, " +
            "(SELECT COUNT(*) FROM appointment_panel WHERE appointment_id = va.id AND letter_sent = 1) AS sent_panel " +
            "FROM appointment_letter_approval ala " +
            "JOIN viva_appointment va ON va.id = ala.appointment_id " +
            "JOIN candidate c ON c.id = va.candidate_id " +
            "LEFT JOIN program p ON p.id = c.program_id " +
            "WHERE ala.signer_user_id = ? AND ala.status = 'signed' " +
            "ORDER BY ala.signed_at DESC " +
            "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, signerUserId);
            ps.setInt(2, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new LinkedHashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("appointment_id", rs.getInt("appointment_id"));
                    m.put("signer_label", rs.getString("signer_label"));
                    m.put("signed_at", rs.getTimestamp("signed_at"));
                    m.put("student_id", rs.getString("student_id"));
                    m.put("candidate_name", rs.getString("candidate_name"));
                    m.put("candidate_program", rs.getString("candidate_program"));
                    m.put("total_panel", rs.getInt("total_panel"));
                    m.put("sent_panel", rs.getInt("sent_panel"));
                    out.add(m);
                }
            }
        }
        return out;
    }

    /** Returns how many panel members have had their letter email sent for a given appointment. */
    public int getLetterSentCount(int appointmentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM appointment_panel WHERE appointment_id = ? AND letter_sent = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * Summary counts for the admin dashboard approval widget.
     * Considers only appointments in 'scheduled' or 'letter_generated' status.
     * Returns a Map with keys: pending_count, signed_count, not_requested_count, total_count.
     */
    public Map<String,Integer> getLetterApprovalStats() throws SQLException {
        Map<String,Integer> out = new LinkedHashMap<>();
        String sql =
            "SELECT " +
            "  COUNT(*) AS total_count, " +
            "  SUM(CASE WHEN ala.status = 'pending' THEN 1 ELSE 0 END) AS pending_count, " +
            "  SUM(CASE WHEN ala.status = 'signed'  THEN 1 ELSE 0 END) AS signed_count, " +
            "  SUM(CASE WHEN ala.id IS NULL          THEN 1 ELSE 0 END) AS not_requested_count " +
            "FROM viva_appointment va " +
            "LEFT JOIN appointment_letter_approval ala ON ala.appointment_id = va.id " +
            "WHERE va.status IN ('scheduled', 'letter_generated')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                out.put("total_count",         rs.getInt("total_count"));
                out.put("pending_count",        rs.getInt("pending_count"));
                out.put("signed_count",         rs.getInt("signed_count"));
                out.put("not_requested_count",  rs.getInt("not_requested_count"));
            } else {
                out.put("total_count", 0); out.put("pending_count", 0);
                out.put("signed_count", 0); out.put("not_requested_count", 0);
            }
        }
        return out;
    }

    // =========================================================================
    // External Examiner Online Response Methods
    // =========================================================================

    /**
     * Generates a secure random 32-hex-char token, saves it to the given
     * External Examiner panel row, and returns the token.
     * Each call overwrites the previous token (re-send scenario).
     */
    public String generateAndSaveExternalResponseToken(int panelId) throws SQLException {
        byte[] bytes = new byte[16];
        new java.security.SecureRandom().nextBytes(bytes);
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) sb.append(String.format("%02x", b));
        String token = sb.toString();
        String sql = "UPDATE appointment_panel SET response_token = ? WHERE id = ? AND member_role = 'External Examiner'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setInt(2, panelId);
            if (ps.executeUpdate() == 0) {
                throw new SQLException("Panel row not found or not External Examiner: " + panelId);
            }
        }
        return token;
    }

    /** Updates ee_email for an external examiner row (admin action). */
    public void updateExternalExaminerEmail(int externalExaminerId, String email) throws SQLException {
        String sql = "UPDATE external_examiner SET email = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            ps.setInt(2, externalExaminerId);
            ps.executeUpdate();
        }
    }

    /**
     * Looks up a panel row by response_token and returns all data needed
     * to render the public response form (panelResponse.jsp).
     * Returns null if the token is not found or not an External Examiner row.
     */
    public Map<String,Object> getPanelDetailByResponseToken(String token) throws SQLException {
        String sql =
            "SELECT ap.id AS panel_id, ap.appointment_id, ap.member_role, " +
            "ap.panel_response, ap.rejection_reason, ap.responded_at, ap.letter_sent_at, " +
            "ee.name AS ee_name, ee.email AS ee_email, ee.title AS ee_title, " +
            "va.status AS appointment_status, va.scheduled_at, va.venue, " +
            "c.full_name AS candidate_name, c.student_id, c.thesis_title, " +
            "COALESCE(p.name, c.program) AS candidate_program, " +
            "ap.bank_account_name, ap.bank_account_number, ap.bank_name, ap.bank_iban, ap.bank_swift, ap.bank_country, ap.bank_provided_at, " +
            "ap.response_source, ap.responded_by_user_id, ap.responded_ip " +
            "FROM appointment_panel ap " +
            "JOIN viva_appointment va ON va.id = ap.appointment_id " +
            "JOIN candidate c ON c.id = va.candidate_id " +
            "LEFT JOIN external_examiner ee ON ee.id = ap.external_examiner_id " +
            "LEFT JOIN program p ON p.id = c.program_id " +
            "WHERE ap.response_token = ? AND ap.member_role = 'External Examiner' LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("panel_id",          rs.getInt("panel_id"));
                m.put("appointment_id",    rs.getInt("appointment_id"));
                m.put("member_role",       rs.getString("member_role"));
                m.put("panel_response",    rs.getString("panel_response"));
                m.put("rejection_reason",  rs.getString("rejection_reason"));
                m.put("responded_at",      rs.getTimestamp("responded_at"));
                m.put("letter_sent_at",    rs.getTimestamp("letter_sent_at"));
                m.put("ee_name",           rs.getString("ee_name"));
                m.put("ee_email",          rs.getString("ee_email"));
                m.put("ee_title",          rs.getString("ee_title"));
                m.put("appointment_status",rs.getString("appointment_status"));
                m.put("scheduled_at",      rs.getTimestamp("scheduled_at"));
                m.put("venue",             rs.getString("venue"));
                m.put("candidate_name",    rs.getString("candidate_name"));
                m.put("student_id",        rs.getString("student_id"));
                m.put("thesis_title",      rs.getString("thesis_title"));
                m.put("candidate_program", rs.getString("candidate_program"));
                java.sql.ResultSetMetaData md = rs.getMetaData();
                int cols = md.getColumnCount();
                java.util.Set<String> colNames = new java.util.HashSet<>();
                for (int i = 1; i <= cols; i++) colNames.add(md.getColumnLabel(i));
                if (colNames.contains("bank_account_name") && "External Examiner".equals(rs.getString("member_role"))) {
                    m.put("bank_account_name", rs.getString("bank_account_name"));
                    m.put("bank_account_number", rs.getString("bank_account_number"));
                    m.put("bank_name", rs.getString("bank_name"));
                    m.put("bank_iban", rs.getString("bank_iban"));
                    m.put("bank_swift", rs.getString("bank_swift"));
                    m.put("bank_country", rs.getString("bank_country"));
                    m.put("bank_provided_at", rs.getTimestamp("bank_provided_at"));
                }
                m.put("response_source", rs.getString("response_source"));
                m.put("responded_by_user_id", rs.getObject("responded_by_user_id"));
                m.put("responded_ip", rs.getString("responded_ip"));
                return m;
            }
        }
    }

    /**
     * Returns panel row detail by panel id. Used for authenticated internal responses.
     */
    public Map<String,Object> getPanelDetailById(int panelId) throws SQLException {
        String sql =
            "SELECT ap.id AS panel_id, ap.appointment_id, ap.member_role, " +
            "ap.panel_response, ap.rejection_reason, ap.responded_at, ap.letter_sent_at, " +
            "ap.internal_user_id, ap.external_examiner_id, " +
            "u.full_name AS user_name, u.email AS user_email, COALESCE(ast.title, '') AS user_title, " +
            "ee.name AS ee_name, ee.email AS ee_email, ee.title AS ee_title, " +
            "c.full_name AS candidate_name, c.student_id, c.thesis_title, " +
            "COALESCE(p.name, c.program) AS candidate_program " +
            "FROM appointment_panel ap " +
            "LEFT JOIN `user` u ON u.id = ap.internal_user_id " +
            "LEFT JOIN academic_staff ast ON ast.user_id = ap.internal_user_id " +
            "LEFT JOIN external_examiner ee ON ee.id = ap.external_examiner_id " +
            "LEFT JOIN viva_appointment va ON va.id = ap.appointment_id " +
            "LEFT JOIN candidate c ON c.id = va.candidate_id " +
            "LEFT JOIN program p ON p.id = c.program_id " +
            "WHERE ap.id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, panelId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Map<String,Object> m = new LinkedHashMap<>();
                m.put("panel_id", rs.getInt("panel_id"));
                m.put("appointment_id", rs.getInt("appointment_id"));
                m.put("member_role", rs.getString("member_role"));
                m.put("panel_response", rs.getString("panel_response"));
                m.put("rejection_reason", rs.getString("rejection_reason"));
                m.put("responded_at", rs.getTimestamp("responded_at"));
                m.put("letter_sent_at", rs.getTimestamp("letter_sent_at"));
                m.put("internal_user_id", rs.getObject("internal_user_id"));
                m.put("external_examiner_id", rs.getObject("external_examiner_id"));
                m.put("user_name", rs.getString("user_name"));
                m.put("user_email", rs.getString("user_email"));
                m.put("user_title", rs.getString("user_title"));
                m.put("ee_name", rs.getString("ee_name"));
                m.put("ee_email", rs.getString("ee_email"));
                m.put("ee_title", rs.getString("ee_title"));
                m.put("candidate_name", rs.getString("candidate_name"));
                m.put("student_id", rs.getString("student_id"));
                m.put("thesis_title", rs.getString("thesis_title"));
                m.put("candidate_program", rs.getString("candidate_program"));
                java.sql.ResultSetMetaData md = rs.getMetaData();
                int cols = md.getColumnCount();
                java.util.Set<String> colNames = new java.util.HashSet<>();
                for (int i = 1; i <= cols; i++) colNames.add(md.getColumnLabel(i));
                if (colNames.contains("bank_account_name") && "External Examiner".equals(rs.getString("member_role"))) {
                    m.put("bank_account_name", rs.getString("bank_account_name"));
                    m.put("bank_account_number", rs.getString("bank_account_number"));
                    m.put("bank_name", rs.getString("bank_name"));
                    m.put("bank_iban", rs.getString("bank_iban"));
                    m.put("bank_swift", rs.getString("bank_swift"));
                    m.put("bank_country", rs.getString("bank_country"));
                    m.put("bank_provided_at", rs.getTimestamp("bank_provided_at"));
                }
                if (colNames.contains("response_source")) {
                    m.put("response_source", rs.getString("response_source"));
                    m.put("responded_by_user_id", rs.getObject("responded_by_user_id"));
                    m.put("responded_ip", rs.getString("responded_ip"));
                }
                return m;
            }
        }
    }

    /**
     * Records a panel member's response by panel id (used for internal authenticated members).
     */
    public void savePanelResponseByPanelId(int panelId, String response, String reason) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Resolve appointment id
                int appointmentId = 0;
                String selSql = "SELECT appointment_id FROM appointment_panel WHERE id = ? LIMIT 1";
                try (PreparedStatement ps = conn.prepareStatement(selSql)) {
                    ps.setInt(1, panelId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new SQLException("Panel row not found: " + panelId);
                        appointmentId = rs.getInt("appointment_id");
                    }
                }
                // Update panel row
                String updPanel = "UPDATE appointment_panel SET panel_response = ?, rejection_reason = ?, responded_at = NOW() WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updPanel)) {
                    ps.setString(1, response);
                    if (reason != null && !reason.trim().isEmpty()) ps.setString(2, reason.trim()); else ps.setNull(2, java.sql.Types.VARCHAR);
                    ps.setInt(3, panelId);
                    ps.executeUpdate();
                }
                // If declined, move appointment to 'examiner_declined'
                if ("declined".equals(response)) {
                    String updAppt = "UPDATE viva_appointment SET status = 'examiner_declined' WHERE id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updAppt)) {
                        ps.setInt(1, appointmentId);
                        ps.executeUpdate();
                    }
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * Wrapper that saves response and attempts to write audit metadata (source, user id, ip).
     * If the optional audit columns do not exist in the schema, the extra update is quietly skipped.
     */
    public void savePanelResponseByPanelIdWithAudit(int panelId, String response, String reason,
                                                    String responseSource, Integer respondedByUserId, String respondedIp) throws SQLException {
        // Primary save
        savePanelResponseByPanelId(panelId, response, reason);

        // Attempt to write audit columns (non-fatal if columns not present)
        String updAudit = "UPDATE appointment_panel SET response_source = ?, responded_by_user_id = ?, responded_ip = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(updAudit)) {
            ps.setString(1, responseSource);
            if (respondedByUserId != null) ps.setInt(2, respondedByUserId); else ps.setNull(2, java.sql.Types.INTEGER);
            ps.setString(3, respondedIp);
            ps.setInt(4, panelId);
            ps.executeUpdate();
        } catch (SQLException ex) {
            // If the DB doesn't have these columns, ignore to remain backward-compatible
        }
    }

    /**
     * Records the external examiner's accept/decline response.
     * If declined, the viva_appointment status is set to 'examiner_declined'.
     * Transactional — both updates succeed or both roll back.
     */
    public void savePanelResponse(String token, String response, String reason) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Resolve panel row
                int panelId = 0;
                int appointmentId = 0;
                String selSql = "SELECT id, appointment_id FROM appointment_panel " +
                                "WHERE response_token = ? AND member_role = 'External Examiner' LIMIT 1";
                try (PreparedStatement ps = conn.prepareStatement(selSql)) {
                    ps.setString(1, token);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new SQLException("Response token not found.");
                        panelId       = rs.getInt("id");
                        appointmentId = rs.getInt("appointment_id");
                    }
                }
                // Save response to panel row
                String updPanel = "UPDATE appointment_panel " +
                                  "SET panel_response = ?, rejection_reason = ?, responded_at = NOW() " +
                                  "WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updPanel)) {
                    ps.setString(1, response);
                    if (reason != null && !reason.trim().isEmpty()) {
                        ps.setString(2, reason.trim());
                    } else {
                        ps.setNull(2, java.sql.Types.VARCHAR);
                    }
                    ps.setInt(3, panelId);
                    ps.executeUpdate();
                }
                // If declined, move appointment to 'examiner_declined'
                if ("declined".equals(response)) {
                    String updAppt = "UPDATE viva_appointment SET status = 'examiner_declined' WHERE id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updAppt)) {
                        ps.setInt(1, appointmentId);
                        ps.executeUpdate();
                    }
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * Wrapper that saves response by token and attempts to store audit metadata.
     * Performs the primary save then tries to update response_source/responded_by_user_id/responded_ip.
     */
    public void savePanelResponseWithAudit(String token, String response, String reason,
                                          String responseSource, Integer respondedByUserId, String respondedIp) throws SQLException {
        // Primary save
        savePanelResponse(token, response, reason);

        // Resolve panel id for token
        Integer panelId = null;
        String sel = "SELECT id FROM appointment_panel WHERE response_token = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sel)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) panelId = rs.getInt(1);
            }
        }

        if (panelId != null) {
            String updAudit = "UPDATE appointment_panel SET response_source = ?, responded_by_user_id = ?, responded_ip = ? WHERE id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(updAudit)) {
                ps.setString(1, responseSource);
                if (respondedByUserId != null) ps.setInt(2, respondedByUserId); else ps.setNull(2, java.sql.Types.INTEGER);
                ps.setString(3, respondedIp);
                ps.setInt(4, panelId);
                ps.executeUpdate();
            } catch (SQLException ex) {
                // ignore if columns do not exist
            }
            // commit bank fields may be NULL at this stage; nothing else to do
        }
    }

    /** Save bank/payment details for a panel row identified by token (External Examiner flow). */
    public void savePanelBankDetailsByToken(String token, String bankAccountName, String bankAccountNumber,
                                           String bankName, String bankIban, String bankSwift, String bankCountry) throws SQLException {
        // Resolve panel id
        Integer panelId = null;
        String sel = "SELECT id FROM appointment_panel WHERE response_token = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sel)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) panelId = rs.getInt(1);
            }
        }
        if (panelId == null) throw new SQLException("Response token not found when saving bank details.");

        savePanelBankDetailsByPanelId(panelId, bankAccountName, bankAccountNumber, bankName, bankIban, bankSwift, bankCountry);
    }

    /** Save bank/payment details for a panel row by id. */
    public void savePanelBankDetailsByPanelId(int panelId, String bankAccountName, String bankAccountNumber,
                                             String bankName, String bankIban, String bankSwift, String bankCountry) throws SQLException {
        String upd = "UPDATE appointment_panel SET bank_account_name = ?, bank_account_number = ?, bank_name = ?, bank_iban = ?, bank_swift = ?, bank_country = ?, bank_provided_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(upd)) {
            if (bankAccountName != null && !bankAccountName.trim().isEmpty()) ps.setString(1, bankAccountName.trim()); else ps.setNull(1, java.sql.Types.VARCHAR);
            if (bankAccountNumber != null && !bankAccountNumber.trim().isEmpty()) ps.setString(2, bankAccountNumber.trim()); else ps.setNull(2, java.sql.Types.VARCHAR);
            if (bankName != null && !bankName.trim().isEmpty()) ps.setString(3, bankName.trim()); else ps.setNull(3, java.sql.Types.VARCHAR);
            if (bankIban != null && !bankIban.trim().isEmpty()) ps.setString(4, bankIban.trim()); else ps.setNull(4, java.sql.Types.VARCHAR);
            if (bankSwift != null && !bankSwift.trim().isEmpty()) ps.setString(5, bankSwift.trim()); else ps.setNull(5, java.sql.Types.VARCHAR);
            if (bankCountry != null && !bankCountry.trim().isEmpty()) ps.setString(6, bankCountry.trim()); else ps.setNull(6, java.sql.Types.VARCHAR);
            ps.setInt(7, panelId);
            ps.executeUpdate();
        }
    }

    /**
     * Returns the count of External Examiner panel rows where the letter was sent
     * more than 7 days ago but no online response has been recorded yet.
     * Used by the admin list to show an overdue warning banner.
     */
    public int getOverdueExternalResponseCount() throws SQLException {
        String sql =
            "SELECT COUNT(*) FROM appointment_panel " +
            "WHERE member_role = 'External Examiner' " +
            "AND panel_response IS NULL " +
            "AND letter_sent_at IS NOT NULL " +
            "AND letter_sent_at < DATE_SUB(NOW(), INTERVAL 7 DAY)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /**
     * Returns the count of appointments that are in 'examiner_declined' status.
     * Used by the admin list to show a declined banner.
     */
    public int getExaminerDeclinedCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM viva_appointment WHERE status = 'examiner_declined'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /**
     * Returns true if the given user_id is assigned as an internal panel member
     * for the specified appointment_id.
     */
    public boolean isUserAssignedToAppointment(int appointmentId, int userId) throws SQLException {
        String sql = "SELECT 1 FROM appointment_panel WHERE appointment_id = ? AND internal_user_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Returns pending (no response yet) panel rows assigned to an internal user.
     */
    public java.util.List<java.util.Map<String,Object>> getPendingPanelsForUser(int userId) throws SQLException {
        String sql =
            "SELECT ap.id AS panel_id, ap.appointment_id, ap.member_role, ap.panel_response, " +
            "c.full_name AS candidate_name, c.student_id, c.thesis_title, " +
            "COALESCE(p.name, c.program) AS candidate_program, " +
            "va.scheduled_at, va.venue, va.status AS appointment_status " +
            "FROM appointment_panel ap " +
            "JOIN viva_appointment va ON va.id = ap.appointment_id " +
            "JOIN candidate c ON c.id = va.candidate_id " +
            "LEFT JOIN program p ON p.id = c.program_id " +
            "WHERE ap.internal_user_id = ? AND ap.panel_response IS NULL " +
            "ORDER BY va.scheduled_at IS NULL ASC, va.scheduled_at ASC";
        java.util.List<java.util.Map<String,Object>> out = new java.util.ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("panel_id",           rs.getInt("panel_id"));
                    m.put("appointment_id",     rs.getInt("appointment_id"));
                    m.put("member_role",        rs.getString("member_role"));
                    m.put("panel_response",     rs.getString("panel_response"));
                    m.put("candidate_name",     rs.getString("candidate_name"));
                    m.put("student_id",         rs.getString("student_id"));
                    m.put("thesis_title",       rs.getString("thesis_title"));
                    m.put("candidate_program",  rs.getString("candidate_program"));
                    m.put("scheduled_at",       rs.getTimestamp("scheduled_at"));
                    m.put("venue",              rs.getString("venue"));
                    m.put("appointment_status", rs.getString("appointment_status"));
                    out.add(m);
                }
            }
        }
        return out;
    }

    /**
     * Returns ALL panel assignments (pending + responded) for an internal user.
     * Used for the My Appointments history/upcoming view.
     */
    public java.util.List<java.util.Map<String,Object>> getAllAppointmentsForUser(int userId) throws SQLException {
        String sql =
            "SELECT ap.id AS panel_id, ap.appointment_id, ap.member_role, ap.panel_response, " +
            "ap.rejection_reason, ap.responded_at, ap.letter_sent, " +
            "c.full_name AS candidate_name, c.student_id, c.thesis_title, " +
            "COALESCE(p.name, c.program) AS candidate_program, " +
            "va.scheduled_at, va.venue, va.status AS appointment_status " +
            "FROM appointment_panel ap " +
            "JOIN viva_appointment va ON va.id = ap.appointment_id " +
            "JOIN candidate c ON c.id = va.candidate_id " +
            "LEFT JOIN program p ON p.id = c.program_id " +
            "WHERE ap.internal_user_id = ? " +
            "ORDER BY va.scheduled_at IS NULL ASC, va.scheduled_at ASC";
        java.util.List<java.util.Map<String,Object>> out = new java.util.ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("panel_id",           rs.getInt("panel_id"));
                    m.put("appointment_id",     rs.getInt("appointment_id"));
                    m.put("member_role",        rs.getString("member_role"));
                    m.put("panel_response",     rs.getString("panel_response"));
                    m.put("rejection_reason",   rs.getString("rejection_reason"));
                    m.put("responded_at",       rs.getTimestamp("responded_at"));
                    m.put("letter_sent",        rs.getInt("letter_sent") == 1);
                    m.put("candidate_name",     rs.getString("candidate_name"));
                    m.put("student_id",         rs.getString("student_id"));
                    m.put("thesis_title",       rs.getString("thesis_title"));
                    m.put("candidate_program",  rs.getString("candidate_program"));
                    m.put("scheduled_at",       rs.getTimestamp("scheduled_at"));
                    m.put("venue",              rs.getString("venue"));
                    m.put("appointment_status", rs.getString("appointment_status"));
                    out.add(m);
                }
            }
        }
        return out;
    }
}
