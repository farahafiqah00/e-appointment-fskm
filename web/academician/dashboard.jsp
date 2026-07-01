<%-- Academician dashboard: nomination status counts, corrections-required alert, recent nominations, and pending panel invitations. --%>
<%@ page import="java.util.List, model.Nomination" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String _role = (String) session.getAttribute("role_name");
    if (!"Academician".equals(_role) && !"Dean".equals(_role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null) fullName = "Academician";
    String _staffTitle = (String) session.getAttribute("staff_title");
    String displayName = (_staffTitle != null && !_staffTitle.isEmpty()) ? _staffTitle + " " + fullName : fullName;

    int totalNominations   = request.getAttribute("totalNominations")   != null ? (int) request.getAttribute("totalNominations")   : 0;
    int underReview        = request.getAttribute("underReview")        != null ? (int) request.getAttribute("underReview")        : 0;
    int requiresCorrection = request.getAttribute("requiresCorrection") != null ? (int) request.getAttribute("requiresCorrection") : 0;
    int approved           = request.getAttribute("approved")           != null ? (int) request.getAttribute("approved")           : 0;

    @SuppressWarnings("unchecked")
    List<Nomination> corrections   = (List<Nomination>) request.getAttribute("corrections");
    @SuppressWarnings("unchecked")
    List<Nomination> recentActivity = (List<Nomination>) request.getAttribute("recentActivity");
    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String,Object>> pendingPanels =
        (java.util.List<java.util.Map<String,Object>>) request.getAttribute("pendingPanels");
    if (corrections    == null) corrections    = new java.util.ArrayList<>();
    if (recentActivity == null) recentActivity = new java.util.ArrayList<>();
    if (pendingPanels  == null) pendingPanels  = new java.util.ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Dashboard - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="sidebar-overlay" id="sidebarOverlay"></div>
  <div class="layout">

    <!-- SIDEBAR — full menu shown on dashboard -->
    <nav class="sidebar" id="mainSidebar">
      <div class="sidebar-menu">
        <ul class="nav flex-column">
          <li class="nav-item">
            <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/AcademicianDashboardServlet">
              <span class="nav-icon"><i class="bi bi-speedometer2" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">Dashboard</span>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#nominationMenu" role="button" aria-expanded="false" aria-controls="nominationMenu">
              <span><span class="nav-icon"><i class="bi bi-file-earmark-text" style="font-size:17px;color:#0f766e;"></i></span> Examiner Nomination</span>
              <span class="small">&#9662;</span>
            </a>
            <div class="collapse" id="nominationMenu">
              <ul class="nav flex-column ms-3 mt-2">
                <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/MyNominationsServlet"><span class="sub-icon"><i class="bi bi-file-earmark-text"></i></span> My Nominations</a></li>
                <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/SubmitNominationServlet"><span class="sub-icon"><i class="bi bi-plus-circle"></i></span> Submit New Nomination</a></li>
              </ul>
            </div>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/academician/examiners">
              <span class="nav-icon"><i class="bi bi-person-lines-fill" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">Examiner Directory</span>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/academician/my-students-viva">
              <span class="nav-icon"><i class="bi bi-people-fill" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">My Students' Viva</span>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/academician/my-appointments">
              <span class="nav-icon"><i class="bi bi-calendar-check" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">My Appointments</span>
            </a>
          </li>
        </ul>
      </div>
      <div class="sidebar-profile">
        <%
          String[] _sp = fullName.trim().split("\\s+");
          String _sini = _sp.length == 1 ? String.valueOf(_sp[0].charAt(0)).toUpperCase()
                       : (String.valueOf(_sp[0].charAt(0)) + String.valueOf(_sp[_sp.length-1].charAt(0))).toUpperCase();
        %>
        <a href="<%= request.getContextPath() %>/ProfileServlet" class="profile-box" style="color:#111827;">
          <div class="profile-avatar"><%= _sini %></div>
          <div class="profile-info">
            <strong><%= fullName %></strong>
            <span>My Profile</span>
          </div>
          <i class="bi bi-gear ms-auto" style="font-size:0.9rem;color:#9ca3af;"></i>
        </a>
      </div>
    </nav>

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

        <!-- Page Header -->
        <div class="mb-4">
          <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Dashboard</h1>
          <div style="font-size:1rem;color:#6b7280;">Welcome back, <%= displayName %>! Here's your nomination progress.</div>
        </div>

        <!-- Stats Cards -->
        <div class="row g-3 mb-4">
          <!-- Total Nominations -->
          <div class="col-xl-3 col-md-6">
            <div style="background:#fff;border:1px solid #e5e7eb;border-top:4px solid #105e60;border-radius:14px;padding:20px 22px;min-height:140px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div class="d-flex align-items-start justify-content-between">
                <div>
                  <div style="font-size:0.875rem;font-weight:500;color:#6b7280;margin-bottom:6px;">Total Nominations Submitted</div>
                  <div style="font-size:2rem;font-weight:700;color:#105e60;"><%= totalNominations %></div>
                </div>
                <div style="background:#f0fdf4;border-radius:10px;padding:10px;">
                  <i class="bi bi-file-earmark-text" style="font-size:1.4rem;color:#105e60;"></i>
                </div>
              </div>
            </div>
          </div>

          <!-- Under Review -->
          <div class="col-xl-3 col-md-6">
            <div style="background:#fff;border:1px solid #e5e7eb;border-top:4px solid #d97706;border-radius:14px;padding:20px 22px;min-height:140px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div class="d-flex align-items-start justify-content-between">
                <div>
                  <div style="font-size:0.875rem;font-weight:500;color:#6b7280;margin-bottom:6px;">Nominations Under Review</div>
                  <div style="font-size:2rem;font-weight:700;color:#d97706;"><%= underReview %></div>
                </div>
                <div style="background:#fffbeb;border-radius:10px;padding:10px;">
                  <i class="bi bi-clock" style="font-size:1.4rem;color:#d97706;"></i>
                </div>
              </div>
            </div>
          </div>

          <!-- Requires Correction -->
          <div class="col-xl-3 col-md-6">
            <div style="background:#fff;border:1px solid #e5e7eb;border-top:4px solid #ef4444;border-radius:14px;padding:20px 22px;min-height:140px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div class="d-flex align-items-start justify-content-between">
                <div>
                  <div style="font-size:0.875rem;font-weight:500;color:#6b7280;margin-bottom:6px;">Nominations Requiring Correction</div>
                  <div style="font-size:2rem;font-weight:700;color:#ef4444;"><%= requiresCorrection %></div>
                </div>
                <div style="background:#fef2f2;border-radius:10px;padding:10px;">
                  <i class="bi bi-exclamation-circle" style="font-size:1.4rem;color:#ef4444;"></i>
                </div>
              </div>
            </div>
          </div>

          <!-- Approved -->
          <div class="col-xl-3 col-md-6">
            <div style="background:#fff;border:1px solid #e5e7eb;border-top:4px solid #16a34a;border-radius:14px;padding:20px 22px;min-height:140px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div class="d-flex align-items-start justify-content-between">
                <div>
                  <div style="font-size:0.875rem;font-weight:500;color:#6b7280;margin-bottom:6px;">Approved Nominations</div>
                  <div style="font-size:2rem;font-weight:700;color:#16a34a;"><%= approved %></div>
                </div>
                <div style="background:#f0fdf4;border-radius:10px;padding:10px;">
                  <i class="bi bi-check-circle" style="font-size:1.4rem;color:#16a34a;"></i>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Nominations Requiring Attention -->
        <div class="w-100 mb-4 p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center mb-3">
            <i class="bi bi-exclamation-circle me-2" style="color:#ef4444;font-size:1.1rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Nominations Requiring Attention</span>
          </div>
          <% if (corrections.isEmpty()) { %>
          <div class="text-muted" style="font-size:0.95rem;padding:6px 0;">No nominations require attention at this time.</div>
          <% } else { for (Nomination c : corrections) { %>
          <div class="alert-pill alert-danger d-flex align-items-center justify-content-between flex-wrap gap-2" style="margin-bottom:10px;">
            <div class="d-flex align-items-center gap-2 flex-grow-1">
              <span class="alert-icon"><i class="bi bi-exclamation-circle"></i></span>
              <div>
                <div class="fw-semibold" style="color:#111827;">
                  Nomination for <%= c.getExaminerName() != null ? c.getExaminerName() : "—" %> requires corrections
                </div>
                <% if (c.getDiscrepancyNotes() != null && !c.getDiscrepancyNotes().isEmpty()) { %>
                <div style="font-size:0.875rem;color:#92400e;">
                  <i class="bi bi-person-exclamation me-1"></i>Examiner reported: <%= c.getDiscrepancyNotes() %>
                </div>
                <% } else if (c.getRemarks() != null && !c.getRemarks().isEmpty()) { %>
                <div style="font-size:0.875rem;color:#6b7280;">
                  <i class="bi bi-shield-exclamation me-1"></i>Admin feedback: <%= c.getRemarks() %>
                </div>
                <% } %>
              </div>
            </div>
            <a href="<%= request.getContextPath() %>/EditNominationServlet?id=<%= c.getId() %>"
               class="ea-btn-primary d-flex align-items-center gap-1"
               style="text-decoration:none;border-radius:9px;padding:7px 18px;font-size:0.9rem;white-space:nowrap;">
              <i class="bi bi-pencil-square"></i> Edit
            </a>
          </div>
          <% } } %>
        </div>

        <!-- Pending Panel Appointments Widget -->
        <% if (!pendingPanels.isEmpty()) {
             java.text.SimpleDateFormat panelFmt = new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a");
        %>
        <div class="w-100 mb-4" style="background:#fffbeb;border-left:5px solid #f59e0b;border-radius:14px;padding:18px 22px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
            <div class="d-flex align-items-center gap-2">
              <i class="bi bi-hourglass-split" style="color:#d97706;font-size:1.2rem;"></i>
              <div>
                <div style="font-weight:700;color:#92400e;font-size:0.97rem;">
                  <strong><%= pendingPanels.size() %></strong> Viva Panel Appointment<%= pendingPanels.size() == 1 ? "" : "s" %> Awaiting Your Response
                </div>
                <div style="font-size:0.83rem;color:#b45309;">Please respond within 7 working days of receiving your appointment letter.</div>
              </div>
            </div>
            <a href="<%= request.getContextPath() %>/academician/my-appointments"
               style="background:#f59e0b;color:#fff;border:none;padding:8px 18px;border-radius:9px;font-weight:700;font-size:0.84rem;text-decoration:none;display:inline-flex;align-items:center;gap:6px;white-space:nowrap;">
              View All <i class="bi bi-arrow-right"></i>
            </a>
          </div>
          <% for (java.util.Map<String,Object> pp : pendingPanels) {
               String ppApptId  = String.valueOf(pp.get("appointment_id"));
               String ppPanelId = String.valueOf(pp.get("panel_id"));
               String ppCand    = pp.get("candidate_name") != null ? pp.get("candidate_name").toString() : "—";
               String ppRole    = pp.get("member_role")    != null ? pp.get("member_role").toString()    : "—";
               java.sql.Timestamp ppSched = (java.sql.Timestamp) pp.get("scheduled_at");
               String ppSchedLbl = ppSched != null ? panelFmt.format(ppSched) : "Date TBD";
               boolean ppLetterSent = Boolean.TRUE.equals(pp.get("letter_sent"));
          %>
          <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;background:#fff;border:1px solid #fde68a;border-radius:10px;padding:11px 14px;margin-bottom:8px;flex-wrap:wrap;">
            <div style="flex:1;min-width:0;">
              <div style="font-weight:600;font-size:0.92rem;color:#111827;"><%= ppCand %></div>
              <div style="font-size:0.8rem;color:#6b7280;margin-top:2px;">
                Role: <strong><%= ppRole %></strong>
                &nbsp;|&nbsp;
                <i class="bi bi-calendar-event" style="color:#d97706;"></i> <%= ppSchedLbl %>
                <% if (!ppLetterSent) { %>&nbsp;&nbsp;<span style="color:#9ca3af;font-size:0.77rem;">(Letter pending)</span><% } %>
              </div>
            </div>
            <a href="<%= request.getContextPath() %>/panel/member/preview?appointment_id=<%= ppApptId %>&panel_id=<%= ppPanelId %>"
               class="ea-btn-teal-outline">
              <i class="bi bi-envelope-open-text"></i>
              <%= ppLetterSent ? "Review & Respond" : "Preview Letter" %>
            </a>
          </div>
          <% } %>
        </div>
        <% } %>

        <!-- Quick Actions -->
        <div class="quick-actions-section w-100 mb-4 p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="section-title">
            <i class="bi bi-plus-lg"></i>
            <span>Quick Actions</span>
          </div>
          <div class="quick-actions-grid" style="grid-template-columns:repeat(2,1fr);">
            <a href="<%= request.getContextPath() %>/SubmitNominationServlet"
               class="qa-card" style="height:130px;font-size:1rem;">
              <i class="bi bi-plus-circle" style="font-size:1.6rem;"></i>
              <span>Submit New Nomination</span>
            </a>
            <a href="<%= request.getContextPath() %>/MyNominationsServlet"
               class="qa-card" style="height:130px;font-size:1rem;">
              <i class="bi bi-file-earmark-text" style="font-size:1.6rem;"></i>
              <span>View My Nominations</span>
            </a>
          </div>
        </div>

        <!-- Recent Activity -->
        <div class="w-100 mb-4 p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="section-title mb-0">
            <i class="bi bi-activity"></i>
            <span>Recent Activity</span>
          </div>
          <% if (recentActivity.isEmpty()) { %>
          <div class="text-muted text-center py-4" style="font-size:0.95rem;">No recent activity yet.</div>
          <% } else { %>
          <ul class="list-group mt-2">
            <% for (Nomination r : recentActivity) {
                 String rStatus = r.getStatus() != null ? r.getStatus() : "submitted";
                 String dotColor, labelText;
                 if ("verified".equals(rStatus)) {
                     dotColor = "#16a34a"; labelText = "Approved";
                 } else if ("needs_correction".equals(rStatus)) {
                     dotColor = "#ef4444"; labelText = "Needs Correction";
                 } else if ("submitted".equals(rStatus)) {
                     dotColor = "#3b82f6"; labelText = "Under Review";
                 } else {
                     dotColor = "#6b7280"; labelText = "Submitted";
                 }
                 String timeAgo = "—";
                 if (r.getCreatedAt() != null) {
                     long diffMs = System.currentTimeMillis() - r.getCreatedAt().getTime();
                     long diffH  = diffMs / 3600000;
                     long diffD  = diffH  / 24;
                     if (diffH < 1)       timeAgo = "Just now";
                     else if (diffH < 24) timeAgo = diffH + " hour" + (diffH == 1 ? "" : "s") + " ago";
                     else                 timeAgo = diffD + " day"  + (diffD == 1 ? "" : "s") + " ago";
                 }
            %>
            <li class="list-group-item">
              <div class="d-flex align-items-start">
                <div style="width:10px;height:10px;border-radius:50%;background:<%= dotColor %>;margin-right:12px;margin-top:6px;flex-shrink:0;"></div>
                <div>
                  <div>Nomination for <%= r.getExaminerName() != null ? r.getExaminerName() : "—" %> - <%= labelText %></div>
                  <small class="text-muted"><%= timeAgo %></small>
                </div>
              </div>
            </li>
            <% } %>
          </ul>
          <% } %>
        </div>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    (function(){
      var btn = document.getElementById('sidebarToggleBtn');
      var overlay = document.getElementById('sidebarOverlay');
      if (!btn) {
        var topbar = document.querySelector('.topbar');
        if (topbar) {
          btn = document.createElement('button');
          btn.id = 'sidebarToggleBtn';
          btn.className = 'sidebar-toggle';
          btn.setAttribute('aria-label', 'Toggle navigation');
          btn.innerHTML = '<i class="bi bi-list"></i>';
          topbar.insertBefore(btn, topbar.firstChild);
        }
      }
      if (btn) btn.addEventListener('click', function(){ document.body.classList.toggle('sidebar-open'); });
      if (overlay) overlay.addEventListener('click', function(){ document.body.classList.remove('sidebar-open'); });
    })();
  </script>
</body>
</html>
