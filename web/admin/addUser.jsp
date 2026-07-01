<%-- Admin: form to create a new user account; on save AddUserServlet auto-generates and emails a password. --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add User - E-Appointment FSKM</title>
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
              <h1 class="ea-dashboard-title mb-1" style="font-size:2rem;font-weight:700;color:#105e60;">Add New User</h1>
              <div class="ea-dashboard-subtitle" style="font-size:1rem;color:#6b7280;">Create a new system account</div>
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
                <i class="bi bi-person-plus" style="font-size:1.3rem;color:#0f766e;"></i>
                <span style="font-size:1.05rem;font-weight:600;color:#111827;">User Information</span>
              </div>
              <form method="POST" action="<%= request.getContextPath() %>/AddUserServlet">
                <div class="row g-3">
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Title</label>
                    <select name="title" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                      <%
                        try (java.sql.Connection c = util.DBConnection.getConnection();
                             java.sql.PreparedStatement ps = c.prepareStatement("SELECT name FROM title ORDER BY id")) {
                          try (java.sql.ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                      %>
                      <option><%= rs.getString("name") %></option>
                      <%      }
                          }
                        } catch (Exception e) { %>
                      <option>Mr</option><option>Mrs</option><option>Ms</option><option>Miss</option>
                      <option>Dr.</option><option>Ts.</option><option>Ts. Dr.</option>
                      <option>Ir.</option><option>Ir. Dr.</option>
                      <option>Prof.</option><option>Prof. Dr.</option><option>Prof. Ts.</option>
                      <option>Prof. Ts. Dr.</option><option>Prof. Ir.</option><option>Prof. Ir. Dr.</option>
                      <option>Assoc. Prof.</option><option>Assoc. Prof. Dr.</option>
                      <option>Assoc. Prof. Ts.</option><option>Assoc. Prof. Ts. Dr.</option>
                      <option>Assoc. Prof. Ir.</option><option>Assoc. Prof. Ir. Dr.</option>
                      <% } %>
                    </select>
                  </div>
                  <div class="col-md-8">
                    <label class="form-label fw-medium">Full Name <span class="text-danger">*</span></label>
                    <input type="text" name="fullName" class="form-control" placeholder="e.g. Ahmad bin Abdullah / Nur Farah binti Ahmad" required style="border-radius:10px;border-color:#e5e7eb;">
                  </div>
                  <div class="col-md-12">
                    <label class="form-label fw-medium">Email <span class="text-danger">*</span></label>
                    <input type="email" name="email" class="form-control" placeholder="e.g. ahmad@umt.edu.my" required style="border-radius:10px;border-color:#e5e7eb;">
                  </div>
                  <div class="col-md-12">
                    <div class="alert alert-info d-flex align-items-center gap-2 py-2 mb-0" style="border-radius:10px;font-size:0.93rem;">
                      <i class="bi bi-envelope-check"></i>
                      A temporary password will be <strong>auto-generated</strong> and emailed to the user upon account creation.
                    </div>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Role <span class="text-danger">*</span></label>
                    <select name="role" id="roleSelect" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                      <option>Admin</option>
                      <option>Academician</option>
                      <option>Dean</option>
                    </select>
                  </div>
                  <div class="col-md-6 d-flex align-items-end">
                    <div class="form-check mb-2">
                      <input class="form-check-input" type="checkbox" id="statusActive" name="active" checked>
                      <label class="form-check-label fw-medium" for="statusActive">Account Active</label>
                    </div>
                  </div>
                </div>
                <div id="academicianNote" class="alert alert-info mt-3 d-none" style="border-radius:10px;">
                  <i class="bi bi-info-circle me-2"></i>After saving, you'll be redirected to fill in the <strong>academic staff profile</strong> for this user.
                </div>
                <div class="d-flex gap-2 mt-4">
                  <button type="submit" class="ea-btn-primary-action"><i class="bi bi-check-lg me-2"></i>Save User</button>
                  <a href="<%= request.getContextPath() %>/UserListServlet" class="btn-ea-back">Cancel</a>
                </div>
              </form>
            </div>
          </div>
        </div>
      </main>
    </div>

    <script>
      var roleSelect = document.getElementById('roleSelect');
      var note = document.getElementById('academicianNote');
      roleSelect.addEventListener('change', function(){
        if(roleSelect.value === 'Academician' || roleSelect.value === 'Dean') note.classList.remove('d-none');
        else note.classList.add('d-none');
      });
    </script>
  </body>
</html>
