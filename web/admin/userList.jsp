<%-- Admin: user management list with search, role, and status filters. --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null || fullName.trim().isEmpty()) {
        fullName = "Admin";
    }
    String _userListError = request.getParameter("error");
    String _userListMsg   = request.getParameter("msg");
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>User Management - User List</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  </head>
  <body class="admin">

    <jsp:include page="/includes/topbar.jsp" />


    <div class="layout ea-layout">
      <% request.setAttribute("activeSection", "users"); %>
      <jsp:include page="/admin/sidebar.jsp" />
      <!-- Main Content -->
      <main class="content ea-content" style="max-width:none;">
        <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">
          <div class="ea-section-header w-100" style="max-width:none; display:flex; align-items:center; justify-content:space-between; gap:12px;">
            <div>
              <h1 class="ea-dashboard-title mb-1" style="font-size:2rem;font-weight:700;color:#105e60;">User Management</h1>
              <div class="ea-dashboard-subtitle" style="font-size:1.1rem;color:#6b7280;">Manage registered accounts</div>
            </div>
          </div>
          <% if ("missing_fields".equals(_userListError)) { %>
          <div class="alert d-flex align-items-center gap-2 mb-3"
               style="background:#fef2f2;border:1px solid #fca5a5;border-radius:12px;color:#991b1b;padding:14px 18px;">
            <i class="bi bi-exclamation-circle-fill" style="font-size:1.1rem;"></i>
            Please fill in all required fields: Full Name, Email, and Role.
          </div>
          <% } else if ("user_created".equals(_userListMsg)) { %>
          <div class="alert d-flex align-items-center gap-2 mb-3"
               style="background:#ecfdf5;border:1px solid #6ee7b7;border-radius:12px;color:#065f46;padding:14px 18px;">
            <i class="bi bi-check-circle-fill" style="color:#10b981;font-size:1.1rem;"></i>
            User account created successfully. A welcome email has been sent.
          </div>
          <% } %>
          <div class="w-100 mb-3" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 12px rgba(0,0,0,0.06);">
            <div class="p-3">
              <form class="row g-2 align-items-center" method="GET" action="<%= request.getContextPath() %>/UserListServlet">
                <div class="col-lg-5 col-md-6 col-12">
                  <input class="form-control" name="q" placeholder="Search by name or email" style="font-size:1rem;border-radius:10px;border-color:#e5e7eb;">
                </div>
                <div class="col-lg-2 col-md-3 col-6">
                  <select name="role" class="form-select" style="font-size:1rem;border-radius:10px;border-color:#e5e7eb;">
                    <option value="">All roles</option>
                    <option>Admin</option>
                    <option>Academician</option>
                    <option>Dean</option>
                  </select>
                </div>
                <div class="col-lg-2 col-md-3 col-6">
                  <select name="status" class="form-select" style="font-size:1rem;border-radius:10px;border-color:#e5e7eb;">
                    <option value="">All status</option>
                    <option>Active</option>
                    <option>Deactivated</option>
                  </select>
                </div>
                <div class="col-lg-1 col-md-6 col-6 d-flex align-items-center">
                  <button class="ea-btn-icon" type="submit"><i class="bi bi-search"></i></button>
                </div>
                <div class="col-lg-2 col-md-6 col-6 d-flex justify-content-end align-items-center">
                  <a href="<%= request.getContextPath() %>/admin/addUser.jsp" class="ea-btn-primary-action">
                    <i class="bi bi-person-plus me-2" aria-hidden="true"></i>
                    <span>Add New User</span>
                  </a>
                </div>
              </form>
            </div>
          </div>
          <div class="w-100 mb-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 12px rgba(0,0,0,0.06);overflow:hidden;">
            <div class="d-flex justify-content-between align-items-center ea-card-header" style="padding:1.2em 1.5em;">
              <span class="fw-semibold" style="font-size:1.1rem;">User List</span>
              <span class="text-muted small" style="font-size:1rem;"><% if (request.getAttribute("users") != null) { java.util.List users = (java.util.List) request.getAttribute("users"); out.print(users.size()); } else { out.print(0); } %> users</span>
            </div>
            <div class="table-responsive">
              <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:1rem;">
                <thead>
                  <tr>
                    <th style="font-size:1.05rem;">User Name</th>
                    <th style="font-size:1.05rem;">Email</th>
                    <th style="font-size:1.05rem;">Role</th>
                    <th style="font-size:1.05rem;">Account Status</th>
                    <th style="font-size:1.05rem;">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <%
                    java.util.List<model.User> users = (java.util.List<model.User>) request.getAttribute("users");
                    @SuppressWarnings("unchecked")
                    java.util.Map<Integer,Integer> staffByUser =
                        (java.util.Map<Integer,Integer>) request.getAttribute("staffByUser");
                    if (staffByUser == null) staffByUser = new java.util.HashMap<>();
                    if (users != null && !users.isEmpty()) {
                      for (model.User u : users) {
                        String role = u.getRoleName() != null ? u.getRoleName() : "-";
                        Integer staffId = staffByUser.get(u.getId());
                  %>
                  <tr>
                    <td><%= u.getFullName() != null ? u.getFullName() : u.getUsername() %></td>
                    <td><%= u.getEmail() %></td>
                    <td>
                      <% if ("Administrator".equalsIgnoreCase(role) || "Admin".equalsIgnoreCase(role)) { %>
                        <span class="ea-badge-role ea-badge-admin">Admin</span>
                      <% } else if ("Dean".equalsIgnoreCase(role)) { %>
                        <span class="ea-badge-role ea-badge-dean">Dean</span>
                      <% } else if ("Academician".equalsIgnoreCase(role)) { %>
                        <span class="ea-badge-role ea-badge-academician">Academician</span>
                      <% } else { %>
                        <span class="ea-badge-role bg-secondary">-</span>
                      <% } %>
                    </td>
                    <td>
                      <% if ("active".equalsIgnoreCase(u.getStatus())) { %>
                        <span class="ea-badge-status ea-badge-active">Active</span>
                      <% } else { %>
                        <span class="ea-badge-status ea-badge-inactive">Deactivated</span>
                      <% } %>
                    </td>
                    <td>
                      <a href="<%= request.getContextPath() %>/admin/editUser.jsp?id=<%= u.getId() %>" class="ea-btn-icon" title="Edit" style="font-size:1.1rem;padding:0.4em 0.7em;text-decoration:none;"><i class="bi bi-pencil"></i></a>
                      <% if ("active".equalsIgnoreCase(u.getStatus())) { %>
                        <button class="ea-btn-icon toggle-status-btn" data-bs-toggle="modal" data-bs-target="#confirmModal" data-user="<%= u.getFullName() %>" data-id="<%= u.getId() %>" data-newstatus="deactivated" title="Deactivate" style="font-size:1.1rem;padding:0.4em 0.7em;"><i class="bi bi-power"></i></button>
                      <% } else { %>
                        <button class="ea-btn-icon toggle-status-btn" data-bs-toggle="modal" data-bs-target="#confirmModal" data-user="<%= u.getFullName() %>" data-id="<%= u.getId() %>" data-newstatus="active" title="Activate" style="font-size:1.1rem;padding:0.4em 0.7em;"><i class="bi bi-power"></i></button>
                      <% } %>
                      <a href="<%= request.getContextPath() %>/admin/viewUser.jsp?id=<%= u.getId() %>" class="ea-btn-icon" title="View" style="font-size:1.1rem;padding:0.4em 0.7em;text-decoration:none;"><i class="bi bi-eye"></i></a>
                      <% if ("Academician".equalsIgnoreCase(role) || "Dean".equalsIgnoreCase(role)) {
                           if (staffId != null) { %>
                        <a href="<%= request.getContextPath() %>/admin/academician/addAcademicStaff.jsp?id=<%= staffId %>&from=userList" class="ea-btn-icon" title="Edit Staff Record" style="font-size:1.1rem;padding:0.4em 0.7em;text-decoration:none;color:#0f766e;"><i class="bi bi-mortarboard-fill"></i></a>
                      <%   } else { %>
                        <a href="<%= request.getContextPath() %>/admin/academician/addAcademicStaff.jsp?userId=<%= u.getId() %>&from=userList" class="ea-btn-icon" title="Add Staff Record" style="font-size:1.1rem;padding:0.4em 0.7em;text-decoration:none;color:#9ca3af;"><i class="bi bi-mortarboard"></i></a>
                      <%   } %>
                      <% } %>
                    </td>
                  </tr>
                  <%    }
                    } else { %>
                  <tr><td colspan="5" class="text-center text-muted">No users found.</td></tr>
                  <% } %>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Modal for confirm activate/deactivate -->
        <div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title" id="confirmModalLabel">Confirm Action</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body">
                <span id="confirmModalMessage">Are you sure?</span>
              </div>
              <div class="modal-footer">
                <form id="toggleStatusForm" method="post" action="<%= request.getContextPath() %>/ToggleUserStatusServlet">
                  <input type="hidden" name="id" id="modalUserId">
                  <input type="hidden" name="newStatus" id="modalNewStatus">
                  <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                  <button type="submit" class="btn btn-primary-action">Confirm</button>
                </form>
              </div>
            </div>
          </div>
        </div>

      </main>
    </div>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
      // Modal logic for activate/deactivate
      document.addEventListener('DOMContentLoaded', function() {
        var confirmModal = document.getElementById('confirmModal');
        if (confirmModal) {
          confirmModal.addEventListener('show.bs.modal', function (event) {
            var button = event.relatedTarget;
            var user = button.getAttribute('data-user') || 'this user';
            var id = button.getAttribute('data-id');
            var newStatus = button.getAttribute('data-newstatus');
            document.getElementById('modalUserId').value = id;
            document.getElementById('modalNewStatus').value = newStatus;
            var msg = 'Are you sure you want to ' + (newStatus === 'active' ? 'activate' : 'deactivate') + ' user <b>' + user + '</b>?';
            document.getElementById('confirmModalMessage').innerHTML = msg;
          });
        }
      });
    </script>
  </body>
</html>
