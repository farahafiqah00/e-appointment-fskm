<%--
  Dean dashboard: shows upcoming viva appointments, programme breakdown, pending letter approvals,
  and statistics. Data is loaded inline from DAO calls (no DeanDashboardServlet redirect here).
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.ReportsDAO, dao.AppointmentDAO, dao.NominationDAO, model.Nomination, java.util.List, java.util.Map, java.util.ArrayList, java.util.LinkedHashMap, java.text.SimpleDateFormat" %>
<%
    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    if (!"Dean".equals(session.getAttribute("role_name"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null || fullName.trim().isEmpty()) fullName = "Dean";
    String _staffTitle = (String) session.getAttribute("staff_title");
    String displayName = (_staffTitle != null && !_staffTitle.isEmpty()) ? _staffTitle + " " + fullName : fullName;

    Map<String,Integer> stats = new LinkedHashMap<>();
    List<Map<String,Object>> upcomingList = new ArrayList<>();
    List<Map<String,Object>> programmeBreakdown = new ArrayList<>();
    List<Map<String,Object>> pendingApprovals = (List<Map<String,Object>>) request.getAttribute("pendingApprovals");
    List<Map<String,Object>> signedApprovals  = (List<Map<String,Object>>) request.getAttribute("signedApprovals");
    List<Map<String,Object>> pendingPanels    = new ArrayList<>();
    List<Nomination> deanCorrections = new ArrayList<>();
    try {
        ReportsDAO rdao = new ReportsDAO();
        stats             = rdao.getDeanDashboardStats();
        upcomingList      = rdao.getUpcomingAppointmentsList(6);
        programmeBreakdown = rdao.getCandidatesByProgramme();
        Object uidObj = session.getAttribute("user_id");
        if (uidObj instanceof Number) {
          int uid = ((Number) uidObj).intValue();
          AppointmentDAO apptDao = new AppointmentDAO();
          if (pendingApprovals == null) {
            pendingApprovals = apptDao.getPendingLetterApprovalsForSigner(uid, 8);
            signedApprovals  = apptDao.getSignedLetterApprovalsForSigner(uid, 5);
          }
          pendingPanels    = apptDao.getPendingPanelsForUser(uid);
          deanCorrections  = new NominationDAO().findCorrectionsRequired(uid);
        }
    } catch (Exception _e) { /* leave lists empty */ }
    if (pendingApprovals == null) pendingApprovals = new ArrayList<>();
    if (signedApprovals  == null) signedApprovals  = new ArrayList<>();

    int maxProgCount = 1;
    for (Map<String,Object> p : programmeBreakdown) {
        int c = ((Number) p.get("count")).intValue();
        if (c > maxProgCount) maxProgCount = c;
    }
    request.setAttribute("activeSection", "dashboard");
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Dean Dashboard - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    /* Role switcher dropdown */
    .role-switcher {
      position: relative;
      display: inline-block;
    }
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
      transition: border-color 0.15s;
    }
    .role-switcher-btn:focus { outline: none; border-color: #0f766e; }

    /* Programme bar chart */
    .prog-bar-track {
      height: 8px;
      background: #e5e7eb;
      border-radius: 6px;
      overflow: hidden;
      margin-top: 4px;
    }
    .prog-bar-fill {
      height: 100%;
      background: #0f766e;
      border-radius: 6px;
      transition: width 0.4s ease;
    }
    .prog-label {
      font-size: 0.9rem;
      color: #374151;
      font-weight: 500;
    }
    .prog-count {
      font-size: 0.9rem;
      font-weight: 700;
      color: #0f766e;
    }

    /* Quick nav cards */
    .quick-nav-card {
      background: #fff;
      border: 1.5px solid #e5e7eb;
      border-radius: 14px;
      padding: 24px 20px;
      cursor: pointer;
      transition: box-shadow 0.2s, border-color 0.2s;
      text-decoration: none;
      color: #111827;
      display: flex;
      align-items: center;
      gap: 14px;
    }
    .quick-nav-card:hover {
      box-shadow: 0 6px 20px rgba(15,118,110,0.10);
      border-color: #0f766e;
      color: #0f766e;
    }
    .quick-nav-card .qnc-icon {
      width: 44px; height: 44px;
      background: #f0fdf9;
      border-radius: 10px;
      display: flex; align-items: center; justify-content: center;
      color: #0f766e;
      font-size: 1.3rem;
      flex-shrink: 0;
    }
    .quick-nav-card .qnc-label { font-weight: 700; font-size: 0.95rem; }
    .quick-nav-card .qnc-sub   { font-size: 0.8rem; color: #6b7280; }

    /* Upcoming list */
    .upcoming-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 14px 18px;
      border: 1.5px solid #f3f4f6;
      border-radius: 12px;
      background: #fafafa;
      margin-bottom: 10px;
    }
    .upcoming-item:last-child { margin-bottom: 0; }
    .upcoming-item .ui-name { font-weight: 600; font-size: 0.95rem; color: #111827; }
    .upcoming-item .ui-prog { font-size: 0.82rem; color: #6b7280; margin-top: 1px; }
    .upcoming-item .ui-date { font-size: 0.85rem; font-weight: 600; color: #374151; text-align: right; }
    .upcoming-item .ui-time { font-size: 0.8rem; color: #9ca3af; text-align: right; }

    /* stat card sizes fit within stats-grid */
    .stats-grid .card-stat small { font-size: 0.82rem; }

    .approval-alert {
      background: #fffbeb;
      border-left: 5px solid #f59e0b;
      border-radius: 12px;
      padding: 14px 18px;
      margin-bottom: 20px;
      box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }
    .approval-row {
      display: flex;
      gap: 12px;
      align-items: center;
      justify-content: space-between;
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      padding: 10px 14px;
      margin-top: 10px;
    }
    .approval-row .meta {
      font-size: 0.8rem;
      color: #6b7280;
      margin-top: 2px;
    }
  </style>
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
            <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/DeanDashboardServlet">
              <span class="nav-icon"><i class="bi bi-speedometer2" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">Dean Dashboard</span>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#vivaMenu" role="button" aria-expanded="false" aria-controls="vivaMenu">
              <span><span class="nav-icon"><i class="bi bi-collection" style="font-size:17px;color:#0f766e;"></i></span> Viva Overview</span>
              <span class="small">&#9662;</span>
            </a>
            <div class="collapse" id="vivaMenu">
              <ul class="nav flex-column ms-3 mt-2">
                <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/CandidateListServlet"><span class="sub-icon"><i class="bi bi-people"></i></span> Viva Candidates</a></li>
                <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/AppointmentListServlet"><span class="sub-icon"><i class="bi bi-calendar3"></i></span> Viva Appointments</a></li>
              </ul>
            </div>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#deanNominationMenu" role="button" aria-expanded="false" aria-controls="deanNominationMenu">
              <span><span class="nav-icon"><i class="bi bi-file-earmark-text" style="font-size:17px;color:#0f766e;"></i></span> Examiner Nomination</span>
              <span class="small">&#9662;</span>
            </a>
            <div class="collapse" id="deanNominationMenu">
              <ul class="nav flex-column ms-3 mt-2">
                <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/MyNominationsServlet"><span class="sub-icon"><i class="bi bi-file-earmark-text"></i></span> My Nominations</a></li>
                <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/SubmitNominationServlet"><span class="sub-icon"><i class="bi bi-plus-circle"></i></span> Submit New Nomination</a></li>
              </ul>
            </div>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/dean/examiners">
              <span class="nav-icon"><i class="bi bi-person-lines-fill" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">Examiner Directory</span>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/dean/appointment/letterApprovals.jsp">
              <span class="nav-icon"><i class="bi bi-pen-fill" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">Letter Approvals</span>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/academician/my-appointments">
              <span class="nav-icon"><i class="bi bi-calendar-check" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">My Appointments</span>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/dean/my-students-viva">
              <span class="nav-icon"><i class="bi bi-people-fill" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">My Students' Viva</span>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link menu-item d-flex justify-content-between align-items-center" data-bs-toggle="collapse" href="#reportsMenu" role="button" aria-expanded="false" aria-controls="reportsMenu">
              <span><span class="nav-icon"><i class="bi bi-bar-chart-line" style="font-size:17px;color:#0f766e;"></i></span> Reports &amp; Statistics</span>
              <span class="small">&#9662;</span>
            </a>
            <div class="collapse" id="reportsMenu">
              <ul class="nav flex-column ms-3 mt-2">
                <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/dean/reports/appointments"><span class="sub-icon"><i class="bi bi-bar-chart"></i></span> Appointment Statistics</a></li>
                <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/UnverifiedReportServlet"><span class="sub-icon"><i class="bi bi-exclamation-circle"></i></span> Unverified Nominations</a></li>
              </ul>
            </div>
          </li>
        </ul>
      </div>
      <div class="sidebar-profile">
        <%
          String[] _dp = fullName.trim().split("\\s+");
          String _dini = _dp.length == 1 ? String.valueOf(_dp[0].charAt(0)).toUpperCase()
                       : (String.valueOf(_dp[0].charAt(0)) + String.valueOf(_dp[_dp.length-1].charAt(0))).toUpperCase();
        %>
        <a href="<%= request.getContextPath() %>/ProfileServlet" class="profile-box" style="color:#111827;">
          <div class="profile-avatar"><%= _dini %></div>
          <div class="profile-info">
            <strong><%= fullName %></strong>
            <span>My Profile</span>
          </div>
          <i class="bi bi-gear ms-auto" style="font-size:0.9rem;color:#9ca3af;"></i>
        </a>
      </div>
    </nav>

    <!-- MAIN CONTENT -->
    <main class="content">

      <div class="mb-3" style="margin-bottom:32px !important;">
        <h1 class="h3">Dean Dashboard</h1>
        <p class="text-muted">Welcome back, <strong><%= displayName %></strong>! Here's your faculty overview.</p>
      </div>

      <!-- STAT CARDS -->
      <div class="stats-grid">
        <div class="card-stat teal">
          <div class="d-flex justify-content-between align-items-center">
            <div>
              <small class="text-muted">Total Viva Candidates</small>
              <div class="value mt-2"><%= stats.getOrDefault("totalCandidates", 0) %></div>
            </div>
            <div class="stat-icon fill-teal">
              <i class="bi bi-people" style="font-size:1.7rem;"></i>
            </div>
          </div>
        </div>
        <div class="card-stat yellow">
          <div class="d-flex justify-content-between align-items-center">
            <div>
              <small class="text-muted">Upcoming Appointments</small>
              <div class="value mt-2"><%= stats.getOrDefault("upcomingAppointments", 0) %></div>
            </div>
            <div class="stat-icon fill-yellow">
              <i class="bi bi-calendar-event" style="font-size:1.7rem;"></i>
            </div>
          </div>
        </div>
        <div class="card-stat green">
          <div class="d-flex justify-content-between align-items-center">
            <div>
              <small class="text-muted">Completed This Month</small>
              <div class="value mt-2"><%= stats.getOrDefault("completedThisMonth", 0) %></div>
            </div>
            <div class="stat-icon fill-green">
              <i class="bi bi-check-circle" style="font-size:1.7rem;"></i>
            </div>
          </div>
        </div>
        <div class="card-stat red">
          <div class="d-flex justify-content-between align-items-center">
            <div>
              <small class="text-muted">Pending Decisions</small>
              <div class="value mt-2"><%= stats.getOrDefault("pendingDecisions", 0) %></div>
            </div>
            <div class="stat-icon fill-red">
              <i class="bi bi-clock" style="font-size:1.7rem;"></i>
            </div>
          </div>
        </div>
      </div>

      <%-- ── Nomination Corrections Alert ───────────────────────────────── --%>
      <% if (!deanCorrections.isEmpty()) { %>
      <div style="background:#fff3f3;border:1.5px solid #fca5a5;border-radius:14px;padding:14px 16px;margin-bottom:20px;">
        <div class="fw-bold mb-2" style="color:#991b1b;font-size:0.92rem;">
          <i class="bi bi-exclamation-circle me-1" style="color:#ef4444;"></i>
          Nominations Requiring Your Attention (<%= deanCorrections.size() %>)
        </div>
        <% for (Nomination dc : deanCorrections) { %>
        <div class="d-flex align-items-start justify-content-between gap-2 mb-2 p-2"
             style="background:#fff;border:1px solid #fca5a5;border-radius:10px;">
          <div>
            <div class="fw-semibold" style="color:#111827;font-size:0.92rem;">
              Nomination for <%= dc.getExaminerName() != null ? dc.getExaminerName() : "—" %>
            </div>
            <% if (dc.getDiscrepancyNotes() != null && !dc.getDiscrepancyNotes().isEmpty()) { %>
            <div style="font-size:0.82rem;color:#92400e;">
              <i class="bi bi-person-exclamation me-1"></i>Examiner reported: <%= dc.getDiscrepancyNotes() %>
            </div>
            <% } else if (dc.getRemarks() != null && !dc.getRemarks().isEmpty()) { %>
            <div style="font-size:0.82rem;color:#6b7280;">
              <i class="bi bi-shield-exclamation me-1"></i>Admin feedback: <%= dc.getRemarks() %>
            </div>
            <% } %>
          </div>
          <a href="<%= request.getContextPath() %>/EditNominationServlet?id=<%= dc.getId() %>"
             class="ea-btn-primary d-flex align-items-center gap-1 flex-shrink-0"
             style="text-decoration:none;border-radius:9px;padding:6px 14px;font-size:0.85rem;white-space:nowrap;">
            <i class="bi bi-pencil-square"></i> Edit
          </a>
        </div>
        <% } %>
      </div>
      <% } %>

      <%-- ── Letter Approvals Alert Block ──────────────────────────────── --%>
      <% if (!pendingApprovals.isEmpty()) { %>
      <div class="approval-alert">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-2">
          <div>
            <div class="fw-bold" style="color:#92400e;">
              <i class="bi bi-hourglass-split me-1" style="color:#d97706;"></i>
              Action Required: Letter Approvals Pending
            </div>
            <div style="font-size:0.88rem;color:#78350f;">
              You have <strong><%= pendingApprovals.size() %></strong> appointment letter(s) awaiting your signature.
            </div>
          </div>
        </div>

        <%
          java.text.SimpleDateFormat reqFmt = new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a");
          reqFmt.setTimeZone(java.util.TimeZone.getTimeZone("Asia/Kuala_Lumpur"));
          for (Map<String,Object> pa : pendingApprovals) {
            int apptId = ((Number) pa.get("appointment_id")).intValue();
            Object reqAtObj = pa.get("requested_at");
            String reqAt = reqAtObj instanceof java.util.Date ? reqFmt.format((java.util.Date) reqAtObj) : "-";
        %>
        <div class="approval-row">
          <div>
            <div class="fw-semibold" style="color:#111827;font-size:0.93rem;"><%= pa.get("candidate_name") %> (<%= pa.get("student_id") %>)</div>
            <div class="meta">Programme: <%= pa.get("candidate_program") != null ? pa.get("candidate_program") : "-" %> &nbsp;|&nbsp; Requested: <%= reqAt %></div>
          </div>
          <a class="ea-btn-teal-outline" href="<%= request.getContextPath() %>/appointment/letter/review?id=<%= apptId %>">
            <i class="bi bi-eye"></i>Review &amp; Sign
          </a>
        </div>
        <%   }   %>
      </div>
      <% } %>

      <%-- ── Signed Approvals — Admin Sending Progress ─────────────────── --%>
      <% if (!signedApprovals.isEmpty()) { %>
      <div style="background:#fff;border:1.5px solid #e5e7eb;border-radius:14px;padding:14px 16px;margin-bottom:20px;">
        <div class="fw-bold mb-2" style="color:#111827;font-size:0.92rem;">
          <i class="bi bi-envelope-arrow-up me-1" style="color:#2563eb;"></i>
          Letters You Signed — Admin Sending Progress
        </div>
        <% java.text.SimpleDateFormat signFmt = new java.text.SimpleDateFormat("dd MMM yyyy");
           signFmt.setTimeZone(java.util.TimeZone.getTimeZone("Asia/Kuala_Lumpur"));
           for (Map<String,Object> sa : signedApprovals) {
             int apptId2 = ((Number) sa.get("appointment_id")).intValue();
             int totalPanel = sa.get("total_panel") instanceof Number ? ((Number) sa.get("total_panel")).intValue() : 0;
             int sentPanel  = sa.get("sent_panel")  instanceof Number ? ((Number) sa.get("sent_panel")).intValue()  : 0;
             Object signedAtObj = sa.get("signed_at");
             String signedAtStr = signedAtObj instanceof java.util.Date ? signFmt.format((java.util.Date) signedAtObj) : "-";
             boolean allSent = totalPanel > 0 && sentPanel == totalPanel;
        %>
        <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;padding:9px 12px;background:<%= allSent ? "#f0fdf4" : "#f8fafc" %>;border:1px solid <%= allSent ? "#bbf7d0" : "#f3f4f6" %>;border-radius:10px;margin-bottom:8px;flex-wrap:wrap;">
          <div>
            <div style="font-size:0.88rem;font-weight:600;color:#111827;"><%= sa.get("candidate_name") %> (<%= sa.get("student_id") %>)</div>
            <div style="font-size:0.78rem;color:#6b7280;margin-top:1px;">Signed by you on <%= signedAtStr %></div>
          </div>
          <div style="display:flex;align-items:center;gap:10px;flex-shrink:0;">
            <span style="font-size:0.83rem;font-weight:700;padding:4px 12px;border-radius:20px;
                         background:<%= allSent ? "#dcfce7" : "#eff6ff" %>;
                         color:<%= allSent ? "#15803d" : "#1d4ed8" %>;">
              <i class="bi bi-envelope-<%= allSent ? "check-fill" : "arrow-up" %> me-1"></i>
              <%= sentPanel %>/<%= totalPanel %> sent
            </span>
            <a href="<%= request.getContextPath() %>/appointment/letter/review?id=<%= apptId2 %>"
               style="font-size:0.78rem;color:#0f766e;text-decoration:none;font-weight:600;">
              View <i class="bi bi-arrow-right"></i>
            </a>
          </div>
        </div>
        <% } %>
      </div>
      <% } %>

      <%-- ── My Panel Appointments Pending Response ──────────────────────── --%>
      <% if (!pendingPanels.isEmpty()) {
           SimpleDateFormat panelFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
           panelFmt.setTimeZone(java.util.TimeZone.getTimeZone("Asia/Kuala_Lumpur"));
      %>
      <div style="background:#fffbeb;border-left:5px solid #f59e0b;border-radius:14px;padding:18px 22px;margin-bottom:20px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
        <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
          <div class="d-flex align-items-center gap-2">
            <i class="bi bi-hourglass-split" style="color:#d97706;font-size:1.2rem;"></i>
            <div>
              <div class="fw-bold" style="color:#92400e;font-size:0.97rem;">
                <strong><%= pendingPanels.size() %></strong> Panel Appointment<%= pendingPanels.size() == 1 ? "" : "s" %> Awaiting Your Response
              </div>
              <div style="font-size:0.83rem;color:#b45309;">You have been invited as a viva panel member. Please respond within 7 working days.</div>
            </div>
          </div>
          <a href="<%= request.getContextPath() %>/academician/my-appointments"
             style="background:#f59e0b;color:#fff;border:none;padding:8px 18px;border-radius:9px;font-weight:700;font-size:0.84rem;text-decoration:none;display:inline-flex;align-items:center;gap:6px;white-space:nowrap;">
            View All <i class="bi bi-arrow-right"></i>
          </a>
        </div>
        <% for (Map<String,Object> pp : pendingPanels) {
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
            <div class="fw-semibold" style="font-size:0.92rem;color:#111827;"><%= ppCand %></div>
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

      <div class="row g-4 mb-4">

        <!-- UPCOMING VIVA APPOINTMENTS -->
        <div class="col-12 col-lg-7">
          <div class="card shadow-sm h-100" style="border-radius:16px; border:1.5px solid #f3f4f6;">
            <div class="card-body p-4">
              <h6 class="fw-bold mb-3" style="color:#111827;">
                <i class="bi bi-calendar3 me-2" style="color:#0f766e;"></i>Upcoming Viva Appointments
              </h6>
              <%
                if (upcomingList.isEmpty()) {
              %>
              <p class="text-muted small mb-0">No upcoming appointments found.</p>
              <%
                } else {
                  for (Map<String,Object> item : upcomingList) {
              %>
              <div class="upcoming-item">
                <div>
                  <div class="ui-name"><%= item.get("name") %></div>
                  <div class="ui-prog"><%= item.get("programme") != null ? item.get("programme") : "–" %></div>
                </div>
                <div>
                  <div class="ui-date"><%= item.get("date") %></div>
                  <div class="ui-time"><%= item.get("time") %></div>
                </div>
              </div>
              <%
                  }
                }
              %>
            </div>
          </div>
        </div>

        <!-- VIVA CANDIDATES BY PROGRAMME -->
        <div class="col-12 col-lg-5">
          <div class="card shadow-sm h-100" style="border-radius:16px; border:1.5px solid #f3f4f6;">
            <div class="card-body p-4">
              <h6 class="fw-bold mb-3" style="color:#111827;">
                <i class="bi bi-bar-chart me-2" style="color:#0f766e;"></i>Viva Candidates by Programme
              </h6>
              <%
                if (programmeBreakdown.isEmpty()) {
              %>
              <p class="text-muted small mb-0">No data available.</p>
              <%
                } else {
                  for (Map<String,Object> prog : programmeBreakdown) {
                    int cnt = ((Number) prog.get("count")).intValue();
                    int widthPct = (int) Math.round(cnt * 100.0 / maxProgCount);
              %>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span class="prog-label"><%= prog.get("programme") != null ? prog.get("programme") : "Unknown" %></span>
                  <span class="prog-count"><%= cnt %></span>
                </div>
                <div class="prog-bar-track">
                  <div class="prog-bar-fill" style="width:<%= widthPct %>%;"></div>
                </div>
              </div>
              <%
                  }
                }
              %>
            </div>
          </div>
        </div>

      </div>

      <!-- QUICK NAVIGATION -->
      <div class="row g-3 mb-2">
        <div class="col-12 col-sm-6 col-lg-4">
          <a class="quick-nav-card" href="<%= request.getContextPath() %>/CandidateListServlet">
            <div class="qnc-icon"><i class="bi bi-people"></i></div>
            <div>
              <div class="qnc-label">View Viva Candidates</div>
              <div class="qnc-sub">Review all candidates</div>
            </div>
          </a>
        </div>
        <div class="col-12 col-sm-6 col-lg-4">
          <a class="quick-nav-card" href="<%= request.getContextPath() %>/SubmitNominationServlet">
            <div class="qnc-icon"><i class="bi bi-person-plus"></i></div>
            <div>
              <div class="qnc-label">Add Nomination</div>
              <div class="qnc-sub">Nominate an external examiner</div>
            </div>
          </a>
        </div>
        <div class="col-12 col-sm-6 col-lg-4">
          <a class="quick-nav-card" href="<%= request.getContextPath() %>/dean/reports/appointments">
            <div class="qnc-icon"><i class="bi bi-bar-chart-line"></i></div>
            <div>
              <div class="qnc-label">View Statistics</div>
              <div class="qnc-sub">Access reports &amp; analytics</div>
            </div>
          </a>
        </div>
      </div>

    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    (function(){
      var btn = document.getElementById('sidebarToggleBtn');
      var overlay = document.getElementById('sidebarOverlay');
      if(btn){ btn.addEventListener('click', function(){ document.body.classList.toggle('sidebar-open'); }); }
      if(overlay){ overlay.addEventListener('click', function(){ document.body.classList.remove('sidebar-open'); }); }
    })();

  </script>
</body>
</html>
