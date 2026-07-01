<%-- Shared admin sidebar fragment - matches dashboard nav style --%>
<%@ page pageEncoding="UTF-8" %>
<%
  String active = (String) request.getAttribute("activeSection");
%>
<nav class="sidebar" id="mainSidebar">
  <div class="sidebar-menu">
    <ul class="nav flex-column">

      <!-- Back to Dashboard (always shown on sub-pages) -->
      <li class="nav-item">
        <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/admin/adminDashboard.jsp">
          <span class="nav-icon"><i class="bi bi-speedometer2" style="font-size:17px;color:#0f766e;"></i></span>
          <span class="ms-2">Back to Dashboard</span>
        </a>
      </li>

      <% if ("users".equals(active)) { %>
      <!-- User Management (expanded) -->
      <li class="nav-item">
        <a class="nav-link menu-item active d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#usersMenu" role="button"
           aria-expanded="true" aria-controls="usersMenu">
          <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zM6 20v-1c0-2.21 3.58-4 6-4s6 1.79 6 4v1H6z" fill="currentColor"/></svg></span> User Management</span>
          <span class="small">&#9662;</span>
        </a>
        <div class="collapse show" id="usersMenu">
          <ul class="nav flex-column ms-3 mt-2">
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/UserListServlet"><span class="sub-icon"><i class="bi bi-people"></i></span> Manage Users</a></li>
          </ul>
        </div>
      </li>

      <% } else if ("academicstaff".equals(active)) { %>
      <!-- Academic Staff Records (expanded) -->
      <li class="nav-item">
        <a class="nav-link menu-item active d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#academicStaffMenu" role="button"
           aria-expanded="true" aria-controls="academicStaffMenu">
          <span><span class="nav-icon"><i class="bi bi-mortarboard" style="font-size:17px;color:#0f766e;"></i></span> Academic Staff Records</span>
          <span class="small">&#9662;</span>
        </a>
        <div class="collapse show" id="academicStaffMenu">
          <ul class="nav flex-column ms-3 mt-2">
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/academician/academicStaffList.jsp"><span class="sub-icon"><i class="bi bi-people"></i></span> View Academic Staff</a></li>
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/academician/addAcademicStaff.jsp"><span class="sub-icon"><i class="bi bi-person-plus"></i></span> Add / Update Staff Info</a></li>
          </ul>
        </div>
      </li>

      <% } else if ("viva".equals(active)) { %>
      <!-- Viva Candidates (expanded) -->
      <li class="nav-item">
        <a class="nav-link menu-item active d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#vivaMenu" role="button"
           aria-expanded="true" aria-controls="vivaMenu">
          <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5" fill="currentColor"/></svg></span> Viva Candidates</span>
          <span class="small">&#9662;</span>
        </a>
        <div class="collapse show" id="vivaMenu">
          <ul class="nav flex-column ms-3 mt-2">
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/CandidateListServlet"><span class="sub-icon"><i class="bi bi-list-ul"></i></span> View Viva Candidates</a></li>
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/viva/addVivaCandidate.jsp"><span class="sub-icon"><i class="bi bi-person-plus"></i></span> Add / Update Viva Candidate</a></li>
          </ul>
        </div>
      </li>

      <% } else if ("examiner".equals(active)) { %>
      <!-- Examiner Management (expanded) -->
      <li class="nav-item">
        <a class="nav-link menu-item active d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#examinerMenu" role="button"
           aria-expanded="true" aria-controls="examinerMenu">
          <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M12 2a7 7 0 0 0-7 7v2H3v6h18v-6h-2V9a7 7 0 0 0-7-7z" fill="currentColor"/></svg></span> Examiner Management</span>
          <span class="small">&#9662;</span>
        </a>
        <div class="collapse show" id="examinerMenu">
          <ul class="nav flex-column ms-3 mt-2">
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/NominationListServlet"><span class="sub-icon"><i class="bi bi-clipboard-check"></i></span> Examiner Nominations</a></li>
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/VerifiedExaminerServlet"><span class="sub-icon"><i class="bi bi-search"></i></span> Search Verified Examiners</a></li>
          </ul>
        </div>
      </li>

      <% } else if ("nomination".equals(active)) { %>
      <!-- Viva Nomination & Appointment (expanded) -->
      <li class="nav-item">
        <a class="nav-link menu-item active d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#nominationMenu" role="button"
           aria-expanded="true" aria-controls="nominationMenu">
          <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M7 10l5 5 5-5H7z" fill="currentColor"/></svg></span> Viva Nomination &amp; Appointment</span>
          <span class="small">&#9662;</span>
        </a>
        <div class="collapse show" id="nominationMenu">
          <ul class="nav flex-column ms-3 mt-2">
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/appointments"><span class="sub-icon"><i class="bi bi-calendar3"></i></span> Viva Appointment List</a></li>
          </ul>
        </div>
      </li>

      <% } else if ("reports".equals(active)) { %>
      <!-- Reports & Statistics (expanded) -->
      <li class="nav-item">
        <a class="nav-link menu-item active d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#reportsMenu" role="button"
           aria-expanded="true" aria-controls="reportsMenu">
          <span><span class="nav-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M3 13h2v-2H3v2zm4 0h14v-2H7v2zM3 8h2V6H3v2z" fill="currentColor"/></svg></span> Reports &amp; Statistics</span>
          <span class="small">&#9662;</span>
        </a>
        <div class="collapse show" id="reportsMenu">
          <ul class="nav flex-column ms-3 mt-2">
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/reports/appointments"><span class="sub-icon"><i class="bi bi-bar-chart"></i></span> Appointment Statistics</a></li>
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/UnverifiedReportServlet?from=reports"><span class="sub-icon"><i class="bi bi-exclamation-circle"></i></span> Unverified Nominations</a></li>
            <li class="nav-item"><a class="sub-link" href="<%= request.getContextPath() %>/admin/reports/exportPage"><span class="sub-icon"><i class="bi bi-download"></i></span> Export Reports</a></li>
          </ul>
        </div>
      </li>
      <% } %>

    </ul>
  </div>

  <!-- Profile footer — pinned at bottom by sidebar-profile flex-shrink:0 -->
  <div class="sidebar-profile">
    <%
      String _sn = (String) session.getAttribute("full_name");
      if (_sn == null || _sn.trim().isEmpty()) _sn = "U";
      String[] _p = _sn.trim().split("\\s+");
      String _ini = _p.length == 1 ? String.valueOf(_p[0].charAt(0)).toUpperCase()
                  : (String.valueOf(_p[0].charAt(0)) + String.valueOf(_p[_p.length-1].charAt(0))).toUpperCase();
    %>
    <a href="<%= request.getContextPath() %>/ProfileServlet" class="profile-box"
       style="color:<%= "profile".equals(active) ? "#0f766e" : "#111827" %>;">
      <div class="profile-avatar"><%= _ini %></div>
      <div class="profile-info">
        <strong><%= _sn %></strong>
        <span>My Profile</span>
      </div>
      <i class="bi bi-gear ms-auto" style="font-size:0.9rem;color:#9ca3af;"></i>
    </a>
  </div>
</nav>
<script>
(function(){
  if(document.getElementById('sidebarOverlay')) return;
  var overlay = document.createElement('div');
  overlay.id = 'sidebarOverlay';
  overlay.className = 'sidebar-overlay';
  overlay.onclick = function(){ document.body.classList.remove('sidebar-open'); };
  document.body.insertBefore(overlay, document.body.firstChild);
  var topbar = document.querySelector('.topbar');
  if(topbar && !document.getElementById('sidebarToggleBtn')){
    var btn = document.createElement('button');
    btn.id = 'sidebarToggleBtn';
    btn.className = 'sidebar-toggle';
    btn.setAttribute('aria-label','Toggle navigation');
    btn.innerHTML = '<i class="bi bi-list"></i>';
    btn.onclick = function(){ document.body.classList.toggle('sidebar-open'); };
    topbar.insertBefore(btn, topbar.firstChild);
  }
})();
</script>
