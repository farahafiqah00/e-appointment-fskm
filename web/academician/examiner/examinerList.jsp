<%-- Academician: searchable examiner directory showing examiners the current user has nominated along with a global list. --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null) fullName = "Academician";

    String q         = request.getParameter("q")               != null ? request.getParameter("q").trim()               : "";
    String specIdStr = request.getParameter("specializationId") != null ? request.getParameter("specializationId").trim() : "";
    String _exListSuccess = request.getParameter("success");
    String _exListError   = request.getParameter("error");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> examiners = (List<Map<String,Object>>) request.getAttribute("examiners");
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> specializations = (List<Map<String,Object>>) request.getAttribute("specializations");
    if (examiners      == null) examiners      = new java.util.ArrayList<>();
    if (specializations == null) specializations = new java.util.ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Examiner Directory - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout">
    <% request.setAttribute("activeSection", "examinerList"); %>
    <jsp:include page="/academician/sidebar.jsp" />

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

        <!-- Page Header -->
        <div class="mb-4">
          <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Examiner Directory</h1>
          <div style="font-size:1rem;color:#6b7280;">Browse registered examiners to avoid duplicate nominations.</div>
        </div>

        <% if ("1".equals(_exListSuccess)) { %>
        <div class="alert d-flex align-items-center gap-2 mb-3"
             style="background:#ecfdf5;border:1px solid #6ee7b7;border-radius:12px;color:#065f46;padding:14px 18px;">
          <i class="bi bi-check-circle-fill" style="color:#10b981;font-size:1.1rem;"></i>
          Examiner information updated successfully.
        </div>
        <% } else if ("missing_name".equals(_exListError)) { %>
        <div class="alert d-flex align-items-center gap-2 mb-3"
             style="background:#fef2f2;border:1px solid #fca5a5;border-radius:12px;color:#991b1b;padding:14px 18px;">
          <i class="bi bi-exclamation-circle-fill" style="font-size:1.1rem;"></i>
          Could not save: Examiner name is required.
        </div>
        <% } %>

        <!-- Search & Filter -->
        <div class="w-100 mb-4 p-3" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="row g-2 align-items-center">
            <div class="col-lg-6 col-md-12">
              <div class="input-group" style="border:1.5px solid #e5e7eb;border-radius:10px;overflow:hidden;">
                <span class="input-group-text bg-transparent border-0"><i class="bi bi-search text-muted"></i></span>
                <input id="elSearch" class="form-control border-0 ps-0" value="<%= q %>"
                       placeholder="Type to search by name or affiliation..."
                       style="font-size:0.97rem;box-shadow:none;" oninput="elFilter()">
              </div>
            </div>
            <div class="col-lg-4 col-md-8">
              <select id="elSpecFilter" class="form-select" style="border-radius:10px;border-color:#e5e7eb;" onchange="elFilter()">
                <option value="">All Specializations</option>
                <% for (Map<String,Object> s : specializations) {
                     String sid = s.get("id").toString();
                     boolean sel = sid.equals(specIdStr); %>
                <option value="<%= s.get("name").toString().replace("\"","&quot;") %>" <%= sel ? "selected" : "" %>><%= s.get("name") %></option>
                <% } %>
              </select>
            </div>
            <div class="col-lg-2 col-md-4">
              <button type="button" class="btn w-100" onclick="elClear()"
                      style="border-radius:10px;border:1px solid #e5e7eb;color:#6b7280;font-size:0.9rem;">
                <i class="bi bi-x-lg me-1"></i>Clear
              </button>
            </div>
          </div>
        </div>

        <!-- Examiner List -->
        <div class="w-100 mb-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
          <div class="d-flex align-items-center justify-content-between px-4 py-3" style="border-bottom:1px solid #f3f4f6;">
            <div class="d-flex align-items-center">
              <i class="bi bi-people me-2" style="color:#0f766e;font-size:1.1rem;"></i>
              <span class="fw-semibold" style="font-size:1.05rem;">Examiners (<span id="elCount"><%= examiners.size() %></span>)</span>
            </div>
            <span style="font-size:0.82rem;color:#9ca3af;">
              <i class="bi bi-info-circle me-1"></i> You can only edit examiners you nominated.
            </span>
          </div>
          <div class="table-responsive">
            <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.97rem;">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Affiliation</th>
                  <th>Specialization</th>
                  <th>Expertise</th>
                  <th class="text-center">Status</th>
                  <th class="text-center">Actions</th>
                </tr>
              </thead>
              <tbody id="elTbody">
                <% if (examiners.isEmpty()) { %>
                <tr>
                  <td colspan="6" class="text-center py-5 text-muted">
                    <i class="bi bi-people d-block mb-2" style="font-size:2rem;color:#d1d5db;"></i>
                    No examiners found.
                  </td>
                </tr>
                <% } else { for (Map<String,Object> ex : examiners) {
                     boolean isMine = Boolean.TRUE.equals(ex.get("is_my_examiner"));
                     String exStatus = ex.get("status") != null ? ex.get("status").toString() : "active";
                     String specName = ex.get("specialization_name") != null ? ex.get("specialization_name").toString() : "";
                     String expName  = ex.get("expertise_name")      != null ? ex.get("expertise_name").toString()      : "";
                     String affil    = ex.get("affiliation")          != null ? ex.get("affiliation").toString()          : "—";
                     String exName   = ex.get("name")                != null ? ex.get("name").toString()                : "";
                %>
                <tr data-name="<%= exName.toLowerCase().replace("\"","&quot;") %>"
                    data-affil="<%= affil.toLowerCase().replace("\"","&quot;") %>"
                    data-spec="<%= specName.replace("\"","&quot;") %>">
                  <td>
                    <div class="fw-semibold" style="color:#111827;"><%= ex.get("name") %></div>
                    <% if (isMine) { %>
                    <span style="background:#e5f7f5;color:#0f766e;padding:1px 8px;border-radius:10px;font-size:0.75rem;font-weight:600;">
                      <i class="bi bi-person-check me-1"></i>My Nominee
                    </span>
                    <% } %>
                  </td>
                  <td style="color:#374151;font-size:0.92rem;"><%= affil %></td>
                  <td style="color:#374151;font-size:0.88rem;"><%= !specName.isEmpty() ? specName : "—" %></td>
                  <td style="color:#374151;font-size:0.88rem;"><%= !expName.isEmpty() ? expName : "—" %></td>
                  <td class="text-center">
                    <% if ("active".equalsIgnoreCase(exStatus)) { %>
                    <span style="background:#dcfce7;color:#16a34a;padding:3px 12px;border-radius:20px;font-size:0.82rem;font-weight:600;">Active</span>
                    <% } else { %>
                    <span style="background:#f3f4f6;color:#6b7280;padding:3px 12px;border-radius:20px;font-size:0.82rem;font-weight:600;"><%= exStatus %></span>
                    <% } %>
                  </td>
                  <td class="text-center">
                    <% if (isMine) { %>
                    <a href="<%= request.getContextPath() %>/academician/examiner/edit?id=<%= ex.get("id") %>"
                       class="btn btn-sm d-inline-flex align-items-center gap-1"
                       style="background:#e5f7f5;color:#0f766e;border:1px solid #a7f3d0;border-radius:8px;font-size:0.85rem;">
                      <i class="bi bi-pencil-square"></i> Edit
                    </a>
                    <% } else { %>
                    <span style="color:#d1d5db;font-size:0.82rem;">—</span>
                    <% } %>
                  </td>
                </tr>
                <% } } %>
                <% if (!examiners.isEmpty()) { %>
                <tr id="elNoResults" style="display:none;">
                  <td colspan="6" class="text-center py-4 text-muted">
                    <i class="bi bi-search d-block mb-1" style="font-size:1.5rem;color:#d1d5db;"></i>
                    No examiners match your search.
                  </td>
                </tr>
                <% } %>
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  function elFilter() {
    var q    = document.getElementById('elSearch').value.toLowerCase().trim();
    var spec = document.getElementById('elSpecFilter').value;
    var rows = document.querySelectorAll('#elTbody tr[data-name]');
    var shown = 0;
    rows.forEach(function(r) {
      var nameMatch  = !q    || r.dataset.name.indexOf(q)   !== -1 || r.dataset.affil.indexOf(q) !== -1;
      var specMatch  = !spec || r.dataset.spec === spec;
      var visible    = nameMatch && specMatch;
      r.style.display = visible ? '' : 'none';
      if (visible) shown++;
    });
    document.getElementById('elCount').textContent = shown;
    var noRes = document.getElementById('elNoResults');
    if (noRes) noRes.style.display = (shown === 0) ? '' : 'none';
  }
  function elClear() {
    document.getElementById('elSearch').value = '';
    document.getElementById('elSpecFilter').value = '';
    elFilter();
    document.getElementById('elSearch').focus();
  }
  </script>
</body>
</html>
