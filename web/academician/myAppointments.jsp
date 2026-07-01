<%--
  Academician/Dean: "My Appointments" page as a panel member — shows pending-response
  invitations (with Accept/Decline) and full panel appointment history.
--%>
<%@ page import="java.util.List, java.util.Map, java.text.SimpleDateFormat, java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  if (session == null || session.getAttribute("user_id") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  List<Map<String,Object>> pending = (List<Map<String,Object>>) request.getAttribute("pendingPanels");
  List<Map<String,Object>> all     = (List<Map<String,Object>>) request.getAttribute("allPanels");
  if (pending == null) pending = new java.util.ArrayList<>();
  if (all     == null) all     = new java.util.ArrayList<>();

  SimpleDateFormat dtFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
  Date now = new Date();

  java.util.List<Map<String,Object>> upcoming = new java.util.ArrayList<>();
  java.util.List<Map<String,Object>> history  = new java.util.ArrayList<>();
  for (Map<String,Object> p : all) {
    String resp  = p.get("panel_response") != null ? p.get("panel_response").toString() : "";
    java.sql.Timestamp sched = (java.sql.Timestamp) p.get("scheduled_at");
    boolean future = sched != null && sched.after(now);
    if (!resp.isEmpty()) {
      if ("accepted".equals(resp) && future) upcoming.add(p);
      else history.add(p);
    }
  }
  String roleName = (String) session.getAttribute("role_name");
  boolean isDean  = "Dean".equals(roleName);
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My Appointments - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    body { font-family: 'Inter', Arial, sans-serif; }

    /* Custom tab pills */
    .appt-tabs { display: flex; gap: 6px; border-bottom: 2px solid #e5e7eb; margin-bottom: 24px; }
    .appt-tab  {
      background: none; border: none; padding: 10px 20px 12px;
      font-weight: 600; font-size: 0.93rem; color: #6b7280; cursor: pointer;
      border-bottom: 3px solid transparent; margin-bottom: -2px; transition: color 0.15s;
    }
    .appt-tab.active { color: #0f766e; border-bottom-color: #0f766e; }
    .appt-tab:hover  { color: #0f766e; }
    .appt-panel { display: none; }
    .appt-panel.active { display: block; }

    /* Appointment card */
    .appt-card {
      background: #fff;
      border: 1.5px solid #e5e7eb;
      border-radius: 14px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
      margin-bottom: 14px;
      transition: box-shadow 0.2s, border-color 0.2s;
    }
    .appt-card:hover { box-shadow: 0 6px 20px rgba(15,118,110,0.10); border-color: #a7f3d0; }
    .appt-card-header {
      padding: 11px 20px;
      display: flex; align-items: center; gap: 10px;
      border-bottom: 1px solid #f3f4f6;
    }
    .appt-card-body {
      padding: 18px 20px;
      display: flex; justify-content: space-between; align-items: center; gap: 16px; flex-wrap: wrap;
    }
    .appt-meta { font-size: 0.84rem; color: #6b7280; display: flex; gap: 16px; flex-wrap: wrap; margin-top: 5px; }
    .appt-meta span { display: flex; align-items: center; gap: 5px; }

    /* Stat pill badge */
    .count-pill {
      display: inline-flex; align-items: center; justify-content: center;
      width: 22px; height: 22px; border-radius: 50%;
      font-size: 0.72rem; font-weight: 700; line-height: 1;
    }

    /* Response badge */
    .resp-badge { border-radius: 20px; padding: 4px 12px; font-size: 0.8rem; font-weight: 700; display: inline-flex; align-items: center; gap: 5px; }

    /* Empty state */
    .empty-state { padding: 48px 32px; text-align: center; background: #fff; border: 1px solid #e5e7eb; border-radius: 14px; }
    .empty-state i { font-size: 2.6rem; color: #d1d5db; }
    .empty-state .title { font-weight: 700; color: #6b7280; margin-top: 14px; font-size: 1rem; }
    .empty-state .sub   { font-size: 0.88rem; color: #9ca3af; margin-top: 5px; }

    /* Primary action button */
    .btn-appt-primary {
      background: #fff; color: #0f766e; border: 1.5px solid #0f766e;
      padding: 9px 20px; border-radius: 10px;
      font-weight: 600; font-size: 0.88rem; white-space: nowrap;
      text-decoration: none; display: inline-flex; align-items: center; gap: 7px;
      transition: all 0.15s;
    }
    .btn-appt-primary:hover { background: #f0fdf4; color: #0f766e; }
    .btn-appt-outline {
      background: #fff; color: #0f766e; border: 1.5px solid #0f766e;
      padding: 9px 20px; border-radius: 10px;
      font-weight: 700; font-size: 0.88rem; white-space: nowrap;
      text-decoration: none; display: inline-flex; align-items: center; gap: 7px;
      transition: all 0.15s;
    }
    .btn-appt-outline:hover { background: #f0fdf4; color: #0f766e; }
  </style>
</head>
<body>
  <jsp:include page="/includes/topbar.jsp" />
  <div class="layout ea-layout">
    <% request.setAttribute("activeSection", "myAppointments"); %>
    <% if (isDean) { %>
      <jsp:include page="/dean/sidebar.jsp" />
    <% } else { %>
      <jsp:include page="/academician/sidebar.jsp" />
    <% } %>

    <main class="content ea-content">
      <div class="ea-main-content-centered">

        <!-- Page header -->
        <div class="mb-4">
          <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">My Appointments</h1>
          <div style="font-size:0.97rem;color:#6b7280;">Your viva panel invitations — review letters and confirm participation</div>
        </div>

        <!-- ── Action-required banner ── -->
        <% if (!pending.isEmpty()) { %>
        <div class="d-flex align-items-center justify-content-between gap-3 mb-4 px-4 py-3"
             style="background:#fffbeb;border-left:5px solid #f59e0b;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.05);">
          <div class="d-flex align-items-center gap-3">
            <i class="bi bi-hourglass-split" style="color:#d97706;font-size:1.25rem;flex-shrink:0;"></i>
            <div>
              <div style="font-weight:700;color:#92400e;font-size:0.95rem;">
                <strong><%= pending.size() %></strong> appointment invitation<%= pending.size() == 1 ? "" : "s" %> need your response
              </div>
              <div style="font-size:0.83rem;color:#b45309;">Please respond within 7 working days of receiving the appointment letter.</div>
            </div>
          </div>
          <button onclick="showTab('pending')" style="background:#f59e0b;color:#fff;border:none;padding:8px 18px;border-radius:8px;font-weight:700;font-size:0.84rem;cursor:pointer;white-space:nowrap;">
            View All <i class="bi bi-arrow-right ms-1"></i>
          </button>
        </div>
        <% } %>

        <!-- ── Tabs ── -->
        <div class="appt-tabs">
          <button class="appt-tab active" id="tab-pending" onclick="showTab('pending')">
            Pending Response
            <% if (!pending.isEmpty()) { %>
            <span class="count-pill ms-1" style="background:#f59e0b;color:#fff;"><%= pending.size() %></span>
            <% } %>
          </button>
          <button class="appt-tab" id="tab-upcoming" onclick="showTab('upcoming')">
            Upcoming
            <% if (!upcoming.isEmpty()) { %>
            <span class="count-pill ms-1" style="background:#0f766e;color:#fff;"><%= upcoming.size() %></span>
            <% } %>
          </button>
          <button class="appt-tab" id="tab-history" onclick="showTab('history')">History</button>
        </div>

        <!-- ════ PENDING TAB ════ -->
        <div class="appt-panel active" id="panel-pending">
          <% if (pending.isEmpty()) { %>
          <div class="empty-state">
            <i class="bi bi-check-circle"></i>
            <div class="title">All caught up!</div>
            <div class="sub">No pending invitations. You'll be notified when a new appointment is assigned to you.</div>
          </div>
          <% } else {
               for (Map<String,Object> p : pending) {
                 String panelId = String.valueOf(p.get("panel_id"));
                 String apptId  = String.valueOf(p.get("appointment_id"));
                 String cand    = p.get("candidate_name") != null ? p.get("candidate_name").toString() : "—";
                 String matric  = p.get("student_id")    != null ? p.get("student_id").toString()    : "";
                 String prog    = p.get("candidate_program") != null ? p.get("candidate_program").toString() : "";
                 String role0   = p.get("member_role")   != null ? p.get("member_role").toString()   : "—";
                 String thesis  = p.get("thesis_title")  != null ? p.get("thesis_title").toString()  : "";
                 java.sql.Timestamp sched = (java.sql.Timestamp) p.get("scheduled_at");
                 String schedLabel = sched != null ? dtFmt.format(sched) : "Date TBD";
                 String venue0  = p.get("venue") != null ? p.get("venue").toString() : "";
                 boolean letterSent = Boolean.TRUE.equals(p.get("letter_sent"));
          %>
          <div class="appt-card" style="border-left:4px solid #f59e0b;">
            <div class="appt-card-header" style="background:#fffbeb;">
              <i class="bi bi-hourglass-split" style="color:#d97706;font-size:1rem;"></i>
              <span style="font-weight:700;color:#92400e;font-size:0.88rem;">Awaiting Response</span>
              <span style="margin-left:4px;background:#fff;color:#92400e;border:1px solid #fde68a;border-radius:20px;padding:2px 10px;font-size:0.76rem;font-weight:600;"><%= role0 %></span>
              <% if (letterSent) { %>
              <span class="ms-auto" style="background:#dcfce7;color:#15803d;border-radius:20px;padding:2px 10px;font-size:0.76rem;font-weight:600;"><i class="bi bi-envelope-check me-1"></i>Letter Sent</span>
              <% } else { %>
              <span class="ms-auto" style="background:#f3f4f6;color:#9ca3af;border-radius:20px;padding:2px 10px;font-size:0.76rem;font-weight:600;"><i class="bi bi-clock me-1"></i>Letter Pending</span>
              <% } %>
            </div>
            <div class="appt-card-body">
              <div style="flex:1;min-width:0;">
                <div style="font-weight:700;font-size:1rem;color:#111827;margin-bottom:3px;">
                  <%= cand %>
                  <% if (!matric.isEmpty()) { %><span style="font-weight:400;color:#9ca3af;font-size:0.85rem;"> (<%= matric %>)</span><% } %>
                </div>
                <% if (!prog.isEmpty()) { %>
                <div style="color:#374151;font-size:0.87rem;margin-bottom:2px;"><i class="bi bi-mortarboard me-1" style="color:#0f766e;"></i><%= prog %></div>
                <% } %>
                <% if (!thesis.isEmpty()) { %>
                <div style="color:#6b7280;font-size:0.82rem;font-style:italic;margin-bottom:3px;">"<%= thesis %>"</div>
                <% } %>
                <div class="appt-meta">
                  <span><i class="bi bi-calendar-event" style="color:#0f766e;"></i><%= schedLabel %></span>
                  <% if (!venue0.isEmpty()) { %><span><i class="bi bi-geo-alt" style="color:#0f766e;"></i><%= venue0 %></span><% } %>
                </div>
              </div>
              <div style="flex-shrink:0;">
                <a href="<%= request.getContextPath() %>/panel/member/preview?appointment_id=<%= apptId %>&panel_id=<%= panelId %>"
                   class="btn-appt-primary">
                  <i class="bi bi-envelope-open-text"></i>
                  <% if (letterSent) { %>Review &amp; Respond<% } else { %>Preview Letter<% } %>
                </a>
              </div>
            </div>
          </div>
          <% } } %>
        </div>

        <!-- ════ UPCOMING TAB ════ -->
        <div class="appt-panel" id="panel-upcoming">
          <% if (upcoming.isEmpty()) { %>
          <div class="empty-state">
            <i class="bi bi-calendar-x"></i>
            <div class="title">No upcoming appointments</div>
            <div class="sub">Accepted appointments with future viva dates will appear here.</div>
          </div>
          <% } else {
               for (Map<String,Object> p : upcoming) {
                 String panelId = String.valueOf(p.get("panel_id"));
                 String apptId  = String.valueOf(p.get("appointment_id"));
                 String cand    = p.get("candidate_name") != null ? p.get("candidate_name").toString() : "—";
                 String matric  = p.get("student_id")    != null ? p.get("student_id").toString()    : "";
                 String prog    = p.get("candidate_program") != null ? p.get("candidate_program").toString() : "";
                 String role0   = p.get("member_role")   != null ? p.get("member_role").toString()   : "—";
                 String thesis  = p.get("thesis_title")  != null ? p.get("thesis_title").toString()  : "";
                 java.sql.Timestamp sched = (java.sql.Timestamp) p.get("scheduled_at");
                 String schedLabel = sched != null ? dtFmt.format(sched) : "—";
                 String venue0  = p.get("venue") != null ? p.get("venue").toString() : "";
                 // Days remaining
                 String daysLabel = "";
                 if (sched != null) {
                   long diffMs = sched.getTime() - now.getTime();
                   long diffD  = diffMs / (1000 * 60 * 60 * 24);
                   daysLabel = diffD <= 0 ? "Today" : (diffD == 1 ? "Tomorrow" : "in " + diffD + " days");
                 }
          %>
          <div class="appt-card" style="border-left:4px solid #0f766e;">
            <div class="appt-card-header" style="background:#f0fdf4;">
              <i class="bi bi-calendar-check-fill" style="color:#15803d;font-size:1rem;"></i>
              <span style="font-weight:700;color:#15803d;font-size:0.88rem;">Confirmed — Upcoming</span>
              <span style="margin-left:4px;background:#fff;color:#15803d;border:1px solid #86efac;border-radius:20px;padding:2px 10px;font-size:0.76rem;font-weight:600;"><%= role0 %></span>
              <% if (!daysLabel.isEmpty()) { %>
              <span class="ms-auto" style="background:#0f766e;color:#fff;border-radius:20px;padding:2px 10px;font-size:0.76rem;font-weight:700;"><%= daysLabel %></span>
              <% } %>
            </div>
            <div class="appt-card-body">
              <div style="flex:1;min-width:0;">
                <div style="font-weight:700;font-size:1rem;color:#111827;margin-bottom:3px;">
                  <%= cand %>
                  <% if (!matric.isEmpty()) { %><span style="font-weight:400;color:#9ca3af;font-size:0.85rem;"> (<%= matric %>)</span><% } %>
                </div>
                <% if (!prog.isEmpty()) { %>
                <div style="color:#374151;font-size:0.87rem;margin-bottom:2px;"><i class="bi bi-mortarboard me-1" style="color:#0f766e;"></i><%= prog %></div>
                <% } %>
                <% if (!thesis.isEmpty()) { %>
                <div style="color:#6b7280;font-size:0.82rem;font-style:italic;margin-bottom:3px;">"<%= thesis %>"</div>
                <% } %>
                <div class="appt-meta">
                  <span><i class="bi bi-calendar-event" style="color:#0f766e;"></i><strong><%= schedLabel %></strong></span>
                  <% if (!venue0.isEmpty()) { %><span><i class="bi bi-geo-alt" style="color:#0f766e;"></i><%= venue0 %></span><% } %>
                </div>
              </div>
              <a href="<%= request.getContextPath() %>/panel/member/preview?appointment_id=<%= apptId %>&panel_id=<%= panelId %>"
                 class="btn-appt-outline" style="flex-shrink:0;">
                <i class="bi bi-file-earmark-text"></i> View Letter
              </a>
            </div>
          </div>
          <% } } %>
        </div>

        <!-- ════ HISTORY TAB ════ -->
        <div class="appt-panel" id="panel-history">
          <% if (history.isEmpty()) { %>
          <div class="empty-state">
            <i class="bi bi-archive"></i>
            <div class="title">No history yet</div>
            <div class="sub">Past and responded appointments will be listed here.</div>
          </div>
          <% } else { %>
          <div style="background:#fff;border:1px solid #e5e7eb;border-radius:14px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <table style="width:100%;border-collapse:collapse;font-size:0.9rem;">
              <thead>
                <tr style="background:#f9fafb;border-bottom:2px solid #e5e7eb;">
                  <th style="padding:13px 18px;text-align:left;font-weight:700;color:#374151;font-size:0.82rem;text-transform:uppercase;letter-spacing:.04em;">Candidate</th>
                  <th style="padding:13px 18px;text-align:left;font-weight:700;color:#374151;font-size:0.82rem;text-transform:uppercase;letter-spacing:.04em;">Programme</th>
                  <th style="padding:13px 18px;text-align:left;font-weight:700;color:#374151;font-size:0.82rem;text-transform:uppercase;letter-spacing:.04em;">Role</th>
                  <th style="padding:13px 18px;text-align:left;font-weight:700;color:#374151;font-size:0.82rem;text-transform:uppercase;letter-spacing:.04em;">Viva Date</th>
                  <th style="padding:13px 18px;text-align:center;font-weight:700;color:#374151;font-size:0.82rem;text-transform:uppercase;letter-spacing:.04em;">Response</th>
                  <th style="padding:13px 18px;text-align:center;font-weight:700;color:#374151;font-size:0.82rem;text-transform:uppercase;letter-spacing:.04em;"></th>
                </tr>
              </thead>
              <tbody>
                <% for (Map<String,Object> p : history) {
                     String panelId = String.valueOf(p.get("panel_id"));
                     String apptId  = String.valueOf(p.get("appointment_id"));
                     String cand    = p.get("candidate_name") != null ? p.get("candidate_name").toString() : "—";
                     String matric  = p.get("student_id")    != null ? p.get("student_id").toString()    : "";
                     String prog    = p.get("candidate_program") != null ? p.get("candidate_program").toString() : "—";
                     String role0   = p.get("member_role")   != null ? p.get("member_role").toString()   : "—";
                     String resp    = p.get("panel_response") != null ? p.get("panel_response").toString() : "—";
                     java.sql.Timestamp sched = (java.sql.Timestamp) p.get("scheduled_at");
                     String schedLabel = sched != null ? dtFmt.format(sched) : "—";
                     boolean isAccepted = "accepted".equals(resp);
                     boolean isDeclined = "declined".equals(resp);
                %>
                <tr style="border-bottom:1px solid #f3f4f6;">
                  <td style="padding:13px 18px;">
                    <div style="font-weight:600;color:#111827;"><%= cand %></div>
                    <% if (!matric.isEmpty()) { %><div style="color:#9ca3af;font-size:0.78rem;"><%= matric %></div><% } %>
                  </td>
                  <td style="padding:13px 18px;color:#374151;max-width:180px;white-space:normal;font-size:0.88rem;"><%= prog %></td>
                  <td style="padding:13px 18px;color:#374151;white-space:nowrap;font-size:0.88rem;"><%= role0 %></td>
                  <td style="padding:13px 18px;color:#374151;white-space:nowrap;font-size:0.85rem;"><%= schedLabel %></td>
                  <td style="padding:13px 18px;text-align:center;">
                    <% if (isAccepted) { %>
                    <span class="resp-badge" style="background:#dcfce7;color:#15803d;"><i class="bi bi-check-circle-fill"></i>Accepted</span>
                    <% } else if (isDeclined) { %>
                    <span class="resp-badge" style="background:#fee2e2;color:#b91c1c;"><i class="bi bi-x-circle-fill"></i>Declined</span>
                    <% } else { %>
                    <span class="resp-badge" style="background:#f3f4f6;color:#6b7280;"><%= resp %></span>
                    <% } %>
                  </td>
                  <td style="padding:13px 18px;text-align:center;">
                    <a href="<%= request.getContextPath() %>/panel/member/preview?appointment_id=<%= apptId %>&panel_id=<%= panelId %>"
                       class="btn-appt-outline" style="padding:6px 14px;font-size:0.82rem;">
                      <i class="bi bi-eye"></i>View
                    </a>
                  </td>
                </tr>
                <% } %>
              </tbody>
            </table>
          </div>
          <% } %>
        </div>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function showTab(name) {
      document.querySelectorAll('.appt-tab').forEach(function(t) { t.classList.remove('active'); });
      document.querySelectorAll('.appt-panel').forEach(function(p) { p.classList.remove('active'); });
      var tab   = document.getElementById('tab-' + name);
      var panel = document.getElementById('panel-' + name);
      if (tab)   tab.classList.add('active');
      if (panel) panel.classList.add('active');
    }
    <% if (!pending.isEmpty()) { %>
    document.addEventListener('DOMContentLoaded', function() { showTab('pending'); });
    <% } %>
  </script>
</body>
</html>
