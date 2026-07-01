<%-- Shared user profile page (Academician/Dean/Admin): edit name, email, phone, optional password, and academic details. --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.User" %>
<%
    if (session == null || session.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String role = (String) session.getAttribute("role_name");
    if (role == null) {
      response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    String sessionRole = role;
    String displayRole = sessionRole;
    if ("System Administrator".equals(sessionRole) || "Administrator".equalsIgnoreCase(sessionRole) || "System Admin".equalsIgnoreCase(sessionRole)) {
      displayRole = "Admin";
    }

    User u       = (User) request.getAttribute("profileUser");
    String error        = (String) request.getAttribute("error");
    String success      = request.getParameter("success");
    String emailChanged = request.getParameter("emailChanged");

    String fName  = u != null && u.getFullName() != null ? u.getFullName() : "";
    String fEmail = u != null && u.getEmail()    != null ? u.getEmail()    : "";
    String fPhone = u != null && u.getPhone()    != null ? u.getPhone()    : "";
    String fRole  = u != null && u.getRoleName() != null ? u.getRoleName() : role;
    String joined = u != null && u.getCreatedAt() != null
                    ? new java.text.SimpleDateFormat("dd MMM yyyy").format(u.getCreatedAt()) : "—";

    // Avatar initials
    String initials = "?";
    if (!fName.trim().isEmpty()) {
        String[] parts = fName.trim().split("\\s+");
        initials = parts.length == 1
            ? String.valueOf(parts[0].charAt(0)).toUpperCase()
            : (String.valueOf(parts[0].charAt(0)) + String.valueOf(parts[parts.length - 1].charAt(0))).toUpperCase();
    }
    request.setAttribute("activeSection", "profile");

    // Resolve acTitle early so it's available throughout the page
    @SuppressWarnings("unchecked")
    java.util.Map<String,Object> _earlyAcStaff = (java.util.Map<String,Object>) request.getAttribute("academicStaff");
    String acTitle = (_earlyAcStaff != null && _earlyAcStaff.get("title") != null) ? (String) _earlyAcStaff.get("title") : "";
    String userTitleName = request.getAttribute("userTitleName") != null ? (String) request.getAttribute("userTitleName") : "";
    @SuppressWarnings("unchecked")
    java.util.List<String> titleOptions = (java.util.List<String>) request.getAttribute("titleOptions");
    if (titleOptions == null) titleOptions = new java.util.ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My Profile - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    .pf-card       { background:#fff; border:1px solid #e5e7eb; border-radius:16px; padding:28px 32px; margin-bottom:20px; }
    .pf-sec-title  { font-size:1rem; font-weight:600; color:#105e60; display:flex; align-items:center; gap:8px; margin-bottom:20px; padding-bottom:10px; border-bottom:1px solid #f3f4f6; }
    .pf-label      { font-size:0.88rem; font-weight:600; color:#374151; margin-bottom:5px; }
    .pf-input      { border:1px solid #d1d5db; border-radius:8px; padding:10px 14px; font-size:0.92rem; width:100%; background:#fff; color:#111827; }
    .pf-input:focus{ outline:none; border-color:#0f766e; box-shadow:0 0 0 3px rgba(15,118,110,0.08); }
    .pf-input[readonly]{ background:#f3f4f6; color:#6b7280; cursor:not-allowed; }
    .pf-avatar     { width:96px; height:96px; border-radius:50%; background:linear-gradient(135deg,#0f766e,#14b8a6); color:#fff; display:flex; align-items:center; justify-content:center; font-size:2.2rem; font-weight:800; flex-shrink:0; }
    .pf-role-badge { display:inline-block; padding:3px 14px; border-radius:20px; font-size:0.82rem; font-weight:600;
                     background:#e5f7f5; color:#0f766e; }
    .pf-hint       { font-size:0.78rem; color:#9ca3af; margin-top:4px; }
    .pf-divider    { border:none; border-top:1px solid #f3f4f6; margin:18px 0; }
    .pw-toggle     { position:absolute; right:12px; top:50%; transform:translateY(-50%); cursor:pointer; color:#9ca3af; background:none; border:none; padding:0; }
    .pw-toggle:hover { color:#374151; }
  </style>
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="sidebar-overlay" id="sidebarOverlay"></div>
  <div class="layout">

    <% if ("Dean".equals(role)) { %>
    <jsp:include page="/dean/sidebar.jsp" />
    <% } else if ("Admin".equals(role)) { %>
    <jsp:include page="/admin/sidebar.jsp" />
    <% } else { %>
    <jsp:include page="/academician/sidebar.jsp" />
    <% } %>

    <main class="content" style="max-width:none;">
      <div style="max-width:1000px;">

        <!-- Page header -->
        <div class="d-flex align-items-center gap-4 mb-4">
          <div class="pf-avatar"><%= initials %></div>
          <div>
            <h1 style="font-size:2.4rem;font-weight:800;color:#105e60;margin-bottom:4px;"><%= (session.getAttribute("staff_title") != null ? session.getAttribute("staff_title") + " " : "") + fName %></h1>
            <div class="d-flex align-items-center gap-2 flex-wrap">
              <span class="pf-role-badge"><%= fRole %></span>
              <span style="font-size:0.85rem;color:#9ca3af;">Member since <%= joined %></span>
            </div>
          </div>
        </div>

        <% if ("1".equals(success)) { %>
        <div class="alert d-flex align-items-center gap-2 mb-3"
             style="background:#ecfdf5;border:1px solid #6ee7b7;border-radius:12px;color:#065f46;padding:14px 18px;">
          <i class="bi bi-check-circle-fill" style="color:#10b981;font-size:1.1rem;flex-shrink:0;"></i>
          Profile updated successfully.
        </div>
        <% } %>
        <% if (error != null) { %>
        <div class="alert d-flex align-items-center gap-2 mb-4"
             style="background:#fef2f2;border:1px solid #fca5a5;border-radius:12px;color:#b91c1c;padding:14px 18px;">
          <i class="bi bi-exclamation-circle-fill" style="font-size:1.1rem;"></i>
          <%= error %>
        </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/ProfileServlet" method="POST" id="profileForm">

          <!-- Section 1: Personal Information -->
          <div class="pf-card">
            <div class="pf-sec-title"><i class="bi bi-person-circle"></i> Personal Information</div>

            <div class="row g-3 mb-3">
              <% if ("Academician".equals(role) || "Dean".equals(role)) { %>
              <div class="col-md-3">
                <div class="pf-label">Title</div>
                <select name="pf_title" class="pf-input" style="appearance:auto;">
                  <option value="">— none —</option>
                  <% for (String t : new String[]{"Dr.","Prof. Dr.","Assoc. Prof. Dr.","Prof.","Mr.","Mrs.","Ms."}) { %>
                  <option value="<%= t %>" <%= t.equals(acTitle) ? "selected" : "" %>><%= t %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-9">
              <% } else if ("Admin".equals(role)) { %>
              <div class="col-md-3">
                <div class="pf-label">Title</div>
                <select name="pf_user_title" class="pf-input" style="appearance:auto;">
                  <option value="">— none —</option>
                  <% for (String t : titleOptions) { %>
                  <option value="<%= t %>" <%= t.equals(userTitleName) ? "selected" : "" %>><%= t %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-9">
              <% } else { %>
              <div class="col-12">
              <% } %>
                <div class="pf-label">Full Name *</div>
                <input type="text" name="fullName" class="pf-input" value="<%= fName %>" required
                       placeholder="e.g. Ahmad bin Abdullah / Nur Farah binti Ahmad">
              </div>
            </div>
            <div class="row g-3 mb-1">
              <div class="col-md-6">
                <div class="pf-label">Email Address *</div>
                <input type="email" name="email" class="pf-input" value="<%= fEmail %>" required
                       placeholder="your@email.com">
                <div class="pf-hint">Used for login</div>
              </div>
              <div class="col-md-6">
                <div class="pf-label">Phone Number</div>
                <input type="tel" name="phone" class="pf-input" value="<%= fPhone %>"
                       placeholder="e.g. +60123456789">
              </div>
            </div>

            <hr class="pf-divider">

            <div class="row g-3 mb-1">
              <div class="col-md-6">
                <div class="pf-label">Role</div>
                <input type="text" class="pf-input" value="<%= fRole %>" readonly>
                <div class="pf-hint">Role is managed by the administrator</div>
              </div>
              <div class="col-md-6">
                <div class="pf-label">Username</div>
                <input type="text" class="pf-input"
                       value="<%= u != null && u.getUsername() != null ? u.getUsername() : "" %>" readonly>
                <div class="pf-hint">Username cannot be changed</div>
              </div>
            </div>
          </div>

          <!-- Section 2: Change Password -->
          <div class="pf-card">
            <div class="pf-sec-title"><i class="bi bi-shield-lock"></i> Change Password
              <span style="font-size:0.82rem;font-weight:400;color:#9ca3af;">(leave blank to keep current password)</span>
            </div>

            <div class="row g-3">
              <div class="col-12">
                <div class="pf-label">Current Password</div>
                <div class="position-relative">
                  <input type="password" name="currentPassword" id="currentPw" class="pf-input"
                         placeholder="Enter your current password" autocomplete="current-password">
                  <button type="button" class="pw-toggle" onclick="togglePw('currentPw','eyeCurrent')">
                    <i class="bi bi-eye" id="eyeCurrent"></i>
                  </button>
                </div>
              </div>
              <div class="col-md-6">
                <div class="pf-label">New Password</div>
                <div class="position-relative">
                  <input type="password" name="newPassword" id="newPw" class="pf-input"
                         placeholder="Minimum 6 characters" autocomplete="new-password">
                  <button type="button" class="pw-toggle" onclick="togglePw('newPw','eyeNew')">
                    <i class="bi bi-eye" id="eyeNew"></i>
                  </button>
                </div>
              </div>
              <div class="col-md-6">
                <div class="pf-label">Confirm New Password</div>
                <div class="position-relative">
                  <input type="password" name="confirmPassword" id="confirmPw" class="pf-input"
                         placeholder="Repeat new password" autocomplete="new-password">
                  <button type="button" class="pw-toggle" onclick="togglePw('confirmPw','eyeConfirm')">
                    <i class="bi bi-eye" id="eyeConfirm"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>

<%
    // Load academic staff record linked to this user (Academician/Dean only)
    java.util.Map<String,Object> acStaff = (java.util.Map<String,Object>) request.getAttribute("academicStaff");
    java.util.List<String> acPrograms  = (java.util.List<String>) request.getAttribute("acPrograms");
    java.util.List<String> acFaculties = (java.util.List<String>) request.getAttribute("acFaculties");
    java.util.List<java.util.Map<String,Object>> acSpecs = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("acSpecs");
    java.util.List<java.util.Map<String,Object>> acExpertise = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("acExpertise");
    java.util.List<java.util.Map<String,Object>> acDivisions = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("acDivisions");
    java.util.List<java.util.Map<String,Object>> acAreas = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("acAreas");
    boolean hasAcademic = acStaff != null && ("Academician".equals(role) || "Dean".equals(role));
    if (acPrograms == null)  acPrograms  = new java.util.ArrayList<>();
    if (acFaculties == null) acFaculties = new java.util.ArrayList<>();
    if (acSpecs == null)     acSpecs     = new java.util.ArrayList<>();
    if (acExpertise == null) acExpertise = new java.util.ArrayList<>();
    if (acDivisions == null) acDivisions = new java.util.ArrayList<>();
    if (acAreas == null)     acAreas     = new java.util.ArrayList<>();

    String acDept  = hasAcademic && acStaff.get("department")     != null ? (String) acStaff.get("department")     : "";
    String acFac   = hasAcademic && acStaff.get("faculty")        != null ? (String) acStaff.get("faculty")        : "";
    String acQual  = hasAcademic && acStaff.get("qualification")  != null ? (String) acStaff.get("qualification")  : "";
    String acRank  = hasAcademic && acStaff.get("academic_rank")  != null ? (String) acStaff.get("academic_rank")  : "";
    // acTitle already declared at top of page
    int    acYears = hasAcademic && acStaff.get("years_experience") != null ? (Integer) acStaff.get("years_experience") : 0;
    Integer acSpecId = hasAcademic && acStaff.get("specialization_id") != null ? (Integer) acStaff.get("specialization_id") : null;
    Integer acExpId  = hasAcademic && acStaff.get("expertise_id")      != null ? (Integer) acStaff.get("expertise_id")      : null;
    Integer acDivId  = hasAcademic && acStaff.get("division_id")       != null ? (Integer) acStaff.get("division_id")       : null;
    Integer acAreaId = hasAcademic && acStaff.get("area_id")           != null ? (Integer) acStaff.get("area_id")           : null;
%>

<% if ("Academician".equals(role) || "Dean".equals(role)) { %>
          <!-- Section 3: Academic Profile -->
          <div class="pf-card">
            <div class="pf-sec-title"><i class="bi bi-mortarboard-fill"></i> Academic Profile</div>

            <% if (!hasAcademic) { %>
            <div class="alert" style="background:#fff7ed;border:1px solid #fed7aa;border-radius:10px;color:#92400e;font-size:0.9rem;padding:12px 16px;">
              <i class="bi bi-exclamation-triangle me-2"></i>
              No academic staff profile is linked to your account yet. Please contact the administrator.
            </div>
            <% } else { %>

            <div class="row g-3 mb-3">
              <div class="col-md-6">
                <div class="pf-label">Department</div>
                <select name="ac_program" class="pf-input" style="appearance:auto;">
                  <option value="">Select Department</option>
                  <% for (String p : acPrograms) { %>
                  <option value="<%= p %>" <%= p.equals(acDept) ? "selected" : "" %>><%= p %></option>
                  <% } %>
                  <% if (!acDept.isEmpty()) {
                       boolean found = false;
                       for (String p : acPrograms) { if (p.equals(acDept)) { found = true; break; } }
                       if (!found) { %><option value="<%= acDept %>" selected><%= acDept %></option><% } } %>
                </select>
              </div>
              <div class="col-md-6">
                <div class="pf-label">Faculty</div>
                <select name="ac_faculty" class="pf-input" style="appearance:auto;">
                  <option value="">Select Faculty</option>
                  <% for (String f : acFaculties) { %>
                  <option value="<%= f %>" <%= f.equals(acFac) ? "selected" : "" %>><%= f %></option>
                  <% } %>
                  <% if (!acFac.isEmpty()) {
                       boolean found = false;
                       for (String f : acFaculties) { if (f.equals(acFac)) { found = true; break; } }
                       if (!found) { %><option value="<%= acFac %>" selected><%= acFac %></option><% } } %>
                </select>
              </div>
              <div class="col-md-6">
                <div class="pf-label">Highest Qualification</div>
                <select name="ac_qualification" class="pf-input" style="appearance:auto;">
                  <option value="">Select Qualification</option>
                  <% for (String q : new String[]{"PhD","Master's Degree","Bachelor's Degree","Professional Certification"}) { %>
                  <option value="<%= q %>" <%= q.equals(acQual) ? "selected" : "" %>><%= q %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-6">
                <div class="pf-label">Academic Rank</div>
                <select name="ac_rank" class="pf-input" style="appearance:auto;">
                  <option value="">Select Rank</option>
                  <% for (String r : new String[]{"Professor","Associate Professor","Senior Lecturer","Lecturer","Research Fellow","Postdoctoral Researcher"}) { %>
                  <option value="<%= r %>" <%= r.equals(acRank) ? "selected" : "" %>><%= r %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-4">
                <div class="pf-label">Years of Experience</div>
                <input type="number" name="ac_years" class="pf-input" min="0" max="60"
                       value="<%= acYears > 0 ? acYears : "" %>" placeholder="e.g. 10">
              </div>
            </div>

            <hr class="pf-divider">
            <div class="pf-label mb-3" style="color:#105e60;">Research Field</div>
            <div class="row g-3">
              <div class="col-md-6">
                <div class="pf-label">Specialization</div>
                <select name="ac_spec_id" id="pf_sel_spec" class="pf-input" style="appearance:auto;">
                  <option value="">Select Specialization</option>
                  <% for (java.util.Map<String,Object> sp : acSpecs) {
                       int spId = (Integer) sp.get("id"); %>
                  <option value="<%= spId %>" <%= (acSpecId != null && acSpecId == spId) ? "selected" : "" %>><%= sp.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-6">
                <div class="pf-label">Expertise</div>
                <select name="ac_expertise_id" id="pf_sel_exp" class="pf-input" style="appearance:auto;" disabled>
                  <option value="">— select specialization first —</option>
                  <% for (java.util.Map<String,Object> ex : acExpertise) {
                       int exId = (Integer) ex.get("id"); %>
                  <option value="<%= exId %>" data-spec="<%= ex.get("spec_id") %>"
                          <%= (acExpId != null && acExpId == exId) ? "selected" : "" %>><%= ex.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-6">
                <div class="pf-label">Division / Research Group</div>
                <select name="ac_division_id" id="pf_sel_div" class="pf-input" style="appearance:auto;" disabled>
                  <option value="">— select expertise first —</option>
                  <% for (java.util.Map<String,Object> dv : acDivisions) {
                       int dvId = (Integer) dv.get("id"); %>
                  <option value="<%= dvId %>" data-expertise="<%= dv.get("expertise_id") %>"
                          <%= (acDivId != null && acDivId == dvId) ? "selected" : "" %>><%= dv.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-6">
                <div class="pf-label">Area of Research</div>
                <select name="ac_area_id" id="pf_sel_area" class="pf-input" style="appearance:auto;" disabled>
                  <option value="">— select division first —</option>
                  <% for (java.util.Map<String,Object> ar : acAreas) {
                       int arId = (Integer) ar.get("id"); %>
                  <option value="<%= arId %>" data-division="<%= ar.get("division_id") %>"
                          <%= (acAreaId != null && acAreaId == arId) ? "selected" : "" %>><%= ar.get("name") %></option>
                  <% } %>
                </select>
              </div>
            </div>
            <% } %>
          </div>
<% } %>

          <!-- Actions -->
          <div class="d-flex justify-content-end gap-3 mb-5">
            <% String dashUrl = "Dean".equals(role)
                    ? request.getContextPath() + "/DeanDashboardServlet"
                    : "Admin".equals(role)
                    ? request.getContextPath() + "/admin/adminDashboard.jsp"
                    : request.getContextPath() + "/AcademicianDashboardServlet"; %>
            <a href="<%= dashUrl %>" class="btn-ea-back">Cancel</a>
            <button type="submit" class="ea-btn-primary-action">
              <i class="bi bi-check-lg me-1"></i> Save Changes
            </button>
          </div>

        </form>
      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function togglePw(inputId, iconId) {
      var el = document.getElementById(inputId);
      var ic = document.getElementById(iconId);
      if (el.type === 'password') {
        el.type = 'text';
        ic.className = 'bi bi-eye-slash';
      } else {
        el.type = 'password';
        ic.className = 'bi bi-eye';
      }
    }

    // Client-side confirm-password match check
    document.getElementById('profileForm').addEventListener('submit', function(e) {
      var np = document.getElementById('newPw').value;
      var cp = document.getElementById('confirmPw').value;
      if (np && np !== cp) {
        e.preventDefault();
        alert('New password and confirmation do not match.');
      }
    });

    // Academic profile 4-level cascade
    (function(){
      var s = document.getElementById('pf_sel_spec');
      var e = document.getElementById('pf_sel_exp');
      var d = document.getElementById('pf_sel_div');
      var a = document.getElementById('pf_sel_area');
      if (!s) return;

      var allExp  = Array.from(e.querySelectorAll('option[data-spec]'));
      var allDiv  = Array.from(d.querySelectorAll('option[data-expertise]'));
      var allArea = Array.from(a.querySelectorAll('option[data-division]'));

      function rebuild(sel, opts, attr, val) {
        var prev = sel.value;
        while (sel.options.length > 1) sel.remove(1);
        if (!val) { sel.disabled = true; sel.value = ''; return; }
        sel.disabled = false;
        opts.filter(function(o){ return String(o.getAttribute(attr)) === String(val); })
            .forEach(function(o){ sel.appendChild(o.cloneNode(true)); });
        sel.value = Array.from(sel.options).some(function(o){ return o.value === prev; }) ? prev : '';
      }

      s.addEventListener('change', function(){ rebuild(e,allExp,'data-spec',this.value); rebuild(d,allDiv,'data-expertise',''); rebuild(a,allArea,'data-division',''); });
      e.addEventListener('change', function(){ rebuild(d,allDiv,'data-expertise',this.value); rebuild(a,allArea,'data-division',''); });
      d.addEventListener('change', function(){ rebuild(a,allArea,'data-division',this.value); });

      // Restore edit-mode values
      if (s.value) {
        rebuild(e,allExp,'data-spec',s.value); e.value = '<%= acExpId != null ? acExpId : "" %>';
        if (e.value) { rebuild(d,allDiv,'data-expertise',e.value); d.value = '<%= acDivId != null ? acDivId : "" %>'; }
        if (d.value) { rebuild(a,allArea,'data-division',d.value); a.value = '<%= acAreaId != null ? acAreaId : "" %>'; }
      }
    })();

    // Sidebar toggle
    (function(){
      var btn = document.getElementById('sidebarToggleBtn');
      var overlay = document.getElementById('sidebarOverlay');
      if (btn) btn.addEventListener('click', function(){ document.body.classList.toggle('sidebar-open'); });
      if (overlay) overlay.addEventListener('click', function(){ document.body.classList.remove('sidebar-open'); });
    })();

    // Email-changed modal with countdown
    <% if ("1".equals(emailChanged)) { %>
    document.addEventListener('DOMContentLoaded', function(){
      var modal   = document.getElementById('emailChangedModal');
      var counter = document.getElementById('ecCountdown');
      var seconds = 4;
      modal.style.display = 'flex';
      var tick = setInterval(function(){
        seconds--;
        counter.textContent = seconds;
        if (seconds <= 0) {
          clearInterval(tick);
          window.location.href = '<%= request.getContextPath() %>/LogoutServlet';
        }
      }, 1000);
      document.getElementById('ecSignOutNow').addEventListener('click', function(){
        clearInterval(tick);
        window.location.href = '<%= request.getContextPath() %>/LogoutServlet';
      });
    });
    <% } %>
  </script>

  <!-- Email-changed modal overlay -->
  <% if ("1".equals(emailChanged)) { %>
  <div id="emailChangedModal" style="display:none;position:fixed;inset:0;z-index:9999;
       background:rgba(0,0,0,0.45);align-items:center;justify-content:center;">
    <div style="background:#fff;border-radius:18px;padding:36px 40px;max-width:420px;width:90%;
                box-shadow:0 8px 40px rgba(0,0,0,0.18);text-align:center;">
      <div style="width:60px;height:60px;border-radius:50%;background:#fffbeb;
                  display:flex;align-items:center;justify-content:center;margin:0 auto 18px;">
        <i class="bi bi-envelope-check-fill" style="font-size:1.7rem;color:#d97706;"></i>
      </div>
      <div style="font-size:1.15rem;font-weight:700;color:#111827;margin-bottom:8px;">Email updated</div>
      <div style="font-size:0.92rem;color:#374151;margin-bottom:6px;">
        Your login email has been changed to
      </div>
      <div style="font-size:1rem;font-weight:700;color:#0f766e;margin-bottom:16px;">
        <%= fEmail %>
      </div>
      <div style="font-size:0.88rem;color:#6b7280;margin-bottom:24px;">
        You'll be signed out in <strong id="ecCountdown">4</strong> seconds so the change takes effect.
        Your data and history are not affected.
      </div>
      <button id="ecSignOutNow"
              style="background:#0f766e;color:#fff;border:none;border-radius:9px;
                     padding:10px 28px;font-size:0.95rem;font-weight:600;cursor:pointer;width:100%;">
        Sign out now
      </button>
    </div>
  </div>
  <% } %>
</body>
</html>
