<%-- Dean sidebar fragment --%>
<%@ page pageEncoding="UTF-8" %>
<%
  String active = (String) request.getAttribute("activeSection");
  if (active == null) active = "";
  boolean isDeanNominationSection = "myNominations".equals(active) || "submitNomination".equals(active);
  boolean isReportsSection = "reports".equals(active);
  boolean isVivaSection    = "viva".equals(active);
%>
<nav class="sidebar" id="mainSidebar">
  <div class="sidebar-menu">
    <ul class="nav flex-column">

      <!-- Dean Dashboard (always shown) -->
      <li class="nav-item">
        <a class="nav-link menu-item d-flex align-items-center" href="<%= request.getContextPath() %>/DeanDashboardServlet">
          <span class="nav-icon"><i class="bi bi-speedometer2" style="font-size:17px;color:#0f766e;"></i></span>
          <span class="ms-2">Dean Dashboard</span>
        </a>
      </li>

      <% if (isVivaSection) { %>
      <!-- Viva Overview (expanded) -->
      <li class="nav-item">
        <a class="nav-link menu-item active d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#vivaMenu" role="button"
           aria-expanded="true" aria-controls="vivaMenu">
          <span>
            <span class="nav-icon"><i class="bi bi-collection" style="font-size:17px;color:#0f766e;"></i></span>
            Viva Overview
          </span>
          <span class="small">&#9662;</span>
        </a>
        <div class="collapse show" id="vivaMenu">
          <ul class="nav flex-column ms-3 mt-2">
            <li class="nav-item">
              <a class="sub-link" href="<%= request.getContextPath() %>/CandidateListServlet">
                <span class="sub-icon"><i class="bi bi-people"></i></span> Viva Candidates
              </a>
            </li>
            <li class="nav-item">
              <a class="sub-link" href="<%= request.getContextPath() %>/AppointmentListServlet">
                <span class="sub-icon"><i class="bi bi-calendar3"></i></span> Viva Appointments
              </a>
            </li>
          </ul>
        </div>
      </li>

      <% } else if (isDeanNominationSection) { %>
      <!-- Examiner Nomination (expanded) -->
      <li class="nav-item">
        <a class="nav-link menu-item active d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#deanNominationMenu" role="button"
           aria-expanded="true" aria-controls="deanNominationMenu">
          <span>
            <span class="nav-icon"><i class="bi bi-file-earmark-text" style="font-size:17px;color:#0f766e;"></i></span>
            Examiner Nomination
          </span>
          <span class="small">&#9662;</span>
        </a>
        <div class="collapse show" id="deanNominationMenu">
          <ul class="nav flex-column ms-3 mt-2">
            <li class="nav-item">
              <a class="sub-link" href="<%= request.getContextPath() %>/MyNominationsServlet">
                <span class="sub-icon"><i class="bi bi-file-earmark-text"></i></span> My Nominations
              </a>
            </li>
            <li class="nav-item">
              <a class="sub-link" href="<%= request.getContextPath() %>/SubmitNominationServlet">
                <span class="sub-icon"><i class="bi bi-plus-circle"></i></span> Submit New Nomination
              </a>
            </li>
          </ul>
        </div>
      </li>

      <% } else if ("examinerList".equals(active)) { %>
      <!-- Examiner Directory -->
      <li class="nav-item">
        <a class="nav-link menu-item d-flex align-items-center active"
           href="<%= request.getContextPath() %>/dean/examiners">
          <span class="nav-icon"><i class="bi bi-person-lines-fill" style="font-size:17px;color:#0f766e;"></i></span>
          <span class="ms-2">Examiner Directory</span>
        </a>
      </li>

      <% } else if ("letterApprovals".equals(active)) { %>
      <!-- Letter Approvals -->
      <li class="nav-item">
        <a class="nav-link menu-item d-flex align-items-center active"
           href="<%= request.getContextPath() %>/dean/appointment/letterApprovals.jsp">
          <span class="nav-icon"><i class="bi bi-pen-fill" style="font-size:17px;color:#0f766e;"></i></span>
          <span class="ms-2">Letter Approvals</span>
        </a>
      </li>

      <% } else if ("myAppointments".equals(active)) { %>
      <!-- My Appointments -->
      <li class="nav-item">
        <a class="nav-link menu-item d-flex align-items-center active"
           href="<%= request.getContextPath() %>/academician/my-appointments">
          <span class="nav-icon"><i class="bi bi-calendar-check" style="font-size:17px;color:#0f766e;"></i></span>
          <span class="ms-2">My Appointments</span>
        </a>
      </li>

      <% } else if ("myStudentsViva".equals(active)) { %>
      <!-- My Students' Viva -->
      <li class="nav-item">
        <a class="nav-link menu-item d-flex align-items-center active"
           href="<%= request.getContextPath() %>/dean/my-students-viva">
          <span class="nav-icon"><i class="bi bi-people-fill" style="font-size:17px;color:#0f766e;"></i></span>
          <span class="ms-2">My Students' Viva</span>
        </a>
      </li>

      <% } else if (isReportsSection) { %>
      <!-- Reports & Statistics (expanded) -->
      <li class="nav-item">
        <a class="nav-link menu-item active d-flex justify-content-between align-items-center"
           data-bs-toggle="collapse" href="#reportsMenu" role="button"
           aria-expanded="true" aria-controls="reportsMenu">
          <span>
            <span class="nav-icon"><i class="bi bi-bar-chart-line" style="font-size:17px;color:#0f766e;"></i></span>
            Reports &amp; Statistics
          </span>
          <span class="small">&#9662;</span>
        </a>
        <div class="collapse show" id="reportsMenu">
          <ul class="nav flex-column ms-3 mt-2">
            <li class="nav-item">
              <a class="sub-link" href="<%= request.getContextPath() %>/dean/reports/appointments">
                <span class="sub-icon"><i class="bi bi-bar-chart"></i></span> Appointment Statistics
              </a>
            </li>
            <li class="nav-item">
              <a class="sub-link" href="<%= request.getContextPath() %>/UnverifiedReportServlet">
                <span class="sub-icon"><i class="bi bi-exclamation-circle"></i></span> Unverified Nominations
              </a>
            </li>
          </ul>
        </div>
      </li>
      <% } %>

    </ul>
  </div>

  <!-- Profile footer -->
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
