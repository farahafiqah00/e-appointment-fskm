<%--
  Admin: viva appointment list with text, level, status, letter-approval, and overdue filters.
  Filter state is preserved as hidden fields so active badges correctly survive form re-submits.
--%>
<%@ page import="java.util.List, java.util.Map, model.VivaAppointment" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String fullName = (String) session.getAttribute("full_name"); if (fullName == null) fullName = "Admin";
  String q = request.getParameter("q") != null ? request.getParameter("q").trim() : "";
  String statusF = request.getParameter("status") != null ? request.getParameter("status").trim() : "";
  String levelF  = request.getParameter("level")  != null ? request.getParameter("level").trim()  : "";
  String letterApprovalF = request.getAttribute("letterApprovalFilter") != null ? (String) request.getAttribute("letterApprovalFilter") : (request.getParameter("letterApproval") != null ? request.getParameter("letterApproval").trim() : "");
  boolean overdueOnlyF = Boolean.TRUE.equals(request.getAttribute("overdueOnly")) || "1".equals(request.getParameter("overdue"));
  boolean showArchived = Boolean.TRUE.equals(request.getAttribute("showArchived")) || "1".equals(request.getParameter("showArchived"));
  List<VivaAppointment> appts = (List<VivaAppointment>) request.getAttribute("appointments");
  if (appts == null) appts = new java.util.ArrayList<>();
  int overdueCount  = request.getAttribute("overdueCount")  != null ? ((Number) request.getAttribute("overdueCount")).intValue()  : 0;
  int declinedCount = request.getAttribute("declinedCount") != null ? ((Number) request.getAttribute("declinedCount")).intValue() : 0;
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Viva Appointment List - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout ea-layout">
    <% request.setAttribute("activeSection", "nomination"); %>
      <jsp:include page="/admin/sidebar.jsp" />

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Viva Appointment List</h1>
            <div style="font-size:1rem;color:#6b7280;">View candidates ready for appointment discussion</div>
          </div>
        </div>

        <div class="w-100 mb-4 p-3" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <form class="row g-2 align-items-center" method="GET" action="<%= request.getContextPath() %>/admin/appointments">
            <div class="col-lg-4 col-md-12">
              <div class="input-group" style="border:1.5px solid #e5e7eb;border-radius:10px;overflow:hidden;">
                <span class="input-group-text bg-transparent border-0"><i class="bi bi-search text-muted"></i></span>
                <input class="form-control border-0 ps-0" name="q" value="<%= q %>" placeholder="Search by name, matric number, or programme..." style="font-size:0.97rem;box-shadow:none;">
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
                <option value="pending" <%= "pending".equals(statusF) ? "selected" : "" %>>Pending (No Panel Yet)</option>
                <option value="scheduled" <%= "scheduled".equals(statusF) ? "selected" : "" %>>Scheduled</option>
                <option value="letter_generated" <%= "letter_generated".equals(statusF) ? "selected" : "" %>>Letter Generated</option>
                <option value="deferred" <%= "deferred".equals(statusF) ? "selected" : "" %>>Deferred</option>
                <option value="examiner_declined" <%= "examiner_declined".equals(statusF) ? "selected" : "" %>>Examiner Declined</option>
              </select>
            </div>
            <% if (showArchived) { %><input type="hidden" name="showArchived" value="1"><% } %>
          <% if (!letterApprovalF.isEmpty()) { %><input type="hidden" name="letterApproval" value="<%= letterApprovalF %>"><% } %>
          <% if (overdueOnlyF) { %><input type="hidden" name="overdue" value="1"><% } %>
            <div class="col-lg-3 col-md-4 d-flex gap-2">
              <button type="submit" class="ea-btn-icon w-100" title="Search"><i class="bi bi-search"></i></button>
              <% if (!q.isEmpty() || !statusF.isEmpty() || !levelF.isEmpty() || !letterApprovalF.isEmpty() || overdueOnlyF) { %>
              <a href="<%= request.getContextPath() %>/admin/appointments<%= showArchived ? "?showArchived=1" : "" %>" class="ea-btn-icon w-100 text-decoration-none text-center" style="display:inline-flex;align-items:center;justify-content:center;" title="Clear"><i class="bi bi-x-lg"></i></a>
              <% } %>
            </div>
          </form>
          <%
            String _apptBase = request.getContextPath() + "/admin/appointments?q=" +
                java.net.URLEncoder.encode(q, "UTF-8") +
                (statusF.isEmpty() ? "" : "&status=" + statusF) +
                (levelF.isEmpty()  ? "" : "&level="  + levelF) +
                (letterApprovalF.isEmpty() ? "" : "&letterApproval=" + letterApprovalF) +
                (overdueOnlyF ? "&overdue=1" : "");
            // Build current list URL to pass through to decision/preview pages so Back links return here
            StringBuilder _listUrlBuf = new StringBuilder(request.getContextPath() + "/admin/appointments");
            boolean _lpHasParam = false;
            if (!q.isEmpty()) { _listUrlBuf.append(_lpHasParam?"&":"?").append("q=").append(java.net.URLEncoder.encode(q,"UTF-8")); _lpHasParam=true; }
            if (!statusF.isEmpty()) { _listUrlBuf.append(_lpHasParam?"&":"?").append("status=").append(statusF); _lpHasParam=true; }
            if (!levelF.isEmpty()) { _listUrlBuf.append(_lpHasParam?"&":"?").append("level=").append(levelF); _lpHasParam=true; }
            if (!letterApprovalF.isEmpty()) { _listUrlBuf.append(_lpHasParam?"&":"?").append("letterApproval=").append(letterApprovalF); _lpHasParam=true; }
            if (overdueOnlyF) { _listUrlBuf.append(_lpHasParam?"&":"?").append("overdue=1"); _lpHasParam=true; }
            if (showArchived) { _listUrlBuf.append(_lpHasParam?"&":"?").append("showArchived=1"); _lpHasParam=true; }
            String _currentListUrl = _listUrlBuf.toString();
            String _currentListUrlEncoded = java.net.URLEncoder.encode(_currentListUrl, "UTF-8");
          %>
          <div class="d-flex justify-content-end mt-2">
            <% if (!showArchived) { %>
            <a href="<%= _apptBase %>&showArchived=1"
               style="font-size:0.8rem;color:#9ca3af;text-decoration:none;display:inline-flex;align-items:center;gap:4px;">
              <i class="bi bi-archive"></i> Show archived (completed viva)
            </a>
            <% } else { %>
            <a href="<%= _apptBase %>"
               style="font-size:0.8rem;color:#059669;text-decoration:none;display:inline-flex;align-items:center;gap:4px;font-weight:600;">
              <i class="bi bi-archive-fill"></i> Showing archived &mdash; click to hide
            </a>
            <% } %>
          </div>
        </div>

        <% if (!letterApprovalF.isEmpty() || overdueOnlyF) { %>
        <div class="d-flex align-items-center gap-2 mb-3 px-4 py-2"
             style="background:#f0fdf4;border-left:5px solid #0f766e;border-radius:12px;font-size:0.88rem;color:#065f46;">
          <i class="bi bi-funnel-fill" style="font-size:1rem;"></i>
          <span style="font-weight:600;">
            <% if ("pending".equals(letterApprovalF)) { %>Filtered: Awaiting Signature (sent for approval)<% }
               else if ("signed".equals(letterApprovalF)) { %>Filtered: Approved &amp; Ready to Send<% }
               else if (overdueOnlyF) { %>Filtered: Overdue External Examiner Response (&gt;7 days)<% }
            %>
          </span>
          <a href="<%= request.getContextPath() %>/admin/appointments" style="margin-left:auto;font-size:0.8rem;color:#0f766e;text-decoration:none;font-weight:600;">Clear filter ×</a>
        </div>
        <% } %>

        <% if (declinedCount > 0) { %>
        <div class="d-flex align-items-center gap-3 mb-3 px-4 py-3"
             style="background:#fff5f5;border-left:5px solid #dc2626;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.04);">
          <i class="bi bi-x-circle-fill" style="color:#dc2626;font-size:1.2rem;flex-shrink:0;"></i>
          <div style="flex:1;">
            <span style="font-weight:700;color:#991b1b;font-size:0.95rem;">
              <%= declinedCount %> appointment<%= declinedCount > 1 ? "s" : "" %> declined by examiner
            </span>
            <span style="color:#b91c1c;font-size:0.88rem;margin-left:6px;">— reassignment required</span>
          </div>
          <a href="<%= request.getContextPath() %>/admin/appointments?status=examiner_declined"
             style="font-size:0.82rem;font-weight:600;color:#dc2626;text-decoration:none;white-space:nowrap;border:1.5px solid #fca5a5;border-radius:8px;padding:4px 12px;background:#fff;">
            View Declined
          </a>
        </div>
        <% } %>

        <% if (overdueCount > 0) { %>
        <div class="d-flex align-items-center gap-3 mb-3 px-4 py-3"
             style="background:#fffbeb;border-left:5px solid #f59e0b;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.04);">
          <i class="bi bi-clock-history" style="color:#d97706;font-size:1.2rem;flex-shrink:0;"></i>
          <div style="flex:1;">
            <span style="font-weight:700;color:#92400e;font-size:0.95rem;">
              <%= overdueCount %> external examiner<%= overdueCount > 1 ? "s" : "" %> have not responded in over 7 days
            </span>
            <span style="color:#b45309;font-size:0.88rem;margin-left:6px;">— consider resending the email</span>
          </div>
          <a href="<%= request.getContextPath() %>/admin/appointments?overdue=1"
             style="font-size:0.82rem;font-weight:600;color:#d97706;text-decoration:none;white-space:nowrap;border:1.5px solid #fcd34d;border-radius:8px;padding:4px 12px;background:#fff;">
            View Overdue
          </a>
        </div>
        <% } %>

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
                <tr><td colspan="6" class="text-center py-5 text-muted">
                  <i class="bi bi-<%= "examiner_declined".equals(statusF) ? "check-circle" : "calendar3" %> d-block mb-2" style="font-size:2rem;color:#d1d5db;"></i>
                  <% if ("examiner_declined".equals(statusF)) { %>
                  <div style="font-weight:600;color:#374151;margin-bottom:4px;">No declined appointments found.</div>
                  <div style="font-size:0.88rem;color:#9ca3af;margin-bottom:10px;">Previously declined appointments may have been reassigned and moved to a different status.</div>
                  <a href="<%= request.getContextPath() %>/admin/appointments" style="font-size:0.85rem;font-weight:600;color:#0f766e;text-decoration:none;border:1.5px solid #0f766e;border-radius:8px;padding:5px 14px;">View All Appointments</a>
                  <% } else { %>
                  No appointments found.
                  <% } %>
                </td></tr>
                <% } else { for (VivaAppointment a : appts) {
                    String apptStatus = a.getStatus() != null ? a.getStatus() : "scheduled";
                    String vivaStatus = a.getCandidateVivaStatus() != null ? a.getCandidateVivaStatus() : "active";
                %>
                <tr>
                  <td><div class="fw-semibold" style="color:#111827;"><%= a.getCandidateName() != null ? a.getCandidateName() : "—" %></div></td>
                  <td><span style="color:#6b7280;"><%= a.getCandidateStudentId() != null ? a.getCandidateStudentId() : "—" %></span></td>
                  <td><span style="color:#6b7280;"><%= a.getCandidateProgram() != null ? a.getCandidateProgram() : "—" %></span></td>
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
                    <% } else if ("examiner_declined".equals(apptStatus)) { %>
                      <span style="background:#fee2e2;color:#b91c1c;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;"><i class="bi bi-x-circle me-1"></i>Examiner Declined</span>
                      <% if (a.getPanelMembers() != null) {
                           for (Map<String,Object> _dpm : a.getPanelMembers()) {
                             if ("declined".equals(_dpm.get("panel_response"))) {
                               String _dpName   = _dpm.get("name") != null ? _dpm.get("name").toString() : "Unknown";
                               String _dpRole   = _dpm.get("role") != null ? _dpm.get("role").toString() : "";
                               String _dpReason = _dpm.get("rejection_reason") != null ? _dpm.get("rejection_reason").toString().trim() : ""; %>
                      <div style="font-size:0.75rem;color:#991b1b;margin-top:3px;line-height:1.3;">
                        <i class="bi bi-person-x me-1"></i><strong><%= _dpName %></strong><%= _dpRole.isEmpty() ? "" : " (" + _dpRole + ")" %>
                        <% if (!_dpReason.isEmpty()) { %><span style="color:#6b7280;font-style:italic;"> — <%= _dpReason.replace("<","&lt;").replace(">","&gt;") %></span><% } %>
                      </div>
                      <%   }
                           }
                         } %>
                    <% } else if ("deferred".equals(apptStatus)) { %>
                      <span style="background:#f3f4f6;color:#6b7280;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Deferred</span>
                    <% } else if ("pending".equals(apptStatus)) { %>
                      <span style="background:#fff7ed;color:#c2410c;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Pending Schedule</span>
                    <% } else { %>
                      <span style="background:#f3f4f6;color:#6b7280;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;"><%= apptStatus %></span>
                    <% } %>
                  </td>
                  <td style="white-space:nowrap;">
                    <a href="<%= request.getContextPath() %>/admin/appointment/decision?id=<%= a.getId() %>&listUrl=<%= _currentListUrlEncoded %>" class="ea-btn-icon" title="View / Record Decision" style="font-size:1rem;padding:0.4em 0.7em;text-decoration:none;"><i class="bi bi-eye"></i></a>
                    <% if ("signed".equals(letterApprovalF)) { %>
                    <a href="<%= request.getContextPath() %>/admin/appointment/letter/preview?id=<%= a.getId() %>&listUrl=<%= _currentListUrlEncoded %>" class="ea-btn-icon ms-1" title="Send Letter Emails" style="font-size:1rem;padding:0.4em 0.7em;text-decoration:none;color:#0f766e;border-color:#0f766e;"><i class="bi bi-envelope-check"></i></a>
                    <% } %>
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
