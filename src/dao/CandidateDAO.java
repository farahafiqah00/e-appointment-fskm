package dao;

import model.Candidate;
import model.CoSupervisor;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/** Data-access methods for the candidate and co_supervisor tables. */
public class CandidateDAO {

    // ── helpers ──────────────────────────────────────────────────────────────

    private Candidate mapRow(ResultSet rs) throws SQLException {
        Candidate c = new Candidate();
        c.setId(rs.getInt("id"));
        c.setStudentId(rs.getString("student_id"));
        c.setFullName(rs.getString("full_name"));
        c.setThesisTitle(rs.getString("thesis_title"));
        c.setSupervisorName(rs.getString("supervisor_name"));
        c.setStatus(rs.getString("status"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        // Optional columns (added in later migrations) — silently skip if not present in this query.
        try { c.setContactEmail(rs.getString("contact_email")); } catch (SQLException ignore) {}
        try { c.setNationality(rs.getString("nationality")); } catch (SQLException ignore) {}
        try {
            int pid = rs.getInt("program_id");
            if (!rs.wasNull()) c.setProgramId(pid);
        } catch (SQLException ignore) {}
        try {
            String pname = rs.getString("program_name");
            if (pname != null) c.setProgramName(pname);
        } catch (SQLException ignore) {}
        try { c.setProgram(rs.getString("program")); } catch (SQLException ignore) {}
        try {
            int sid = rs.getInt("supervisor_id");
            if (!rs.wasNull()) c.setSupervisorId(sid);
        } catch (SQLException ignore) {}
        try { c.setProgramLevel(rs.getString("program_level")); } catch (SQLException ignore) {}
        return c;
    }

    private void loadCoSupervisors(Connection conn, Candidate c) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT cs.id, cs.name, cs.cosv_type, cs.internal_staff_id, " +
                "cs.university_name, cs.faculty, cs.programme, cs.country, cs.email, " +
                "TRIM(CONCAT(COALESCE(CONCAT(ast.title, ' '), ''), COALESCE(ast.full_name, u.full_name, ''))) AS staff_name " +
                "FROM co_supervisor cs " +
                "LEFT JOIN academic_staff ast ON ast.id = cs.internal_staff_id " +
                "LEFT JOIN `user` u ON u.id = ast.user_id " +
                "WHERE cs.candidate_id = ? ORDER BY cs.id")) {
            ps.setInt(1, c.getId());
            try (ResultSet rs = ps.executeQuery()) {
                List<CoSupervisor> list = new ArrayList<>();
                while (rs.next()) {
                    CoSupervisor cs = new CoSupervisor();
                    cs.setId(rs.getInt("id"));
                    cs.setCosvType(rs.getString("cosv_type"));
                    int staffId = rs.getInt("internal_staff_id");
                    if (!rs.wasNull()) cs.setInternalStaffId(staffId);
                    // For internal: prefer staff_name; for external: use stored name
                    String staffName = rs.getString("staff_name");
                    String storedName = rs.getString("name");
                    cs.setName("internal".equals(cs.getCosvType()) && staffName != null ? staffName : storedName);
                    cs.setUniversityName(rs.getString("university_name"));
                    cs.setFaculty(rs.getString("faculty"));
                    cs.setProgramme(rs.getString("programme"));
                    cs.setCountry(rs.getString("country"));
                    cs.setEmail(rs.getString("email"));
                    list.add(cs);
                }
                c.setCoSupervisors(list);
            }
        }
    }

    // Delete-then-reinsert: simpler than diffing individual changes for a small list.
    private void saveCoSupervisors(Connection conn, int candidateId, List<CoSupervisor> coSups) throws SQLException {
        try (PreparedStatement del = conn.prepareStatement(
                "DELETE FROM co_supervisor WHERE candidate_id = ?")) {
            del.setInt(1, candidateId);
            del.executeUpdate();
        }
        if (coSups == null || coSups.isEmpty()) return;
        try (PreparedStatement ins = conn.prepareStatement(
                "INSERT INTO co_supervisor (candidate_id, name, cosv_type, internal_staff_id, " +
                "university_name, faculty, programme, country, email) VALUES (?,?,?,?,?,?,?,?,?)")) {
            for (CoSupervisor cs : coSups) {
                if (cs == null || (cs.getName() == null || cs.getName().trim().isEmpty())) continue;
                ins.setInt(1, candidateId);
                ins.setString(2, cs.getName().trim());
                ins.setString(3, cs.getCosvType() != null ? cs.getCosvType() : "external");
                if (cs.getInternalStaffId() != null) ins.setInt(4, cs.getInternalStaffId());
                else ins.setNull(4, Types.INTEGER);
                ins.setString(5, cs.getUniversityName());
                ins.setString(6, cs.getFaculty());
                ins.setString(7, cs.getProgramme());
                ins.setString(8, cs.getCountry());
                ins.setString(9, cs.getEmail());
                ins.addBatch();
            }
            ins.executeBatch();
        }
    }

    // ── public API ───────────────────────────────────────────────────────────

    public List<Candidate> findAll(String q, String programId, String status, String level, boolean showArchived) throws SQLException {
        List<Candidate> out = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT c.id, c.student_id, c.full_name, c.program, c.program_id, " +
            "c.thesis_title, c.supervisor_name, c.status, c.created_at, " +
            "p.name AS program_name, p.level AS program_level " +
            "FROM candidate c LEFT JOIN program p ON c.program_id = p.id " +
            "WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (c.full_name LIKE ? OR c.student_id LIKE ? OR c.thesis_title LIKE ?)");
            params.add("%" + q + "%"); params.add("%" + q + "%"); params.add("%" + q + "%");
        }
        if (programId != null && !programId.trim().isEmpty()) {
            sql.append(" AND c.program_id = ?"); params.add(Integer.parseInt(programId));
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND c.status = ?"); params.add(status.toLowerCase());
        } else if (!showArchived) {
            sql.append(" AND c.status != 'completed'");
        }
        if (level != null && !level.trim().isEmpty()) {
            sql.append(" AND p.level = ?"); params.add(level.trim());
        }
        sql.append(" ORDER BY c.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapRow(rs));
            }
        }
        return out;
    }

    public Candidate findById(int id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT c.id, c.student_id, c.full_name, c.program, c.program_id, " +
                "c.thesis_title, TRIM(CONCAT(COALESCE(CONCAT(ast_sup.title, ' '), ''), c.supervisor_name)) AS supervisor_name, c.status, c.created_at, " +
                "c.contact_email, c.nationality, p.name AS program_name, p.level AS program_level " +
                "FROM candidate c LEFT JOIN program p ON c.program_id = p.id " +
                "LEFT JOIN academic_staff ast_sup ON ast_sup.id = c.supervisor_id " +
                "WHERE c.id = ? LIMIT 1")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Candidate c = mapRow(rs);
                    try { loadCoSupervisors(conn, c); } catch (SQLException ignore) {}
                    return c;
                }
            }
        }
        return null;
    }

    public int insert(Candidate c) throws SQLException {
        // Step 1: save candidate + co-supervisors atomically.
        int newId;
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO candidate (student_id, full_name, program, program_id, thesis_title, " +
                        "supervisor_name, supervisor_id, contact_email, nationality, status) VALUES (?,?,?,?,?,?,?,?,?,?)",
                        PreparedStatement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, c.getStudentId());
                    ps.setString(2, c.getFullName());
                    ps.setString(3, c.getProgram());
                    if (c.getProgramId() != null) ps.setInt(4, c.getProgramId()); else ps.setNull(4, Types.INTEGER);
                    ps.setString(5, c.getThesisTitle());
                    ps.setString(6, c.getSupervisorName());
                    if (c.getSupervisorId() != null) ps.setInt(7, c.getSupervisorId()); else ps.setNull(7, Types.INTEGER);
                    ps.setString(8, c.getContactEmail());
                    ps.setString(9, c.getNationality());
                    ps.setString(10, c.getStatus() != null ? c.getStatus() : "prepared");
                    ps.executeUpdate();
                    try (ResultSet gk = ps.getGeneratedKeys()) {
                        if (gk.next()) newId = gk.getInt(1); else { conn.rollback(); return -1; }
                    }
                }
                saveCoSupervisors(conn, newId, c.getCoSupervisors());
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
        // Step 2: create a pending viva_appointment so the candidate appears in the
        // appointment list. This is a separate, best-effort transaction — if it fails
        // (e.g. migration 030 not yet run), the candidate is still saved.
        try (Connection conn2 = DBConnection.getConnection();
             PreparedStatement va = conn2.prepareStatement(
                     "INSERT INTO viva_appointment (candidate_id, status) " +
                     "SELECT ?, 'pending' FROM DUAL " +
                     "WHERE NOT EXISTS (SELECT 1 FROM viva_appointment WHERE candidate_id = ?)")) {
            va.setInt(1, newId);
            va.setInt(2, newId);
            va.executeUpdate();
        } catch (SQLException ignore) {
            // Silently skip: scheduled_at is likely still NOT NULL (run 030_nullable_scheduled_at.sql).
        }
        return newId;
    }

    public void update(Candidate c) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE candidate SET student_id=?, full_name=?, program=?, program_id=?, " +
                        "thesis_title=?, supervisor_name=?, supervisor_id=?, contact_email=?, nationality=?, status=? WHERE id=?")) {
                    ps.setString(1, c.getStudentId());
                    ps.setString(2, c.getFullName());
                    ps.setString(3, c.getProgram());
                    if (c.getProgramId() != null) ps.setInt(4, c.getProgramId()); else ps.setNull(4, Types.INTEGER);
                    ps.setString(5, c.getThesisTitle());
                    ps.setString(6, c.getSupervisorName());
                    if (c.getSupervisorId() != null) ps.setInt(7, c.getSupervisorId()); else ps.setNull(7, Types.INTEGER);
                    ps.setString(8, c.getContactEmail());
                    ps.setString(9, c.getNationality());
                    ps.setString(10, c.getStatus());
                    ps.setInt(11, c.getId());
                    ps.executeUpdate();
                }
                saveCoSupervisors(conn, c.getId(), c.getCoSupervisors());
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /**
     * Returns candidates whose supervisor_id matches the given academic_staff.id.
     * Used by the Academician view to show only their own students.
     */
    public List<Candidate> findBySupervisorStaffId(int staffId, String q, String programId, String status) throws SQLException {
        List<Candidate> out = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT c.id, c.student_id, c.full_name, c.program, c.program_id, " +
            "c.thesis_title, c.supervisor_name, c.supervisor_id, c.status, c.created_at, " +
            "p.name AS program_name, p.level AS program_level " +
            "FROM candidate c LEFT JOIN program p ON c.program_id = p.id " +
            "WHERE c.supervisor_id = ?");
        List<Object> params = new ArrayList<>();
        params.add(staffId);
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (c.full_name LIKE ? OR c.student_id LIKE ? OR c.thesis_title LIKE ?)");
            params.add("%" + q + "%"); params.add("%" + q + "%"); params.add("%" + q + "%");
        }
        if (programId != null && !programId.trim().isEmpty()) {
            sql.append(" AND c.program_id = ?"); params.add(Integer.parseInt(programId));
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND c.status = ?"); params.add(status.toLowerCase());
        }
        sql.append(" ORDER BY c.created_at DESC");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapRow(rs));
            }
        }
        return out;
    }

    public List<java.util.Map<String, Object>> findAllPrograms() throws SQLException {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            // Try with level column first; fall back if column doesn't exist yet
            try (PreparedStatement ps = conn.prepareStatement("SELECT id, code, name, level FROM program ORDER BY level, name");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",    rs.getInt("id"));
                    m.put("code",  rs.getString("code"));
                    m.put("name",  rs.getString("name"));
                    m.put("level", rs.getString("level"));
                    list.add(m);
                }
            } catch (SQLException e) {
                // level column not yet added — retry without it
                list.clear();
                try (PreparedStatement ps = conn.prepareStatement("SELECT id, code, name FROM program ORDER BY name");
                     ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                        m.put("id",    rs.getInt("id"));
                        m.put("code",  rs.getString("code"));
                        m.put("name",  rs.getString("name"));
                        m.put("level", null);
                        list.add(m);
                    }
                }
            }
        }
        return list;
    }


    public void delete(int candidateId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM co_supervisor WHERE candidate_id = ?")) {
                    ps.setInt(1, candidateId);
                    ps.executeUpdate();
                }
                // Guard: only delete if still in 'prepared' state; prevents accidental removal of active candidates.
        try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM candidate WHERE id = ? AND status = 'prepared'")) {
                    ps.setInt(1, candidateId);
                    ps.executeUpdate();
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

    /** Sets a candidate's status to 'completed'. Only applies when currently 'appointed'. */
    public void markCompleted(int candidateId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE candidate SET status = 'completed' WHERE id = ? AND status = 'appointed'")) {
            ps.setInt(1, candidateId);
            ps.executeUpdate();
        }
    }
}
