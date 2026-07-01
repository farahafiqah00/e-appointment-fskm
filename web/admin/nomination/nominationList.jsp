<%--
  Admin: list of all examiner nominations with text search, status filter, and an optional
  "show archived (verified)" toggle so verified nominations are hidden by default.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String fullName = (String) session.getAttribute("full_name"); if (fullName==null) fullName="Admin";
  String q = request.getParameter("q") != null ? request.getParameter("q").trim() : "";
  String statusF = request.getParameter("status") != null ? request.getParameter("status").trim() : "";
  boolean showArchived = Boolean.TRUE.equals(request.getAttribute("showArchived")) || "1".equals(request.getParameter("showArchived"));
  java.util.List<model.Nomination> nominations = (java.util.List<model.Nomination>) request.getAttribute("nominations");
  if (nominations == null) nominations = new java.util.ArrayList<>();
  int totalCount = nominations.size();
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Examiner Nominations - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  </head>
  <body class="admin">

    <jsp:include page="/includes/topbar.jsp" />

    <div class="layout ea-layout">
      <% request.setAttribute("activeSection", "examiner"); request.setAttribute("activeSubSection", "examinerNominations"); %>
      <jsp:include page="/admin/sidebar.jsp" />

      <main class="content ea-content" style="max-width:none;">
        <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

          <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
            <div>
              <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Examiner Nominations</h1>
              <div style="font-size:1rem;color:#6b7280;">Review and verify examiner nominations submitted by academicians</div>
            </div>
          </div>

          <div class="w-100 mb-4 p-3" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <form class="row g-2 align-items-center" method="GET" action="<%= request.getContextPath() %>/NominationListServlet">
              <div class="col-lg-6 col-md-12">
                <div class="input-group" style="border:1.5px solid #e5e7eb;border-radius:10px;overflow:hidden;">
                  <span class="input-group-text bg-transparent border-0"><i class="bi bi-search text-muted"></i></span>
                  <input class="form-control border-0 ps-0" name="q" value="<%= q %>" placeholder="Search by examiner name or university..." style="font-size:0.97rem;box-shadow:none;">
                </div>
              </div>
              <div class="col-lg-4 col-md-8">
                <select name="status" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                  <option value="">All Status</option>
                  <option value="submitted" <%= "submitted".equals(statusF) ? "selected" : "" %>>Pending Review</option>
                  <option value="pending_examiner" <%= "pending_examiner".equals(statusF) ? "selected" : "" %>>Awaiting Examiner</option>
                  <option value="verified" <%= "verified".equals(statusF) ? "selected" : "" %>>Verified</option>
                  <option value="needs_correction" <%= "needs_correction".equals(statusF) ? "selected" : "" %>>Needs Correction</option>
                </select>
              </div>
              <% if (showArchived) { %><input type="hidden" name="showArchived" value="1"><% } %>
              <div class="col-lg-2 col-md-4 d-flex gap-2">
                <button type="submit" class="ea-btn-icon w-100" title="Search"><i class="bi bi-search"></i></button>
                <% if (!q.isEmpty() || !statusF.isEmpty()) { %>
                <a href="<%= request.getContextPath() %>/NominationListServlet<%= showArchived ? "?showArchived=1" : "" %>" class="ea-btn-icon w-100 text-decoration-none text-center" style="display:inline-flex;align-items:center;justify-content:center;" title="Clear"><i class="bi bi-x-lg"></i></a>
                <% } %>
              </div>
            </form>
            <%
              String _nomBase = request.getContextPath() + "/NominationListServlet?q=" +
                  java.net.URLEncoder.encode(q, "UTF-8") +
                  (statusF.isEmpty() ? "" : "&status=" + statusF);
            %>
            <div class="d-flex justify-content-end mt-2">
              <% if (!showArchived) { %>
              <a href="<%= _nomBase %>&showArchived=1"
                 style="font-size:0.8rem;color:#9ca3af;text-decoration:none;display:inline-flex;align-items:center;gap:4px;">
                <i class="bi bi-archive"></i> Show archived (verified)
              </a>
              <% } else { %>
              <a href="<%= _nomBase %>"
                 style="font-size:0.8rem;color:#059669;text-decoration:none;display:inline-flex;align-items:center;gap:4px;font-weight:600;">
                <i class="bi bi-archive-fill"></i> Showing archived &mdash; click to hide
              </a>
              <% } %>
            </div>
          </div>

          <div class="w-100 mb-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
            <div class="d-flex align-items-center px-4 py-3" style="border-bottom:1px solid #f3f4f6;">
              <i class="bi bi-person-badge me-2" style="color:#0f766e;font-size:1.1rem;"></i>
              <span class="fw-semibold" style="font-size:1.05rem;">Examiner Nominations (<%= totalCount %>)</span>
            </div>
            <div class="table-responsive">
              <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.97rem;">
                <thead>
                  <tr>
                    <th>Examiner Name</th>
                    <th>University / Organisation</th>
                    <th>Nominated By</th>
                    <th>Status</th>
                    <th>Submission Date</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <% if (nominations.isEmpty()) { %>
                  <tr><td colspan="6" class="text-center py-5 text-muted"><i class="bi bi-person-badge d-block mb-2" style="font-size:2rem;color:#d1d5db;"></i>No nominations found.</td></tr>
                  <% } else { for (model.Nomination n : nominations) { String st = n.getStatus() != null ? n.getStatus() : "pending"; %>
                  <tr>
                    <td><div class="fw-semibold" style="color:#111827;"><%= n.getExaminerName() != null ? n.getExaminerName() : "—" %></div></td>
                    <td><span style="color:#6b7280;"><%= n.getExaminerAffiliation() != null ? n.getExaminerAffiliation() : "—" %></span></td>
                    <td><span style="color:#6b7280;"><%= n.getNominatorName() != null ? n.getNominatorName() : "—" %></span></td>
                    <td>
                      <% if ("verified".equals(st)) { %><span style="background:#dcfce7;color:#16a34a;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Verified</span>
                      <% } else if ("needs_correction".equals(st)) { %><span style="background:#fee2e2;color:#dc2626;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Needs Correction</span>
                      <% } else if ("under_review".equals(st)) { %><span style="background:#eff6ff;color:#1d4ed8;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Under Review</span>
                      <% } else if ("pending_examiner".equals(st)) { %><span style="background:#ede9fe;color:#7c3aed;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Awaiting Examiner</span>
                      <% } else { %><span style="background:#fef3c7;color:#d97706;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Pending Review</span><% } %>
                    </td>
                    <td style="color:#6b7280;"><%= n.getCreatedAt() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(n.getCreatedAt()) : "—" %></td>
                    <td>
                      <div class="d-flex gap-2">
                        <a href="<%= request.getContextPath() %>/ViewNominationServlet?id=<%= n.getId() %>" class="ea-btn-icon" title="View" style="font-size:1rem;padding:0.4em 0.7em;text-decoration:none;"><i class="bi bi-eye"></i></a>
                        <% if ("verified".equals(st)) { %>
                          <%-- already verified, no action needed --%>
                        <% } else if ("pending_examiner".equals(st)) { %>
                          <span class="ea-btn-icon" title="Waiting for examiner to confirm their profile"
                                style="font-size:1rem;padding:0.4em 0.7em;color:#9ca3af;border-color:#e5e7eb;cursor:default;">
                            <i class="bi bi-hourglass-split"></i>
                          </span>
                        <% } else { %>
                          <a href="<%= request.getContextPath() %>/ViewNominationServlet?id=<%= n.getId() %>" class="ea-btn-icon" title="Verify" style="font-size:1rem;padding:0.4em 0.7em;text-decoration:none;color:#0f766e;border-color:#0f766e;"><i class="bi bi-clipboard-check"></i></a>
                        <% } %>
                      </div>
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