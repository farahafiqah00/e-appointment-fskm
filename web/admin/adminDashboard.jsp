<%--
  Admin dashboard: shows summary KPIs, recent activity feed, upcoming appointments,
  and alert badges (overdue, declined, etc.) polled via /admin/alertCounts JSON endpoint.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null || fullName.trim().isEmpty()) {
        fullName = "Admin";
    }
%>
<!doctype html>
<html lang="en">
  <%@ page import="dao.ReportsDAO, java.util.List, java.util.Map" %>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
     <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
      .role-switcher-btn {
        background: #fff;
        border: 1.5px solid #d1d5db;
        border-radius: 10px;
        padding: 6px 36px 6px 14px;
        font-size: 0.95rem;
        font-weight: 600;
        color: #111827;
        cursor: pointer;
        appearance: none;
        -webkit-appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24'%3E%3Cpath d='M7 10l5 5 5-5z' fill='%236b7280'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 10px center;
      }
      .role-switcher-btn:focus { outline: none; border-color: #0f766e; }
    </style>
  <body class="admin">

    <jsp:include page="/includes/topbar.jsp" />

    <div class="sidebar-overlay" id="sidebarOverlay"></div>
    <div class="layout">
        <nav class="sidebar" id="mainSidebar">
          <div class="position-sticky">
            <ul class="nav flex-column mt-3">
              <!-- User Management -->
              <li class="nav-item">
                <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#usersMenu" role="button" aria-expanded="false" aria-controls="usersMenu">
                  <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zM6 20v-1c0-2.21 3.58-4 6-4s6 1.79 6 4v1H6z" fill="currentColor"/></svg></span> User Management</span>
                  <span class="small">▾</span>
                </a>
                <div class="collapse" id="usersMenu">
                  <ul class="nav flex-column ms-3 mt-2">
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/UserListServlet"><span class="sub-icon"><i class="bi bi-people"></i></span> Manage Users</a></li>
                  </ul>
                </div>
              </li>

              <!-- other menus -->
              <li class="nav-item">
                <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#academicStaffMenu" role="button" aria-expanded="false" aria-controls="academicStaffMenu">
                  <span><span class="nav-icon"><i class="bi bi-mortarboard" style="font-size:17px;color:#0f766e;"></i></span> Academic Staff Records</span>
                  <span class="small">▾</span>
                </a>
                <div class="collapse" id="academicStaffMenu">
                  <ul class="nav flex-column ms-3 mt-2">
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/academician/academicStaffList.jsp"><span class="sub-icon"><i class="bi bi-people"></i></span> View Academic Staff</a></li>
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/academician/addAcademicStaff.jsp"><span class="sub-icon"><i class="bi bi-person-plus"></i></span> Add / Update Staff Info</a></li>
                  </ul>
                </div>
              </li>

              <!-- other menus -->
              <li class="nav-item">
                <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#vivaMenu" role="button" aria-expanded="false" aria-controls="vivaMenu">
                  <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5" fill="currentColor"/></svg></span> Viva Candidates</span>
                  <span class="small">▾</span>
                </a>
                <div class="collapse" id="vivaMenu">
                  <ul class="nav flex-column ms-3 mt-2">
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/CandidateListServlet"><span class="sub-icon"><i class="bi bi-list-ul"></i></span> View Viva Candidates</a></li>
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/viva/addVivaCandidate.jsp"><span class="sub-icon"><i class="bi bi-person-plus"></i></span> Add / Update Viva Candidate Info</a></li>
                  </ul>
                </div>
              </li>

              <li class="nav-item">
                <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#examinerMenu" role="button" aria-expanded="false" aria-controls="examinerMenu">
                  <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 2a7 7 0 0 0-7 7v2H3v6h18v-6h-2V9a7 7 0 0 0-7-7z" fill="currentColor"/></svg></span> Examiner Management</span>
                  <span class="small">▾</span>
                </a>
                <div class="collapse" id="examinerMenu">
                  <ul class="nav flex-column ms-3 mt-2">
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/NominationListServlet"><span class="sub-icon"><i class="bi bi-clipboard-check"></i></span> Examiner Nominations</a></li>
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/VerifiedExaminerServlet"><span class="sub-icon"><i class="bi bi-search"></i></span> Search Verified Examiners</a></li>
                  </ul>
                </div>
              </li>

              <li class="nav-item">
                <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#nominationMenu" role="button" aria-expanded="false" aria-controls="nominationMenu">
                  <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M7 10l5 5 5-5H7z" fill="currentColor"/></svg></span> Viva Nomination & Appointment</span>
                  <span class="small">▾</span>
                </a>
                <div class="collapse" id="nominationMenu">
                  <ul class="nav flex-column ms-3 mt-2">
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/appointments"><span class="sub-icon"><i class="bi bi-calendar3"></i></span> Viva Appointment List</a></li>
                  </ul>
                </div>
              </li>

              <li class="nav-item">
                <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#reportsMenu" role="button" aria-expanded="false" aria-controls="reportsMenu">
                  <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M3 13h2v-2H3v2zm4 0h14v-2H7v2zM3 8h2V6H3v2z" fill="currentColor"/></svg></span> Reports & Statistics</span>
                  <span class="small">▾</span>
                </a>
                <div class="collapse" id="reportsMenu">
                  <ul class="nav flex-column ms-3 mt-2">
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/reports/appointments"><span class="sub-icon"><i class="bi bi-bar-chart"></i></span> Appointment Statistics</a></li>
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/UnverifiedReportServlet?from=reports"><span class="sub-icon"><i class="bi bi-exclamation-circle"></i></span> Unverified Nominations</a></li>
                    <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/reports/exportPage"><span class="sub-icon"><i class="bi bi-download"></i></span> Export Reports</a></li>
                  </ul>
                </div>
              </li>
            </ul>
          </div>

          <!-- Profile footer -->
          <div style="position:absolute;bottom:0;left:0;right:0;border-top:1px solid #d1d5db;padding:12px 16px;background:#e5e5e5;">
            <a href="<%= request.getContextPath() %>/ProfileServlet"
               class="d-flex align-items-center gap-3 text-decoration-none" style="color:#374151;">
              <%
                String[] _dp = fullName.trim().split("\\s+");
                String _dini = _dp.length == 1 ? String.valueOf(_dp[0].charAt(0)).toUpperCase()
                             : (String.valueOf(_dp[0].charAt(0)) + String.valueOf(_dp[_dp.length-1].charAt(0))).toUpperCase();
              %>
              <div style="width:36px;height:36px;border-radius:50%;background:linear-gradient(135deg,#0f766e,#14b8a6);color:#fff;
                          display:flex;align-items:center;justify-content:center;font-size:0.85rem;font-weight:700;flex-shrink:0;">
                <%= _dini %>
              </div>
              <div style="overflow:hidden;">
                <div style="font-size:0.85rem;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><%= fullName %></div>
                <div style="font-size:0.75rem;color:#9ca3af;">My Profile</div>
              </div>
              <i class="bi bi-gear ms-auto" style="font-size:0.9rem;color:#9ca3af;"></i>
            </a>
          </div>
        </nav>

        <main class="content">
          <div class="mb-3" style="margin-bottom:32px !important;">
            <h1 class="h3">Dashboard Overview</h1>
            <p class="text-muted">Welcome back, <strong><%= ("Admin".equals(fullName) ? "Mr. Admin" : fullName) %></strong>! Here's what's happening today.</p>
          </div>

          <%
            Map<String,Integer> stats = new java.util.HashMap<>();
            ReportsDAO rdao = new ReportsDAO();
            try {
              stats = rdao.getDashboardStats();
            } catch (Exception _e) { }
          %>

          <div class="stats-grid">
            <div class="card-stat teal">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <small class="text-muted">Total Viva Candidates</small>
                  <div class="value mt-2"><%= stats.getOrDefault("totalCandidates", 0) %></div>
                </div>
                <div class="stat-icon fill-teal">
                  <i class="bi bi-mortarboard" style="font-size:1.7rem;"></i>
                </div>
              </div>
            </div>
            <div class="card-stat yellow">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <small class="text-muted">Pending Examiner Nominations</small>
                  <div class="value mt-2"><%= stats.getOrDefault("pendingNominations", 0) %></div>
                </div>
                <div class="stat-icon fill-yellow">
                  <i class="bi bi-clock" style="font-size:1.7rem;"></i>
                </div>
              </div>
            </div>
            <div class="card-stat green">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <small class="text-muted">Verified Examiners</small>
                  <div class="value mt-2"><%= stats.getOrDefault("verifiedExaminers", 0) %></div>
                </div>
                <div class="stat-icon fill-green">
                  <i class="bi bi-patch-check" style="font-size:1.7rem;"></i>
                </div>
              </div>
            </div>
            <div class="card-stat red">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <small class="text-muted">Pending Appointments</small>
                  <div class="value mt-2"><%= stats.getOrDefault("pendingAppointments", 0) %></div>
                </div>
                <div class="stat-icon fill-red">
                  <i class="bi bi-calendar-event" style="font-size:1.7rem;"></i>
                </div>
              </div>
            </div>
          </div>

          <%
            Map<String,Integer> alerts = new java.util.HashMap<>();
            try {
              alerts = rdao.getAdminAlerts();
            } catch (Exception _ae) { }
            int alertPendingVerif    = alerts.getOrDefault("pendingVerification",    0);
            int alertNoLetter        = alerts.getOrDefault("letterNotGenerated",     0);
            int alertOverdue         = alerts.getOrDefault("overdueExternalResponse", 0);
            int alertDeclined        = alerts.getOrDefault("examinerDeclined",        0);
            int alertLetterReady     = alerts.getOrDefault("letterApprovedNotSent",  0);
            boolean hasAlerts        = alertPendingVerif > 0 || alertNoLetter > 0
                                       || alertOverdue > 0 || alertDeclined > 0 || alertLetterReady > 0;
          %>
          <div class="card mb-4 shadow-sm custom-card">
            <div class="card-body">
              <h5 class="card-title d-flex align-items-center justify-content-between">
                <span><i class="bi bi-bell me-2"></i>Action Alerts &amp; Notifications</span>
                <span id="alertLiveIndicator" title="Live updates every 30s"
                      style="display:inline-flex;align-items:center;gap:5px;font-size:0.72rem;font-weight:600;
                             color:#9ca3af;letter-spacing:.04em;">
                  <span id="alertPulseDot" style="width:7px;height:7px;border-radius:50%;background:#16a34a;
                                                  display:inline-block;animation:alertPulse 2s infinite;"></span>
                  LIVE
                </span>
              </h5>
                <div class="mt-3" id="alertsContainer">
                  <% if (!hasAlerts) { %>
                  <p class="text-muted mb-0" id="noAlertsMsg" style="font-size:0.95rem;">No pending actions. Everything is up to date.</p>
                  <% } else { %>
                  <p class="text-muted mb-0" id="noAlertsMsg" style="font-size:0.95rem;display:none;">No pending actions. Everything is up to date.</p>
                  <% } %>

                  <div id="pill-pendingVerif" class="alert-pill alert-warning" style="<%= alertPendingVerif > 0 ? "" : "display:none;" %>">
                    <span class="alert-icon"><i class="bi bi-clock"></i></span>
                    <a href="<%= request.getContextPath() %>/NominationListServlet" style="color:inherit;text-decoration:none;">
                      <span id="txt-pendingVerif"><%= alertPendingVerif %> examiner nomination<%= alertPendingVerif == 1 ? "" : "s" %> pending verification</span>
                    </a>
                  </div>

                  <div id="pill-letterReady" class="alert-pill alert-info" style="<%= alertLetterReady > 0 ? "" : "display:none;" %>">
                    <span class="alert-icon"><i class="bi bi-envelope-arrow-up"></i></span>
                    <a href="<%= request.getContextPath() %>/admin/appointments?letterApproval=signed" style="color:inherit;text-decoration:none;">
                      <span id="txt-letterReady"><%= alertLetterReady %> approved letter<%= alertLetterReady == 1 ? "" : "s" %> ready to send</span>
                    </a>
                  </div>

                  <div id="pill-noLetter" class="alert-pill alert-danger" style="<%= alertNoLetter > 0 ? "" : "display:none;" %>">
                    <span class="alert-icon"><i class="bi bi-file-earmark-text"></i></span>
                    <a href="<%= request.getContextPath() %>/admin/appointments?status=scheduled" style="color:inherit;text-decoration:none;">
                      <span id="txt-noLetter">Appointment letter<%= alertNoLetter == 1 ? "" : "s" %> not generated for <%= alertNoLetter %> case<%= alertNoLetter == 1 ? "" : "s" %></span>
                    </a>
                  </div>

                  <div id="pill-declined" class="alert-pill alert-danger" style="<%= alertDeclined > 0 ? "" : "display:none;" %>">
                    <span class="alert-icon"><i class="bi bi-x-circle"></i></span>
                    <a href="<%= request.getContextPath() %>/admin/appointments?status=examiner_declined"
                       style="color:inherit;text-decoration:none;">
                      <span id="txt-declined"><%= alertDeclined %> appointment<%= alertDeclined == 1 ? "" : "s" %> declined by a panel member</span>
                    </a>
                  </div>

                  <div id="pill-overdue" class="alert-pill alert-warning" style="<%= alertOverdue > 0 ? "" : "display:none;" %>">
                    <span class="alert-icon"><i class="bi bi-clock-history"></i></span>
                    <a href="<%= request.getContextPath() %>/admin/appointments" style="color:inherit;text-decoration:none;">
                      <span id="txt-overdue"><%= alertOverdue %> external examiner<%= alertOverdue == 1 ? "" : "s" %> have not responded in over 7 days</span>
                    </a>
                  </div>
                </div>
            </div>
          </div>

          <%-- Letter Approval Status Widget (moved below Quick Actions) --%>
          <%-- (widget rendered after quick-actions-section below) --%>

          <div class="quick-actions-section">
            <div class="section-title">
              <i class="bi bi-plus-lg"></i>
              <span>Quick Actions</span>
            </div>

            <div class="quick-actions-grid">
              <div class="qa-card" role="button" onclick="location.href='<%= request.getContextPath() %>/admin/addUser.jsp'">
                <i class="bi bi-person-plus"></i>
                <span>Add New User</span>
              </div>

              <div class="qa-card" role="button" onclick="location.href='<%= request.getContextPath() %>/CandidateListServlet'">
                <i class="bi bi-mortarboard"></i>
                <span>Prepare Viva Candidate</span>
              </div>

              <div class="qa-card" role="button" onclick="location.href='<%= request.getContextPath() %>/NominationListServlet'">
                <i class="bi bi-clipboard-check"></i>
                <span>Verify Examiner</span>
              </div>

              <div class="qa-card" role="button" onclick="location.href='<%= request.getContextPath() %>/admin/appointments'">
                <i class="bi bi-file-earmark-text"></i>
                <span>Record Appointment</span>
              </div>
            </div>
          </div><!-- end quick-actions-section -->

          <%-- Letter Approval Status — redesigned, below Quick Actions --%>
          <%
            java.util.Map<String,Integer> approvalStats = new java.util.LinkedHashMap<>();
            try {
              approvalStats = new dao.AppointmentDAO().getLetterApprovalStats();
            } catch (Exception _as) { }
            int apvPending = approvalStats.getOrDefault("pending_count", 0);
            int apvSigned  = approvalStats.getOrDefault("signed_count", 0);
            int apvNone    = approvalStats.getOrDefault("not_requested_count", 0);
          %>
          <div style="margin:1.5rem 0;">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;">
              <i class="bi bi-pen-fill" style="color:#0f766e;font-size:1rem;"></i>
              <span style="font-size:0.78rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#374151;">Letter Approval Status</span>
            </div>
            <div class="stats-grid" style="grid-template-columns:repeat(3,minmax(0,1fr));">

              <!-- Awaiting signature -->
              <div class="card-stat yellow">
                <div class="d-flex justify-content-between align-items-center">
                  <div>
                    <small class="text-muted">Awaiting Signature</small>
                    <div class="value mt-2"><%= apvPending %></div>
                    <div style="font-size:0.78rem;color:#6b7280;margin-top:4px;">pending dean / TDA / TDB</div>
                    <% if (apvPending > 0) { %>
                    <a href="<%= request.getContextPath() %>/admin/appointments?letterApproval=pending"
                       class="d-inline-flex align-items-center gap-1 mt-2"
                       style="font-size:0.78rem;font-weight:600;color:#d97706;text-decoration:none;">
                      <i class="bi bi-arrow-right-short"></i> View
                    </a>
                    <% } %>
                  </div>
                  <div class="stat-icon fill-yellow">
                    <i class="bi bi-hourglass-split" style="font-size:1.7rem;"></i>
                  </div>
                </div>
              </div>

              <!-- Approved / ready to send -->
              <div class="card-stat green">
                <div class="d-flex justify-content-between align-items-center">
                  <div>
                    <small class="text-muted">Approved &mdash; Ready</small>
                    <div class="value mt-2"><%= apvSigned %></div>
                    <div style="font-size:0.78rem;color:#6b7280;margin-top:4px;">signed, emails can be sent</div>
                    <% if (apvSigned > 0) { %>
                    <a href="<%= request.getContextPath() %>/admin/appointments?letterApproval=signed"
                       class="d-inline-flex align-items-center gap-1 mt-2"
                       style="font-size:0.78rem;font-weight:600;color:#059669;text-decoration:none;">
                      <i class="bi bi-envelope-arrow-up"></i> Send Emails
                    </a>
                    <% } %>
                  </div>
                  <div class="stat-icon fill-green">
                    <i class="bi bi-patch-check-fill" style="font-size:1.7rem;"></i>
                  </div>
                </div>
              </div>

              <!-- Not yet requested -->
              <div class="card-stat" style="border-top:5px solid #9ca3af;">
                <div class="d-flex justify-content-between align-items-center">
                  <div>
                    <small class="text-muted">Not Requested</small>
                    <div class="value mt-2" style="color:#9ca3af;"><%= apvNone %></div>
                    <div style="font-size:0.78rem;color:#6b7280;margin-top:4px;">not yet sent for signature</div>
                  </div>
                  <div class="stat-icon" style="background:rgba(156,163,175,0.15);color:#9ca3af;">
                    <i class="bi bi-clock" style="font-size:1.7rem;"></i>
                  </div>
                </div>
              </div>

            </div>
          </div>

            <!-- Recent Activity Block (server-side rendered minimal list) -->
            <div class="card mb-4 shadow-sm">
              <div class="card-body">
                <h5 class="card-title">Recent Activity Log</h5>
                <div class="mt-3">
                  <ul class="list-group">
                    <%
                      try {
                        List<Map<String,Object>> items = rdao.getRecentActivity(10);
                        if (items.isEmpty()) {
                    %>
                    <li class="list-group-item text-muted">No recent activity yet.</li>
                    <%  } else { for (Map<String,Object> it : items) { %>
                    <li class="list-group-item">
                      <div class="d-flex align-items-start">
                        <div style="width:10px;height:10px;border-radius:50%;background:var(--accent-green);margin-right:12px;margin-top:6px;flex-shrink:0;"></div>
                        <div>
                          <div><%= it.get("message") %></div>
                          <small class="text-muted"><%= it.get("created_at") %></small>
                        </div>
                      </div>
                    </li>
                    <%  } }
                      } catch (Exception e) {
                        System.err.println("[Dashboard] recent activity error: " + e.getMessage());
                    %>
                    <li class="list-group-item text-danger">Unable to load recent activity. Check server logs.</li>
                    <% } %>
                  </ul>
                </div>
              </div>
            </div>

          </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <style>
      @keyframes alertPulse {
        0%, 100% { opacity: 1; transform: scale(1); }
        50%       { opacity: 0.4; transform: scale(0.8); }
      }
    </style>
    <script>
      (function(){
        var btn = document.getElementById('sidebarToggleBtn');
        var overlay = document.getElementById('sidebarOverlay');
        if(btn){ btn.addEventListener('click', function(){ document.body.classList.toggle('sidebar-open'); }); }
        if(overlay){ overlay.addEventListener('click', function(){ document.body.classList.remove('sidebar-open'); }); }
      })();

      // ── Real-time alert polling (every 30 s) ──────────────────────────────
      (function() {
        var POLL_URL = '<%= request.getContextPath() %>/admin/alertCounts';

        function plural(n, word) {
          return n + ' ' + word + (n === 1 ? '' : 's');
        }

        function updatePill(pillId, txtId, count, textFn) {
          var pill = document.getElementById(pillId);
          var txt  = document.getElementById(txtId);
          if (!pill || !txt) return;
          if (count > 0) {
            txt.textContent = textFn(count);
            pill.style.display = '';
          } else {
            pill.style.display = 'none';
          }
        }

        function refreshAlerts() {
          fetch(POLL_URL, { credentials: 'same-origin' })
            .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
            .then(function(d) {
              var pv = d.pendingVerification    || 0;
              var nl = d.letterNotGenerated     || 0;
              var od = d.overdueExternalResponse|| 0;
              var dc = d.examinerDeclined       || 0;
              var lr = d.letterApprovedNotSent  || 0;

              updatePill('pill-pendingVerif', 'txt-pendingVerif', pv, function(n){
                return plural(n, 'examiner nomination') + ' pending verification';
              });
              updatePill('pill-letterReady', 'txt-letterReady', lr, function(n){
                return plural(n, 'approved letter') + ' ready to send';
              });
              updatePill('pill-noLetter', 'txt-noLetter', nl, function(n){
                return 'Appointment letter' + (n === 1 ? '' : 's') + ' not generated for ' + n + ' case' + (n === 1 ? '' : 's');
              });
              updatePill('pill-declined', 'txt-declined', dc, function(n){
                return plural(n, 'appointment') + ' declined by a panel member';
              });
              updatePill('pill-overdue', 'txt-overdue', od, function(n){
                return plural(n, 'external examiner') + ' have not responded in over 7 days';
              });

              var anyAlert = pv > 0 || lr > 0 || nl > 0 || od > 0 || dc > 0;
              var noMsg = document.getElementById('noAlertsMsg');
              if (noMsg) noMsg.style.display = anyAlert ? 'none' : '';

              // Pulse dot: green when all clear, amber when alerts present
              var dot = document.getElementById('alertPulseDot');
              if (dot) dot.style.background = anyAlert ? '#d97706' : '#16a34a';
            })
            .catch(function() {
              // silently ignore network errors; dot turns grey
              var dot = document.getElementById('alertPulseDot');
              if (dot) dot.style.background = '#9ca3af';
            });
        }

        // Poll every 30 seconds
        setInterval(refreshAlerts, 30000);
      })();
    </script>
  </body>
</html>
