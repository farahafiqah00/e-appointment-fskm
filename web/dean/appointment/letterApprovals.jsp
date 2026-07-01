<%--
  Dean/TDA/TDB: inbox of letter approvals assigned to the signed-in user.
  Shows pending approvals with a link to the letter review/sign page.
--%>
<%@ page import="java.util.List, java.util.Map, java.util.ArrayList, dao.AppointmentDAO" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  if (session == null || session.getAttribute("user_id") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String _role = (String) session.getAttribute("role_name");
  if (!"Dean".equals(_role) && !"Admin".equals(_role) && !"System Administrator".equals(_role)) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  String fullName = (String) session.getAttribute("full_name");
  if (fullName == null) fullName = "Dean";
  int _userId = ((Number) session.getAttribute("user_id")).intValue();
  List<Map<String,Object>> approvals = new ArrayList<>();
  try {
    approvals = new AppointmentDAO().getAllLetterApprovalsForSigner(_userId);
  } catch (Exception _e) { /* leave empty */ }
  long pendingCount = approvals.stream().filter(a -> "pending".equals(a.get("status"))).count();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Letter Approvals - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout ea-layout">
    <% request.setAttribute("activeSection", "letterApprovals"); %>
    <jsp:include page="/dean/sidebar.jsp" />

    <main class="content ea-content">
      <div class="ea-main-content-centered">

        <div class="mb-4">
          <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Letter Approvals</h1>
          <div style="font-size:1rem;color:#6b7280;">Appointment letters assigned to you for signing</div>
        </div>

        <% if (pendingCount > 0) { %>
        <div class="d-flex align-items-center gap-3 mb-4 px-4 py-3"
             style="background:#fffbeb;border-left:5px solid #f59e0b;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.04);">
          <i class="bi bi-hourglass-split" style="color:#d97706;font-size:1.2rem;flex-shrink:0;"></i>
          <span style="font-weight:700;color:#92400e;font-size:0.95rem;">
            <strong><%= pendingCount %></strong> appointment letter<%= pendingCount == 1 ? "" : "s" %> awaiting your signature.
          </span>
        </div>
        <% } %>

        <% if (approvals.isEmpty()) { %>
        <div class="p-5 text-center" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;">
          <i class="bi bi-pen" style="font-size:2.5rem;color:#d1d5db;"></i>
          <div class="mt-3 fw-semibold" style="color:#6b7280;">No letter approvals assigned to you.</div>
          <div style="font-size:0.88rem;color:#9ca3af;margin-top:4px;">The admin will send approval requests when letters are ready for signing.</div>
        </div>
        <% } else { %>
        <div style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.93rem;">
            <thead>
              <tr>
                <th>Candidate</th>
                <th>Matric</th>
                <th>Programme</th>
                <th>Viva Date</th>
                <th style="text-align:center;">Status</th>
                <th style="text-align:center;">Requested</th>
                <th style="text-align:center;">Action</th>
              </tr>
            </thead>
            <tbody>
              <% for (Map<String,Object> a : approvals) {
                   String status = a.get("status") != null ? a.get("status").toString() : "";
                   boolean isPending = "pending".equals(status);
                   boolean isSigned  = "signed".equals(status);
                   java.sql.Timestamp requestedAt = (java.sql.Timestamp) a.get("requested_at");
                   java.sql.Timestamp signedAt    = (java.sql.Timestamp) a.get("signed_at");
                   java.sql.Timestamp scheduledAt = (java.sql.Timestamp) a.get("scheduled_at");
                   String requestedStr = requestedAt != null ? new java.text.SimpleDateFormat("dd MMM yyyy").format(requestedAt) : "—";
                   String signedStr    = signedAt    != null ? new java.text.SimpleDateFormat("dd MMM yyyy").format(signedAt)    : "—";
                   String vivaStr      = scheduledAt != null ? new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(scheduledAt) : "—";
              %>
              <tr style="<%= isPending ? "background:#fffbeb;" : "" %>">
                <td style="font-weight:600;color:#105e60;"><%= a.get("candidate_name") != null ? a.get("candidate_name") : "—" %></td>
                <td style="color:#6b7280;font-size:0.85rem;"><%= a.get("student_id") != null ? a.get("student_id") : "—" %></td>
                <td style="color:#374151;max-width:160px;white-space:normal;"><%= a.get("candidate_program") != null ? a.get("candidate_program") : "—" %></td>
                <td style="color:#374151;font-size:0.88rem;white-space:nowrap;"><%= vivaStr %></td>
                <td style="text-align:center;">
                  <% if (isPending) { %>
                  <span style="background:#fef3c7;color:#92400e;border-radius:8px;padding:3px 10px;font-size:0.8rem;font-weight:600;">
                    <i class="bi bi-hourglass-split me-1"></i>Pending
                  </span>
                  <% } else if (isSigned) { %>
                  <span style="background:#dcfce7;color:#15803d;border-radius:8px;padding:3px 10px;font-size:0.8rem;font-weight:600;">
                    <i class="bi bi-patch-check-fill me-1"></i>Signed
                  </span>
                  <% } else { %>
                  <span style="background:#f3f4f6;color:#6b7280;border-radius:8px;padding:3px 10px;font-size:0.8rem;font-weight:600;"><%= status %></span>
                  <% } %>
                </td>
                <td style="text-align:center;font-size:0.83rem;color:#6b7280;">
                  <%= requestedStr %>
                  <% if (isSigned) { %><br><span style="color:#15803d;font-size:0.78rem;">Signed <%= signedStr %></span><% } %>
                </td>
                <td style="text-align:center;">
                  <a href="<%= request.getContextPath() %>/appointment/letter/review?id=<%= a.get("appointment_id") %>"
                     class="btn btn-sm"
                     style="border-radius:8px;font-size:0.82rem;font-weight:600;padding:0.35rem 1rem;
                            background:<%= isPending ? "#0f766e" : "#fff" %>;
                            color:<%= isPending ? "#fff" : "#374151" %>;
                            border:1.5px solid <%= isPending ? "#0f766e" : "#d1d5db" %>;">
                    <i class="bi bi-<%= isPending ? "pen-fill" : "eye" %> me-1"></i><%= isPending ? "Review & Sign" : "View" %>
                  </a>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
        <% } %>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
