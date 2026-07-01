<%-- Admin: searchable list of academic staff records with link/unlink user actions. --%>
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

    String q       = request.getParameter("q")      != null ? request.getParameter("q").trim()      : "";
    String deptF   = request.getParameter("dept")   != null ? request.getParameter("dept").trim()   : "";
    String statusF = request.getParameter("status") != null ? request.getParameter("status").trim() : "";
    String specF   = request.getParameter("specId") != null ? request.getParameter("specId").trim() : "";
    String expF    = request.getParameter("expId")  != null ? request.getParameter("expId").trim()  : "";
    String divF    = request.getParameter("divId")  != null ? request.getParameter("divId").trim()  : "";
    String areaF   = request.getParameter("areaId") != null ? request.getParameter("areaId").trim() : "";
    String success = request.getParameter("success");

    java.util.List<java.util.Map<String, Object>> staffList   = new java.util.ArrayList<>();
    java.util.List<String>                        departments = new java.util.ArrayList<>();
    java.util.List<java.util.Map<String,Object>>  specList    = new java.util.ArrayList<>();
    java.util.List<java.util.Map<String,Object>>  expList     = new java.util.ArrayList<>();
    java.util.List<java.util.Map<String,Object>>  divList     = new java.util.ArrayList<>();
    java.util.List<java.util.Map<String,Object>>  areaList    = new java.util.ArrayList<>();
    int totalCount = 0;

    try (java.sql.Connection conn = util.DBConnection.getConnection()) {

        // Distinct departments for filter dropdown
        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT DISTINCT department FROM academic_staff WHERE department IS NOT NULL AND department <> '' ORDER BY department")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) departments.add(rs.getString("department"));
            }
        }

        // Load hierarchy tables for 4-level filter
        try (java.sql.PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM specialization ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) { while (rs.next()) { java.util.Map<String,Object> m = new java.util.LinkedHashMap<>(); m.put("id",rs.getInt("id")); m.put("name",rs.getString("name")); specList.add(m); } }
        }
        try (java.sql.PreparedStatement ps = conn.prepareStatement("SELECT id, specialization_id, name FROM expertise ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) { while (rs.next()) { java.util.Map<String,Object> m = new java.util.LinkedHashMap<>(); m.put("id",rs.getInt("id")); m.put("spec_id",rs.getObject("specialization_id")); m.put("name",rs.getString("name")); expList.add(m); } }
        }
        try (java.sql.PreparedStatement ps = conn.prepareStatement("SELECT id, specialization_id, expertise_id, name FROM division ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) { while (rs.next()) { java.util.Map<String,Object> m = new java.util.LinkedHashMap<>(); m.put("id",rs.getInt("id")); m.put("spec_id",rs.getObject("specialization_id")); m.put("exp_id",rs.getObject("expertise_id")); m.put("name",rs.getString("name")); divList.add(m); } }
        }
        try (java.sql.PreparedStatement ps = conn.prepareStatement("SELECT id, specialization_id, division_id, name FROM area ORDER BY name")) {
            try (java.sql.ResultSet rs = ps.executeQuery()) { while (rs.next()) { java.util.Map<String,Object> m = new java.util.LinkedHashMap<>(); m.put("id",rs.getInt("id")); m.put("spec_id",rs.getObject("specialization_id")); m.put("div_id",rs.getObject("division_id")); m.put("name",rs.getString("name")); areaList.add(m); } }
        }

        // Main list query
        StringBuilder sql = new StringBuilder(
            "SELECT a.id, a.staff_number, " +
            "CONCAT(COALESCE(CONCAT(a.title, ' '), ''), COALESCE(a.full_name, u.full_name, '—')) AS display_name, " +
            "COALESCE(a.department, '—') AS dept, " +
            "COALESCE(a.status, 'active') AS astatus, " +
            "s.name AS specialization_name, " +
            "e.name AS expertise_name, " +
            "dv.name AS division_name, " +
            "ar.name AS area_name, " +
            "a.academic_rank, " +
            "(CASE WHEN a.user_id IS NOT NULL THEN 1 ELSE 0 END) AS has_user " +
            "FROM academic_staff a " +
            "LEFT JOIN specialization s  ON s.id  = a.specialization_id " +
            "LEFT JOIN expertise e       ON e.id  = a.expertise_id " +
            "LEFT JOIN division dv       ON dv.id = a.division_id " +
            "LEFT JOIN area ar           ON ar.id = a.area_id " +
            "LEFT JOIN `user` u ON a.user_id = u.id " +
            "WHERE 1=1 "
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        if (!q.isEmpty()) {
            sql.append("AND (COALESCE(a.full_name, u.full_name, '') LIKE ? OR a.staff_number LIKE ? OR s.name LIKE ?) ");
            params.add("%" + q + "%"); params.add("%" + q + "%"); params.add("%" + q + "%");
        }
        if (!deptF.isEmpty())  { sql.append("AND a.department = ? ");          params.add(deptF); }
        if (!statusF.isEmpty()){ sql.append("AND a.status = ? ");              params.add(statusF.toLowerCase()); }
        if (!specF.isEmpty())  { sql.append("AND a.specialization_id = ? ");   params.add(Integer.parseInt(specF)); }
        if (!expF.isEmpty())   { sql.append("AND a.expertise_id = ? ");        params.add(Integer.parseInt(expF)); }
        if (!divF.isEmpty())   { sql.append("AND a.division_id = ? ");         params.add(Integer.parseInt(divF)); }
        if (!areaF.isEmpty())  { sql.append("AND a.area_id = ? ");             params.add(Integer.parseInt(areaF)); }
        sql.append("ORDER BY display_name");

        try (java.sql.PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.LinkedHashMap<>();
                    row.put("id",               rs.getInt("id"));
                    row.put("staffNumber",      rs.getString("staff_number")      != null ? rs.getString("staff_number")      : "—");
                    row.put("displayName",      rs.getString("display_name")      != null ? rs.getString("display_name")      : "—");
                    row.put("department",       rs.getString("dept")              != null ? rs.getString("dept")              : "—");
                    row.put("specialization",   rs.getString("specialization_name") != null ? rs.getString("specialization_name") : "");
                    row.put("expertise",        rs.getString("expertise_name")    != null ? rs.getString("expertise_name")    : "");
                    row.put("division",         rs.getString("division_name")     != null ? rs.getString("division_name")     : "");
                    row.put("area",             rs.getString("area_name")         != null ? rs.getString("area_name")         : "");
                    row.put("academicRank",     rs.getString("academic_rank")     != null ? rs.getString("academic_rank")     : "");
                    row.put("status",           rs.getString("astatus")           != null ? rs.getString("astatus")           : "active");
                    row.put("hasUser",          rs.getInt("has_user") == 1);
                    staffList.add(row);
                }
            }
        }
        totalCount = staffList.size();

    } catch (Exception e) {
        // graceful – show empty table
    }
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Academic Staff List - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"  rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  </head>
  <body class="admin">

    <jsp:include page="/includes/topbar.jsp" />

    <div class="layout ea-layout">
      <% request.setAttribute("activeSection", "academicstaff"); request.setAttribute("activeSubSection", "viewStaff"); %>
      <jsp:include page="/admin/sidebar.jsp" />

      <main class="content ea-content" style="max-width:none;">
        <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

          <!-- Page Header -->
          <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
            <div>
              <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Academic Staff List</h1>
              <div style="font-size:1rem;color:#6b7280;">Manage academic staff records for internal examiner appointments</div>
            </div>
            <a href="<%= request.getContextPath() %>/admin/academician/addAcademicStaff.jsp"
               class="ea-btn-primary-action d-inline-flex align-items-center gap-2">
              <i class="bi bi-person-plus-fill"></i> Add Academic Staff
            </a>
          </div>

          <% if ("1".equals(success)) { %>
          <div class="alert d-flex align-items-center gap-2 mb-3"
               style="background:#ecfdf5;border:1px solid #6ee7b7;border-radius:12px;color:#065f46;padding:14px 18px;">
            <i class="bi bi-check-circle-fill" style="color:#10b981;font-size:1.1rem;"></i>
            Academic staff record saved successfully.
          </div>
          <% } %>

          <!-- Info Banner -->
          <div class="d-flex align-items-start gap-2 mb-4 p-3"
               style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:12px;color:#1d4ed8;font-size:0.95rem;">
            <i class="bi bi-info-circle-fill mt-1" style="flex-shrink:0;color:#3b82f6;"></i>
            <span>This list serves as the <strong>internal examiner pool</strong> for viva appointments (Chairperson, Secretary, Internal Examiner).</span>
          </div>

          <!-- Search & Filter Bar -->
          <div class="w-100 mb-4 p-3"
               style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <form class="row g-2 align-items-end" method="GET" id="staffFilterForm"
                  action="<%= request.getContextPath() %>/admin/academician/academicStaffList.jsp">

              <!-- Row 1: text search + dept + status + submit -->
              <div class="col-lg-4 col-md-12">
                <div class="input-group" style="border:1.5px solid #e5e7eb;border-radius:10px;overflow:hidden;">
                  <span class="input-group-text bg-transparent border-0"><i class="bi bi-search text-muted"></i></span>
                  <input class="form-control border-0 ps-0" name="q" value="<%= q %>"
                         placeholder="Search by name, staff ID..."
                         style="font-size:0.97rem;box-shadow:none;">
                </div>
              </div>
              <div class="col-lg-3 col-md-6">
                <select name="dept" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                  <option value="">All Programs</option>
                  <% for (String d : departments) { %>
                  <option value="<%= d %>" <%= d.equals(deptF) ? "selected" : "" %>><%= d %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-lg-2 col-md-6">
                <select name="status" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                  <option value="">All Status</option>
                  <option value="active"    <%= "active".equals(statusF)    ? "selected" : "" %>>Active</option>
                  <option value="on leave"  <%= "on leave".equals(statusF)  ? "selected" : "" %>>On Leave</option>
                  <option value="inactive"  <%= "inactive".equals(statusF)  ? "selected" : "" %>>Inactive</option>
                </select>
              </div>
              <div class="col-lg-3 col-md-12 d-flex gap-2">
                <button type="submit" class="ea-btn-icon" title="Search"><i class="bi bi-search"></i></button>
                <% if (!q.isEmpty() || !deptF.isEmpty() || !statusF.isEmpty() || !specF.isEmpty() || !expF.isEmpty() || !divF.isEmpty() || !areaF.isEmpty()) { %>
                <a href="<%= request.getContextPath() %>/admin/academician/academicStaffList.jsp"
                   class="ea-btn-icon text-decoration-none text-center" title="Clear filters"
                   style="display:inline-flex;align-items:center;justify-content:center;">
                  <i class="bi bi-x-lg"></i>
                </a>
                <% } %>
                <button type="button" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1"
                        style="border-radius:8px;font-size:0.88rem;white-space:nowrap;"
                        onclick="toggleHierarchyFilter()">
                  <i class="bi bi-funnel" id="hierarchyFilterIcon"></i>
                  Research Field
                  <% if (!specF.isEmpty() || !expF.isEmpty() || !divF.isEmpty() || !areaF.isEmpty()) { %>
                  <span class="badge rounded-pill" style="background:#0f766e;color:#fff;font-size:0.72rem;">ON</span>
                  <% } %>
                </button>
              </div>

              <!-- Row 2: 4-level hierarchy filter (collapsible) -->
              <div id="hierarchyFilterRow" class="col-12 mt-1"
                   style="<%= (!specF.isEmpty() || !expF.isEmpty() || !divF.isEmpty() || !areaF.isEmpty()) ? "" : "display:none;" %>">
                <div class="row g-2">
                  <div class="col-md-3">
                    <label class="form-label mb-1" style="font-size:0.82rem;color:#6b7280;">Specialization</label>
                    <select name="specId" id="sf_spec" class="form-select form-select-sm"
                            style="border-radius:8px;border-color:#e5e7eb;" onchange="sfCascade()">
                      <option value="">All</option>
                      <% for (java.util.Map<String,Object> sp : specList) {
                           int spId = (Integer) sp.get("id"); %>
                      <option value="<%= spId %>" <%= String.valueOf(spId).equals(specF) ? "selected" : "" %>><%= sp.get("name") %></option>
                      <% } %>
                    </select>
                  </div>
                  <div class="col-md-3">
                    <label class="form-label mb-1" style="font-size:0.82rem;color:#6b7280;">Expertise</label>
                    <select name="expId" id="sf_exp" class="form-select form-select-sm"
                            style="border-radius:8px;border-color:#e5e7eb;" onchange="sfCascade()">
                      <option value="">All</option>
                      <% for (java.util.Map<String,Object> ex : expList) {
                           int exId = (Integer) ex.get("id"); %>
                      <option value="<%= exId %>"
                              data-spec="<%= ex.get("spec_id") %>"
                              <%= String.valueOf(exId).equals(expF) ? "selected" : "" %>><%= ex.get("name") %></option>
                      <% } %>
                    </select>
                  </div>
                  <div class="col-md-3">
                    <label class="form-label mb-1" style="font-size:0.82rem;color:#6b7280;">Division / Group</label>
                    <select name="divId" id="sf_div" class="form-select form-select-sm"
                            style="border-radius:8px;border-color:#e5e7eb;" onchange="sfCascade()">
                      <option value="">All</option>
                      <% for (java.util.Map<String,Object> dv : divList) {
                           int dvId = (Integer) dv.get("id"); %>
                      <option value="<%= dvId %>"
                              data-spec="<%= dv.get("spec_id") %>"
                              data-exp="<%= dv.get("exp_id") %>"
                              <%= String.valueOf(dvId).equals(divF) ? "selected" : "" %>><%= dv.get("name") %></option>
                      <% } %>
                    </select>
                  </div>
                  <div class="col-md-3">
                    <label class="form-label mb-1" style="font-size:0.82rem;color:#6b7280;">Area</label>
                    <select name="areaId" id="sf_area" class="form-select form-select-sm"
                            style="border-radius:8px;border-color:#e5e7eb;">
                      <option value="">All</option>
                      <% for (java.util.Map<String,Object> ar : areaList) {
                           int arId = (Integer) ar.get("id"); %>
                      <option value="<%= arId %>"
                              data-spec="<%= ar.get("spec_id") %>"
                              data-div="<%= ar.get("div_id") %>"
                              <%= String.valueOf(arId).equals(areaF) ? "selected" : "" %>><%= ar.get("name") %></option>
                      <% } %>
                    </select>
                  </div>
                </div>
              </div>

            </form>
          </div>

          <!-- Staff Table -->
          <div class="w-100 mb-4"
               style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
            <div class="d-flex align-items-center px-4 py-3" style="border-bottom:1px solid #f3f4f6;">
              <i class="bi bi-mortarboard me-2" style="color:#0f766e;font-size:1.1rem;"></i>
              <span class="fw-semibold" style="font-size:1.05rem;">Academic Staff (<%= totalCount %>)</span>
            </div>
            <div class="table-responsive">
              <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.97rem;">
                <thead>
                  <tr>
                    <th>Staff Name</th>
                    <th>Staff ID</th>
                    <th>Program</th>
                    <th>Specialization</th>
                    <th>Academic Status</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <% if (staffList.isEmpty()) { %>
                  <tr>
                    <td colspan="6" class="text-center py-5 text-muted">
                      <i class="bi bi-people d-block mb-2" style="font-size:2rem;color:#d1d5db;"></i>
                      No academic staff records found.
                      <a href="<%= request.getContextPath() %>/admin/academician/addAcademicStaff.jsp"
                         class="d-block mt-2 text-decoration-none" style="color:#0f766e;">
                        Add the first staff member
                      </a>
                    </td>
                  </tr>
                  <% } else { for (java.util.Map<String,Object> s : staffList) {
                       String stStatus    = (String) s.get("status");
                       boolean hasUser    = (Boolean) s.get("hasUser");
                       String rankLabel   = (String) s.get("academicRank"); %>
                  <tr>
                    <td>
                      <div class="fw-semibold" style="color:#111827;"><%= s.get("displayName") %></div>
                      <% if (rankLabel != null && !rankLabel.isEmpty()) { %>
                      <div style="font-size:0.8rem;color:#9ca3af;margin-top:2px;"><%= rankLabel %></div>
                      <% } %>
                    </td>
                    <td><code style="background:#f3f4f6;padding:3px 8px;border-radius:6px;font-size:0.88rem;color:#374151;"><%= s.get("staffNumber") %></code></td>
                    <td><%= s.get("department") %></td>
                    <td>
                      <% String spec = (String) s.get("specialization");
                         String exp  = (String) s.get("expertise");
                         String div  = (String) s.get("division");
                         String area = (String) s.get("area");
                         if (spec != null && !spec.isEmpty()) { %>
                      <div style="font-size:0.85rem;">
                        <span style="background:#e5f7f5;color:#0f766e;padding:2px 8px;border-radius:12px;font-weight:500;"><%= spec %></span>
                        <% if (exp != null && !exp.isEmpty()) { %>
                        <span style="color:#9ca3af;font-size:0.78rem;"> › </span>
                        <span style="color:#374151;font-size:0.82rem;"><%= exp %></span>
                        <% } %>
                        <% if (div != null && !div.isEmpty()) { %>
                        <span style="color:#9ca3af;font-size:0.78rem;"> › </span>
                        <span style="color:#374151;font-size:0.82rem;"><%= div %></span>
                        <% } %>
                        <% if (area != null && !area.isEmpty()) { %>
                        <div style="font-size:0.78rem;color:#9ca3af;margin-top:2px;"><i class="bi bi-pin-angle me-1"></i><%= area %></div>
                        <% } %>
                      </div>
                      <% } else { %>
                      <span style="color:#9ca3af;font-size:0.9rem;">—</span>
                      <% } %>
                    </td>
                    <td>
                      <% if ("active".equalsIgnoreCase(stStatus)) { %>
                      <span class="ea-badge-status ea-badge-active">Active</span>
                      <% } else if ("on leave".equalsIgnoreCase(stStatus)) { %>
                      <span class="ea-badge-status ea-badge-onleave">On Leave</span>
                      <% } else { %>
                      <span class="ea-badge-status ea-badge-inactive">Inactive</span>
                      <% } %>
                    </td>
                    <td style="white-space:nowrap;">
                      <a href="<%= request.getContextPath() %>/admin/academician/addAcademicStaff.jsp?id=<%= s.get("id") %>"
                         class="ea-btn-icon" title="Edit" style="font-size:1rem;padding:0.4em 0.7em;text-decoration:none;">
                        <i class="bi bi-pencil-square"></i>
                      </a>
                      <form method="POST" action="<%= request.getContextPath() %>/ArchiveStaffServlet"
                            style="display:inline;"
                            onsubmit="return confirm('<%= "inactive".equalsIgnoreCase(stStatus) ? "Restore this staff member to Active?" : "Archive this staff member? They will no longer appear in examiner selection." %>')">
                        <input type="hidden" name="staffId" value="<%= s.get("id") %>">
                        <input type="hidden" name="action"  value="<%= "inactive".equalsIgnoreCase(stStatus) ? "restore" : "archive" %>">
                        <button type="submit" class="ea-btn-icon"
                                title="<%= "inactive".equalsIgnoreCase(stStatus) ? "Restore" : "Archive" %>"
                                style="font-size:1rem;padding:0.4em 0.7em;
                                       color:<%= "inactive".equalsIgnoreCase(stStatus) ? "#059669" : "#dc2626" %>;">
                          <i class="bi bi-<%= "inactive".equalsIgnoreCase(stStatus) ? "arrow-counterclockwise" : "archive" %>"></i>
                        </button>
                      </form>
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
    <script>
    // ── Hierarchy filter cascade ────────────────────────────────────────────
    var allExpOpts  = Array.from(document.querySelectorAll('#sf_exp  option[data-spec]'));
    var allDivOpts  = Array.from(document.querySelectorAll('#sf_div  option[data-spec]'));
    var allAreaOpts = Array.from(document.querySelectorAll('#sf_area option[data-spec]'));

    function filterSelect(sel, opts, tests, prevVal) {
      while (sel.options.length > 1) sel.remove(1);
      var matched = opts.filter(function(o) {
        return tests.every(function(t) { return !t.val || String(o.getAttribute(t.attr)) === String(t.val); });
      });
      matched.forEach(function(o) { sel.appendChild(o.cloneNode(true)); });
      // Restore previous value if still present
      var still = Array.from(sel.options).some(function(o) { return o.value === prevVal; });
      sel.value = still ? prevVal : '';
    }

    function sfCascade() {
      var specVal = document.getElementById('sf_spec').value;
      var expVal  = document.getElementById('sf_exp').value;
      var divVal  = document.getElementById('sf_div').value;

      filterSelect(document.getElementById('sf_exp'),  allExpOpts,
        [{attr:'data-spec', val:specVal}], expVal);

      filterSelect(document.getElementById('sf_div'),  allDivOpts,
        [{attr:'data-spec', val:specVal}, {attr:'data-exp', val:document.getElementById('sf_exp').value}], divVal);

      filterSelect(document.getElementById('sf_area'), allAreaOpts,
        [{attr:'data-spec', val:specVal}, {attr:'data-div', val:document.getElementById('sf_div').value}], '');
    }

    function toggleHierarchyFilter() {
      var row  = document.getElementById('hierarchyFilterRow');
      var icon = document.getElementById('hierarchyFilterIcon');
      if (row.style.display === 'none') {
        row.style.display = '';
        icon.className = 'bi bi-funnel-fill';
      } else {
        row.style.display = 'none';
        icon.className = 'bi bi-funnel';
        // Clear hierarchy values on hide
        ['sf_spec','sf_exp','sf_div','sf_area'].forEach(function(id) {
          document.getElementById(id).value = '';
        });
      }
    }

    // Init cascade on load to filter dropdowns based on server-set values
    (function() {
      var specV = document.getElementById('sf_spec').value;
      if (specV) sfCascade();
    })();
    </script>
  </body>
</html>
