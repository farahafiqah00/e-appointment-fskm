package dao;

import model.User;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/** Data-access methods for the user account table. */
public class UserDAO {

    private static final String SELECT_BY_EMAIL = "SELECT u.id, u.role_id, u.username, u.password_hash, u.email, u.full_name, u.phone, u.status, u.created_at, r.name AS role_name FROM `user` u LEFT JOIN role r ON u.role_id = r.id WHERE u.email = ? LIMIT 1";

    public User findByEmail(String email) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BY_EMAIL)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setRoleId(rs.getInt("role_id"));
                    u.setUsername(rs.getString("username"));
                    u.setPasswordHash(rs.getString("password_hash"));
                    u.setEmail(rs.getString("email"));
                    u.setFullName(rs.getString("full_name"));
                    u.setPhone(rs.getString("phone"));
                    u.setStatus(rs.getString("status"));
                    u.setCreatedAt(rs.getTimestamp("created_at"));
                    u.setRoleName(rs.getString("role_name"));
                    return u;
                }
            }
        }
        return null;
    }

    public List<User> findAll(String q, String role, String status) throws SQLException {
        List<User> out = new ArrayList<>();
        // CONCAT(COALESCE(CONCAT(t.name, ' '), ''), full_name) prepends the academic title
        // (e.g. "Prof. Dr.") only when one exists, avoiding a leading space for untitled users.
        StringBuilder sql = new StringBuilder(
            "SELECT u.id, u.username, u.email, " +
            "TRIM(CONCAT(COALESCE(CONCAT(t.name, ' '), ''), u.full_name)) AS full_name, " +
            "u.status, u.created_at, r.name AS role_name " +
            "FROM `user` u " +
            "LEFT JOIN role r ON u.role_id = r.id " +
            "LEFT JOIN title t ON u.title_id = t.id " +
            "WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (q != null && !q.trim().isEmpty()) {
            sql.append(" AND (CONCAT(COALESCE(CONCAT(t.name, ' '), ''), u.full_name) LIKE ? OR u.email LIKE ?)");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
        }
        if (role != null && !role.trim().isEmpty()) {
            sql.append(" AND r.name = ?");
            params.add(role);
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND u.status = ?");
            params.add(status.toLowerCase());
        }
        sql.append(" ORDER BY u.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setFullName(rs.getString("full_name"));
                    u.setStatus(rs.getString("status"));
                    u.setCreatedAt(rs.getTimestamp("created_at"));
                    u.setRoleName(rs.getString("role_name"));
                    out.add(u);
                }
            }
        }
        return out;
    }

    public User findById(int id) throws SQLException {
        String sql = "SELECT u.id, u.role_id, u.username, u.password_hash, u.email, u.full_name, u.phone, " +
                     "u.status, u.created_at, r.name AS role_name " +
                     "FROM `user` u LEFT JOIN role r ON u.role_id = r.id WHERE u.id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setRoleId(rs.getInt("role_id"));
                    u.setUsername(rs.getString("username"));
                    u.setPasswordHash(rs.getString("password_hash"));
                    u.setEmail(rs.getString("email"));
                    u.setFullName(rs.getString("full_name"));
                    u.setPhone(rs.getString("phone"));
                    u.setStatus(rs.getString("status"));
                    u.setCreatedAt(rs.getTimestamp("created_at"));
                    u.setRoleName(rs.getString("role_name"));
                    return u;
                }
            }
        }
        return null;
    }

    /**
     * Updates full_name, email, phone for a user.
     * If newPasswordHash is non-null it is also updated.
     * Returns true if the row was found and updated.
     */
    public boolean updateProfile(int id, String fullName, String email, String phone,
                                 String newPasswordHash) throws SQLException {
        String sql = newPasswordHash != null
            ? "UPDATE `user` SET full_name=?, email=?, phone=?, password_hash=? WHERE id=?"
            : "UPDATE `user` SET full_name=?, email=?, phone=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            if (newPasswordHash != null) {
                ps.setString(4, newPasswordHash);
                ps.setInt(5, id);
            } else {
                ps.setInt(4, id);
            }
            return ps.executeUpdate() > 0;
        }
    }

    public boolean emailTakenByOther(String email, int excludeUserId) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT 1 FROM `user` WHERE email = ? AND id != ? LIMIT 1")) {
            ps.setString(1, email);
            ps.setInt(2, excludeUserId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }
}
