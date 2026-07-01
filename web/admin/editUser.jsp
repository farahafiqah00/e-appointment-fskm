<%-- Admin: form to edit an existing user's name, email, role, title, status, and optional password reset. --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String id = request.getParameter("id") != null ? request.getParameter("id") : "";
  String fullNameVal = "";
  String emailVal = "";
  String roleVal = "Admin";
  String statusVal = "Active";
  String createdDateVal = "";
  String titleVal = null;
  String adminPosVal = "";
  if (!id.isEmpty()) {
    try (java.sql.Connection c = util.DBConnection.getConnection();
       java.sql.PreparedStatement ps = c.prepareStatement(
           "SELECT u.full_name, u.email, u.status, u.created_at, r.name AS role_name, t.name AS title_name, " +
           "COALESCE(ast.administrative_position, '') AS administrative_position " +
           "FROM `user` u LEFT JOIN role r ON u.role_id = r.id LEFT JOIN title t ON u.title_id = t.id " +
           "LEFT JOIN academic_staff ast ON ast.user_id = u.id " +
           "WHERE u.id = ? LIMIT 1")) {
      ps.setInt(1, Integer.parseInt(id));
      try (java.sql.ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          fullNameVal = rs.getString("full_name");
          emailVal = rs.getString("email");
          statusVal = rs.getString("status");
          java.sql.Timestamp ct = rs.getTimestamp("created_at");
          createdDateVal = ct != null ? ct.toString() : "";
          roleVal = rs.getString("role_name") != null ? rs.getString("role_name") : roleVal;
          titleVal = rs.getString("title_name");
          adminPosVal = rs.getString("administrative_position");
        }
      }
    } catch (Exception e) { }
  }
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Edit User - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  </head>
  <body class="admin">
    <jsp:include page="/includes/topbar.jsp" />

    <div class="layout">
      <% request.setAttribute("activeSection", "users"); %>
      <jsp:include page="/admin/sidebar.jsp" />
      <main class="content">
        <div style="max-width:860px; margin:0 auto; padding:0 8px;">
          <div class="ea-section-header mb-4" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div>
              <h1 class="ea-dashboard-title mb-1" style="font-size:2rem;font-weight:700;color:#105e60;">Edit User</h1>
              <div class="ea-dashboard-subtitle" style="font-size:1rem;color:#6b7280;">Update existing user information</div>
            </div>
            <div>
              <a href="<%= request.getContextPath() %>/UserListServlet" class="btn-ea-back">
                <i class="bi bi-arrow-left me-2"></i> Back to User List
              </a>
            </div>
          </div>
          <div class="card" style="border-radius:16px;border:1px solid #e5e7eb;box-shadow:0 2px 12px rgba(0,0,0,0.06);padding:0;">
            <div class="card-body" style="padding:2rem;">
              <div class="d-flex align-items-center mb-4" style="gap:10px;">
                <i class="bi bi-pencil-square" style="font-size:1.3rem;color:#0f766e;"></i>
                <span style="font-size:1.05rem;font-weight:600;color:#111827;">User Information</span>
              </div>
              <form method="POST" action="<%= request.getContextPath() %>/EditUserServlet">
                <input type="hidden" name="id" value="<%= id %>">
                <div class="row g-3">
                  <div class="col-md-6">
                    <label class="form-label fw-medium">User ID</label>
                    <input type="text" class="form-control" value="<%= id %>" readonly style="background:#f3f4f6;border-radius:10px;border-color:#e5e7eb;">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Created Date</label>
                    <input type="text" class="form-control" value="<%= createdDateVal %>" readonly style="background:#f3f4f6;border-radius:10px;border-color:#e5e7eb;">
                  </div>
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Title</label>
                    <select name="title" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                      <%
                        try (java.sql.Connection c = util.DBConnection.getConnection();
                             java.sql.PreparedStatement ps = c.prepareStatement("SELECT name FROM title ORDER BY id")) {
                          try (java.sql.ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                              String t = rs.getString("name");
                      %>
                      <option <%= (t.equals(titleVal) ? "selected" : "") %>><%= t %></option>
                      <%      }
                          }
                        } catch (Exception e) { %>
                      <option <%= ("Mr".equals(titleVal) ? "selected" : "") %>>Mr</option>
                      <option <%= ("Dr".equals(titleVal) ? "selected" : "") %>>Dr</option>
                      <option <%= ("Assoc".equals(titleVal) ? "selected" : "") %>>Assoc. Prof. Dr</option>
                      <option <%= ("Prof".equals(titleVal) ? "selected" : "") %>>Prof. Dr</option>
                      <% } %>
                    </select>
                  </div>
                  <div class="col-md-8">
                    <label class="form-label fw-medium">Full Name <span class="text-danger">*</span></label>
                    <input type="text" name="fullName" class="form-control" value="<%= fullNameVal %>" required style="border-radius:10px;border-color:#e5e7eb;">
                  </div>
                  <div class="col-12">
                    <label class="form-label fw-medium">Email <span class="text-danger">*</span></label>
                    <input type="email" name="email" class="form-control" value="<%= emailVal %>" required style="border-radius:10px;border-color:#e5e7eb;">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Role <span class="text-danger">*</span></label>
                    <select name="role" id="roleSelect" class="form-select" style="border-radius:10px;border-color:#e5e7eb;" onchange="toggleAdminPos()">
                      <option <%= ("Admin".equals(roleVal) ? "selected" : "") %>>Admin</option>
                      <option <%= ("Academician".equals(roleVal) ? "selected" : "") %>>Academician</option>
                      <option <%= ("Dean".equals(roleVal) ? "selected" : "") %>>Dean</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Account Status <span class="text-danger">*</span></label>
                    <select name="status" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                      <option <%= ("active".equalsIgnoreCase(statusVal) ? "selected" : "") %>>Active</option>
                      <option <%= (!"active".equalsIgnoreCase(statusVal) ? "selected" : "") %>>Deactivated</option>
                    </select>
                  </div>
                  <div class="col-md-6" id="adminPosField" style="<%= ("Academician".equals(roleVal) || "Dean".equals(roleVal)) ? "" : "display:none;" %>">
                    <label class="form-label fw-medium">Administrative Position</label>
                    <select name="administrative_position" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                      <option value="" <%= ("".equals(adminPosVal) ? "selected" : "") %>>— None —</option>
                      <option value="TDA" <%= ("TDA".equals(adminPosVal) ? "selected" : "") %>>TDA — Timbalan Dekan (Akademik)</option>
                      <option value="TDB" <%= ("TDB".equals(adminPosVal) ? "selected" : "") %>>TDB — Timbalan Dekan (Berkaitan)</option>
                    </select>
                    <div class="form-text text-muted">Only set this for staff who sign appointment letters as TDA or TDB.</div>
                  </div>
                </div>
                <div class="d-flex gap-2 mt-4">
                  <button type="submit" class="ea-btn-primary-action"><i class="bi bi-check-lg me-2"></i>Update User</button>
                  <a href="<%= request.getContextPath() %>/UserListServlet" class="btn-ea-back">Cancel</a>
                </div>
              </form>
            </div>
          </div>
        </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function toggleAdminPos() {
      var role = document.getElementById('roleSelect').value;
      var field = document.getElementById('adminPosField');
      field.style.display = (role === 'Academician' || role === 'Dean') ? '' : 'none';
    }
  </script>
  </body>
</html>
