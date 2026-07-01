<%--
  Admin/Dean: CSV export selection page. isDeanExp flag is used to show/hide admin-only
  export options; form POSTs to ExportReportsServlet which streams the file download.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String fullName = (String) session.getAttribute("full_name"); if (fullName == null) fullName = "Admin";
  String roleNavExp = (String) session.getAttribute("role_name");
  boolean isDeanExp = "Dean".equals(roleNavExp);
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Reports - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    @media print {
      .topbar, .sidebar, .no-print { display: none !important; }
      .ea-layout { display: block !important; }
      .ea-content { margin: 0 !important; padding: 0 !important; }
    }
    .report-card {
      background: #fff; border: 1px solid #e5e7eb; border-radius: 16px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04); padding: 24px 28px;
      display: flex; align-items: flex-start; gap: 18px;
      transition: box-shadow 0.15s, border-color 0.15s;
      text-decoration: none; color: inherit;
    }
    .report-card:hover {
      box-shadow: 0 4px 16px rgba(15,118,110,0.12); border-color: #a7f3d0;
    }
  </style>
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout ea-layout">
    <% request.setAttribute("activeSection", isDeanExp ? "export" : "reports"); request.setAttribute("activeSubSection", "exportReports"); %>
    <% if (isDeanExp) { %>
      <jsp:include page="/dean/sidebar.jsp" />
    <% } else { %>
      <jsp:include page="/admin/sidebar.jsp" />
    <% } %>

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;max-width:860px;">

        <div class="d-flex align-items-start justify-content-between mb-4 flex-wrap gap-3 no-print">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Reports</h1>
            <div style="font-size:1rem;color:#6b7280;">View and print professional faculty reports</div>
          </div>
        </div>

        <div class="d-flex flex-column gap-3">

          <!-- Appointment Statistics -->
          <div class="report-card" style="cursor:pointer;"
               onclick="openReport('<%= request.getContextPath() %><%= isDeanExp ? "/dean/reports/appointments" : "/admin/reports/appointments" %>?autoprint=1')">
            <div style="background:rgba(15,118,110,0.10);color:#0f766e;width:48px;height:48px;border-radius:14px;
                        display:flex;align-items:center;justify-content:center;font-size:1.4rem;flex-shrink:0;">
              <i class="bi bi-bar-chart-line"></i>
            </div>
            <div style="flex:1;">
              <div style="font-size:1.05rem;font-weight:700;color:#105e60;margin-bottom:3px;">Appointment Statistics</div>
              <div style="font-size:0.88rem;color:#6b7280;line-height:1.5;">
                Full report with summary stats, appointment progress, examiner role frequency, all appointments,
                pending decisions, and panel response tracking. Includes FSKM letterhead. Opens for the current year.
              </div>
              <div style="margin-top:8px;display:flex;align-items:center;gap:8px;">
                <span style="background:#f0fdf4;color:#065f46;border:1px solid #a7f3d0;border-radius:8px;padding:2px 10px;font-size:0.8rem;font-weight:600;">
                  <i class="bi bi-file-pdf me-1"></i>Opens PDF dialog directly
                </span>
              </div>
            </div>
            <i class="bi bi-box-arrow-up-right" style="color:#9ca3af;font-size:1rem;flex-shrink:0;margin-top:2px;"></i>
          </div>

          <!-- Unverified Nominations -->
          <div class="report-card" style="cursor:pointer;"
               onclick="openReport('<%= request.getContextPath() %>/UnverifiedReportServlet?from=reports&autoprint=1')">
            <div style="background:rgba(245,158,11,0.10);color:#d97706;width:48px;height:48px;border-radius:14px;
                        display:flex;align-items:center;justify-content:center;font-size:1.4rem;flex-shrink:0;">
              <i class="bi bi-file-earmark-person"></i>
            </div>
            <div style="flex:1;">
              <div style="font-size:1.05rem;font-weight:700;color:#105e60;margin-bottom:3px;">Unverified Examiner Nominations</div>
              <div style="font-size:0.88rem;color:#6b7280;line-height:1.5;">
                List of pending examiner nominations grouped by nominating academician, with examiner details,
                specialization, and submission date. Includes FSKM letterhead.
              </div>
              <div style="margin-top:8px;display:flex;align-items:center;gap:8px;">
                <span style="background:#fef3c7;color:#92400e;border:1px solid #fcd34d;border-radius:8px;padding:2px 10px;font-size:0.8rem;font-weight:600;">
                  <i class="bi bi-file-pdf me-1"></i>Opens PDF dialog directly
                </span>
              </div>
            </div>
            <i class="bi bi-box-arrow-up-right" style="color:#9ca3af;font-size:1rem;flex-shrink:0;margin-top:2px;"></i>
          </div>

        </div>

        <div class="mt-4 p-3 no-print"
             style="background:#f0fdf4;border:1px solid #a7f3d0;border-radius:12px;font-size:0.88rem;color:#065f46;display:flex;align-items:flex-start;gap:10px;">
          <i class="bi bi-info-circle" style="font-size:1rem;flex-shrink:0;margin-top:1px;"></i>
          <span>Clicking a report opens it in a new tab and shows the print/PDF dialog automatically. Choose <em>Save as PDF</em> in the dialog to download the report.</span>
        </div>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function openReport(url) {
      var w = window.open(url, '_blank');
      // The target page handles auto-print via its own ?autoprint=1 detection
    }
  </script>
</body>
</html>
