package dao;

import model.Document;
import model.Nomination;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data-access methods for nominations, external examiners, and related documents. */
public class NominationDAO {

    public List<Nomination> findAll(String q, String status, boolean showArchived) throws SQLException {
        List<Nomination> out = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT n.id, CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS examiner_name, ee.affiliation AS university, n.status, n.created_at, u.full_name AS nominator_name " +
            "FROM nomination n " +
            "LEFT JOIN external_examiner ee ON n.external_examiner_id = ee.id " +
            "LEFT JOIN `user` u ON n.nominator_user_id = u.id " +
            "WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (ee.name LIKE ? OR ee.affiliation LIKE ?)");
            params.add("%" + q + "%"); params.add("%" + q + "%");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND n.status = ?"); params.add(status.toLowerCase());
        } else if (!showArchived) {
            sql.append(" AND n.status != 'verified'");
        }
        sql.append(" ORDER BY n.created_at DESC");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i+1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Nomination n = new Nomination();
                    n.setId(rs.getInt("id"));
                    n.setExaminerName(rs.getString("examiner_name"));
                    n.setExaminerAffiliation(rs.getString("university"));
                    n.setStatus(rs.getString("status"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setNominatorName(rs.getString("nominator_name"));
                    out.add(n);
                }
            }
        }
        return out;
    }

    public Nomination findById(int id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "SELECT n.*, CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS examiner_name, ee.affiliation AS examiner_affiliation, ee.email AS examiner_email, " +
                "COALESCE(ee.info_confirmed, 0) AS info_confirmed, ee.discrepancy_notes, " +
                "u.full_name AS nominator_name " +
                "FROM nomination n " +
                "LEFT JOIN external_examiner ee ON n.external_examiner_id = ee.id " +
                "LEFT JOIN `user` u ON n.nominator_user_id = u.id " +
                "WHERE n.id = ? LIMIT 1")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Nomination n = new Nomination();
                    n.setId(rs.getInt("id"));
                    n.setExternalExaminerId(rs.getObject("external_examiner_id") != null ? rs.getInt("external_examiner_id") : null);
                    n.setNominatorUserId(rs.getInt("nominator_user_id"));
                    n.setRemarks(rs.getString("remarks"));
                    n.setStatus(rs.getString("status"));
                    n.setNominationDate(rs.getTimestamp("nomination_date"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setExaminerName(rs.getString("examiner_name"));
                    n.setExaminerAffiliation(rs.getString("examiner_affiliation"));
                    n.setExaminerEmail(rs.getString("examiner_email"));
                    n.setExaminerConfirmed(rs.getInt("info_confirmed") == 1);
                    n.setDiscrepancyNotes(rs.getString("discrepancy_notes"));
                    n.setNominatorName(rs.getString("nominator_name"));
                    return n;
                }
            }
        }
        return null;
    }

    public List<Document> getDocumentsForNomination(int nominationId) throws SQLException {
        List<Document> out = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, nomination_id, uploaded_by, filename, filepath, file_type FROM document WHERE nomination_id = ? ORDER BY id")) {
            ps.setInt(1, nominationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Document d = new Document();
                    d.setId(rs.getInt("id"));
                    d.setNominationId(rs.getObject("nomination_id") != null ? rs.getInt("nomination_id") : null);
                    d.setUploadedBy(rs.getObject("uploaded_by") != null ? rs.getInt("uploaded_by") : null);
                    d.setFilename(rs.getString("filename"));
                    d.setFilepath(rs.getString("filepath"));
                    d.setFileType(rs.getString("file_type"));
                    out.add(d);
                }
            }
        }
        return out;
    }

    public void updateStatus(int id, String status, String remarks) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE nomination SET status = ?, remarks = ? WHERE id = ?")) {
            ps.setString(1, status);
            ps.setString(2, remarks);
            ps.setInt(3, id);
            ps.executeUpdate();
        }
    }

    /** Returns the candidate_id linked to a nomination, or -1 if not found. */
    public int getCandidateIdByNominationId(int nominationId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT candidate_id FROM nomination WHERE id = ? LIMIT 1")) {
            ps.setInt(1, nominationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("candidate_id");
            }
        }
        return -1;
    }

    /** Nominations submitted BY a specific user (academician's own list). */
    public List<Nomination> findByUserId(int userId, String q, String status) throws SQLException {
        List<Nomination> out = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT n.id, CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS examiner_name, " +
            "ee.affiliation AS university, ee.email AS examiner_email, ee.info_confirmed, ee.discrepancy_notes, n.status, n.remarks, n.created_at, " +
            "pc.candidate_name " +
            "FROM nomination n " +
            "LEFT JOIN external_examiner ee ON n.external_examiner_id = ee.id " +
            "LEFT JOIN ( " +
            "  SELECT ap.external_examiner_id, c.full_name AS candidate_name " +
            "  FROM appointment_panel ap " +
            "  JOIN viva_appointment va ON va.id = ap.appointment_id " +
            "  JOIN candidate c ON c.id = va.candidate_id " +
            "  GROUP BY ap.external_examiner_id " +
            ") pc ON pc.external_examiner_id = n.external_examiner_id " +
            "WHERE n.nominator_user_id = ?");
        List<Object> params = new ArrayList<>();
        params.add(userId);
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (ee.name LIKE ? OR ee.affiliation LIKE ?)");
            params.add("%" + q + "%"); params.add("%" + q + "%");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND n.status = ?"); params.add(status.toLowerCase());
        }
        sql.append(" ORDER BY n.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Nomination n = new Nomination();
                    n.setId(rs.getInt("id"));
                    n.setExaminerName(rs.getString("examiner_name"));
                    n.setExaminerAffiliation(rs.getString("university"));
                    n.setExaminerEmail(rs.getString("examiner_email"));
                    n.setExaminerConfirmed(rs.getInt("info_confirmed") == 1);
                    n.setDiscrepancyNotes(rs.getString("discrepancy_notes"));
                    n.setRemarks(rs.getString("remarks"));
                    n.setStatus(rs.getString("status"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    n.setCandidateName(rs.getString("candidate_name"));
                    out.add(n);
                }
            }
        }
        return out;
    }

    public int countByUserAndStatus(int userId, String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM nomination WHERE nominator_user_id = ?" +
                     (status != null ? " AND status = ?" : "");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            if (status != null) ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Nominations requiring correction for this academician (for dashboard alert section). */
    public List<Nomination> findCorrectionsRequired(int userId) throws SQLException {
        List<Nomination> out = new ArrayList<>();
        String sql = "SELECT n.id, CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS examiner_name, " +
                     "n.remarks, ee.discrepancy_notes " +
                     "FROM nomination n " +
                     "LEFT JOIN external_examiner ee ON n.external_examiner_id = ee.id " +
                     "WHERE n.nominator_user_id = ? AND n.status = 'needs_correction' " +
                     "ORDER BY n.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Nomination n = new Nomination();
                    n.setId(rs.getInt("id"));
                    n.setExaminerName(rs.getString("examiner_name"));
                    n.setRemarks(rs.getString("remarks"));
                    n.setDiscrepancyNotes(rs.getString("discrepancy_notes"));
                    out.add(n);
                }
            }
        }
        return out;
    }

    /** Recent activity feed for this academician. */
    public List<Nomination> findRecentByUserId(int userId, int limit) throws SQLException {
        List<Nomination> out = new ArrayList<>();
        String sql = "SELECT n.id, CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS examiner_name, n.status, n.created_at " +
                     "FROM nomination n " +
                     "LEFT JOIN external_examiner ee ON n.external_examiner_id = ee.id " +
                     "WHERE n.nominator_user_id = ? " +
                     "ORDER BY n.created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Nomination n = new Nomination();
                    n.setId(rs.getInt("id"));
                    n.setExaminerName(rs.getString("examiner_name"));
                    n.setStatus(rs.getString("status"));
                    n.setCreatedAt(rs.getTimestamp("created_at"));
                    out.add(n);
                }
            }
        }
        return out;
    }

    /**
     * All unverified (pending / requires_correction) nominations with full examiner +
     * specialization detail, for the unverified-nominations report.
     */
    public List<java.util.Map<String,Object>> getUnverifiedNominationsReport() throws SQLException {
        List<java.util.Map<String,Object>> out = new ArrayList<>();
        String sql =
            "SELECT n.id, n.status, DATE_FORMAT(n.created_at, '%d %b %Y') AS nominated_date, " +
            "  u.full_name AS nominator_name, " +
            "  CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS examiner_name, ee.affiliation AS university, ee.email AS examiner_email, " +
            "  COALESCE(s.name, ee.specialization, '') AS specialization_name, " +
            "  COALESCE(exp.name, '') AS expertise_name " +
            "FROM nomination n " +
            "LEFT JOIN external_examiner ee ON n.external_examiner_id = ee.id " +
            "LEFT JOIN `user` u ON n.nominator_user_id = u.id " +
            "LEFT JOIN specialization s   ON s.id   = ee.specialization_id " +
            "LEFT JOIN expertise      exp ON exp.id = ee.expertise_id " +
            "WHERE n.status NOT IN ('verified') " +
            "ORDER BY u.full_name ASC, n.created_at DESC";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String,Object> row = new java.util.LinkedHashMap<>();
                row.put("id",           rs.getInt("id"));
                row.put("status",       rs.getString("status"));
                row.put("date",         rs.getString("nominated_date"));
                row.put("nominator",    rs.getString("nominator_name"));
                row.put("examiner",     rs.getString("examiner_name"));
                row.put("university",   rs.getString("university"));
                row.put("email",        rs.getString("examiner_email"));
                row.put("specialization", rs.getString("specialization_name"));
                row.put("expertise",    rs.getString("expertise_name"));
                out.add(row);
            }
        }
        return out;
    }

    /**
     * Returns all external examiners with specialization data and a flag indicating
     * whether the given user was the nominator.  Used by the Academician Examiner List.
     */
    public List<java.util.Map<String,Object>> findAllExaminers(String q, Integer specId, int currentUserId) throws SQLException {
        List<java.util.Map<String,Object>> out = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT ee.id, CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS name, ee.affiliation, ee.email, ee.phone, ee.status, " +
            "  COALESCE(s.name, ee.specialization, '') AS specialization_name, " +
            "  COALESCE(exp.name, '') AS expertise_name, " +
            "  COALESCE(dv.name, '')  AS division_name, " +
            "  COALESCE(ar.name, '')  AS area_name, " +
            "  ee.specialization_id, ee.expertise_id, ee.division_id, ee.area_id, " +
            // MAX(CASE…) collapses multiple nomination rows per examiner into a single flag.
            "  MAX(CASE WHEN n.nominator_user_id = ? THEN 1 ELSE 0 END) AS is_my_examiner " +
            "FROM external_examiner ee " +
            "LEFT JOIN nomination n       ON n.external_examiner_id = ee.id " +
            "LEFT JOIN specialization s   ON s.id   = ee.specialization_id " +
            "LEFT JOIN expertise      exp ON exp.id = ee.expertise_id " +
            "LEFT JOIN division       dv  ON dv.id  = ee.division_id " +
            "LEFT JOIN area           ar  ON ar.id  = ee.area_id " +
            "WHERE 1=1");
        List<Object> params = new ArrayList<>();
        params.add(currentUserId);
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (ee.name LIKE ? OR ee.affiliation LIKE ?)");
            String like = "%" + q.trim() + "%";
            params.add(like); params.add(like);
        }
        if (specId != null) {
            sql.append(" AND ee.specialization_id = ?");
            params.add(specId);
        }
        sql.append(" GROUP BY ee.id, ee.name, ee.affiliation, ee.email, ee.phone, ee.status, " +
                   "specialization_name, expertise_name, division_name, area_name, " +
                   "ee.specialization_id, ee.expertise_id, ee.division_id, ee.area_id");
        sql.append(" ORDER BY ee.name");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",                  rs.getInt("id"));
                    m.put("name",                rs.getString("name"));
                    m.put("affiliation",         rs.getString("affiliation"));
                    m.put("email",               rs.getString("email"));
                    m.put("phone",               rs.getString("phone"));
                    m.put("status",              rs.getString("status"));
                    m.put("specialization_name", rs.getString("specialization_name"));
                    m.put("expertise_name",      rs.getString("expertise_name"));
                    m.put("division_name",       rs.getString("division_name"));
                    m.put("area_name",           rs.getString("area_name"));
                    m.put("specialization_id",   rs.getObject("specialization_id"));
                    m.put("is_my_examiner",      rs.getInt("is_my_examiner") == 1);
                    out.add(m);
                }
            }
        }
        return out;
    }

    /** Returns a single external examiner with full hierarchy data for the edit form. */
    public java.util.Map<String,Object> findExaminerById(int id) throws SQLException {
        String sql =
            "SELECT ee.id, ee.name, ee.affiliation, ee.email, ee.phone, ee.status, " +
            "  ee.specialization_id, ee.expertise_id, ee.division_id, ee.area_id, " +
            "  COALESCE(s.name, ee.specialization, '') AS specialization_name, " +
            "  COALESCE(exp.name, '') AS expertise_name, " +
            "  COALESCE(dv.name, '')  AS division_name, " +
            "  COALESCE(ar.name, '')  AS area_name " +
            "FROM external_examiner ee " +
            "LEFT JOIN specialization s   ON s.id   = ee.specialization_id " +
            "LEFT JOIN expertise      exp ON exp.id = ee.expertise_id " +
            "LEFT JOIN division       dv  ON dv.id  = ee.division_id " +
            "LEFT JOIN area           ar  ON ar.id  = ee.area_id " +
            "WHERE ee.id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",                  rs.getInt("id"));
                    m.put("name",                rs.getString("name"));
                    m.put("affiliation",         rs.getString("affiliation"));
                    m.put("email",               rs.getString("email"));
                    m.put("phone",               rs.getString("phone"));
                    m.put("status",              rs.getString("status"));
                    m.put("specialization_id",   rs.getObject("specialization_id"));
                    m.put("expertise_id",        rs.getObject("expertise_id"));
                    m.put("division_id",         rs.getObject("division_id"));
                    m.put("area_id",             rs.getObject("area_id"));
                    m.put("specialization_name", rs.getString("specialization_name"));
                    m.put("expertise_name",      rs.getString("expertise_name"));
                    m.put("division_name",       rs.getString("division_name"));
                    m.put("area_name",           rs.getString("area_name"));
                    return m;
                }
            }
        }
        return null;
    }

    /**
     * Returns the user_id of the nominator who submitted the nomination for this examiner.
     * Used to verify edit permissions (only the nominator may edit).
     */
    public Integer getNominatorUserIdForExaminer(int examinerId) throws SQLException {
        String sql = "SELECT nominator_user_id FROM nomination WHERE external_examiner_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, examinerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("nominator_user_id");
            }
        }
        return null;
    }

    /** Updates external_examiner fields (used by nominator-only edit). */
    public void updateExaminer(int id, String name, String affiliation, String email, String phone,
                               Integer specializationId, Integer expertiseId, Integer divisionId, Integer areaId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "UPDATE external_examiner SET name=?, affiliation=?, email=?, phone=?, " +
                "specialization_id=?, expertise_id=?, division_id=?, area_id=? WHERE id=?")) {
            ps.setString(1, name);
            ps.setString(2, affiliation);
            ps.setString(3, email);
            ps.setString(4, phone);
            if (specializationId != null) ps.setInt(5, specializationId); else ps.setNull(5, java.sql.Types.INTEGER);
            if (expertiseId      != null) ps.setInt(6, expertiseId);      else ps.setNull(6, java.sql.Types.INTEGER);
            if (divisionId       != null) ps.setInt(7, divisionId);       else ps.setNull(7, java.sql.Types.INTEGER);
            if (areaId           != null) ps.setInt(8, areaId);           else ps.setNull(8, java.sql.Types.INTEGER);
            ps.setInt(9, id);
            ps.executeUpdate();
        }
    }

    /**
     * Updates ALL editable fields on external_examiner, then resets nomination status
     * to 'submitted' and clears the admin correction remarks in a single transaction.
     */
    public void updateNominationAfterCorrection(
            int nominationId, int examinerId,
            String name, String affiliation, String email, String phone,
            String title, String gender, String nationality, String icPassport,
            String faculty, String country, String specialization,
            Integer specializationId, Integer expertiseId, Integer divisionId, Integer areaId,
            String qualification, String position) throws SQLException {

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE external_examiner SET name=?, affiliation=?, email=?, phone=?, " +
                        "title=?, gender=?, nationality=?, ic_passport=?, faculty=?, country=?, " +
                        "specialization=?, specialization_id=?, expertise_id=?, division_id=?, area_id=?, " +
                        "qualification=?, position=?, discrepancy_notes=NULL WHERE id=?")) {
                    ps.setString(1, name);
                    ps.setString(2, affiliation);
                    ps.setString(3, email);
                    ps.setString(4, phone);
                    ps.setString(5, title);
                    ps.setString(6, gender);
                    ps.setString(7, nationality);
                    ps.setString(8, icPassport);
                    ps.setString(9, faculty);
                    ps.setString(10, country);
                    ps.setString(11, specialization);
                    if (specializationId != null) ps.setInt(12, specializationId); else ps.setNull(12, java.sql.Types.INTEGER);
                    if (expertiseId      != null) ps.setInt(13, expertiseId);      else ps.setNull(13, java.sql.Types.INTEGER);
                    if (divisionId       != null) ps.setInt(14, divisionId);       else ps.setNull(14, java.sql.Types.INTEGER);
                    if (areaId           != null) ps.setInt(15, areaId);           else ps.setNull(15, java.sql.Types.INTEGER);
                    ps.setString(16, qualification);
                    ps.setString(17, position);
                    ps.setInt(18, examinerId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE nomination SET status='pending_examiner', remarks=NULL WHERE id=?")) {
                    ps.setInt(1, nominationId);
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

    /**
     * Updates external_examiner fields and resubmits directly to 'submitted' after an
     * admin-requested correction. Examiner re-confirmation is skipped because the examiner
     * already confirmed their info — admin only needed an additional document or minor fix.
     */
    public void updateNominationForAdminCorrection(
            int nominationId, int examinerId,
            String name, String affiliation, String email, String phone,
            String title, String gender, String nationality, String icPassport,
            String faculty, String country, String specialization,
            Integer specializationId, Integer expertiseId, Integer divisionId, Integer areaId,
            String qualification, String position) throws SQLException {

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE external_examiner SET name=?, affiliation=?, email=?, phone=?, " +
                        "title=?, gender=?, nationality=?, ic_passport=?, faculty=?, country=?, " +
                        "specialization=?, specialization_id=?, expertise_id=?, division_id=?, area_id=?, " +
                        "qualification=?, position=? WHERE id=?")) {
                    ps.setString(1, name);
                    ps.setString(2, affiliation);
                    ps.setString(3, email);
                    ps.setString(4, phone);
                    ps.setString(5, title);
                    ps.setString(6, gender);
                    ps.setString(7, nationality);
                    ps.setString(8, icPassport);
                    ps.setString(9, faculty);
                    ps.setString(10, country);
                    ps.setString(11, specialization);
                    if (specializationId != null) ps.setInt(12, specializationId); else ps.setNull(12, java.sql.Types.INTEGER);
                    if (expertiseId      != null) ps.setInt(13, expertiseId);      else ps.setNull(13, java.sql.Types.INTEGER);
                    if (divisionId       != null) ps.setInt(14, divisionId);       else ps.setNull(14, java.sql.Types.INTEGER);
                    if (areaId           != null) ps.setInt(15, areaId);           else ps.setNull(15, java.sql.Types.INTEGER);
                    ps.setString(16, qualification);
                    ps.setString(17, position);
                    ps.setInt(18, examinerId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE nomination SET status='submitted', remarks=NULL WHERE id=?")) {
                    ps.setInt(1, nominationId);
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

    /** Returns all specializations for the edit examiner form dropdowns. */
    public List<java.util.Map<String,Object>> getAllSpecializations() throws SQLException {
        List<java.util.Map<String,Object>> out = new ArrayList<>();
        String sql = "SELECT id, name FROM specialization ORDER BY name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                m.put("id",   rs.getInt("id"));
                m.put("name", rs.getString("name"));
                out.add(m);
            }
        }
        return out;
    }

    // ─── Examiner verification token methods ──────────────────────────────────

    /** Stores a fresh verification token for an examiner. Overwrites any existing token. */
    public void saveVerificationToken(int examinerId, String token, java.sql.Timestamp expiresAt) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "UPDATE external_examiner SET verification_token=?, token_expires_at=?, " +
                "info_confirmed=0, confirmed_at=NULL, discrepancy_notes=NULL WHERE id=?")) {
            ps.setString(1, token);
            ps.setTimestamp(2, expiresAt);
            ps.setInt(3, examinerId);
            ps.executeUpdate();
        }
    }

    /**
     * Looks up an examiner by verification token.
     * Returns null if the token does not exist or has expired.
     */
    public model.ExternalExaminer getExaminerByToken(String token) throws SQLException {
        String sql =
            "SELECT ee.id, ee.name, ee.affiliation, ee.email, ee.phone, ee.title, ee.gender, " +
            "  ee.nationality, ee.ic_passport, ee.faculty, ee.country, ee.specialization, " +
            "  ee.qualification, ee.position, ee.info_confirmed, ee.confirmed_at, " +
            "  ee.discrepancy_notes, ee.token_expires_at, ee.verification_token, " +
            "  COALESCE(s.name, ee.specialization, '') AS spec_name, " +
            "  COALESCE(exp.name, '') AS exp_name, " +
            "  COALESCE(dv.name, '')  AS div_name, " +
            "  COALESCE(ar.name, '')  AS area_name " +
            "FROM external_examiner ee " +
            "LEFT JOIN specialization s   ON s.id   = ee.specialization_id " +
            "LEFT JOIN expertise      exp ON exp.id = ee.expertise_id " +
            "LEFT JOIN division       dv  ON dv.id  = ee.division_id " +
            "LEFT JOIN area           ar  ON ar.id  = ee.area_id " +
            "WHERE ee.verification_token = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                model.ExternalExaminer ee = new model.ExternalExaminer();
                ee.setId(rs.getInt("id"));
                ee.setName(rs.getString("name"));
                ee.setAffiliation(rs.getString("affiliation"));
                ee.setEmail(rs.getString("email"));
                ee.setPhone(rs.getString("phone"));
                ee.setTitle(rs.getString("title"));
                ee.setGender(rs.getString("gender"));
                ee.setNationality(rs.getString("nationality"));
                ee.setIcPassport(rs.getString("ic_passport"));
                ee.setFaculty(rs.getString("faculty"));
                ee.setCountry(rs.getString("country"));
                ee.setSpecialization(rs.getString("spec_name"));
                ee.setQualification(rs.getString("qualification"));
                ee.setPosition(rs.getString("position"));
                ee.setInfoConfirmed(rs.getInt("info_confirmed") == 1);
                ee.setConfirmedAt(rs.getTimestamp("confirmed_at"));
                ee.setDiscrepancyNotes(rs.getString("discrepancy_notes"));
                ee.setTokenExpiresAt(rs.getTimestamp("token_expires_at"));
                ee.setVerificationToken(rs.getString("verification_token"));
                return ee;
            }
        }
    }

    /**
     * Returns all documents uploaded for the nomination linked to the given examiner verification token.
     * Used by the public verification page so the examiner can download their own submitted files.
     */
    public List<Document> getDocumentsByToken(String token) throws SQLException {
        List<Document> out = new ArrayList<>();
        String sql =
            "SELECT d.id, d.nomination_id, d.uploaded_by, d.filename, d.filepath, d.file_type " +
            "FROM document d " +
            "JOIN nomination n ON n.id = d.nomination_id " +
            "JOIN external_examiner ee ON ee.id = n.external_examiner_id " +
            "WHERE ee.verification_token = ? ORDER BY d.id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Document d = new Document();
                    d.setId(rs.getInt("id"));
                    d.setNominationId(rs.getObject("nomination_id") != null ? rs.getInt("nomination_id") : null);
                    d.setUploadedBy(rs.getObject("uploaded_by") != null ? rs.getInt("uploaded_by") : null);
                    d.setFilename(rs.getString("filename"));
                    d.setFilepath(rs.getString("filepath"));
                    d.setFileType(rs.getString("file_type"));
                    out.add(d);
                }
            }
        }
        return out;
    }

    /** Marks the examiner's information as confirmed (called on examiner approval). */
    public void markInfoConfirmed(String token) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Mark examiner as confirmed
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE external_examiner SET info_confirmed=1, confirmed_at=NOW() " +
                        "WHERE verification_token=?")) {
                    ps.setString(1, token);
                    ps.executeUpdate();
                }
                // Advance nomination to 'submitted' so admin can review.
                // Allow from any non-final status so resend-without-edit still works
                // (status may be 'needs_correction' if examiner previously reported a discrepancy
                // and academician resent the email rather than using the edit form).
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE nomination n " +
                        "JOIN external_examiner ee ON n.external_examiner_id = ee.id " +
                        "SET n.status='submitted' " +
                        "WHERE ee.verification_token=? AND n.status NOT IN ('verified')")) {
                    ps.setString(1, token);
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

    /** Saves a discrepancy note from the examiner (they report an issue). */
    public void saveDiscrepancy(String token, String notes) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Store the discrepancy notes on the examiner record
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE external_examiner SET discrepancy_notes=? WHERE verification_token=?")) {
                    ps.setString(1, notes);
                    ps.setString(2, token);
                    ps.executeUpdate();
                }
                // Automatically flag the linked nomination as needs correction
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE nomination n " +
                        "JOIN external_examiner ee ON n.external_examiner_id = ee.id " +
                        "SET n.status='needs_correction' " +
                        "WHERE ee.verification_token=?")) {
                    ps.setString(1, token);
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

    /**
     * Resets a nomination's status back to 'pending_examiner'.
     * Called by SendVerificationEmailServlet when resending the verification email
     * so the UI reflects that the examiner has been re-notified and confirmation
     * is pending again (handles the needs_correction → resend scenario).
     * Does not touch 'verified' nominations.
     */
    public void resetToPendingExaminer(int nominationId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                "UPDATE nomination SET status='pending_examiner' " +
                "WHERE id=? AND status != 'verified'")) {
            ps.setInt(1, nominationId);
            ps.executeUpdate();
        }
    }

    /**
     * Returns the external_examiner id linked to a nomination,
     * along with the examiner's email — for the resend feature.
     */
    public java.util.Map<String,Object> getExaminerInfoByNominationId(int nominationId) throws SQLException {
        String sql = "SELECT ee.id, ee.title, ee.name, ee.email " +
                     "FROM nomination n " +
                     "JOIN external_examiner ee ON ee.id = n.external_examiner_id " +
                     "WHERE n.id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nominationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",    rs.getInt("id"));
                    m.put("title", rs.getString("title"));
                    m.put("name",  rs.getString("name"));
                    m.put("email", rs.getString("email"));
                    return m;
                }
            }
        }
        return null;
    }

    /**
     * Returns the nominator user_id for a given nomination id.
     * Used by SendVerificationEmailServlet to verify ownership.
     */
    public Integer getNominatorUserIdByNominationId(int nominationId) throws SQLException {
        String sql = "SELECT nominator_user_id FROM nomination WHERE id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nominationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("nominator_user_id");
            }
        }
        return null;
    }

    /**
     * Returns nominator name, email, and examiner display name for a nomination.
     * Used to send email notifications when admin changes nomination status.
     */
    public java.util.Map<String,String> getNominatorInfoByNominationId(int nominationId) throws SQLException {
        String sql = "SELECT u.email, " +
                     "TRIM(CONCAT(COALESCE(CONCAT(ast.title, ' '), COALESCE(CONCAT(t.name, ' '), '')), u.full_name)) AS full_name, " +
                     "CONCAT(COALESCE(CONCAT(ee.title, ' '), ''), ee.name) AS examiner_name " +
                     "FROM nomination n " +
                     "JOIN `user` u ON u.id = n.nominator_user_id " +
                     "LEFT JOIN academic_staff ast ON ast.user_id = u.id " +
                     "LEFT JOIN title t ON t.id = u.title_id " +
                     "LEFT JOIN external_examiner ee ON ee.id = n.external_examiner_id " +
                     "WHERE n.id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nominationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
                    m.put("email",        rs.getString("email"));
                    m.put("fullName",     rs.getString("full_name"));
                    m.put("examinerName", rs.getString("examiner_name"));
                    return m;
                }
            }
        }
        return null;
    }

    /**
     * Returns email and full_name for all active Admin users.
     * Used to notify admins when a nomination is ready for review.
     */
    public List<java.util.Map<String,String>> getAdminEmails() throws SQLException {
        List<java.util.Map<String,String>> out = new ArrayList<>();
        String sql = "SELECT u.email, " +
                     "TRIM(CONCAT(COALESCE(CONCAT(t.name, ' '), ''), u.full_name)) AS full_name " +
                     "FROM `user` u " +
                     "JOIN role r ON u.role_id = r.id " +
                     "LEFT JOIN title t ON t.id = u.title_id " +
                     "WHERE r.name = 'Admin' AND u.status = 'active'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
                m.put("email",    rs.getString("email"));
                m.put("fullName", rs.getString("full_name"));
                out.add(m);
            }
        }
        return out;
    }

    /**
     * Returns the nominator's email and name, looked up via the external_examiner id.
     * Used to notify the academician when an examiner reports a discrepancy.
     */
    public java.util.Map<String,String> getNominatorEmailByExaminerId(int examinerId) throws SQLException {
        String sql = "SELECT u.email, " +
                     "TRIM(CONCAT(COALESCE(CONCAT(ast.title, ' '), COALESCE(CONCAT(t.name, ' '), '')), u.full_name)) AS full_name " +
                     "FROM nomination n " +
                     "JOIN `user` u ON u.id = n.nominator_user_id " +
                     "LEFT JOIN academic_staff ast ON ast.user_id = u.id " +
                     "LEFT JOIN title t ON t.id = u.title_id " +
                     "WHERE n.external_examiner_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, examinerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
                    m.put("email",    rs.getString("email"));
                    m.put("fullName", rs.getString("full_name"));
                    return m;
                }
            }
        }
        return null;
    }

    /**
     * Deletes a single document by ID, but only if it belongs to the given nomination.
     * Returns the filepath so the caller can delete the file on disk.
     */
    public String deleteDocumentById(int docId, int nominationId) throws SQLException {
        String filepath = null;
        try (Connection conn = DBConnection.getConnection()) {
            // Fetch filepath first (for on-disk cleanup)
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT filepath FROM document WHERE id = ? AND nomination_id = ? LIMIT 1")) {
                ps.setInt(1, docId);
                ps.setInt(2, nominationId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) filepath = rs.getString("filepath");
                }
            }
            if (filepath == null) return null; // not found or wrong nomination
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM document WHERE id = ? AND nomination_id = ?")) {
                ps.setInt(1, docId);
                ps.setInt(2, nominationId);
                ps.executeUpdate();
            }
        }
        return filepath;
    }

    /**
     * Deletes a nomination and its linked external_examiner + documents.
     * Only the nominator (or Admin) may call this; ownership must be verified before calling.
     * Safe to call even if the examiner record is shared — in this system each examiner
     * belongs to exactly one nomination.
     */
    public void deleteNomination(int nominationId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Get examiner id before deleting
                int examinerId = -1;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT external_examiner_id FROM nomination WHERE id = ? LIMIT 1")) {
                    ps.setInt(1, nominationId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getObject("external_examiner_id") != null)
                            examinerId = rs.getInt("external_examiner_id");
                    }
                }
                // 2. Delete documents
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM document WHERE nomination_id = ?")) {
                    ps.setInt(1, nominationId);
                    ps.executeUpdate();
                }
                // 3. Delete nomination
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM nomination WHERE id = ?")) {
                    ps.setInt(1, nominationId);
                    ps.executeUpdate();
                }
                // 4. Delete external examiner (only if not referenced elsewhere)
                if (examinerId > 0) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM external_examiner WHERE id = ? " +
                            "AND NOT EXISTS (SELECT 1 FROM nomination WHERE external_examiner_id = ?)")) {
                        ps.setInt(1, examinerId);
                        ps.setInt(2, examinerId);
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
}
