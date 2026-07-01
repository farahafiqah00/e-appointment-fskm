<%-- Admin: read-only detail view of a single user account. --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String sessionName = (String) session.getAttribute("full_name");
    if (sessionName == null || sessionName.trim().isEmpty()) sessionName = "Admin";

    String id      = request.getParameter("id") != null ? request.getParameter("id").trim() : "";
    String fullNameVal    = "";
    String emailVal       = "";
    String roleVal        = "-";
    String statusVal      = "active";
    String createdDateVal = "";
    String titleVal       = "";

    if (!id.isEmpty()) {
        try (java.sql.Connection conn = util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                 "SELECT u.full_name, u.email, u.status, u.created_at, " +
                 "r.name AS role_name, t.name AS title_name " +
                 "FROM `user` u " +
                 "LEFT JOIN role r ON u.role_id = r.id " +
                 "LEFT JOIN title t ON u.title_id = t.id " +
                 "WHERE u.id = ? LIMIT 1")) {
            ps.setInt(1, Integer.parseInt(id));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    fullNameVal    = rs.getString("full_name")  != null ? rs.getString("full_name")  : "";
                    emailVal       = rs.getString("email")       != null ? rs.getString("email")       : "";
                    statusVal      = rs.getString("status")      != null ? rs.getString("status")      : "active";
                    titleVal       = rs.getString("title_name")  != null ? rs.getString("title_name")  : "";
                    roleVal        = rs.getString("role_name")   != null ? rs.getString("role_name")   : "-";
                    java.sql.Timestamp ct = rs.getTimestamp("created_at");
                    if (ct != null) {
                        createdDateVal = new java.text.SimpleDateFormat("yyyy-MM-dd").format(ct);
                    }
                }
            }
        } catch (Exception e) {
            createdDateVal = "";
        }
    }

    // Format display ID e.g. U001
    String displayId = "";
    try {
        displayId = String.format("U%03d", Integer.parseInt(id));
    } catch (Exception e) {
        displayId = id;
    }

    // Display name with title prefix
    String displayName = (titleVal != null && !titleVal.isEmpty() ? titleVal + " " : "") + fullNameVal;

    // Check if this user already has a linked staff record (for Academician/Dean only)
    boolean isAcademicRole = "Academician".equalsIgnoreCase(roleVal) || "Dean".equalsIgnoreCase(roleVal);
    Integer linkedStaffId  = null;
    if (isAcademicRole && !id.isEmpty()) {
        try (java.sql.Connection conn = util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                 "SELECT id FROM academic_staff WHERE user_id = ? LIMIT 1")) {
            ps.setInt(1, Integer.parseInt(id));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) linkedStaffId = rs.getInt("id");
            }
        } catch (Exception ignore) { }
    }
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>User Details - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
      .view-field-label {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.92rem;
        font-weight: 600;
        color: #374151;
        margin-bottom: 4px;
      }
      .view-field-label i {
        font-size: 1rem;
        color: #0f766e;
      }
      .view-field-value {
        font-size: 1rem;
        color: #111827;
        padding-left: 24px;
        margin-bottom: 0;
      }
      .view-field {
        padding: 14px 0;
        border-bottom: 1px solid #f3f4f6;
      }
      .view-field:last-child {
        border-bottom: none;
      }
      .view-section-title {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 1.05rem;
        font-weight: 700;
        color: #0f766e;
        margin-bottom: 18px;
        padding-bottom: 12px;
        border-bottom: 2px solid #e5f7f5;
      }
    </style>
  </head>
  <body class="admin">

    <jsp:include page="/includes/topbar.jsp" />

    <div class="layout">
      <% request.setAttribute("activeSection", "users"); %>
      <jsp:include page="/admin/sidebar.jsp" />

      <!-- Main Content -->
      <main class="content">
        <div style="max-width:860px; margin:0 auto; padding:0 8px;">

          <!-- Page Header -->
          <div class="d-flex align-items-start justify-content-between mb-4 flex-wrap gap-3">
            <div>
              <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">User Details</h1>
              <div style="font-size:1rem;color:#6b7280;">Read-only view of user information</div>
            </div>
            <div class="d-flex gap-2 align-items-center flex-wrap">
              <% if (isAcademicRole) {
                   if (linkedStaffId != null) { %>
              <a href="<%= request.getContextPath() %>/admin/academician/addAcademicStaff.jsp?id=<%= linkedStaffId %>"
                 class="btn d-inline-flex align-items-center gap-2"
                 style="background:#0f766e;color:#fff;border-radius:10px;padding:10px 22px;font-weight:600;border:none;text-decoration:none;">
                <i class="bi bi-mortarboard-fill"></i> View Staff Record
              </a>
              <%   } else { %>
              <a href="<%= request.getContextPath() %>/admin/academician/addAcademicStaff.jsp?userId=<%= id %>"
                 class="btn d-inline-flex align-items-center gap-2"
                 style="background:#0f766e;color:#fff;border-radius:10px;padding:10px 22px;font-weight:600;border:none;text-decoration:none;">
                <i class="bi bi-mortarboard"></i> Add Staff Record
              </a>
              <%   } %>
              <% } %>
              <a href="<%= request.getContextPath() %>/admin/editUser.jsp?id=<%= id %>"
                 class="btn d-inline-flex align-items-center gap-2"
                 style="background:#105e60;color:#fff;border-radius:10px;padding:10px 22px;font-weight:600;border:none;text-decoration:none;">
                <i class="bi bi-pencil-square"></i> Edit User
              </a>
              <a href="<%= request.getContextPath() %>/UserListServlet" class="btn-ea-back">
                <i class="bi bi-arrow-left"></i> Back to List
              </a>
            </div>
          </div>

          <!-- Detail Card -->
          <div style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 12px rgba(0,0,0,0.06);padding:28px 32px;">

            <div class="view-section-title">
              <i class="bi bi-eye-fill" style="font-size:1.2rem;"></i>
              User Information
            </div>

            <div class="row g-0">

              <!-- Row 1: User ID + Created Date -->
              <div class="col-md-6 view-field pe-md-4">
                <div class="view-field-label"><i class="bi bi-person-badge"></i> User ID</div>
                <div class="view-field-value"><%= displayId %></div>
              </div>
              <div class="col-md-6 view-field ps-md-4" style="border-left:1px solid #f3f4f6;">
                <div class="view-field-label"><i class="bi bi-calendar3"></i> Created Date</div>
                <div class="view-field-value"><%= createdDateVal.isEmpty() ? "—" : createdDateVal %></div>
              </div>

              <!-- Row 2: Full Name + Email -->
              <div class="col-md-6 view-field pe-md-4">
                <div class="view-field-label"><i class="bi bi-person"></i> Full Name</div>
                <div class="view-field-value"><%= displayName.trim().isEmpty() ? "—" : displayName %></div>
              </div>
              <div class="col-md-6 view-field ps-md-4" style="border-left:1px solid #f3f4f6;">
                <div class="view-field-label"><i class="bi bi-envelope"></i> Email</div>
                <div class="view-field-value"><%= emailVal.isEmpty() ? "—" : emailVal %></div>
              </div>

              <!-- Row 3: Role + Status -->
              <div class="col-md-6 view-field pe-md-4">
                <div class="view-field-label"><i class="bi bi-shield-check"></i> Role</div>
                <div class="view-field-value mt-1">
                  <%
                    if ("Administrator".equalsIgnoreCase(roleVal) || "Admin".equalsIgnoreCase(roleVal)) {
                  %>
                    <span class="ea-badge-role ea-badge-admin">Administrator</span>
                  <% } else if ("Dean".equalsIgnoreCase(roleVal)) { %>
                    <span class="ea-badge-role" style="background:#7c3aed;color:#fff;">Dean</span>
                  <% } else if ("Academician".equalsIgnoreCase(roleVal)) { %>
                    <span class="ea-badge-role ea-badge-academician">Academician</span>
                  <% } else { %>
                    <span class="ea-badge-role bg-secondary"><%= roleVal %></span>
                  <% } %>
                </div>
              </div>
              <div class="col-md-6 view-field ps-md-4" style="border-left:1px solid #f3f4f6;">
                <div class="view-field-label"><i class="bi bi-check-circle"></i> Account Status</div>
                <div class="view-field-value mt-1">
                  <% if ("active".equalsIgnoreCase(statusVal)) { %>
                    <span class="ea-badge-status ea-badge-active">Active</span>
                  <% } else { %>
                    <span class="ea-badge-status ea-badge-inactive">Inactive</span>
                  <% } %>
                </div>
              </div>

            </div><!-- /row -->
          </div><!-- /card -->

        </div>
      </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  </body>
</html>
