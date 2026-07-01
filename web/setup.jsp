<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="util.DBConnection, util.PasswordUtil, java.sql.*" %>
<%
    /* -----------------------------------------------------------------------
       Process POST: create first admin directly (no email required).
       setup.jsp is already whitelisted in SessionFilter, so this always works.
    ----------------------------------------------------------------------- */
    String successEmail = null;
    String successPw    = null;
    String errMsg       = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fullName = request.getParameter("fullName");
        String email    = request.getParameter("email");
        String pw       = request.getParameter("pw");

        if (fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || pw == null || pw.trim().isEmpty()) {
            errMsg = "All fields are required.";
        } else {
            String hash = PasswordUtil.hash(pw.trim());
            String username = email.trim().split("@")[0];
            try (Connection conn = DBConnection.getConnection()) {
                // Ensure role exists
                Integer roleId = null;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT id FROM role WHERE name='System Administrator' LIMIT 1");
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) roleId = rs.getInt(1);
                }
                if (roleId == null) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT IGNORE INTO role (name) VALUES ('System Administrator')")) {
                        ps.executeUpdate();
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "SELECT id FROM role WHERE name='System Administrator' LIMIT 1");
                         ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) roleId = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO `user` (role_id, username, password_hash, email, full_name, status) VALUES (?,?,?,?,?,'active')")) {
                    ps.setInt(1, roleId);
                    ps.setString(2, username);
                    ps.setString(3, hash);
                    ps.setString(4, email.trim());
                    ps.setString(5, fullName.trim());
                    ps.executeUpdate();
                }
                successEmail = email.trim();
                successPw    = pw.trim();
            } catch (SQLException e) {
                if (e.getErrorCode() == 1062) errMsg = "An account with that email already exists.";
                else errMsg = "Database error: " + e.getMessage();
            }
        }
    }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>System Setup - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="login">
  <div class="login-wrapper">
    <div class="login-card">
      <div class="login-brand">
        <div class="brand-inner">
          <img src="/web/images/umt-logo.png" alt="UMT" style="max-width:140px;margin-bottom:18px" onerror="this.style.display='none'">
          <h2 style="color:var(--primary);font-weight:800;">E-Appointment FSKM</h2>
          <p class="muted">First-Time Setup</p>
        </div>
      </div>
      <div class="login-form">
        <div style="max-width:520px;margin:0 auto;padding-top:12px">

          <% if (successEmail != null) { %>
          <!-- Success panel -->
          <div style="background:#f0fdf4;border:2px solid #86efac;border-radius:14px;padding:20px 24px;margin-bottom:20px;">
            <div style="font-weight:700;color:#15803d;font-size:1.05rem;margin-bottom:12px;">
              <i class="bi bi-check-circle-fill me-2"></i>Administrator account created!
            </div>
            <p style="font-size:0.85rem;color:#166534;margin-bottom:12px;">
              Save these credentials — this page will not show them again.
            </p>
            <table style="font-size:0.93rem;border-collapse:collapse;">
              <tr>
                <td style="padding:4px 14px 4px 0;color:#6b7280;font-weight:600;width:90px;">Email</td>
                <td><code style="background:#dcfce7;padding:3px 10px;border-radius:5px;color:#166534;"><%= successEmail %></code></td>
              </tr>
              <tr>
                <td style="padding:4px 14px 4px 0;color:#6b7280;font-weight:600;">Password</td>
                <td><code style="background:#dcfce7;padding:3px 10px;border-radius:5px;color:#166534;font-weight:700;letter-spacing:1px;"><%= successPw %></code></td>
              </tr>
            </table>
            <div class="d-grid mt-4">
              <a href="<%= request.getContextPath() %>/login.jsp" class="btn btn-primary-action btn-lg action-card">
                Go to Login
              </a>
            </div>
          </div>

          <% } else { %>

          <div style="background:#fef3c7;border:1px solid #fcd34d;border-radius:12px;padding:12px 16px;margin-bottom:20px;display:flex;gap:10px;align-items:flex-start;">
            <i class="bi bi-shield-lock-fill" style="color:#d97706;font-size:1.2rem;flex-shrink:0;margin-top:2px;"></i>
            <div style="font-size:0.88rem;color:#92400e;">
              <strong>One-time setup.</strong> This page auto-disables once an admin account exists.
            </div>
          </div>

          <h5 style="font-weight:700;color:#111827;margin-bottom:4px;">Create Administrator Account</h5>
          <p style="color:#6b7280;font-size:0.92rem;margin-bottom:20px;">
            Set the credentials for the first System Administrator.
          </p>

          <% if (errMsg != null) { %>
          <div class="alert alert-danger py-2" style="font-size:0.9rem;"><%= errMsg %></div>
          <% } %>

          <form method="POST" action="<%= request.getContextPath() %>/setup.jsp">
            <div class="mb-3">
              <label class="form-label small-foot">Full Name</label>
              <div class="input-with-icon">
                <div class="icon"><i class="bi bi-person"></i></div>
                <input type="text" name="fullName" class="form-control"
                       placeholder="e.g. Ahmad bin Abdullah" required autofocus>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label small-foot">Email Address</label>
              <div class="input-with-icon">
                <div class="icon"><i class="bi bi-envelope"></i></div>
                <input type="email" name="email" class="form-control"
                       placeholder="e.g. admin@umt.edu.my" required>
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label small-foot">Password</label>
              <div class="input-with-icon">
                <div class="icon"><i class="bi bi-lock"></i></div>
                <input type="text" name="pw" class="form-control"
                       placeholder="Choose a password" required>
              </div>
            </div>
            <div class="d-grid mt-3">
              <button type="submit" class="btn btn-primary-action btn-lg action-card">
                Create Administrator Account
              </button>
            </div>
          </form>
          <% } %>

        </div>
      </div>
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
