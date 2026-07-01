<%--
  Admin/Dean: table of nominations whose examiner has not yet confirmed (or has reported
  discrepancies in) their profile. isDeanUr flag controls role-specific nav/links.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
  String fullName = (String) session.getAttribute("full_name");
  if (fullName == null || fullName.trim().isEmpty()) {
    String roleForName = (String) session.getAttribute("role_name");
    fullName = (roleForName != null && !roleForName.isEmpty()) ? roleForName : "User";
  }
  String roleNameUr = (String) session.getAttribute("role_name");
  boolean isDeanUr = "Dean".equals(roleNameUr);
  String fromSection = request.getParameter("from");
  @SuppressWarnings("unchecked")
  List<Map<String,Object>> rows = (List<Map<String,Object>>) request.getAttribute("reportRows");
  if (rows == null) rows = new java.util.ArrayList<>();

  java.util.Map<String,List<Map<String,Object>>> byNominator = new java.util.LinkedHashMap<>();
  for (Map<String,Object> r : rows) {
    String nom = r.get("nominator") != null ? r.get("nominator").toString() : "Unknown";
    byNominator.computeIfAbsent(nom, k -> new java.util.ArrayList<>()).add(r);
  }
  String printDate = new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(new java.util.Date());
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Unverified Examiner Nominations - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    .print-only { display: none; }

    @media print {
      @page { size: A4 landscape; margin: 10mm 12mm; }
      .topbar, .sidebar, .no-print { display: none !important; }
      .ea-layout  { display: block !important; }
      .ea-content { margin: 0 !important; padding: 0 !important; }
      .ea-main-content-centered { max-width: 100% !important; padding: 0 !important; }
      .print-only { display: block !important; }
      body { font-size: 9pt; color: #111; -webkit-print-color-adjust: exact; print-color-adjust: exact; }

      .pt { width: 100%; border-collapse: collapse; margin-bottom: 12px; }
      .pt th { background: #e5e7eb; font-size: 7.5pt; font-weight: 600; padding: 5px 6px;
               border: 1px solid #9ca3af; text-align: left;
               -webkit-print-color-adjust: exact; print-color-adjust: exact; }
      .pt td { font-size: 7.5pt; padding: 4px 5px; border: 1px solid #d1d5db; vertical-align: top; }
      .pt tbody tr:nth-child(even) td { background: #f9fafb;
               -webkit-print-color-adjust: exact; print-color-adjust: exact; }
      tr { page-break-inside: avoid; }

      .ps { font-size: 10pt; font-weight: 700; border-bottom: 2px solid #374151;
            padding-bottom: 3px; margin: 14px 0 5px; color: #111; }
      .pn { font-size: 8.5pt; font-weight: 700; color: #105e60; margin: 8px 0 3px; }
    }

    .group-card {
      background: #fff; border: 1px solid #e5e7eb; border-radius: 16px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04); margin-bottom: 1.25rem; overflow: hidden;
    }
    .group-header {
      background: #f0fdf4; border-bottom: 1px solid #d1fae5;
      padding: 12px 20px; display: flex; align-items: center; gap: 10px;
    }
    .status-badge {
      display: inline-block; padding: 3px 12px; border-radius: 20px;
      font-size: 0.85rem; font-weight: 600; white-space: nowrap;
    }
  </style>
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout ea-layout">
    <% request.setAttribute("activeSection", isDeanUr ? "reports" : ("reports".equals(fromSection) ? "reports" : "examiner")); request.setAttribute("activeSubSection", isDeanUr ? "deanReportUnverified" : "reportUnverified"); %>
    <% if (isDeanUr) { %>
      <jsp:include page="/dean/sidebar.jsp" />
    <% } else { %>
      <jsp:include page="/admin/sidebar.jsp" />
    <% } %>

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

        <%-- ╔══════════════════════════════════════════════════════════════╗
             ║   PRINT-ONLY PROFESSIONAL REPORT                           ║
             ╚══════════════════════════════════════════════════════════════╝ --%>
        <div class="print-only">

          <%-- Letterhead Header --%>
          <img src="<%= request.getContextPath() %>/images/lh-header.png"
               alt="FSKM Letterhead" style="width:100%;display:block;margin-bottom:6px;"
               onerror="this.style.display='none'">
          <div style="font-size:12.5pt;font-weight:700;color:#111;margin:4px 0 1px;">
            Unverified Examiner Nominations Report
          </div>
          <div style="font-size:7.5pt;color:#555;margin-bottom:2px;">
            Generated: <%= printDate %> &nbsp;|&nbsp; Prepared by: <%= fullName %> &nbsp;|&nbsp; Faculty of Computer Science and Mathematics, UMT
          </div>
          <hr style="border:none;border-top:1.5px solid #374151;margin:4px 0 10px;">

          <%-- TABLE 1: Summary --%>
          <div class="ps">1. Summary</div>
          <table class="pt">
            <thead><tr><th style="width:50%;">Metric</th><th>Value</th></tr></thead>
            <tbody>
              <tr><td>Total Unverified Nominations</td><td style="font-weight:700;"><%= rows.size() %></td></tr>
              <tr><td>Total Nominating Academicians</td><td style="font-weight:700;"><%= byNominator.size() %></td></tr>
            </tbody>
          </table>

          <%-- TABLE 2+: Nominations grouped by Academician --%>
          <div class="ps">2. Nominations by Academician</div>
          <% if (byNominator.isEmpty()) { %>
          <div style="font-size:8pt;color:#065f46;font-weight:600;margin:6px 0;">No unverified nominations found. &#10003;</div>
          <% } else { int _gno = 0; for (Map.Entry<String,List<Map<String,Object>>> entry : byNominator.entrySet()) { _gno++; %>
          <div class="pn"><%= _gno %>. <%= entry.getKey() %> &mdash; <%= entry.getValue().size() %> nomination(s)</div>
          <table class="pt">
            <thead>
              <tr>
                <th style="width:18px;">#</th>
                <th>Examiner Name</th>
                <th>University / Affiliation</th>
                <th>Specialization</th>
                <th>Expertise</th>
                <th>Date Nominated</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <% int _rno = 0; for (Map<String,Object> r : entry.getValue()) { _rno++; %>
              <tr>
                <td><%= _rno %></td>
                <td style="font-weight:600;"><%= r.get("examiner") != null ? r.get("examiner") : "—" %></td>
                <td><%= r.get("university") != null ? r.get("university") : "—" %></td>
                <td><%= r.get("specialization") != null && !r.get("specialization").toString().isEmpty() ? r.get("specialization") : "—" %></td>
                <td><%= r.get("expertise") != null ? r.get("expertise") : "—" %></td>
                <td><%= r.get("date") != null ? r.get("date") : "—" %></td>
                <td><%= r.get("status") != null ? r.get("status").toString().replace("_"," ") : "—" %></td>
              </tr>
              <% } %>
            </tbody>
          </table>
          <% } } %>

          <%-- Letterhead Footer --%>
          <div style="margin-top:14mm;">
            <img src="<%= request.getContextPath() %>/images/lh-footer.png"
                 alt="" style="width:100%;display:block;"
                 onerror="this.style.display='none'">
          </div>
        </div>
        <%-- END PRINT-ONLY SECTION --%>


        <%-- ╔══════════════════════════════════════════════════════════════╗
             ║   SCREEN VIEW (all hidden on print)                        ║
             ╚══════════════════════════════════════════════════════════════╝ --%>

        <!-- Page Header -->
        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3 no-print">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Unverified Examiner Nominations</h1>
            <div style="font-size:1rem;color:#6b7280;">Pending nominations grouped by nominating academician</div>
          </div>
          <div class="d-flex gap-2 flex-wrap">
            <button onclick="window.print()" class="ea-btn-teal-outline" style="font-size:0.95rem;">
              <i class="bi bi-printer"></i> Print / Save as PDF
            </button>
          </div>
        </div>

        <!-- Summary + Filter Row -->
        <div class="d-flex align-items-center justify-content-between mb-4 no-print flex-wrap gap-3">
          <div class="d-flex gap-3 flex-wrap">
            <div style="background:#fff;border:1px solid #e5e7eb;border-radius:14px;box-shadow:0 2px 8px rgba(0,0,0,0.04);padding:14px 22px;display:flex;align-items:center;gap:12px;">
              <span style="background:rgba(15,118,110,0.10);color:#0f766e;width:36px;height:36px;border-radius:10px;display:inline-flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;">
                <i class="bi bi-file-earmark-text"></i>
              </span>
              <div>
                <div style="font-size:0.78rem;color:#6b7280;font-weight:500;">Total Unverified</div>
                <div style="font-size:1.5rem;font-weight:700;color:#0f766e;line-height:1.1;"><%= rows.size() %></div>
              </div>
            </div>
            <div style="background:#fff;border:1px solid #e5e7eb;border-radius:14px;box-shadow:0 2px 8px rgba(0,0,0,0.04);padding:14px 22px;display:flex;align-items:center;gap:12px;">
              <span style="background:rgba(59,130,246,0.10);color:#2563eb;width:36px;height:36px;border-radius:10px;display:inline-flex;align-items:center;justify-content:center;font-size:1.1rem;flex-shrink:0;">
                <i class="bi bi-people"></i>
              </span>
              <div>
                <div style="font-size:0.78rem;color:#6b7280;font-weight:500;">Nominators</div>
                <div style="font-size:1.5rem;font-weight:700;color:#2563eb;line-height:1.1;"><%= byNominator.size() %></div>
              </div>
            </div>
          </div>
          <div class="d-flex gap-2 flex-wrap" id="groupTabs">
            <button class="ea-filter-tab active" id="tabByAcademician" onclick="showGroup('academician')">By Academician</button>
            <button class="ea-filter-tab" id="tabByDate"              onclick="showGroup('date')">By Date</button>
            <button class="ea-filter-tab" id="tabBySpec"              onclick="showGroup('spec')">By Specialization</button>
            <button class="ea-filter-tab" id="tabFlat"               onclick="showGroup('flat')">All Nominations</button>
          </div>
        </div>

        <!-- By Academician view -->
        <div id="viewAcademician" class="no-print">
          <% if (byNominator.isEmpty()) { %>
          <div class="text-center py-5 text-muted">No unverified nominations found.</div>
          <% } else { for (Map.Entry<String,List<Map<String,Object>>> entry : byNominator.entrySet()) { %>
          <div class="group-card">
            <div class="group-header">
              <i class="bi bi-person-circle" style="color:#0f766e;font-size:1.15rem;"></i>
              <span style="font-weight:700;color:#105e60;font-size:1rem;"><%= entry.getKey() %></span>
              <span class="ms-auto" style="font-size:0.85rem;color:#6b7280;"><%= entry.getValue().size() %> nomination(s)</span>
            </div>
            <div class="table-responsive">
              <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.9rem;">
                <thead>
                  <tr>
                    <th>Examiner Name</th>
                    <th>University / Affiliation</th>
                    <th>Specialization</th>
                    <th>Expertise</th>
                    <th>Date Nominated</th>
                    <th>Status</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <% for (Map<String,Object> r : entry.getValue()) { %>
                  <tr>
                    <td style="font-weight:600;color:#105e60;"><%= r.get("examiner") != null ? r.get("examiner") : "—" %></td>
                    <td style="color:#374151;"><%= r.get("university") != null ? r.get("university") : "—" %></td>
                    <td><% String sp = r.get("specialization") != null ? r.get("specialization").toString() : ""; %>
                      <% if (!sp.isEmpty()) { %><span style="background:#f0fdf4;border:1px solid #a7f3d0;border-radius:8px;padding:2px 8px;font-size:0.82rem;color:#065f46;white-space:nowrap;"><%= sp %></span><% } else { %>—<% } %>
                    </td>
                    <td style="color:#6b7280;font-size:0.87rem;"><%= r.get("expertise") != null ? r.get("expertise") : "—" %></td>
                    <td style="color:#6b7280;"><%= r.get("date") != null ? r.get("date") : "—" %></td>
                    <td>
                      <% String st = r.get("status") != null ? r.get("status").toString() : ""; %>
                      <span class="status-badge status-<%= st %>"><%= st.replace("_"," ") %></span>
                    </td>
                    <td>
                      <a href="<%= request.getContextPath() %>/ViewNominationServlet?id=<%= r.get("id") %>&from=unverifiedReport&reportFrom=<%= fromSection != null ? fromSection : "examiner" %>"
                         class="ea-btn-teal-outline">
                        Review
                      </a>
                    </td>
                  </tr>
                  <% } %>
                </tbody>
              </table>
            </div>
          </div>
          <% } } %>
        </div>

        <!-- By Date view -->
        <div id="viewDate" style="display:none;" class="no-print"></div>
        <!-- By Specialization view -->
        <div id="viewSpec" style="display:none;" class="no-print"></div>

        <!-- Flat (All) view -->
        <div id="viewFlat" style="display:none;" class="no-print">
          <div class="group-card">
            <div class="table-responsive">
              <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.9rem;">
                <thead>
                  <tr>
                    <th>Nominated By</th>
                    <th>Examiner Name</th>
                    <th>University</th>
                    <th>Specialization</th>
                    <th>Date</th>
                    <th>Status</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody id="flatTbody">
                  <% for (Map<String,Object> r : rows) { %>
                  <tr
                    data-date="<%= r.get("date") != null ? r.get("date") : "" %>"
                    data-spec="<%= r.get("specialization") != null ? r.get("specialization").toString().toLowerCase() : "" %>">
                    <td><%= r.get("nominator") != null ? r.get("nominator") : "—" %></td>
                    <td style="font-weight:600;color:#105e60;"><%= r.get("examiner") != null ? r.get("examiner") : "—" %></td>
                    <td><%= r.get("university") != null ? r.get("university") : "—" %></td>
                    <td><% String sp2 = r.get("specialization") != null ? r.get("specialization").toString() : ""; %>
                      <% if (!sp2.isEmpty()) { %><span style="background:#f0fdf4;border:1px solid #a7f3d0;border-radius:8px;padding:2px 8px;font-size:0.82rem;color:#065f46;white-space:nowrap;"><%= sp2 %></span><% } else { %>—<% } %>
                    </td>
                    <td style="color:#6b7280;"><%= r.get("date") != null ? r.get("date") : "—" %></td>
                    <td><span class="status-badge status-<%= r.get("status") %>"><%= r.get("status") != null ? r.get("status").toString().replace("_"," ") : "" %></span></td>
                    <td>
                      <a href="<%= request.getContextPath() %>/ViewNominationServlet?id=<%= r.get("id") %>&from=unverifiedReport&reportFrom=<%= fromSection != null ? fromSection : "examiner" %>"
                         class="ea-btn-teal-outline">Review</a>
                    </td>
                  </tr>
                  <% } %>
                </tbody>
              </table>
            </div>
          </div>
        </div>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  // Auto-print when opened from the Reports hub with ?autoprint=1
  if (new URLSearchParams(window.location.search).get('autoprint') === '1') {
    window.addEventListener('load', function() { setTimeout(window.print, 400); });
  }

  (function(){
    var flatRows = document.querySelectorAll('#flatTbody tr');

    function buildGroupedView(containerId, keyFn, labelFn) {
      var container = document.getElementById(containerId);
      if (container.children.length > 0) return;
      var groups = {}, order = [];
      flatRows.forEach(function(tr) {
        var key = keyFn(tr);
        if (!groups[key]) { groups[key] = []; order.push(key); }
        groups[key].push(tr.cloneNode(true));
      });
      order.forEach(function(key) {
        var card = document.createElement('div'); card.className = 'group-card';
        var header = '<div class="group-header"><span style="font-weight:700;color:#105e60;">' + labelFn(key) +
                     '</span><span class="ms-auto" style="font-size:0.85rem;color:#6b7280;">' + groups[key].length + ' nomination(s)</span></div>';
        var tbl = '<div class="table-responsive"><table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.9rem;">';
        tbl += document.querySelector('#viewFlat table thead').outerHTML;
        tbl += '<tbody>';
        groups[key].forEach(function(r){ tbl += r.outerHTML; });
        tbl += '</tbody></table></div>';
        card.innerHTML = header + tbl;
        container.appendChild(card);
      });
      if (order.length === 0) container.innerHTML = '<div class="text-center py-5 text-muted">No unverified nominations found.</div>';
    }

    window.showGroup = function(view) {
      document.getElementById('viewAcademician').style.display = 'none';
      document.getElementById('viewDate').style.display        = 'none';
      document.getElementById('viewSpec').style.display        = 'none';
      document.getElementById('viewFlat').style.display        = 'none';
      document.querySelectorAll('#groupTabs .ea-filter-tab').forEach(function(b){ b.classList.remove('active'); });

      var activeBtn = document.getElementById(
        view==='academician' ? 'tabByAcademician' :
        view==='date'        ? 'tabByDate'        :
        view==='spec'        ? 'tabBySpec'        : 'tabFlat');
      activeBtn.classList.add('active');

      if (view === 'academician') {
        document.getElementById('viewAcademician').style.display = '';
      } else if (view === 'date') {
        buildGroupedView('viewDate', function(tr){ return tr.dataset.date || 'Unknown'; }, function(k){ return 'Date: ' + k; });
        document.getElementById('viewDate').style.display = '';
      } else if (view === 'spec') {
        buildGroupedView('viewSpec', function(tr){ return tr.dataset.spec || 'unknown'; }, function(k){ return 'Specialization: ' + (k || 'Not specified'); });
        document.getElementById('viewSpec').style.display = '';
      } else {
        document.getElementById('viewFlat').style.display = '';
      }
    };
  })();
  </script>
</body>
</html>
