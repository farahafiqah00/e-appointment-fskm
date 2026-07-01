<%-- Dean: read-only viva appointment list showing panel role summaries (no workflow actions). --%>
<%@ page import="java.util.List, model.VivaAppointment" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String sessionName = (String) session.getAttribute("full_name");
    if (sessionName == null || sessionName.trim().isEmpty()) sessionName = "Dean";
    String q       = request.getParameter("q")      != null ? request.getParameter("q").trim()      : "";
    String statusF = request.getParameter("status") != null ? request.getParameter("status").trim() : "";
    String levelF  = request.getParameter("level")  != null ? request.getParameter("level").trim()  : "";
    boolean showArchived = Boolean.TRUE.equals(request.getAttribute("showArchived")) || "1".equals(request.getParameter("showArchived"));
    @SuppressWarnings("unchecked")
    List<VivaAppointment> appts = (List<VivaAppointment>) request.getAttribute("appointments");
    if (appts == null) appts = new java.util.ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Viva Appointments - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout">
    <% request.setAttribute("activeSection", "viva"); request.setAttribute("activeSubSection", "deanVivaAppointments"); %>
    <jsp:include page="/dean/sidebar.jsp" />

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Viva Appointments</h1>
            <div style="font-size:1rem;color:#6b7280;">Review all viva appointments and assigned roles (Read-Only)</div>
          </div>
        </div>

        <!-- Search & Filter Bar -->
        <div class="w-100 mb-4 p-3" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <form class="row g-2 align-items-center" method="GET" action="<%= request.getContextPath() %>/admin/appointments">
            <div class="col-lg-4 col-md-12">
              <div class="input-group" style="border:1.5px solid #e5e7eb;border-radius:10px;overflow:hidden;">
                <span class="input-group-text bg-transparent border-0"><i class="bi bi-search text-muted"></i></span>
                <input class="form-control border-0 ps-0" name="q" value="<%= q %>"
                       placeholder="Search by name, matric number, or programme..."
                       style="font-size:0.97rem;box-shadow:none;">
              </div>
            </div>
            <div class="col-lg-2 col-md-4">
              <select name="level" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                <option value="">All Levels</option>
                <option value="Master" <%= "Master".equals(levelF) ? "selected" : "" %>>Master</option>
                <option value="PhD"    <%= "PhD".equals(levelF)    ? "selected" : "" %>>PhD</option>
              </select>
            </div>
            <div class="col-lg-3 col-md-6">
              <select name="status" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                <option value="">All Appointment Status</option>
                <option value="scheduled"         <%= "scheduled".equals(statusF)         ? "selected" : "" %>>Scheduled</option>
                <option value="letter_generated"  <%= "letter_generated".equals(statusF)  ? "selected" : "" %>>Letter Generated</option>
                <option value="deferred"          <%= "deferred".equals(statusF)          ? "selected" : "" %>>Deferred</option>
              </select>
            </div>
            <% if (showArchived) { %><input type="hidden" name="showArchived" value="1"><% } %>
            <div class="col-lg-3 col-md-4 d-flex gap-2">
              <button type="submit" class="ea-btn-icon w-100" title="Search"><i class="bi bi-search"></i></button>
              <% if (!q.isEmpty() || !statusF.isEmpty() || !levelF.isEmpty()) { %>
              <a href="<%= request.getContextPath() %>/admin/appointments<%= showArchived ? "?showArchived=1" : "" %>"
                 class="ea-btn-icon w-100 text-decoration-none text-center"
                 style="display:inline-flex;align-items:center;justify-content:center;" title="Clear">
                <i class="bi bi-x-lg"></i>
              </a>
              <% } %>
            </div>
          </form>
          <%
            String _deanApptBase = request.getContextPath() + "/admin/appointments?q=" +
                java.net.URLEncoder.encode(q, "UTF-8") +
                (statusF.isEmpty() ? "" : "&status=" + statusF) +
                (levelF.isEmpty()  ? "" : "&level="  + levelF);
          %>
          <div class="d-flex justify-content-end mt-2">
            <% if (!showArchived) { %>
            <a href="<%= _deanApptBase %>&showArchived=1"
               style="font-size:0.8rem;color:#9ca3af;text-decoration:none;display:inline-flex;align-items:center;gap:4px;">
              <i class="bi bi-archive"></i> Show archived (completed viva)
            </a>
            <% } else { %>
            <a href="<%= _deanApptBase %>"
               style="font-size:0.8rem;color:#059669;text-decoration:none;display:inline-flex;align-items:center;gap:4px;font-weight:600;">
              <i class="bi bi-archive-fill"></i> Showing archived &mdash; click to hide
            </a>
            <% } %>
          </div>
        </div>

        <!-- Appointments Table -->
        <div class="w-100 mb-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
          <div class="d-flex align-items-center px-4 py-3" style="border-bottom:1px solid #f3f4f6;">
            <i class="bi bi-calendar3 me-2" style="color:#0f766e;font-size:1.1rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Viva Appointments (<%= appts.size() %>)</span>
          </div>
          <div class="table-responsive">
            <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.97rem;">
              <thead>
                <tr>
                  <th>Candidate Name</th>
                  <th>Matric Number</th>
                  <th>Programme</th>
                  <th>Viva Status</th>
                  <th>Appointment Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <% if (appts.isEmpty()) { %>
                <tr>
                  <td colspan="6" class="text-center py-5 text-muted">
                    <i class="bi bi-calendar3 d-block mb-2" style="font-size:2rem;color:#d1d5db;"></i>
                    No appointments found.
                  </td>
                </tr>
                <% } else { for (VivaAppointment a : appts) {
                     String apptStatus = a.getStatus()               != null ? a.getStatus()               : "scheduled";
                     String vivaStatus = a.getCandidateVivaStatus()  != null ? a.getCandidateVivaStatus()  : "active";
                %>
                <tr>
                  <td><div class="fw-semibold" style="color:#111827;"><%= a.getCandidateName()      != null ? a.getCandidateName()      : "â€”" %></div></td>
                  <td><span style="color:#6b7280;"><%= a.getCandidateStudentId() != null ? a.getCandidateStudentId() : "â€”" %></span></td>
                  <td><span style="color:#6b7280;"><%= a.getCandidateProgram()   != null ? a.getCandidateProgram()   : "â€”" %></span></td>
                  <td>
                    <% if ("completed".equalsIgnoreCase(vivaStatus)) { %>
                    <span style="background:#dcfce7;color:#16a34a;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Completed</span>
                    <% } else if ("appointed".equalsIgnoreCase(vivaStatus)) { %>
                    <span style="background:#dbeafe;color:#1d4ed8;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Appointed</span>
                    <% } else { %>
                    <span style="background:#fef3c7;color:#d97706;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Pending</span>
                    <% } %>
                  </td>
                  <td>
                    <% if ("scheduled".equals(apptStatus)) { %>
                    <span style="background:#dbeafe;color:#1d4ed8;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Scheduled</span>
                    <% } else if ("letter_generated".equals(apptStatus)) { %>
                    <span style="background:#dcfce7;color:#16a34a;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Letter Generated</span>
                    <% } else if ("deferred".equals(apptStatus)) { %>
                    <span style="background:#f3f4f6;color:#6b7280;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Deferred</span>
                    <% } else if ("pending".equals(apptStatus)) { %>
                    <span style="background:#fff7ed;color:#c2410c;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Pending Schedule</span>
                    <% } else { %>
                    <span style="background:#f3f4f6;color:#6b7280;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;"><%= apptStatus %></span>
                    <% } %>
                  </td>
                  <td>
                    <a href="<%= request.getContextPath() %>/AppointmentDecisionServlet?id=<%= a.getId() %>"
                       class="ea-btn-icon" title="View Details"
                       style="font-size:1rem;padding:0.4em 0.7em;text-decoration:none;">
                      <i class="bi bi-eye"></i>
                    </a>
                  </td>
                </tr>
                <% } } %>
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
