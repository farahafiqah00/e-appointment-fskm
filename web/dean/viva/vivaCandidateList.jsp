<%-- Dean: read-only viva candidate list (same data as admin but without add/delete actions). --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Candidate, java.util.List, java.util.Map" %>
<%
    String sessionName = (String) session.getAttribute("full_name");
    if (sessionName == null || sessionName.trim().isEmpty()) sessionName = "Dean";
    String q        = request.getParameter("q")         != null ? request.getParameter("q").trim()         : "";
    String programF = request.getParameter("programId") != null ? request.getParameter("programId").trim() : "";
    String statusF  = request.getParameter("status")    != null ? request.getParameter("status").trim()    : "";
    String levelF   = request.getParameter("level")     != null ? request.getParameter("level").trim()     : "";
    boolean showArchived = Boolean.TRUE.equals(request.getAttribute("showArchived")) || "1".equals(request.getParameter("showArchived"));
    @SuppressWarnings("unchecked")
    List<Candidate> candidates = (List<Candidate>) request.getAttribute("candidates");
    if (candidates == null) candidates = new java.util.ArrayList<>();
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> programs = (List<Map<String,Object>>) request.getAttribute("programs");
    if (programs == null) programs = new java.util.ArrayList<>();
    int totalCount = candidates.size();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Viva Candidates - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout">
    <% request.setAttribute("activeSection", "viva"); request.setAttribute("activeSubSection", "deanVivaCandidates"); %>
    <jsp:include page="/dean/sidebar.jsp" />

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Viva Candidates</h1>
            <div style="font-size:1rem;color:#6b7280;">Review all viva candidates (Read-Only)</div>
          </div>
        </div>

        <!-- Search & Filter Bar -->
        <div class="w-100 mb-4 p-3" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <form class="row g-2 align-items-center" method="GET" action="<%= request.getContextPath() %>/CandidateListServlet">
            <div class="col-lg-4 col-md-12">
              <div class="input-group" style="border:1.5px solid #e5e7eb;border-radius:10px;overflow:hidden;">
                <span class="input-group-text bg-transparent border-0"><i class="bi bi-search text-muted"></i></span>
                <input class="form-control border-0 ps-0" name="q" value="<%= q %>"
                       placeholder="Search by candidate name, programme, or thesis..."
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
            <div class="col-lg-2 col-md-4">
              <select name="programId" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                <option value="">All Programmes</option>
                <% for (Map<String,Object> prog : programs) {
                     String pid = String.valueOf(prog.get("id")); %>
                <option value="<%= pid %>" <%= pid.equals(programF) ? "selected" : "" %>><%= prog.get("name") %></option>
                <% } %>
              </select>
            </div>
            <div class="col-lg-2 col-md-4">
              <select name="status" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                <option value="">All Status</option>
                <option value="prepared"  <%= "prepared".equals(statusF)  ? "selected" : "" %>>Pending</option>
                <option value="appointed" <%= "appointed".equals(statusF) ? "selected" : "" %>>Appointed</option>
                <option value="completed" <%= "completed".equals(statusF) ? "selected" : "" %>>Completed</option>
              </select>
            </div>
            <% if (showArchived) { %><input type="hidden" name="showArchived" value="1"><% } %>
            <div class="col-lg-2 col-md-12 d-flex gap-2">
              <button type="submit" class="ea-btn-icon w-100" title="Search"><i class="bi bi-search"></i></button>
              <% if (!q.isEmpty() || !programF.isEmpty() || !statusF.isEmpty() || !levelF.isEmpty()) { %>
              <a href="<%= request.getContextPath() %>/CandidateListServlet<%= showArchived ? "?showArchived=1" : "" %>"
                 class="ea-btn-icon w-100 text-decoration-none text-center" title="Clear"
                 style="display:inline-flex;align-items:center;justify-content:center;">
                <i class="bi bi-x-lg"></i>
              </a>
              <% } %>
            </div>
          </form>
          <%
            String _archBase2 = request.getContextPath() + "/CandidateListServlet?q=" +
                java.net.URLEncoder.encode(q, "UTF-8") +
                (programF.isEmpty() ? "" : "&programId=" + programF) +
                (statusF.isEmpty()  ? "" : "&status="    + statusF) +
                (levelF.isEmpty()   ? "" : "&level="     + levelF);
          %>
          <div class="d-flex justify-content-end mt-2">
            <% if (!showArchived) { %>
            <a href="<%= _archBase2 %>&showArchived=1"
               style="font-size:0.8rem;color:#9ca3af;text-decoration:none;display:inline-flex;align-items:center;gap:4px;">
              <i class="bi bi-archive"></i> Show archived (completed)
            </a>
            <% } else { %>
            <a href="<%= _archBase2 %>"
               style="font-size:0.8rem;color:#059669;text-decoration:none;display:inline-flex;align-items:center;gap:4px;font-weight:600;">
              <i class="bi bi-archive-fill"></i> Showing archived &mdash; click to hide
            </a>
            <% } %>
          </div>
        </div>

        <!-- Candidate Table -->
        <div class="w-100 mb-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
          <div class="d-flex align-items-center px-4 py-3" style="border-bottom:1px solid #f3f4f6;">
            <i class="bi bi-people me-2" style="color:#0f766e;font-size:1.1rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Candidates List (<%= totalCount %>)</span>
          </div>
          <div class="table-responsive">
            <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.97rem;">
              <thead>
                <tr>
                  <th>Candidate Name</th>
                  <th>Programme</th>
                  <th>Thesis Title</th>
                  <th>Viva Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <% if (candidates.isEmpty()) { %>
                <tr>
                  <td colspan="5" class="text-center py-5 text-muted">
                    <i class="bi bi-people d-block mb-2" style="font-size:2rem;color:#d1d5db;"></i>
                    No viva candidates found.
                  </td>
                </tr>
                <% } else { for (Candidate c : candidates) {
                     String st = c.getStatus() != null ? c.getStatus().toLowerCase() : "prepared";
                     String progDisplay = c.getDisplayProgram();
                     String thesis = c.getThesisTitle() != null ? c.getThesisTitle() : ""; %>
                <tr>
                  <td><div class="fw-semibold" style="color:#111827;"><%= c.getFullName() != null ? c.getFullName() : "â€”" %></div></td>
                  <td>
                    <% if (!progDisplay.isEmpty()) { %>
                    <span style="background:#e5f7f5;color:#0f766e;padding:3px 10px;border-radius:20px;font-size:0.85rem;font-weight:500;"><%= progDisplay %></span>
                    <% } else { %>
                    <span style="color:#9ca3af;font-size:0.9rem;">â€”</span>
                    <% } %>
                  </td>
                  <td style="max-width:320px;">
                    <div style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:300px;" title="<%= thesis.replace("\"","&quot;") %>">
                      <%= thesis.length() > 70 ? thesis.substring(0,70) + "â€¦" : (thesis.isEmpty() ? "â€”" : thesis) %>
                    </div>
                  </td>
                  <td>
                    <% if ("appointed".equals(st)) { %>
                    <span style="background:#dbeafe;color:#1d4ed8;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Scheduled</span>
                    <% } else if ("completed".equals(st)) { %>
                    <span style="background:#dcfce7;color:#16a34a;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Completed</span>
                    <% } else { %>
                    <span style="background:#fef3c7;color:#d97706;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Pending</span>
                    <% } %>
                  </td>
                  <td>
                    <a href="<%= request.getContextPath() %>/dean/viva/vivaCandidateView.jsp?id=<%= c.getId() %>"
                       class="ea-btn-icon" title="View Details" style="font-size:1rem;padding:0.4em 0.7em;text-decoration:none;">
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
