<%--
  Admin: appointment decision page — assign panel members, set viva date/venue, and track
  per-member letter-signed status. _signedCount/_panelTotal drive the progress indicator.
--%>
<%@ page import="model.VivaAppointment, java.util.List, java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String fullName = (String) session.getAttribute("full_name"); if (fullName == null) fullName = "Admin";
  VivaAppointment a = (VivaAppointment) request.getAttribute("appointment");
  List<Map<String,Object>> internalStaff = (List<Map<String,Object>>) request.getAttribute("internalStaff");
  List<Map<String,Object>> verifiedExaminers = (List<Map<String,Object>>) request.getAttribute("verifiedExaminers");
  @SuppressWarnings("unchecked")
  List<Map<String,Object>> roleStats = (List<Map<String,Object>>) request.getAttribute("roleStats");
  @SuppressWarnings("unchecked")
  List<Map<String,Object>> venues = (List<Map<String,Object>>) request.getAttribute("venues");
  String conflictError    = (String) request.getAttribute("conflictError");
  String validationError  = (String) request.getAttribute("validationError");
  boolean justSaved = "1".equals(request.getParameter("saved"));
  String _listUrl = request.getAttribute("listUrl") != null ? (String) request.getAttribute("listUrl")
      : (request.getParameter("listUrl") != null ? request.getParameter("listUrl") : "");
  String _backUrl = !_listUrl.isEmpty() ? _listUrl : request.getContextPath() + "/admin/appointments";
  String _listUrlEncoded = !_listUrl.isEmpty() ? java.net.URLEncoder.encode(_listUrl, "UTF-8") : "";
  if (internalStaff == null) internalStaff = new java.util.ArrayList<>();
  if (verifiedExaminers == null) verifiedExaminers = new java.util.ArrayList<>();
  if (roleStats == null) roleStats = new java.util.ArrayList<>();
  if (venues == null) venues = new java.util.ArrayList<>();
  // Letter signed count
  int _signedCount = 0; int _panelTotal = 0;
  if (a != null && a.getPanelMembers() != null) {
    for (Map<String,Object> _pm : a.getPanelMembers()) {
      _panelTotal++;
      if (Boolean.TRUE.equals(_pm.get("letter_signed"))) _signedCount++;
    }
  }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Record Appointment Decision - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout ea-layout">
    <nav class="sidebar" id="mainSidebar">
      <div class="position-sticky">
        <ul class="nav flex-column mt-3">
          <li class="nav-item">
            <a class="nav-link menu-item d-flex align-items-center" href="<%= _backUrl %>">
              <span class="nav-icon"><i class="bi bi-arrow-left" style="font-size:17px;color:#0f766e;"></i></span>
              <span class="ms-2">Back to Appointment List</span>
            </a>
          </li>
        </ul>
      </div>
    </nav>

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch; max-width:1000px; margin:0 auto;">

        <% if (a == null) { %>
        <div class="alert alert-warning mt-4">Appointment not found. <a href="<%= _backUrl %>">Back to list</a></div>
        <% } else { %>

        <% if (justSaved) { %>
        <div class="d-flex align-items-center gap-3 mb-4 p-3" style="background:#f0fdf4;border:1.5px solid #86efac;border-radius:12px;">
          <i class="bi bi-check-circle-fill" style="color:#16a34a;font-size:1.3rem;flex-shrink:0;"></i>
          <div style="flex:1;">
            <div class="fw-semibold" style="color:#15803d;">Appointment saved successfully.</div>
            <div style="font-size:0.88rem;color:#166534;">Panel assignment and schedule have been updated for <strong><%= a != null ? a.getCandidateName() : "" %></strong>.</div>
          </div>
          <a href="<%= _backUrl %>"
             style="font-size:0.82rem;font-weight:600;color:#15803d;text-decoration:none;white-space:nowrap;border:1.5px solid #86efac;border-radius:8px;padding:4px 14px;background:#fff;">
            Back to List
          </a>
        </div>
        <% } %>

        <% if (conflictError != null && !conflictError.isEmpty()) { %>
        <div class="d-flex align-items-start gap-3 mb-4 p-3" style="background:#fef2f2;border:1.5px solid #fca5a5;border-radius:12px;">
          <i class="bi bi-exclamation-triangle-fill" style="color:#dc2626;font-size:1.3rem;flex-shrink:0;margin-top:2px;"></i>
          <div>
            <div class="fw-semibold" style="color:#dc2626;">Venue Booking Conflict</div>
            <div style="font-size:0.92rem;color:#7f1d1d;"><%= conflictError %></div>
            <div style="font-size:0.85rem;color:#9ca3af;margin-top:4px;">Please choose a different venue or time to proceed.</div>
          </div>
        </div>
        <% } %>

        <% if (validationError != null && !validationError.isEmpty()) { %>
        <div class="d-flex align-items-start gap-3 mb-4 p-3" style="background:#fef2f2;border:1.5px solid #fca5a5;border-radius:12px;">
          <i class="bi bi-exclamation-triangle-fill" style="color:#dc2626;font-size:1.3rem;flex-shrink:0;margin-top:2px;"></i>
          <div>
            <div class="fw-semibold" style="color:#dc2626;">Cannot Save — Missing Required Fields</div>
            <div style="font-size:0.92rem;color:#7f1d1d;"><%= validationError %></div>
            <div style="font-size:0.85rem;color:#9ca3af;margin-top:4px;">Fill in Chairperson, Secretary, Date &amp; Time, and Venue to confirm the appointment as <strong>Scheduled</strong>. Partial saves will keep the status as <strong>Pending Schedule</strong>.</div>
          </div>
        </div>
        <% } %>

        <%-- Declined panel members alert — shown whenever any member has declined --%>
        <%
          java.util.List<Map<String,Object>> _declinedMembers = new java.util.ArrayList<>();
          if (a != null && a.getPanelMembers() != null) {
            for (Map<String,Object> _dpm : a.getPanelMembers()) {
              if ("declined".equals(_dpm.get("panel_response"))) _declinedMembers.add(_dpm);
            }
          }
        %>
        <% if (!_declinedMembers.isEmpty()) { %>
        <div class="d-flex align-items-start gap-3 mb-4 p-3" style="background:#fef2f2;border:1.5px solid #fca5a5;border-radius:12px;">
          <i class="bi bi-exclamation-triangle-fill" style="color:#dc2626;font-size:1.3rem;flex-shrink:0;margin-top:2px;"></i>
          <div style="flex:1;">
            <div class="fw-semibold mb-2" style="color:#dc2626;">Panel Member Declined</div>
            <% for (Map<String,Object> _dm : _declinedMembers) {
                 String _dmName   = _dm.get("name")             != null ? _dm.get("name").toString()             : "—";
                 String _dmRole   = _dm.get("role")             != null ? _dm.get("role").toString()             : "—";
                 String _dmReason = _dm.get("rejection_reason") != null ? _dm.get("rejection_reason").toString().trim() : "";
            %>
            <div style="background:#fff5f5;border:1px solid #fca5a5;border-radius:8px;padding:10px 14px;margin-bottom:8px;">
              <div style="font-weight:600;color:#b91c1c;"><i class="bi bi-person-x me-1"></i><%= _dmRole %> — <%= _dmName %></div>
              <% if (!_dmReason.isEmpty()) { %>
              <div style="font-size:0.88rem;color:#7f1d1d;margin-top:4px;"><strong>Reason:</strong> <%= _dmReason.replace("<","&lt;").replace(">","&gt;") %></div>
              <% } else { %>
              <div style="font-size:0.88rem;color:#9ca3af;margin-top:2px;font-style:italic;">No reason provided.</div>
              <% } %>
            </div>
            <% } %>
            <div style="font-size:0.85rem;color:#6b7280;">Admin has been notified. Please contact the member directly to follow up.</div>
          </div>
        </div>
        <% } %>

        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Record Appointment Decision</h1>
            <div style="font-size:1rem;color:#6b7280;">Record decisions made in faculty meeting</div>
          </div>
        </div>

        <!-- Candidate Information Card -->
        <div class="w-100 mb-4 p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center mb-3">
            <i class="bi bi-person me-2" style="color:#0f766e;font-size:1.15rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Candidate Information</span>
          </div>
          <div class="row g-3">
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Candidate Name</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getCandidateName() != null ? a.getCandidateName() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Matric Number</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getCandidateStudentId() != null ? a.getCandidateStudentId() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Programme</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getCandidateProgram() != null ? a.getCandidateProgram() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Thesis Title</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getThesisTitle() != null ? a.getThesisTitle() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Supervisor Name</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getSupervisorName() != null ? a.getSupervisorName() : "—" %></div>
            </div>
          </div>
        </div>

<!-- Panel Role Reference — collapsible, lazy-rendered -->
        <div class="w-100 mb-4 p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center justify-content-between" style="cursor:pointer;" onclick="togglePanelRef()">
            <div class="d-flex align-items-center">
              <i class="bi bi-clock-history me-2" style="color:#0f766e;font-size:1.15rem;"></i>
              <span class="fw-semibold" style="font-size:1.05rem;">Panel Role Reference</span>
              <span class="ms-2" style="font-size:0.82rem;color:#9ca3af;">— click to expand before assigning roles</span>
            </div>
            <i class="bi bi-chevron-down" id="panelRefChevron" style="color:#9ca3af;font-size:1rem;"></i>
          </div>

          <div id="panelRefBody" style="display:none;margin-top:14px;">
            <div class="mb-3" style="font-size:0.88rem;color:#9ca3af;">
              <span style="background:#dcfce7;color:#16a34a;padding:1px 7px;border-radius:10px;font-size:0.8rem;font-weight:700;">New</span> = never assigned to any panel yet.
            </div>

            <!-- Search + Filters row -->
            <div class="row g-2 mb-3 align-items-center">
              <div class="col-md-3">
                <div style="position:relative;">
                  <span style="position:absolute;left:9px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
                  <input type="text" id="rsSearchName" class="form-control form-control-sm" placeholder="Search name..."
                         style="border-radius:8px;border-color:#e5e7eb;padding-left:28px;" oninput="rsRender()">
                </div>
              </div>
              <div class="col-md-3">
                <select id="rsFilterSpec" class="form-select form-select-sm" style="border-radius:8px;border-color:#e5e7eb;" onchange="rsRender()">
                  <option value="">All Specializations</option>
                </select>
              </div>
              <div class="col-md-3">
                <select id="rsFilterExp" class="form-select form-select-sm" style="border-radius:8px;border-color:#e5e7eb;" onchange="rsRender()">
                  <option value="">All Expertise</option>
                </select>
              </div>
              <div class="col-md-3">
                <select id="rsFilterDiv" class="form-select form-select-sm" style="border-radius:8px;border-color:#e5e7eb;" onchange="rsRender()">
                  <option value="">All Divisions / Groups</option>
                </select>
              </div>
            </div>

            <!-- Table -->
            <div class="table-responsive">
              <table class="table table-sm align-middle mb-0 w-100" style="font-size:0.86rem;" id="roleStatsTable">
                <thead style="background:#f9fafb;">
                  <tr style="font-size:0.78rem;text-transform:uppercase;letter-spacing:.04em;color:#6b7280;">
                    <th style="padding:6px 10px;font-weight:600;">Name</th>
                    <th style="padding:6px 10px;font-weight:600;">Specialization</th>
                    <th style="padding:6px 10px;font-weight:600;">Expertise</th>
                    <th style="padding:6px 10px;font-weight:600;">Division / Group</th>
                    <th class="text-center" style="padding:6px 10px;font-weight:600;">Chair</th>
                    <th class="text-center" style="padding:6px 10px;font-weight:600;">Secretary</th>
                    <th class="text-center" style="padding:6px 10px;font-weight:600;">Internal</th>
                    <th class="text-center" style="padding:6px 10px;font-weight:600;">External</th>
                    <th class="text-center" style="padding:6px 10px;font-weight:600;">Past Roles</th>
                    <th class="text-center" style="padding:6px 10px;font-weight:600;">Assign</th>
                  </tr>
                </thead>
                <tbody id="roleStatsBody"></tbody>
              </table>
            </div>
            <div id="rsNoResults" class="text-muted text-center py-3" style="display:none;font-size:0.92rem;"><i class="bi bi-search me-1"></i>No matching panel members found.</div>
            <div id="rsShowMoreWrap" class="text-center mt-2" style="display:none;">
              <button type="button" class="btn btn-sm btn-outline-secondary" style="border-radius:8px;font-size:0.85rem;" onclick="rsShowMore()">Show more</button>
            </div>
          </div><!-- end panelRefBody -->
        </div>

        <%-- Embed roleStats as JS data — rendered once, table built lazily on expand --%>
        <script>
        var _rsData = [
          <% for (int _ri = 0; _ri < roleStats.size(); _ri++) {
               Map<String,Object> _m = roleStats.get(_ri);
               String _rn  = _m.get("name")               != null ? _m.get("name").toString().replace("\"","\\\"")               : "";
               String _rs  = _m.get("specialization_name") != null ? _m.get("specialization_name").toString().replace("\"","\\\"") : "";
               String _re  = _m.get("expertise_name")      != null ? _m.get("expertise_name").toString().replace("\"","\\\"")      : "";
               String _rd  = _m.get("division_name")       != null ? _m.get("division_name").toString().replace("\"","\\\"")       : "";
               int _chair  = _m.get("chair_count")    != null ? ((Number)_m.get("chair_count")).intValue()    : 0;
               int _rec    = _m.get("recorder_count") != null ? ((Number)_m.get("recorder_count")).intValue() : 0;
               int _intEx  = _m.get("internal_count") != null ? ((Number)_m.get("internal_count")).intValue() : 0;
               int _extEx  = _m.get("external_count") != null ? ((Number)_m.get("external_count")).intValue() : 0;
               int _total  = _m.get("total_count")    != null ? ((Number)_m.get("total_count")).intValue()    : 0;
               String _rtp = _m.get("type")           != null ? _m.get("type").toString()                                         : "internal";
          %>{"n":"<%= _rn %>","s":"<%= _rs %>","e":"<%= _re %>","d":"<%= _rd %>","ch":<%= _chair %>,"rc":<%= _rec %>,"ie":<%= _intEx %>,"ee":<%= _extEx %>,"t":<%= _total %>,"tp":"<%= _rtp %>"}<% if (_ri < roleStats.size()-1) { %>,<% } %>
          <% } %>
        ];

        var _rsVisible = 0;
        var _rsPageSize = 15;
        var _rsFiltered = [];
        var _rsInitialized = false;

        function rsInit() {
          if (_rsInitialized) return;
          _rsInitialized = true;
          // Populate filter dropdowns
          var specs = new Set(), exps = new Set(), divs = new Set();
          _rsData.forEach(function(r) {
            if (r.s) specs.add(r.s);
            if (r.e) exps.add(r.e);
            if (r.d) divs.add(r.d);
          });
          function fill(id, set) {
            var sel = document.getElementById(id);
            Array.from(set).sort().forEach(function(v) {
              var o = document.createElement('option'); o.value = v; o.textContent = v; sel.appendChild(o);
            });
          }
          fill('rsFilterSpec', specs);
          fill('rsFilterExp',  exps);
          fill('rsFilterDiv',  divs);
          rsRender();
        }

        function rsRender() {
          var q    = document.getElementById('rsSearchName').value.trim().toLowerCase();
          var spec = document.getElementById('rsFilterSpec').value;
          var exp  = document.getElementById('rsFilterExp').value;
          var div  = document.getElementById('rsFilterDiv').value;
          _rsFiltered = _rsData.filter(function(r) {
            return (!q    || r.n.toLowerCase().indexOf(q) !== -1)
                && (!spec || r.s === spec)
                && (!exp  || r.e === exp)
                && (!div  || r.d === div);
          });
          _rsVisible = _rsPageSize;
          rsFlush();
        }

        function rsShowMore() {
          _rsVisible += _rsPageSize;
          rsFlush();
        }

        var _ROLE_LABELS = {chair:'Chairperson', recorder:'Secretary', internal:'Internal Examiner', external:'External Examiner'};

        function rsFlush() {
          var tbody = document.getElementById('roleStatsBody');
          tbody.innerHTML = '';
          var slice = _rsFiltered.slice(0, _rsVisible);
          slice.forEach(function(r) {
            var tr = document.createElement('tr');
            tr.style.cssText = 'border-bottom:1px solid #f0f0f0;transition:background 0.1s;';
            tr.onmouseenter = function(){ this.style.background='#f9fafb'; };
            tr.onmouseleave = function(){ this.style.background=''; };

            function badge(n) {
              return n > 0
                ? '<span style="background:#e5e7eb;color:#374151;padding:2px 9px;border-radius:12px;font-size:0.82rem;font-weight:600;">' + n + 'x</span>'
                : '<span style="color:#d1d5db;font-size:0.85rem;">—</span>';
            }
            var statusBadge = r.t === 0
              ? '<span style="background:#dcfce7;color:#16a34a;padding:3px 10px;border-radius:20px;font-size:0.8rem;font-weight:700;">New</span>'
              : '<span style="background:#f3f4f6;color:#6b7280;padding:3px 10px;border-radius:20px;font-size:0.8rem;">' + r.t + ' total</span>';
            var td = function(content, align) {
              return '<td style="padding:10px 14px;vertical-align:middle;' + (align ? 'text-align:'+align+';' : '') + '">' + content + '</td>';
            };
            var esc2 = function(s) { return s ? s.replace(/</g,'&lt;').replace(/>/g,'&gt;') : ''; };

            var _typeBadge = r.tp === 'external'
              ? '<span style="background:#eff6ff;color:#1d4ed8;padding:1px 6px;border-radius:8px;font-size:0.72rem;font-weight:600;margin-left:5px;">Ext</span>'
              : '<span style="background:#f0fdf4;color:#15803d;padding:1px 6px;border-radius:8px;font-size:0.72rem;font-weight:600;margin-left:5px;">Int</span>';
            tr.innerHTML =
              td('<span style="font-weight:600;color:#111827;font-size:0.9rem;">' + esc2(r.n) + '</span>' + _typeBadge) +
              td('<span style="color:#374151;font-size:0.88rem;">' + (r.s ? esc2(r.s) : '<span style="color:#d1d5db;">—</span>') + '</span>') +
              td('<span style="color:#374151;font-size:0.88rem;">' + (r.e ? esc2(r.e) : '<span style="color:#d1d5db;">—</span>') + '</span>') +
              td('<span style="color:#374151;font-size:0.88rem;">' + (r.d ? esc2(r.d) : '<span style="color:#d1d5db;">—</span>') + '</span>') +
              td(badge(r.ch), 'center') +
              td(badge(r.rc), 'center') +
              td(badge(r.ie), 'center') +
              td(badge(r.ee), 'center') +
              td(statusBadge, 'center');

            // Assign column — built via DOM, handles badge-on-assign + undo
            var assignCell = document.createElement('td');
            assignCell.style.cssText = 'padding:10px 14px;text-align:center;white-space:nowrap;vertical-align:middle;';

            (function(rowName, cell) {
              function buildControls() {
                cell.innerHTML = '';
                var sel = document.createElement('select');
                sel.style.cssText = 'font-size:0.78rem;border-radius:6px;border:1px solid #d1d5db;padding:3px 5px;margin-right:5px;max-width:140px;color:#374151;';
                [['','— role —'],['chair','Chairperson'],['recorder','Secretary'],['internal','Internal Examiner'],['external','External Examiner']].forEach(function(pair) {
                  var o = document.createElement('option'); o.value = pair[0]; o.textContent = pair[1]; sel.appendChild(o);
                });
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.textContent = 'Assign';
                btn.style.cssText = 'font-size:0.78rem;padding:3px 11px;border-radius:6px;background:#0f766e;color:#fff;border:none;cursor:pointer;font-weight:600;';
                btn.onmouseenter = function(){ this.style.background='#0d5f58'; };
                btn.onmouseleave = function(){ this.style.background='#0f766e'; };
                btn.onclick = function() {
                  var role = sel.value;
                  if (!role) { alert('Please select a role first.'); return; }
                  var result = rsDoAssign(rowName, role);
                  if (result) { showBadge(result.id, result.role); }
                };
                cell.appendChild(sel);
                cell.appendChild(btn);
              }

              function showBadge(personId, role) {
                cell.innerHTML = '';
                var wrap = document.createElement('span');
                wrap.style.cssText = 'display:inline-flex;align-items:center;gap:5px;background:#dcfce7;color:#15803d;padding:4px 10px 4px 12px;border-radius:20px;font-size:0.8rem;font-weight:600;';
                wrap.innerHTML = '<i class="bi bi-check-circle-fill" style="font-size:0.82rem;"></i> ' + _ROLE_LABELS[role];
                var undo = document.createElement('button');
                undo.type = 'button';
                undo.title = 'Undo assignment';
                undo.style.cssText = 'background:none;border:none;color:#15803d;cursor:pointer;font-size:1rem;padding:0 0 0 4px;line-height:1;font-weight:700;';
                undo.innerHTML = '&times;';
                undo.onclick = function() {
                  if (role === 'chair' || role === 'recorder') { tsClear(role); }
                  else if (role === 'internal') { mcRemoveInternal(personId); }
                  else { mcRemoveExternal(personId); }
                  buildControls();
                };
                wrap.appendChild(undo);
                cell.appendChild(wrap);
              }

              var _ca = rsCurrentAssignments();
              if (_ca[rowName]) {
                showBadge(_ca[rowName].id, _ca[rowName].role);
              } else {
                buildControls();
              }
            })(r.n, assignCell);

            tr.appendChild(assignCell);
            tbody.appendChild(tr);
          });
          document.getElementById('rsNoResults').style.display = (_rsFiltered.length === 0) ? 'block' : 'none';
          var showMoreWrap = document.getElementById('rsShowMoreWrap');
          if (_rsFiltered.length > _rsVisible) {
            showMoreWrap.style.display = 'block';
            showMoreWrap.querySelector('button').textContent =
              'Show more (' + (_rsFiltered.length - _rsVisible) + ' remaining)';
          } else {
            showMoreWrap.style.display = 'none';
          }
        }

        // Returns a map of {name -> {id, role}} for all currently-assigned panel members
        function rsCurrentAssignments() {
          var map = {};
          var chairName = document.getElementById('ts_chair_label').textContent.trim();
          var chairId   = document.getElementById('ts_chair_val').value;
          if (chairName && chairId) map[chairName] = {id: parseInt(chairId, 10), role: 'chair'};
          var recName = document.getElementById('ts_recorder_label').textContent.trim();
          var recId   = document.getElementById('ts_recorder_val').value;
          if (recName && recId) map[recName] = {id: parseInt(recId, 10), role: 'recorder'};
          mcInternalIds.forEach(function(id) {
            for (var i = 0; i < INTERNAL_STAFF.length; i++) {
              if (INTERNAL_STAFF[i].id === id) { map[INTERNAL_STAFF[i].name] = {id: id, role: 'internal'}; break; }
            }
          });
          mcExternalIds.forEach(function(id) {
            for (var i = 0; i < EXTERNAL_EXAMINERS.length; i++) {
              if (EXTERNAL_EXAMINERS[i].id === id) { map[EXTERNAL_EXAMINERS[i].name] = {id: id, role: 'external'}; break; }
            }
          });
          return map;
        }

        // Returns {id, role} on success, null on failure
        function rsDoAssign(name, role) {
          if (role === 'chair' || role === 'recorder' || role === 'internal') {
            var found = null;
            for (var i = 0; i < INTERNAL_STAFF.length; i++) {
              if (INTERNAL_STAFF[i].name === name) { found = INTERNAL_STAFF[i]; break; }
            }
            if (!found) { alert('"' + name + '" is not in the internal staff list.\nOnly internal staff can be assigned as Chairperson, Secretary, or Internal Examiner.'); return null; }
            if (role === 'chair')         tsSelect('chair',    found.id, found.name);
            else if (role === 'recorder') tsSelect('recorder', found.id, found.name);
            else                          mcAddInternal(found.id, found.name);
            return {id: found.id, role: role};
          } else {
            var found = null;
            for (var i = 0; i < EXTERNAL_EXAMINERS.length; i++) {
              if (EXTERNAL_EXAMINERS[i].name === name) { found = EXTERNAL_EXAMINERS[i]; break; }
            }
            if (!found) { alert('"' + name + '" is not in the verified external examiners list.\nOnly verified examiners can be assigned as External Examiner.'); return null; }
            mcAddExternal(found.id, found.name);
            return {id: found.id, role: role};
          }
        }

        function togglePanelRef() {
          var body = document.getElementById('panelRefBody');
          var icon = document.getElementById('panelRefChevron');
          if (body.style.display === 'none') {
            body.style.display = '';
            icon.className = 'bi bi-chevron-up';
            rsInit(); // lazy-init only on first expand
          } else {
            body.style.display = 'none';
            icon.className = 'bi bi-chevron-down';
          }
        }
        </script>

        <!-- Viva Role Assignment Form — Admin only -->

        <!-- Picker + cascade CSS -->
        <style>
        .ts-picker { position:relative; }
        .ts-box {
          display:flex; align-items:center; flex-wrap:wrap; gap:4px;
          min-height:40px; padding:4px 10px; cursor:text;
          border:1px solid #e5e7eb; border-radius:10px; background:#fff;
        }
        .ts-box:focus-within { border-color:#0f766e; box-shadow:0 0 0 3px rgba(15,118,110,.12); }
        .ts-input { border:none; outline:none; flex:1; min-width:140px; font-size:0.97rem; background:transparent; padding:2px 0; }
        .ts-chip {
          display:inline-flex; align-items:center; gap:5px;
          background:#e5f7f5; color:#0f766e; padding:3px 10px 3px 12px;
          border-radius:20px; font-size:0.88rem; font-weight:500;
        }
        .ts-chip button { background:none; border:none; padding:0; cursor:pointer; color:#0f766e; line-height:1; font-size:0.95rem; }
        .ts-dropdown {
          position:absolute; top:calc(100% + 4px); left:0; right:0; z-index:900;
          background:#fff; border:1px solid #e5e7eb; border-radius:10px;
          box-shadow:0 4px 16px rgba(0,0,0,.10); max-height:240px; overflow-y:auto;
        }
        .ts-opt {
          padding:9px 14px; cursor:pointer; font-size:0.92rem; color:#111827;
          border-bottom:1px solid #f3f4f6;
        }
        .ts-opt:last-child { border-bottom:none; }
        .ts-opt:hover, .ts-opt.ts-focused { background:#f0fdf4; color:#0f766e; }
        .ts-opt .ts-sub { font-size:0.78rem; color:#9ca3af; margin-top:1px; }
        .ts-empty { padding:10px 14px; color:#9ca3af; font-size:0.88rem; }
        /* multi-chip row */
        .mc-row { display:flex; flex-wrap:wrap; gap:6px; margin-bottom:8px; min-height:24px; }
        .mc-chip {
          display:inline-flex; align-items:center; gap:5px;
          background:#e5f7f5; color:#0f766e; padding:4px 10px 4px 12px;
          border-radius:20px; font-size:0.88rem; font-weight:500;
        }
        .mc-chip.ext { background:#eff6ff; color:#1d4ed8; }
        .mc-chip button { background:none; border:none; padding:0; cursor:pointer; color:inherit; line-height:1; font-size:1rem; }
        </style>

        <!-- JSON data for type-to-search -->
        <script>
        var INTERNAL_STAFF = [
          <% for (int _i = 0; _i < internalStaff.size(); _i++) {
               Map<String,Object> _s = internalStaff.get(_i);
               String _sn  = _s.get("full_name")           != null ? _s.get("full_name").toString().replace("\"","\\\"")           : "";
               String _sp  = _s.get("specialization_name") != null ? _s.get("specialization_name").toString().replace("\"","\\\"") : "";
               String _se  = _s.get("expertise_name")      != null ? _s.get("expertise_name").toString().replace("\"","\\\"")      : "";
               String _sd  = _s.get("division_name")       != null ? _s.get("division_name").toString().replace("\"","\\\"")       : "";
               String _sa  = _s.get("area_name")           != null ? _s.get("area_name").toString().replace("\"","\\\"")           : "";
               String _sk  = _s.get("academic_rank")       != null ? _s.get("academic_rank").toString().replace("\"","\\\"")       : "";
          %>{"id":<%= _s.get("id") %>,"name":"<%= _sn %>","spec":"<%= _sp %>","exp":"<%= _se %>","div":"<%= _sd %>","area":"<%= _sa %>","rank":"<%= _sk %>"},
          <% } %>
        ];
        var EXTERNAL_EXAMINERS = [
          <% for (int _i = 0; _i < verifiedExaminers.size(); _i++) {
               Map<String,Object> _e = verifiedExaminers.get(_i);
               String _en  = _e.get("name")               != null ? _e.get("name").toString().replace("\"","\\\"")               : "";
               String _ea  = _e.get("affiliation")        != null ? _e.get("affiliation").toString().replace("\"","\\\"")        : "";
               String _esp = _e.get("specialization_name")!= null ? _e.get("specialization_name").toString().replace("\"","\\\""): "";
               String _eex = _e.get("expertise_name")     != null ? _e.get("expertise_name").toString().replace("\"","\\\"")     : "";
          %>{"id":<%= _e.get("id") %>,"name":"<%= _en %>","affiliation":"<%= _ea %>","spec":"<%= _esp %>","exp":"<%= _eex %>"},
          <% } %>
        ];
        </script>

        <form method="POST" action="<%= request.getContextPath() %>/admin/appointment/decision">
          <input type="hidden" name="id" value="<%= a.getId() %>">
          <% if (!_listUrl.isEmpty()) { %><input type="hidden" name="listUrl" value="<%= _listUrl %>"><% } %>

          <!-- ── Date, Time & Venue ── -->
          <div class="w-100 mb-4 p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <div class="d-flex align-items-center mb-3">
              <i class="bi bi-calendar-event me-2" style="color:#0f766e;font-size:1.15rem;"></i>
              <span class="fw-semibold" style="font-size:1.05rem;">Viva Schedule</span>
            </div>
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="font-size:0.95rem;">Date & Time</label>
                <%
                  String scheduledAtVal = "";
                  if (a.getScheduledAt() != null) {
                      scheduledAtVal = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(a.getScheduledAt());
                  }
                %>
                <input type="datetime-local" name="scheduled_at" class="form-control"
                       style="border-radius:10px;border-color:#e5e7eb;"
                       value="<%= scheduledAtVal %>">
                <input type="hidden" name="duration_minutes" value="90">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="font-size:0.95rem;">Venue / Room</label>
                <select name="venue" class="form-control" style="border-radius:10px;border-color:#e5e7eb;">
                  <option value="">— Select a venue —</option>
                  <% for (Map<String,Object> v : venues) {
                       String vname = v.get("name").toString();
                       String vloc  = v.get("location") != null ? " (" + v.get("location") + ")" : "";
                       boolean vsel = vname.equals(a.getVenue()); %>
                  <option value="<%= vname %>" <%= vsel ? "selected" : "" %>><%= vname %><%= vloc %></option>
                  <% } %>
                  <% if (venues.isEmpty() && a.getVenue() != null && !a.getVenue().isEmpty()) { %>
                  <option value="<%= a.getVenue() %>" selected><%= a.getVenue() %></option>
                  <% } %>
                </select>
                <% if (venues.isEmpty()) { %>
                <div style="font-size:0.78rem;color:#f59e0b;margin-top:4px;">
                  <i class="bi bi-exclamation-triangle me-1"></i>Run migration <strong>013_venue_and_supervisor.sql</strong> to load venue options.
                </div>
                <% } %>
              </div>
            </div>
          </div>

          <div class="w-100 mb-4 p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <div class="d-flex align-items-center mb-3">
              <i class="bi bi-people me-2" style="color:#0f766e;font-size:1.15rem;"></i>
              <span class="fw-semibold" style="font-size:1.05rem;">Viva Role Assignment</span>
            </div>

            <!-- 4-level hierarchy filter for internal staff pickers -->
            <div class="p-3 mb-4" style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;">
              <div class="d-flex align-items-center mb-2" style="font-size:0.85rem;color:#6b7280;font-weight:600;">
                <i class="bi bi-funnel me-1"></i> Filter Internal Staff by Research Field
              </div>
              <div class="row g-2">
                <div class="col-md-3">
                  <select id="ad_spec" class="form-select form-select-sm" style="border-radius:8px;border-color:#e5e7eb;" onchange="adCascade()">
                    <option value="">All Specializations</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <select id="ad_exp" class="form-select form-select-sm" style="border-radius:8px;border-color:#e5e7eb;" onchange="adCascade()">
                    <option value="">All Expertise</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <select id="ad_div" class="form-select form-select-sm" style="border-radius:8px;border-color:#e5e7eb;" onchange="adCascade()">
                    <option value="">All Divisions / Groups</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <select id="ad_area" class="form-select form-select-sm" style="border-radius:8px;border-color:#e5e7eb;" onchange="adRefreshAll()">
                    <option value="">All Areas</option>
                  </select>
                </div>
              </div>
            </div>

            <!-- Chairperson -->
            <div class="mb-3">
              <label class="form-label fw-semibold" style="font-size:0.95rem;">Chairperson <span class="text-danger">*</span></label>
              <div class="ts-picker" id="tsp_chair">
                <input type="hidden" name="chairperson_id" id="ts_chair_val"
                       value="<%= a.getChairpersonId() != null ? a.getChairpersonId() : "" %>">
                <div class="ts-box" onclick="tsFocus('chair')">
                  <div class="ts-chip" id="ts_chair_chip" style="display:none;">
                    <span id="ts_chair_label"></span>
                    <button type="button" onclick="tsClear('chair',event)"><i class="bi bi-x"></i></button>
                  </div>
                  <input type="text" id="ts_chair_input" class="ts-input" placeholder="Type name to search chairperson..."
                         oninput="tsFilter('chair')" onfocus="tsOpen('chair')" onblur="tsBlur('chair')">
                </div>
                <div class="ts-dropdown" id="ts_chair_dd" style="display:none;"></div>
              </div>
            </div>

            <!-- Secretary -->
            <div class="mb-3">
              <label class="form-label fw-semibold" style="font-size:0.95rem;">Secretary <span class="text-danger">*</span></label>
              <div class="ts-picker" id="tsp_recorder">
                <input type="hidden" name="recorder_id" id="ts_recorder_val"
                       value="<%= a.getRecorderId() != null ? a.getRecorderId() : "" %>">
                <div class="ts-box" onclick="tsFocus('recorder')">
                  <div class="ts-chip" id="ts_recorder_chip" style="display:none;">
                    <span id="ts_recorder_label"></span>
                    <button type="button" onclick="tsClear('recorder',event)"><i class="bi bi-x"></i></button>
                  </div>
                  <input type="text" id="ts_recorder_input" class="ts-input" placeholder="Type name to search secretary..."
                         oninput="tsFilter('recorder')" onfocus="tsOpen('recorder')" onblur="tsBlur('recorder')">
                </div>
                <div class="ts-dropdown" id="ts_recorder_dd" style="display:none;"></div>
              </div>
            </div>

            <!-- Internal Examiner (multi) -->
            <div class="mb-3">
              <label class="form-label fw-semibold" style="font-size:0.95rem;">Internal Examiner(s)</label>
              <div id="mc_internal_chips" class="mc-row"></div>
              <div id="mc_internal_hiddens"></div>
              <div class="ts-picker" id="tsp_internal">
                <div class="ts-box" onclick="mcFocus('internal')">
                  <input type="text" id="ts_internal_input" class="ts-input" placeholder="Type to search and add internal examiner..."
                         oninput="tsFilter('internal')" onfocus="mcOpenInternal()" onblur="tsBlur('internal')">
                </div>
                <div class="ts-dropdown" id="ts_internal_dd" style="display:none;"></div>
              </div>
            </div>

            <!-- External Examiner (multi) -->
            <div class="mb-4">
              <label class="form-label fw-semibold" style="font-size:0.95rem;">External Examiner(s)</label>
              <div id="mc_external_chips" class="mc-row"></div>
              <div id="mc_external_hiddens"></div>
              <div class="ts-picker" id="tsp_external">
                <div class="ts-box" onclick="mcFocus('external')">
                  <input type="text" id="ts_external_input" class="ts-input" placeholder="Type to search and add external examiner..."
                         oninput="tsFilterExt()" onfocus="tsOpenExt()" onblur="tsBlurExt()">
                </div>
                <div class="ts-dropdown" id="ts_external_dd" style="display:none;"></div>
              </div>
            </div>

            <hr style="border-color:#f3f4f6;">
            <div id="js-val-err" style="display:none;" class="d-flex align-items-center gap-2 mb-2 p-2" style="background:#fef2f2;border:1px solid #fca5a5;border-radius:8px;">
              <i class="bi bi-exclamation-circle-fill" style="color:#dc2626;"></i>
              <span style="font-size:0.88rem;color:#7f1d1d;">Nothing is filled in. Please add at least the panel members or schedule details before saving.</span>
            </div>
            <div class="d-flex justify-content-end gap-2 mt-3">
              <a href="<%= _backUrl %>" class="btn-ea-back">Cancel</a>
              <% if (!"scheduled".equals(a.getStatus()) && !"letter_generated".equals(a.getStatus()) && !"appointed".equalsIgnoreCase(a.getCandidateVivaStatus())) { %>
              <button type="submit" name="decision" value="defer" class="btn" style="background:#6b7280;color:#fff;border-radius:10px;padding:0.5rem 1.4rem;">
                <i class="bi bi-clock me-1"></i> Defer Decision
              </button>
              <% } %>
              <button type="submit" id="btn-save-appt" name="decision" value="scheduled" class="btn" style="background:#0f766e;color:#fff;border-radius:10px;padding:0.5rem 1.4rem;">
                <i class="bi bi-floppy me-1"></i> Save Appointment
              </button>
            </div>
          </div>

        </form>

        <!-- Generate Letter — shown only after appointment is scheduled -->
        <% if (a != null && "scheduled".equals(a.getStatus())) { %>
        <div class="w-100 mb-4 p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div class="d-flex align-items-center gap-2">
              <i class="bi bi-file-earmark-text" style="color:#0f766e;font-size:1.25rem;"></i>
              <div>
                <div class="fw-semibold" style="font-size:1.05rem;">Appointment Letters</div>
                <div style="font-size:0.85rem;color:#9ca3af;">Preview and send letters to panel members. Use the letter preview to manage approval and per-member sending.</div>
                <% if (_panelTotal > 0) { %>
                <div style="margin-top:4px;">
                  <span style="font-size:0.82rem;font-weight:600;color:<%= _signedCount == _panelTotal ? "#15803d" : "#d97706" %>;">
                    <i class="bi bi-<%= _signedCount == _panelTotal ? "check-circle-fill" : "hourglass-split" %> me-1"></i>
                    <%= _signedCount %>/<%= _panelTotal %> signed letters received
                  </span>
                </div>
                <% } %>
              </div>
            </div>
            <a href="<%= request.getContextPath() %>/admin/appointment/letter/preview?id=<%= a.getId() %><%= !_listUrlEncoded.isEmpty() ? "&listUrl=" + _listUrlEncoded : "" %>"
               class="btn" style="background:#0f766e;color:#fff;border-radius:10px;padding:0.5rem 1.5rem;">
              <i class="bi bi-file-earmark-arrow-down me-1"></i> Generate / Send Letters
            </a>
          </div>
        </div>

        <%-- Panel response summary — visible once letters have been sent --%>
        <%
          int _resp_accepted = 0, _resp_declined = 0, _resp_pending = 0;
          if (a.getPanelMembers() != null) {
            for (Map<String,Object> _rp : a.getPanelMembers()) {
              String _rs = _rp.get("panel_response") != null ? _rp.get("panel_response").toString() : "";
              if ("accepted".equals(_rs)) _resp_accepted++;
              else if ("declined".equals(_rs)) _resp_declined++;
              else if (Boolean.TRUE.equals(_rp.get("letter_sent"))) _resp_pending++;
            }
          }
          boolean _hasResponses = (_resp_accepted + _resp_declined + _resp_pending) > 0;
        %>
        <% if (_hasResponses) { %>
        <div id="panel-responses" class="w-100 mb-4 p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center mb-3">
            <i class="bi bi-people me-2" style="color:#0f766e;font-size:1.15rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Panel Member Responses</span>
          </div>
          <div class="d-flex gap-3 flex-wrap mb-3">
            <% if (_resp_accepted > 0) { %>
            <span style="background:#dcfce7;color:#15803d;padding:4px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">
              <i class="bi bi-check-circle-fill me-1"></i><%= _resp_accepted %> Accepted
            </span>
            <% } %>
            <% if (_resp_declined > 0) { %>
            <span style="background:#fee2e2;color:#b91c1c;padding:4px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">
              <i class="bi bi-x-circle-fill me-1"></i><%= _resp_declined %> Declined
            </span>
            <% } %>
            <% if (_resp_pending > 0) { %>
            <span style="background:#fef3c7;color:#92400e;padding:4px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">
              <i class="bi bi-hourglass-split me-1"></i><%= _resp_pending %> Awaiting
            </span>
            <% } %>
          </div>
          <% if (a.getPanelMembers() != null) { for (Map<String,Object> _rp : a.getPanelMembers()) {
               String _rpName    = _rp.get("name") != null ? _rp.get("name").toString() : "—";
               String _rpRole    = _rp.get("role") != null ? _rp.get("role").toString() : "—";
               String _rpResp    = _rp.get("panel_response") != null ? _rp.get("panel_response").toString() : "";
               String _rpReason  = _rp.get("rejection_reason") != null ? _rp.get("rejection_reason").toString().trim() : "";
               boolean _rpSent   = Boolean.TRUE.equals(_rp.get("letter_sent"));
               boolean _rpAccepted = "accepted".equals(_rpResp);
               boolean _rpDeclined = "declined".equals(_rpResp);
          %>
          <div style="display:flex;align-items:flex-start;gap:10px;padding:8px 0;border-top:1px solid #f3f4f6;">
            <i class="bi bi-<%= _rpAccepted ? "check-circle-fill" : _rpDeclined ? "x-circle-fill" : (_rpSent ? "hourglass-split" : "dash-circle") %>"
               style="color:<%= _rpAccepted ? "#16a34a" : _rpDeclined ? "#b91c1c" : (_rpSent ? "#d97706" : "#d1d5db") %>;font-size:1rem;flex-shrink:0;margin-top:2px;"></i>
            <div style="flex:1;">
              <div style="font-size:0.88rem;font-weight:600;color:#111827;"><%= _rpRole %> — <%= _rpName %></div>
              <div style="font-size:0.78rem;color:<%= _rpAccepted ? "#15803d" : _rpDeclined ? "#b91c1c" : (_rpSent ? "#92400e" : "#9ca3af") %>;">
                <%= _rpAccepted ? "Accepted" : _rpDeclined ? "Declined" : (_rpSent ? "Awaiting response" : "Letter not yet sent") %>
              </div>
              <% if (_rpDeclined && !_rpReason.isEmpty()) { %>
              <div style="font-size:0.78rem;color:#7f1d1d;margin-top:3px;font-style:italic;">"<%= _rpReason.replace("<","&lt;").replace(">","&gt;") %>"</div>
              <% } %>
            </div>
          </div>
          <% } } %>
          <% if (_resp_pending > 0) { %>
          <div style="margin-top:10px;padding:8px 12px;background:#fffbeb;border-radius:8px;font-size:0.8rem;color:#92400e;">
            <i class="bi bi-info-circle me-1"></i>Waiting for <%= _resp_pending %> pending response<%= _resp_pending > 1 ? "s" : "" %>.
          </div>
          <% } %>
        </div>
        <% } %>
        <% } %>

        <!-- Mark as Completed — shown whenever the candidate viva status is appointed -->
        <% if (a != null && "appointed".equalsIgnoreCase(a.getCandidateVivaStatus())) { %>
        <div class="w-100 mb-4 p-4" style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
            <div class="d-flex align-items-center gap-2">
              <i class="bi bi-check2-circle" style="color:#16a34a;font-size:1.25rem;"></i>
              <div>
                <div class="fw-semibold" style="font-size:1.05rem;">Mark Viva as Completed</div>
                <div style="font-size:0.85rem;color:#6b7280;">Click after the viva session has been held. This cannot be undone.</div>
              </div>
            </div>
            <form method="POST" action="<%= request.getContextPath() %>/MarkCandidateCompletedServlet"
                  style="display:inline;margin:0;"
                  onsubmit="return confirm('Mark this candidate\'s viva as completed? This cannot be undone.');">
              <input type="hidden" name="id" value="<%= a.getCandidateId() %>">
              <button type="submit" class="btn d-inline-flex align-items-center gap-2"
                      style="background:#fff;color:#16a34a;border:1.5px solid #16a34a;border-radius:10px;padding:0.5rem 1.5rem;font-weight:600;">
                <i class="bi bi-check2-circle"></i> Mark as Completed
              </button>
            </form>
          </div>
        </div>
        <% } %>

        <% } %>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  // Scroll to anchor on load (used when email notification links include #panel-responses)
  window.addEventListener('DOMContentLoaded', function() {
    if (window.location.hash) {
      var el = document.querySelector(window.location.hash);
      if (el) { setTimeout(function(){ el.scrollIntoView({behavior:'smooth', block:'start'}); }, 300); }
    }
  });
  // ── Helper ──────────────────────────────────────────────────────────────
  function esc(s) { return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }

  // ── Internal staff roles (single-select) ────────────────────────────────
  var INTERNAL_ROLES_SINGLE = ['chair','recorder'];

  function adGetFilter() {
    return {
      spec : document.getElementById('ad_spec').value,
      exp  : document.getElementById('ad_exp').value,
      div  : document.getElementById('ad_div').value,
      area : document.getElementById('ad_area').value
    };
  }

  function adFilteredStaff() {
    var f = adGetFilter();
    return INTERNAL_STAFF.filter(function(s) {
      return (!f.spec || s.spec === f.spec)
          && (!f.exp  || s.exp  === f.exp)
          && (!f.div  || s.div  === f.div)
          && (!f.area || s.area === f.area);
    });
  }

  // Single-select internal picker (chair, recorder)
  function tsBuildInternal(role) {
    var q   = document.getElementById('ts_'+role+'_input').value.toLowerCase().trim();
    var pool = adFilteredStaff();
    // Exclude already-selected in multi-internal AND in other single-select roles
    pool = pool.filter(function(s) {
      if (mcInternalIds.has(s.id)) return false;
      var others = INTERNAL_ROLES_SINGLE.filter(function(r){ return r !== role; });
      for (var i = 0; i < others.length; i++) {
        var v = document.getElementById('ts_'+others[i]+'_val').value;
        if (v && String(s.id) === String(v)) return false;
      }
      return true;
    });
    if (q) pool = pool.filter(function(s){ return s.name.toLowerCase().indexOf(q) !== -1; });
    var dd = document.getElementById('ts_'+role+'_dd');
    if (!pool.length) { dd.innerHTML = '<div class="ts-empty">No staff found</div>'; return; }
    dd.innerHTML = pool.map(function(s) {
      var sub = [s.spec, s.exp, s.div].filter(Boolean).join(' › ');
      return '<div class="ts-opt" onmousedown="tsSelect(\''+role+'\','+s.id+',\''+esc(s.name)+'\')">'
           + esc(s.name)
           + (s.rank ? ' <span style="font-size:0.8rem;color:#6b7280;">— '+esc(s.rank)+'</span>' : '')
           + (sub ? '<div class="ts-sub">'+esc(sub)+'</div>' : '')
           + '</div>';
    }).join('');
  }

  function tsOpen(role) { tsBuildInternal(role); document.getElementById('ts_'+role+'_dd').style.display = ''; }
  function mcOpenInternal() { mcBuildInternal(); document.getElementById('ts_internal_dd').style.display = ''; }
  function tsFilter(role) {
    if (role === 'internal') { mcBuildInternal(); document.getElementById('ts_internal_dd').style.display=''; return; }
    tsBuildInternal(role); document.getElementById('ts_'+role+'_dd').style.display = '';
  }
  function tsSelect(role, id, label) {
    document.getElementById('ts_'+role+'_val').value   = id;
    document.getElementById('ts_'+role+'_label').textContent = label;
    document.getElementById('ts_'+role+'_chip').style.display = '';
    document.getElementById('ts_'+role+'_input').style.display = 'none';
    document.getElementById('ts_'+role+'_dd').style.display = 'none';
  }
  function tsClear(role, ev) {
    if (ev) ev.stopPropagation();
    document.getElementById('ts_'+role+'_val').value   = '';
    document.getElementById('ts_'+role+'_chip').style.display = 'none';
    document.getElementById('ts_'+role+'_input').style.display = '';
    document.getElementById('ts_'+role+'_input').value = '';
    document.getElementById('ts_'+role+'_dd').style.display = 'none';
    document.getElementById('ts_'+role+'_input').focus();
  }
  function tsFocus(role) { var inp = document.getElementById('ts_'+role+'_input'); if (inp.style.display !== 'none') inp.focus(); }
  function tsBlur(role) { setTimeout(function() { document.getElementById('ts_'+role+'_dd').style.display = 'none'; }, 180); }

  // ── Multi-chip picker for internal examiners ────────────────────────────
  var mcInternalIds = new Set();

  function mcFocus(type) { document.getElementById('ts_'+type+'_input').focus(); }

  function mcBuildInternal() {
    var q = document.getElementById('ts_internal_input').value.toLowerCase().trim();
    var pool = adFilteredStaff().filter(function(s) {
      if (mcInternalIds.has(s.id)) return false;
      // Exclude whoever is already selected as chair or recorder
      for (var i = 0; i < INTERNAL_ROLES_SINGLE.length; i++) {
        var v = document.getElementById('ts_'+INTERNAL_ROLES_SINGLE[i]+'_val').value;
        if (v && String(s.id) === String(v)) return false;
      }
      return true;
    });
    if (q) pool = pool.filter(function(s){ return s.name.toLowerCase().indexOf(q) !== -1; });
    var dd = document.getElementById('ts_internal_dd');
    if (!pool.length) { dd.innerHTML = '<div class="ts-empty">No staff found</div>'; return; }
    dd.innerHTML = pool.map(function(s) {
      var sub = [s.spec, s.exp, s.div].filter(Boolean).join(' › ');
      return '<div class="ts-opt" onmousedown="mcAddInternal('+s.id+',\''+esc(s.name)+'\')">'
           + esc(s.name)
           + (s.rank ? ' <span style="font-size:0.8rem;color:#6b7280;">— '+esc(s.rank)+'</span>' : '')
           + (sub ? '<div class="ts-sub">'+esc(sub)+'</div>' : '')
           + '</div>';
    }).join('');
  }

  function mcAddInternal(id, label) {
    if (mcInternalIds.has(id)) return;
    mcInternalIds.add(id);
    var chips = document.getElementById('mc_internal_chips');
    var chip = document.createElement('div');
    chip.className = 'mc-chip';
    chip.id = 'mc_int_chip_'+id;
    chip.innerHTML = '<i class="bi bi-person-fill" style="font-size:0.82rem;"></i>'
                   + '<span>'+esc(label)+'</span>'
                   + '<button type="button" onclick="mcRemoveInternal('+id+')"><i class="bi bi-x"></i></button>';
    chips.appendChild(chip);
    var hiddens = document.getElementById('mc_internal_hiddens');
    var h = document.createElement('input');
    h.type='hidden'; h.name='internal_examiner_id'; h.value=id; h.id='mc_int_h_'+id;
    hiddens.appendChild(h);
    document.getElementById('ts_internal_input').value='';
    document.getElementById('ts_internal_dd').style.display='none';
  }

  function mcRemoveInternal(id) {
    mcInternalIds.delete(id);
    var chip = document.getElementById('mc_int_chip_'+id);
    if (chip) chip.remove();
    var h = document.getElementById('mc_int_h_'+id);
    if (h) h.remove();
  }

  // ── Multi-chip picker for external examiners ────────────────────────────
  var mcExternalIds = new Set();

  function tsBuildExternal() {
    var q  = document.getElementById('ts_external_input').value.toLowerCase().trim();
    var pool = EXTERNAL_EXAMINERS.filter(function(e){ return !mcExternalIds.has(e.id); });
    if (q) pool = pool.filter(function(e){ return e.name.toLowerCase().indexOf(q) !== -1; });
    var dd = document.getElementById('ts_external_dd');
    if (!pool.length) { dd.innerHTML = '<div class="ts-empty">No verified examiners found</div>'; return; }
    dd.innerHTML = pool.map(function(e) {
      var sub = [e.affiliation, e.spec, e.exp].filter(Boolean).join(' · ');
      return '<div class="ts-opt" onmousedown="mcAddExternal('+e.id+',\''+esc(e.name)+'\')">'
           + esc(e.name)
           + (sub ? '<div class="ts-sub">'+esc(sub)+'</div>' : '')
           + '</div>';
    }).join('');
  }

  function tsOpenExt() { tsBuildExternal(); document.getElementById('ts_external_dd').style.display = ''; }
  function tsFilterExt() { tsBuildExternal(); document.getElementById('ts_external_dd').style.display = ''; }
  function tsBlurExt() { setTimeout(function() { document.getElementById('ts_external_dd').style.display = 'none'; }, 180); }

  function mcAddExternal(id, label) {
    if (mcExternalIds.has(id)) return;
    mcExternalIds.add(id);
    var chips = document.getElementById('mc_external_chips');
    var chip = document.createElement('div');
    chip.className = 'mc-chip ext';
    chip.id = 'mc_ext_chip_'+id;
    chip.innerHTML = '<i class="bi bi-globe2" style="font-size:0.82rem;"></i>'
                   + '<span>'+esc(label)+'</span>'
                   + '<button type="button" onclick="mcRemoveExternal('+id+')"><i class="bi bi-x"></i></button>';
    chips.appendChild(chip);
    var hiddens = document.getElementById('mc_external_hiddens');
    var h = document.createElement('input');
    h.type='hidden'; h.name='external_examiner_id'; h.value=id; h.id='mc_ext_h_'+id;
    hiddens.appendChild(h);
    document.getElementById('ts_external_input').value='';
    document.getElementById('ts_external_dd').style.display='none';
  }

  function mcRemoveExternal(id) {
    mcExternalIds.delete(id);
    var chip = document.getElementById('mc_ext_chip_'+id);
    if (chip) chip.remove();
    var h = document.getElementById('mc_ext_h_'+id);
    if (h) h.remove();
  }

  // ── 4-level cascade for internal filter ────────────────────────────────
  function adPopulateSpec() {
    var sel = document.getElementById('ad_spec'); var cur = sel.value; var vals = [];
    INTERNAL_STAFF.forEach(function(s) { if (s.spec && vals.indexOf(s.spec)===-1) vals.push(s.spec); });
    vals.sort(); while (sel.options.length > 1) sel.remove(1);
    vals.forEach(function(v){ var o=document.createElement('option');o.value=v;o.textContent=v;sel.appendChild(o); });
    sel.value = vals.indexOf(cur)!==-1?cur:'';
  }
  function adPopulateExp(specVal) {
    var sel = document.getElementById('ad_exp'); var cur = sel.value; var vals = [];
    INTERNAL_STAFF.forEach(function(s){ if((!specVal||s.spec===specVal)&&s.exp&&vals.indexOf(s.exp)===-1) vals.push(s.exp); });
    vals.sort(); while (sel.options.length > 1) sel.remove(1);
    vals.forEach(function(v){ var o=document.createElement('option');o.value=v;o.textContent=v;sel.appendChild(o); });
    sel.value = vals.indexOf(cur)!==-1?cur:'';
  }
  function adPopulateDiv(specVal, expVal) {
    var sel = document.getElementById('ad_div'); var cur = sel.value; var vals = [];
    INTERNAL_STAFF.forEach(function(s){ if((!specVal||s.spec===specVal)&&(!expVal||s.exp===expVal)&&s.div&&vals.indexOf(s.div)===-1) vals.push(s.div); });
    vals.sort(); while (sel.options.length > 1) sel.remove(1);
    vals.forEach(function(v){ var o=document.createElement('option');o.value=v;o.textContent=v;sel.appendChild(o); });
    sel.value = vals.indexOf(cur)!==-1?cur:'';
  }
  function adPopulateArea(specVal, divVal) {
    var sel = document.getElementById('ad_area'); var cur = sel.value; var vals = [];
    INTERNAL_STAFF.forEach(function(s){ if((!specVal||s.spec===specVal)&&(!divVal||s.div===divVal)&&s.area&&vals.indexOf(s.area)===-1) vals.push(s.area); });
    vals.sort(); while (sel.options.length > 1) sel.remove(1);
    vals.forEach(function(v){ var o=document.createElement('option');o.value=v;o.textContent=v;sel.appendChild(o); });
    sel.value = vals.indexOf(cur)!==-1?cur:'';
  }
  function adRefreshAll() {
    INTERNAL_ROLES_SINGLE.forEach(function(role){ var dd=document.getElementById('ts_'+role+'_dd'); if(dd.style.display!=='none') tsBuildInternal(role); });
    var dd=document.getElementById('ts_internal_dd'); if(dd.style.display!=='none') mcBuildInternal();
  }
  function adCascade() {
    var spec=document.getElementById('ad_spec').value;
    adPopulateExp(spec);
    adPopulateDiv(spec, document.getElementById('ad_exp').value);
    adPopulateArea(spec, document.getElementById('ad_div').value);
    adRefreshAll();
  }

  // ── Client-side guard for Save Appointment ────────────────────────────
  document.getElementById('btn-save-appt').addEventListener('click', function(e) {
    var chairVal    = document.getElementById('ts_chair_val').value;
    var recorderVal = document.getElementById('ts_recorder_val').value;
    var hasInternal = document.querySelectorAll('#mc_internal_hiddens input').length > 0;
    var hasExternal = document.querySelectorAll('#mc_external_hiddens input').length > 0;
    var hasDate     = document.querySelector('[name="scheduled_at"]').value.trim() !== '';
    var hasVenue    = document.querySelector('[name="venue"]').value.trim() !== '';
    var hasAny      = chairVal || recorderVal || hasInternal || hasExternal || hasDate || hasVenue;
    if (!hasAny) {
      e.preventDefault();
      var errDiv = document.getElementById('js-val-err');
      errDiv.style.display = 'flex';
      errDiv.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  });

  // ── Pre-select on load ──────────────────────────────────────────────────
  <%
    // Inject existing panel members for pre-population
    java.util.List<java.util.Map<String,Object>> _pm = a.getPanelMembers();
  %>
  (function init() {
    adPopulateSpec(); adPopulateExp(''); adPopulateDiv('',''); adPopulateArea('','');

    // Single pickers: chair, recorder
    INTERNAL_ROLES_SINGLE.forEach(function(role) {
      var val = document.getElementById('ts_'+role+'_val').value;
      if (val) {
        var found = INTERNAL_STAFF.filter(function(s){ return String(s.id)===String(val); })[0];
        if (found) tsSelect(role, found.id, found.name);
      }
    });

    // Pre-populate multi internal examiners
    <%
    for (java.util.Map<String,Object> _m : _pm) {
      if ("Internal Examiner".equals(_m.get("role")) && _m.get("internal_user_id") != null) {
        String _pname = _m.get("name") != null ? _m.get("name").toString().replace("\"","\\\"") : "";
    %>
    mcAddInternal(<%= _m.get("internal_user_id") %>, '<%= _pname %>');
    <%
      }
    }
    %>

    // Pre-populate multi external examiners
    <%
    for (java.util.Map<String,Object> _m : _pm) {
      if ("External Examiner".equals(_m.get("role")) && _m.get("external_examiner_id") != null) {
        String _pname = _m.get("name") != null ? _m.get("name").toString().replace("\"","\\\"") : "";
    %>
    mcAddExternal(<%= _m.get("external_examiner_id") %>, '<%= _pname %>');
    <%
      }
    }
    %>
  })();
  </script>
</body>
</html>
