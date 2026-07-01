<%-- Admin: form to add or update an academic staff record via SaveAcademicServlet (upsert on staff number). --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String _role = (String) session.getAttribute("role_name");
    if (!"Admin".equals(_role) && !"System Administrator".equals(_role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String sessionName = (String) session.getAttribute("full_name");
    if (sessionName == null || sessionName.trim().isEmpty()) sessionName = "Admin";

    // If ?id= is provided, load existing record for editing
    String editIdStr = request.getParameter("id") != null ? request.getParameter("id").trim() : "";
    boolean isEdit   = !editIdStr.isEmpty();

    // If ?userId= is provided (e.g. coming from Add User), pre-link that user account
    String preUserId   = request.getParameter("userId") != null ? request.getParameter("userId").trim() : "";
    // Track where the user came from for back-button context
    String fromCtx = request.getParameter("from") != null ? request.getParameter("from").trim() : "";
    String preUserName = "";
    String preTitleFromUser = "";
    java.util.List<java.util.Map<String,Object>> unlinkdStaff = new java.util.ArrayList<>();
    if (!preUserId.isEmpty() && !isEdit) {
        try (java.sql.Connection conn = util.DBConnection.getConnection()) {
            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                     "SELECT u.full_name, t.name AS title_name " +
                     "FROM `user` u LEFT JOIN title t ON t.id = u.title_id WHERE u.id = ? LIMIT 1")) {
                ps.setInt(1, Integer.parseInt(preUserId));
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        preUserName = rs.getString("full_name") != null ? rs.getString("full_name") : "";
                        String _rawTitle = rs.getString("title_name");
                        if (_rawTitle != null && !_rawTitle.trim().isEmpty()) preTitleFromUser = _rawTitle.trim();
                    }
                }
            }
            // Load existing unlinked staff records for the "link existing" option
            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                     "SELECT id, CONCAT(COALESCE(CONCAT(title,' '),''), full_name) AS display_name, staff_number " +
                     "FROM academic_staff WHERE user_id IS NULL ORDER BY full_name")) {
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                        m.put("id",   rs.getInt("id"));
                        m.put("name", rs.getString("display_name") != null ? rs.getString("display_name") : "");
                        m.put("snum", rs.getString("staff_number") != null ? rs.getString("staff_number") : "");
                        unlinkdStaff.add(m);
                    }
                }
            }
        } catch (Exception ignore) { }
    }

    String  prefStaffNumber   = "";
    String  prefTitle         = preTitleFromUser;
    String  prefFullName      = !preUserName.isEmpty() ? preUserName : "";
    String  prefProgram       = "";
    String  prefFaculty       = "";
    Integer prefSpecId        = null;
    Integer prefExpertiseId   = null;
    Integer prefDivisionId    = null;
    Integer prefAreaId        = null;
    String  prefQualification = "";
    String  prefRank          = "";
    int     prefYearsExp      = 0;
    String  prefStatus        = "active";
    Integer prefUserId        = !preUserId.isEmpty() ? Integer.parseInt(preUserId) : null;
    String prefUserRole       = "";

    if (isEdit) {
        try (java.sql.Connection conn = util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                 "SELECT * FROM academic_staff WHERE id = ? LIMIT 1")) {
            ps.setInt(1, Integer.parseInt(editIdStr));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    prefStaffNumber   = rs.getString("staff_number")   != null ? rs.getString("staff_number")   : "";
                    prefTitle         = rs.getString("title")           != null ? rs.getString("title")           : "";
                    prefFullName      = rs.getString("full_name")       != null ? rs.getString("full_name")       : "";
                    prefProgram       = rs.getString("department")      != null ? rs.getString("department")      : "";
                    prefFaculty       = rs.getString("faculty")         != null ? rs.getString("faculty")         : "";
                    prefQualification = rs.getString("qualification")   != null ? rs.getString("qualification")   : "";
                    prefRank          = rs.getString("academic_rank")   != null ? rs.getString("academic_rank")   : "";
                    prefYearsExp      = rs.getObject("years_experience") != null ? rs.getInt("years_experience")  : 0;
                    if (rs.getObject("specialization_id") != null) prefSpecId      = rs.getInt("specialization_id");
                    if (rs.getObject("expertise_id")      != null) prefExpertiseId = rs.getInt("expertise_id");
                    if (rs.getObject("division_id")       != null) prefDivisionId  = rs.getInt("division_id");
                    if (rs.getObject("area_id")           != null) prefAreaId      = rs.getInt("area_id");
                    if (rs.getObject("user_id")           != null) prefUserId      = rs.getInt("user_id");
                    prefStatus = rs.getString("status") != null ? rs.getString("status") : "active";
                }
            }
        } catch (Exception ignore) { }
    }

    // Default faculty to FSKM for new records
    if (!isEdit && prefFaculty.isEmpty()) prefFaculty = "Faculty of Computer Science and Mathematics";

    // Determine if we're adding/editing a Dean user, so we can show Dean-specific rank options
    if (!preUserId.isEmpty() && !isEdit) {
        try (java.sql.Connection conn = util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                 "SELECT r.name FROM `user` u JOIN role r ON r.id = u.role_id WHERE u.id = ? LIMIT 1")) {
            ps.setInt(1, Integer.parseInt(preUserId));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) prefUserRole = rs.getString("name") != null ? rs.getString("name") : "";
            }
        } catch (Exception ignore) { }
    } else if (isEdit && prefUserId != null) {
        try (java.sql.Connection conn = util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                 "SELECT r.name FROM `user` u JOIN role r ON r.id = u.role_id WHERE u.id = ? LIMIT 1")) {
            ps.setInt(1, prefUserId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) prefUserRole = rs.getString("name") != null ? rs.getString("name") : "";
            }
        } catch (Exception ignore) { }
    }
    boolean isDeanUser = "Dean".equals(prefUserRole);

    java.util.List<java.util.Map<String,Object>> specializations = new java.util.ArrayList<>();
    java.util.List<java.util.Map<String,Object>> expertiseList   = new java.util.ArrayList<>();
    java.util.List<java.util.Map<String,Object>> divisionList    = new java.util.ArrayList<>();
    java.util.List<java.util.Map<String,Object>> areaList        = new java.util.ArrayList<>();
    java.util.List<String> programList  = new java.util.ArrayList<>();
    java.util.List<String> facultyList  = new java.util.ArrayList<>();

    try (java.sql.Connection conn = util.DBConnection.getConnection()) {

        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT name FROM specialization ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) programList.add(rs.getString("name"));
            }
        }

        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT name FROM faculty ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) facultyList.add(rs.getString("name"));
            }
        }

        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT id, name FROM specialization ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",   rs.getInt("id"));
                    m.put("name", rs.getString("name"));
                    specializations.add(m);
                }
            }
        }

        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT id, specialization_id, name FROM expertise ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",      rs.getInt("id"));
                    m.put("spec_id", rs.getInt("specialization_id"));
                    m.put("name",    rs.getString("name"));
                    expertiseList.add(m);
                }
            }
        }

        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT id, specialization_id, expertise_id, name FROM division ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",           rs.getInt("id"));
                    m.put("spec_id",      rs.getObject("specialization_id") != null ? rs.getInt("specialization_id") : 0);
                    m.put("expertise_id", rs.getObject("expertise_id")      != null ? rs.getInt("expertise_id")      : 0);
                    m.put("name",         rs.getString("name"));
                    divisionList.add(m);
                }
            }
        }

        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT id, specialization_id, division_id, name FROM area ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",          rs.getInt("id"));
                    m.put("spec_id",     rs.getObject("specialization_id") != null ? rs.getInt("specialization_id") : 0);
                    m.put("division_id", rs.getObject("division_id")       != null ? rs.getInt("division_id")       : 0);
                    m.put("name",        rs.getString("name"));
                    areaList.add(m);
                }
            }
        }

    } catch (Exception ignore) { }

    String pageTitle    = isEdit ? "Edit Academic Staff"    : "Add Academic Staff";
    String pageSubtitle = isEdit ? "Update academic staff information" : "Add new academic staff to the internal examiner pool";
    String submitLabel  = isEdit ? "Update Academic Staff"  : "Save Academic Staff";
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= pageTitle %> - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
      .form-section {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        padding: 28px 32px;
        margin-bottom: 24px;
      }
      .section-heading {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 1.05rem;
        font-weight: 700;
        color: #0f766e;
        margin-bottom: 24px;
        padding-bottom: 14px;
        border-bottom: 2px solid #e5f7f5;
      }
      .form-label {
        font-size: 0.9rem;
        font-weight: 600;
        color: #374151;
        margin-bottom: 4px;
      }
      .form-hint {
        font-size: 0.8rem;
        color: #9ca3af;
        margin-top: 4px;
      }
      .form-control, .form-select {
        border-radius: 10px;
        border-color: #e5e7eb;
        font-size: 0.97rem;
      }
      .form-control:focus, .form-select:focus {
        border-color: #6ee7b7;
        box-shadow: 0 0 0 3px rgba(16,94,96,0.08);
      }
      .form-select:disabled {
        background-color: #f3f4f6;
        color: #9ca3af;
        cursor: not-allowed;
        opacity: 1;
      }
    </style>
  </head>
  <body class="admin">

    <jsp:include page="/includes/topbar.jsp" />

    <div class="layout">
      <% request.setAttribute("activeSection", "academicstaff"); request.setAttribute("activeSubSection", "addStaff"); %>
      <jsp:include page="/admin/sidebar.jsp" />

      <main class="content">
        <div style="max-width:1000px; margin:0 auto; padding:0 8px;">

          <!-- Page Header -->
          <div class="d-flex align-items-start justify-content-between mb-4 flex-wrap gap-3">
            <div>
              <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;"><%= pageTitle %></h1>
              <div style="font-size:1rem;color:#6b7280;"><%= pageSubtitle %></div>
            </div>
            <a href="<%= "userList".equals(fromCtx) ? request.getContextPath() + "/UserListServlet" : request.getContextPath() + "/admin/academician/academicStaffList.jsp" %>"
               class="btn-ea-back">
              <i class="bi bi-arrow-left"></i> <%= "userList".equals(fromCtx) ? "Back to User List" : "Back to Staff List" %>
            </a>
          </div>

          <!-- Info Banner -->
          <div class="d-flex align-items-start gap-2 mb-4 p-3"
               style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:12px;color:#1d4ed8;font-size:0.95rem;">
            <i class="bi bi-info-circle-fill mt-1" style="flex-shrink:0;color:#3b82f6;"></i>
            <span>Academic staff records are used for selecting <strong>Internal Examiners, Chairpersons, and Secretaries</strong> during viva appointments.</span>
          </div>

          <% if (!preUserId.isEmpty()) { %>
          <div class="d-flex align-items-start gap-2 mb-4 p-3"
               style="background:#f0fdf4;border:1px solid #86efac;border-radius:12px;color:#166534;font-size:0.95rem;">
            <i class="bi bi-person-check-fill mt-1" style="flex-shrink:0;color:#22c55e;"></i>
            <span>User account created. <strong>Fill in the staff profile below</strong> to complete the setup — the user account has already been pre-linked in Section D.</span>
          </div>

          <% if (!unlinkdStaff.isEmpty()) { %>
          <!-- Link to existing staff record option -->
          <div class="mb-4 p-4"
               style="background:#fff;border:2px solid #bfdbfe;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <div class="d-flex align-items-center gap-2 mb-3">
              <span style="background:#1d4ed8;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;flex-shrink:0;">
                <i class="bi bi-link-45deg"></i>
              </span>
              <span style="font-size:1rem;font-weight:700;color:#1d4ed8;">Link to Existing Staff Record</span>
            </div>
            <p style="font-size:0.93rem;color:#374151;margin-bottom:16px;">
              There are existing staff records with no linked user account. If this user already has a staff record, select it below instead of creating a new one.
            </p>
            <form method="POST" action="<%= request.getContextPath() %>/LinkStaffUserServlet" class="d-flex gap-2 align-items-end flex-wrap">
              <input type="hidden" name="userId" value="<%= preUserId %>">
              <input type="hidden" name="staffId" id="linkStaffIdHidden" value="">
              <div style="flex:1;min-width:220px;position:relative;">
                <label class="form-label" style="font-size:0.88rem;color:#374151;font-weight:600;">Select existing staff record</label>
                <div style="position:relative;">
                  <span style="position:absolute;left:11px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;"><i class="bi bi-search"></i></span>
                  <input type="text" id="linkStaffSearch" autocomplete="off" class="form-select"
                         style="padding-left:34px;border-color:#bfdbfe;"
                         placeholder="Type to search staff name or ID...">
                  <ul id="linkStaffDropdown"
                      style="display:none;position:absolute;z-index:9999;width:100%;max-height:220px;overflow-y:auto;
                             background:#fff;border:1px solid #bfdbfe;border-radius:10px;
                             box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;list-style:none;"></ul>
                </div>
                <div id="linkStaffSelectedBadge" style="display:none;margin-top:8px;background:#eff6ff;border:1px solid #bfdbfe;border-radius:8px;padding:8px 12px;display:none;align-items:center;gap:8px;">
                  <i class="bi bi-person-check-fill" style="color:#1d4ed8;"></i>
                  <span id="linkStaffSelectedName" style="font-weight:600;color:#1e40af;flex:1;"></span>
                  <button type="button" onclick="clearLinkStaff()" style="background:none;border:none;color:#ef4444;padding:0;cursor:pointer;"><i class="bi bi-x-circle-fill"></i></button>
                </div>
              </div>
              <button type="submit" id="linkStaffSubmitBtn" class="btn d-inline-flex align-items-center gap-2" disabled
                      style="background:#1d4ed8;color:#fff;border:none;border-radius:10px;padding:9px 20px;font-weight:600;white-space:nowrap;opacity:0.5;">
                <i class="bi bi-link-45deg"></i> Link Account
              </button>
            </form>
            <%-- Staff data for JS combobox --%>
            <script>
            var linkStaffData = [
              <% for (int _i = 0; _i < unlinkdStaff.size(); _i++) {
                   java.util.Map<String,Object> _us = unlinkdStaff.get(_i);
                   String _n = ((String)_us.get("name")).replace("\\","\\\\").replace("\"","\\\"");
                   String _s = ((String)_us.get("snum")).replace("\\","\\\\").replace("\"","\\\""); %>
              {"id":<%= _us.get("id") %>,"name":"<%= _n %>","snum":"<%= _s %>"}<%=_i<unlinkdStaff.size()-1?",":"" %>
              <% } %>
            ];
            (function(){
              var inp  = document.getElementById('linkStaffSearch');
              var dd   = document.getElementById('linkStaffDropdown');
              var hid  = document.getElementById('linkStaffIdHidden');
              var badge= document.getElementById('linkStaffSelectedBadge');
              var bname= document.getElementById('linkStaffSelectedName');
              var btn  = document.getElementById('linkStaffSubmitBtn');

              function selectStaff(id, name) {
                hid.value = id;
                inp.value = name;
                bname.textContent = name;
                badge.style.display = 'flex';
                dd.style.display = 'none';
                btn.disabled = false;
                btn.style.opacity = '1';
              }

              window.clearLinkStaff = function() {
                hid.value = ''; inp.value = '';
                badge.style.display = 'none';
                btn.disabled = true; btn.style.opacity = '0.5';
                inp.focus();
              };

              function render(q) {
                var lower = q.toLowerCase();
                var hits = linkStaffData.filter(function(s){
                  return s.name.toLowerCase().indexOf(lower) !== -1 || s.snum.toLowerCase().indexOf(lower) !== -1;
                });
                dd.innerHTML = '';
                if (!hits.length) { dd.style.display = 'none'; return; }
                hits.slice(0,40).forEach(function(s){
                  var li = document.createElement('li');
                  li.style.cssText = 'padding:9px 14px;cursor:pointer;font-size:0.92rem;border-bottom:1px solid #f3f4f6;';
                  li.innerHTML = '<span style="font-weight:600;color:#1e40af;">' + s.name + '</span>'
                    + (s.snum ? ' <span style="font-size:0.8rem;color:#6b7280;">(' + s.snum + ')</span>' : '');
                  li.addEventListener('mousedown', function(e){ e.preventDefault(); selectStaff(s.id, s.name + (s.snum?' ('+s.snum+')':'')); });
                  li.addEventListener('mouseover',  function(){ this.style.background='#eff6ff'; });
                  li.addEventListener('mouseout',   function(){ this.style.background=''; });
                  dd.appendChild(li);
                });
                dd.style.display = 'block';
              }

              inp.addEventListener('input', function(){ if(this.value.trim()) render(this.value.trim()); else dd.style.display='none'; });
              inp.addEventListener('focus', function(){ if(this.value.trim()) render(this.value.trim()); });
              document.addEventListener('click', function(e){ if(!inp.contains(e.target)&&!dd.contains(e.target)) dd.style.display='none'; });
            })();
            </script>
            <hr style="margin:20px 0 16px;border-color:#e0e7ff;">
            <div style="font-size:0.88rem;color:#6b7280;">
              <i class="bi bi-arrow-down-circle me-1" style="color:#6b7280;"></i>
              Or fill in the form below to <strong>create a new staff record</strong> for this user.
            </div>
          </div>
          <% } %>

          <% } %>

          <form method="POST" action="<%= request.getContextPath() %>/SaveAcademicServlet">
            <input type="hidden" name="editId" value="<%= editIdStr %>">
            <input type="hidden" name="from" value="<%= fromCtx %>">

            <!-- ── SECTION A: Basic Staff Information ── -->
            <div class="form-section">
              <div class="section-heading">
                <i class="bi bi-person-badge-fill" style="font-size:1.2rem;"></i>
                A. Basic Staff Information
              </div>

              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Staff ID <span class="text-danger">*</span></label>
                  <input type="text" name="staffNumber" id="staffNumber" class="form-control"
                         value="<%= prefStaffNumber %>"
                         placeholder="e.g., UMT00001" required
                         <%= isEdit ? "readonly style=\"background:#f3f4f6;\"" : "" %>>
                  <div class="form-hint">Must match the staff ID in the institutional system</div>
                </div>
                <div class="col-md-4">
                  <label class="form-label">Title</label>
                  <select name="title" class="form-select">
                    <option value="">— None —</option>
                    <%
                      try (java.sql.Connection _tc = util.DBConnection.getConnection();
                           java.sql.PreparedStatement _tp = _tc.prepareStatement(
                               "SELECT name FROM title ORDER BY id")) {
                        try (java.sql.ResultSet _tr = _tp.executeQuery()) {
                          while (_tr.next()) {
                            String _tn = _tr.getString("name");
                    %>
                    <option value="<%= _tn %>" <%= _tn.equals(prefTitle) ? "selected" : "" %>><%= _tn %></option>
                    <%      }
                        }
                      } catch (Exception _te) {
                        String[] _fallback = {"Mr","Mrs","Ms","Miss","Dr.","Ts.","Ts. Dr.",
                            "Ir.","Ir. Dr.","Prof.","Prof. Dr.","Prof. Ts.","Prof. Ts. Dr.",
                            "Prof. Ir.","Prof. Ir. Dr.","Assoc. Prof.","Assoc. Prof. Dr.",
                            "Assoc. Prof. Ts.","Assoc. Prof. Ts. Dr.",
                            "Assoc. Prof. Ir.","Assoc. Prof. Ir. Dr."};
                        for (String _tn : _fallback) { %>
                    <option value="<%= _tn %>" <%= _tn.equals(prefTitle) ? "selected" : "" %>><%= _tn %></option>
                    <%      }
                      }
                    %>
                  </select>
                  <div class="form-hint">Academic title prefix</div>
                </div>
                <div class="col-md-8">
                  <label class="form-label">Full Name <span class="text-danger">*</span></label>
                  <input type="text" name="fullName" id="fullNameInput" class="form-control"
                         value="<%= prefFullName %>"
                         placeholder="e.g., Ahmad bin Hassan" required>
                  <div class="form-hint">For display &amp; appointment letters (no title needed)</div>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Program <span class="text-danger">*</span></label>
                  <select name="department" class="form-select" required>
                    <option value="">Select Program</option>
                    <% if (programList.isEmpty()) { %>
                    <option value="<%= prefProgram %>" selected><%= prefProgram.isEmpty() ? "(no programs in DB)" : prefProgram %></option>
                    <% } else { for (String p : programList) { %>
                    <option value="<%= p %>" <%= p.equals(prefProgram) ? "selected" : "" %>><%= p %></option>
                    <% } } %>
                  </select>

                </div>
                <div class="col-md-6">
                  <label class="form-label">Faculty <span class="text-danger">*</span></label>
                  <select name="faculty" class="form-select" required>
                    <option value="">Select Faculty</option>
                    <% if (facultyList.isEmpty()) { %>
                    <option value="<%= prefFaculty %>" selected><%= prefFaculty.isEmpty() ? "(no faculties in DB)" : prefFaculty %></option>
                    <% } else { for (String f : facultyList) { %>
                    <option value="<%= f %>" <%= f.equals(prefFaculty) ? "selected" : "" %>><%= f %></option>
                    <% } } %>
                  </select>

                </div>
              </div>
            </div>

            <!-- ── SECTION B: Research Hierarchy (4-level cascade) ── -->
            <div class="form-section">
              <div class="section-heading">
                <i class="bi bi-diagram-3-fill" style="font-size:1.15rem;"></i>
                B. Research Field &mdash; Specialization &rarr; Expertise &rarr; Division &rarr; Area
              </div>



              <div class="row g-3">
                <!-- Level 1: Specialization -->
                <div class="col-md-6">
                  <label class="form-label">Specialization <span class="text-danger">*</span></label>
                  <select name="specialization_id" id="sel_spec" class="form-select" required>
                    <option value="">Select Specialization</option>
                    <% for (java.util.Map<String,Object> sp : specializations) {
                         int spId = (Integer) sp.get("id"); %>
                    <option value="<%= spId %>" <%= (prefSpecId != null && prefSpecId == spId) ? "selected" : "" %>><%= sp.get("name") %></option>
                    <% } %>
                  </select>
                  <div class="form-hint">Top-level research category</div>
                </div>

                <!-- Level 2: Expertise (filtered by specialization) -->
                <div class="col-md-6">
                  <label class="form-label">Expertise</label>
                  <select name="expertise_id" id="sel_expertise" class="form-select" disabled>
                    <option value="">— select specialization first —</option>
                    <% for (java.util.Map<String,Object> ex : expertiseList) {
                         int exId = (Integer) ex.get("id"); %>
                    <option value="<%= exId %>"
                            data-spec="<%= ex.get("spec_id") %>"
                            <%= (prefExpertiseId != null && prefExpertiseId == exId) ? "selected" : "" %>>
                      <%= ex.get("name") %>
                    </option>
                    <% } %>
                  </select>
                  <div class="form-hint">Filtered by specialization</div>
                </div>

                <!-- Level 3: Division (filtered by expertise) -->
                <div class="col-md-6">
                  <label class="form-label">Division / Research Group</label>
                  <select name="division_id" id="sel_division" class="form-select" disabled>
                    <option value="">— select expertise first —</option>
                    <% for (java.util.Map<String,Object> dv : divisionList) {
                         int dvId = (Integer) dv.get("id"); %>
                    <option value="<%= dvId %>"
                            data-spec="<%= dv.get("spec_id") %>"
                            data-expertise="<%= dv.get("expertise_id") %>"
                            <%= (prefDivisionId != null && prefDivisionId == dvId) ? "selected" : "" %>>
                      <%= dv.get("name") %>
                    </option>
                    <% } %>
                  </select>
                  <div class="form-hint">Filtered by expertise</div>
                </div>

                <!-- Level 4: Area (filtered by division) -->
                <div class="col-md-6">
                  <label class="form-label">Area of Research</label>
                  <select name="area_id" id="sel_area" class="form-select" disabled>
                    <option value="">— select division first —</option>
                    <% for (java.util.Map<String,Object> ar : areaList) {
                         int arId = (Integer) ar.get("id"); %>
                    <option value="<%= arId %>"
                            data-spec="<%= ar.get("spec_id") %>"
                            data-division="<%= ar.get("division_id") %>"
                            <%= (prefAreaId != null && prefAreaId == arId) ? "selected" : "" %>>
                      <%= ar.get("name") %>
                    </option>
                    <% } %>
                  </select>
                  <div class="form-hint">Filtered by division</div>
                </div>
              </div>
            </div>

            <!-- ── SECTION C: Academic Profile ── -->
            <div class="form-section">
              <div class="section-heading">
                <i class="bi bi-briefcase-fill" style="font-size:1.2rem;"></i>
                C. Academic Profile
              </div>

              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Highest Qualification</label>
                  <select name="qualification" class="form-select">
                    <option value="">Select Qualification</option>
                    <% String[] quals = {"PhD","Master's Degree","Bachelor's Degree","Professional Certification"};
                       for (String q : quals) { %>
                    <option value="<%= q %>" <%= q.equals(prefQualification) ? "selected" : "" %>><%= q %></option>
                    <% } %>
                  </select>
                  <div class="form-hint">Reference only</div>
                </div>

                <div class="col-md-6">
                  <label class="form-label">Academic Rank <% if (isDeanUser) { %><span style="color:#0f766e;font-weight:600;"> (Dean Position)</span><% } %></label>
                  <select name="academic_rank" class="form-select">
                    <option value="">Select Rank</option>
                    <% String[] ranks = isDeanUser
                         ? new String[]{"Dean","TDA","TDB"}
                         : new String[]{"Professor","Associate Professor","Senior Lecturer","Lecturer","Research Fellow","Postdoctoral Researcher"};
                       for (String r : ranks) { %>
                    <option value="<%= r %>" <%= r.equals(prefRank) ? "selected" : "" %>><%= r %></option>
                    <% } %>
                  </select>
                  <% if (isDeanUser) { %>
                  <div class="form-hint" style="color:#0f766e;font-size:0.85rem;margin-top:6px;line-height:1.4;">
                    <strong>Dean:</strong> Faculty Dean<br>
                    <strong>TDA:</strong> Timbalan Dekan A (Deputy Dean A)<br>
                    <strong>TDB:</strong> Timbalan Dekan B (Deputy Dean B)
                  </div>
                  <% } %>
                </div>

                <div class="col-md-6">
                  <label class="form-label">Years of Experience</label>
                  <input type="number" name="years_experience" class="form-control"
                         value="<%= prefYearsExp > 0 ? prefYearsExp : "" %>"
                         min="0" max="60" placeholder="e.g., 10">
                  <div class="form-hint"><%= isDeanUser ? "Optional" : "Optional fairness check" %></div>
                </div>

                <% if (isEdit) { %>
                <div class="col-md-6">
                  <label class="form-label">Academic Status</label>
                  <select name="status" class="form-select">
                    <option value="active"   <%= "active".equalsIgnoreCase(prefStatus)    ? "selected" : "" %>>Active</option>
                    <option value="on leave" <%= "on leave".equalsIgnoreCase(prefStatus)  ? "selected" : "" %>>On Leave</option>
                    <option value="inactive" <%= "inactive".equalsIgnoreCase(prefStatus)  ? "selected" : "" %>>Inactive (Archived)</option>
                  </select>
                  <div class="form-hint">Inactive staff will not appear in examiner selection</div>
                </div>
                <% } %>
              </div>
            </div>

            <%-- User account is auto-linked from the account created in the previous step --%>
            <% if (prefUserId != null) { %>
            <input type="hidden" name="user_id" value="<%= prefUserId %>">
            <% } %>

            <!-- Footer Buttons -->
            <div class="d-flex justify-content-end gap-3 mb-5">
              <a href="<%= "userList".equals(fromCtx) ? request.getContextPath() + "/UserListServlet" : request.getContextPath() + "/admin/academician/academicStaffList.jsp" %>"
                 class="btn-ea-back">
                <i class="bi bi-x-lg"></i> Cancel
              </a>
              <button type="submit"
                      class="ea-btn-primary-action d-inline-flex align-items-center gap-2"
                      style="padding:11px 28px;border-radius:10px;">
                <i class="bi bi-floppy-fill"></i> <%= submitLabel %>
              </button>
            </div>

          </form>
        </div>
      </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    (function () {
      // ── 4-level cascade ─────────────────────────────────────────────────────
      var selSpec      = document.getElementById('sel_spec');
      var selExpertise = document.getElementById('sel_expertise');
      var selDivision  = document.getElementById('sel_division');
      var selArea      = document.getElementById('sel_area');

      // Snapshot original options (excluding placeholder)
      var allExpertise = Array.from(selExpertise.querySelectorAll('option[data-spec]'));
      var allDivision  = Array.from(selDivision.querySelectorAll('option[data-expertise]'));
      var allArea      = Array.from(selArea.querySelectorAll('option[data-division]'));

      function rebuildSelect(select, options, filterAttr, filterValue, emptyLabel) {
        var prev = select.value;
        while (select.options.length > 1) select.remove(1);

        if (!filterValue) {
          select.options[0].text = '— select previous level first —';
          select.value = '';
          select.disabled = true;
          return;
        }

        select.options[0].text = emptyLabel;
        select.disabled = false;

        var matched = options.filter(function (o) {
          return String(o.getAttribute(filterAttr)) === String(filterValue);
        });
        matched.forEach(function (o) { select.appendChild(o.cloneNode(true)); });

        if (matched.length === 0) {
          var ng = document.createElement('option');
          ng.value = ''; ng.text = '— none available —'; ng.disabled = true;
          select.appendChild(ng);
        }

        var stillValid = Array.from(select.options).some(function (o) { return o.value === prev; });
        select.value = (stillValid && prev) ? prev : '';
      }

      selSpec.addEventListener('change', function () {
        rebuildSelect(selExpertise, allExpertise, 'data-spec',      this.value, 'Select expertise');
        rebuildSelect(selDivision,  allDivision,  'data-expertise', '',         'Select division');
        rebuildSelect(selArea,      allArea,      'data-division',  '',         'Select area');
      });

      selExpertise.addEventListener('change', function () {
        rebuildSelect(selDivision, allDivision, 'data-expertise', this.value, 'Select division');
        rebuildSelect(selArea,     allArea,     'data-division',  '',         'Select area');
      });

      selDivision.addEventListener('change', function () {
        rebuildSelect(selArea, allArea, 'data-division', this.value, 'Select area');
      });

      // ── Restore pre-selected values on page load (edit mode) ────────────────
      (function initFromPreselected() {
        var sv = selSpec.value, ev = selExpertise.value,
            dv = selDivision.value, av = selArea.value;
        if (sv) {
          rebuildSelect(selExpertise, allExpertise, 'data-spec', sv, 'Select expertise');
          selExpertise.value = ev;
        }
        if (selExpertise.value) {
          rebuildSelect(selDivision, allDivision, 'data-expertise', selExpertise.value, 'Select division');
          selDivision.value = dv;
        }
        if (selDivision.value) {
          rebuildSelect(selArea, allArea, 'data-division', selDivision.value, 'Select area');
          selArea.value = av;
        }
      })();
    })();
    </script>
  </body>
</html>
