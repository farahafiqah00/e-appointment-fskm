<%-- Dean: appointment statistics report — same dataset as admin view but with dean navigation and export. --%>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String fullName = (String) session.getAttribute("full_name");
  if (fullName == null || fullName.trim().isEmpty()) fullName = "Dean";
  int selectedYear = request.getAttribute("selectedYear") != null ? (Integer) request.getAttribute("selectedYear") : java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
  Map<String,Object> summary            = (Map<String,Object>)       request.getAttribute("summary");
  List<Map<String,Object>> roleFreq     = (List<Map<String,Object>>) request.getAttribute("roleFrequency");
  List<Map<String,Object>> roleFreqYear = (List<Map<String,Object>>) request.getAttribute("roleFreqByYear");
  List<Map<String,Object>> yearlyTrends = (List<Map<String,Object>>) request.getAttribute("yearlyTrends");
  List<Map<String,Object>> deptStats    = (List<Map<String,Object>>) request.getAttribute("deptStats");
  List<Map<String,Object>> apptList     = (List<Map<String,Object>>) request.getAttribute("appointmentList");
  List<Integer> availYears              = (List<Integer>)            request.getAttribute("availableYears");
  List<Map<String,Object>> statusBreakdown = (List<Map<String,Object>>) request.getAttribute("statusBreakdown");
  if (summary == null)         summary = new java.util.HashMap<>();
  if (roleFreq == null)        roleFreq = new java.util.ArrayList<>();
  if (roleFreqYear == null)    roleFreqYear = new java.util.ArrayList<>();
  if (yearlyTrends == null)    yearlyTrends = new java.util.ArrayList<>();
  if (deptStats == null)       deptStats = new java.util.ArrayList<>();
  if (apptList == null)        apptList = new java.util.ArrayList<>();
  if (availYears == null)      availYears = new java.util.ArrayList<>();
  if (statusBreakdown == null) statusBreakdown = new java.util.ArrayList<>();
  String printDate = new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(new java.util.Date());
  // Derived lists for print tables 5 & 6 (computed from apptList — no extra SQL)
  List<Map<String,Object>> pendingList     = new java.util.ArrayList<>();
  List<Map<String,Object>> noResponseList  = new java.util.ArrayList<>();
  for (Map<String,Object> _r : apptList) {
    String _s = _r.get("status") != null ? _r.get("status").toString() : "";
    if (!"scheduled".equals(_s) && !"letter_generated".equals(_s)) pendingList.add(_r);
    int _dec = _r.get("respDeclined") instanceof Number ? ((Number)_r.get("respDeclined")).intValue() : 0;
    int _tot = _r.get("panelTotal")   instanceof Number ? ((Number)_r.get("panelTotal")).intValue()   : 0;
    int _acc = _r.get("respAccepted") instanceof Number ? ((Number)_r.get("respAccepted")).intValue() : 0;
    if (_tot > 0 && (_dec > 0 || (_acc + _dec) < _tot)) noResponseList.add(_r);
  }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Appointment Statistics - E-Appointment FSKM</title>
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

      /* --- Print tables --- */
      .pt { width: 100%; border-collapse: collapse; margin-bottom: 14px; }
      .pt th { background: #e5e7eb; font-size: 7.5pt; font-weight: 600; padding: 5px 6px;
               border: 1px solid #9ca3af; text-align: left;
               -webkit-print-color-adjust: exact; print-color-adjust: exact; }
      .pt td { font-size: 7.5pt; padding: 4px 5px; border: 1px solid #d1d5db; vertical-align: top; }
      .pt tbody tr:nth-child(even) td { background: #f9fafb;
               -webkit-print-color-adjust: exact; print-color-adjust: exact; }
      tr { page-break-inside: avoid; }

      /* --- Section headings --- */
      .ps { font-size: 10pt; font-weight: 700; border-bottom: 2px solid #374151;
            padding-bottom: 3px; margin: 14px 0 5px; color: #111; letter-spacing: 0.01em; }

      /* --- Status / response colour classes --- */
      .p-done { color: #065f46; font-weight: 600; }
      .p-pend { color: #92400e; font-weight: 600; }
      .p-appt { color: #1e40af; font-weight: 600; }
      .p-othr { color: #374151; }
      .p-acc  { color: #065f46; }
      .p-dec  { color: #991b1b; font-weight: 600; }
      .p-np   { color: #6b7280; }

      .page-break { page-break-before: always; }
    }
  </style>
</head>
<body class="dean">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout ea-layout">
    <% request.setAttribute("activeSection", "reports"); request.setAttribute("activeSubSection", "deanReportStats"); %>
    <jsp:include page="/dean/sidebar.jsp" />

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
            Appointment Statistics Report — <%= selectedYear %>
          </div>
          <div style="font-size:7.5pt;color:#555;margin-bottom:2px;">
            Generated: <%= printDate %> &nbsp;|&nbsp; Prepared by: <%= fullName %> &nbsp;|&nbsp; Faculty of Computer Science and Mathematics, UMT
          </div>
          <hr style="border:none;border-top:1.5px solid #374151;margin:4px 0 10px;">

          <%-- ── TABLE 1: Summary Statistics ── --%>
          <div class="ps">1. Summary Statistics (Year <%= selectedYear %>)</div>
          <table class="pt">
            <thead>
              <tr><th style="width:25%;">Metric</th><th style="width:25%;">Value</th><th style="width:25%;">Metric</th><th style="width:25%;">Value</th></tr>
            </thead>
            <tbody>
              <tr>
                <td>Total Appointments</td>
                <td style="font-weight:700;"><%= summary.getOrDefault("totalYear", 0) %></td>
                <td>Average per Month</td>
                <td><%= summary.getOrDefault("avgPerMonth", 0.0) %></td>
              </tr>
              <tr>
                <td>Most Active Examiner</td>
                <td><%= summary.getOrDefault("mostActiveExaminer", "—") %></td>
                <td>Active Departments</td>
                <td><%= summary.getOrDefault("activeDepts", 0) %></td>
              </tr>
            </tbody>
          </table>

          <%-- ── TABLE 2: Appointment Progress / Status Breakdown ── --%>
          <div class="ps">2. Appointment Progress — <%= selectedYear %></div>
          <table class="pt">
            <thead>
              <tr>
                <th style="width:30%;">Status</th>
                <th style="width:15%;text-align:center;">Count</th>
                <th>Description</th>
              </tr>
            </thead>
            <tbody>
              <% if (statusBreakdown.isEmpty()) { %>
              <tr><td colspan="3" style="text-align:center;color:#6b7280;">No appointment data for this year.</td></tr>
              <% } else {
                   for (Map<String,Object> sb : statusBreakdown) {
                     String sbSt = sb.get("status") != null ? sb.get("status").toString() : "unknown";
                     int sbCnt  = sb.get("count") instanceof Number ? ((Number)sb.get("count")).intValue() : 0;
                     String sbLabel = sbSt.replace("_"," ");
                     sbLabel = sbLabel.substring(0,1).toUpperCase() + sbLabel.substring(1);
                     String sbCss, sbDesc;
                     switch (sbSt) {
                       case "letter_generated": sbCss="p-done"; sbDesc="Viva completed — appointment letter issued to panel"; break;
                       case "appointed":        sbCss="p-appt"; sbDesc="Panel confirmed — awaiting viva date"; break;
                       case "scheduled":        sbCss="p-done"; sbDesc="Appointment scheduled — panel and date confirmed"; break;
                       case "deferred":         sbCss="p-othr"; sbDesc="Viva postponed to a later date"; break;
                       case "cancelled":        sbCss="p-othr"; sbDesc="Appointment cancelled"; break;
                       default:                 sbCss="p-othr"; sbDesc="—"; break;
                     }
              %>
              <tr>
                <td class="<%= sbCss %>"><%= sbLabel %></td>
                <td style="text-align:center;font-weight:700;" class="<%= sbCss %>"><%= sbCnt %></td>
                <td><%= sbDesc %></td>
              </tr>
              <% } } %>
            </tbody>
          </table>

          <%-- ── TABLE 3: Examiner Role Frequency ── --%>
          <div class="ps">3. Examiner Role Frequency (All Time)</div>
          <table class="pt">
            <thead>
              <tr>
                <th>Examiner / Staff Name</th>
                <th style="text-align:center;">Chairperson</th>
                <th style="text-align:center;">Secretary</th>
                <th style="text-align:center;">Internal Examiner</th>
                <th style="text-align:center;">External Examiner</th>
                <th style="text-align:center;">Total</th>
              </tr>
            </thead>
            <tbody>
              <% if (roleFreq.isEmpty()) { %>
              <tr><td colspan="6" style="text-align:center;color:#6b7280;">No panel data recorded yet.</td></tr>
              <% } else { for (Map<String,Object> r : roleFreq) { %>
              <tr>
                <td><%= r.get("name") %></td>
                <td style="text-align:center;"><%= r.get("chair") %></td>
                <td style="text-align:center;"><%= r.get("recorder") %></td>
                <td style="text-align:center;"><%= r.get("internal") %></td>
                <td style="text-align:center;"><%= r.get("external") %></td>
                <td style="text-align:center;font-weight:700;"><%= r.get("total") %></td>
              </tr>
              <% } } %>
            </tbody>
          </table>

          <%-- ── TABLE 4: All Appointments ── --%>
          <div class="page-break"></div>
          <div class="ps">4. All Viva Appointments — <%= selectedYear %> (<%= apptList.size() %> record<%= apptList.size()==1?"":"s" %>)</div>
          <table class="pt">
            <thead>
              <tr>
                <th style="width:18px;">#</th>
                <th>Candidate</th>
                <th>Matric</th>
                <th>Programme</th>
                <th style="max-width:160px;">Thesis Title</th>
                <th>Viva Date</th>
                <th>Status</th>
                <th>Chairperson</th>
                <th>Secretary</th>
                <th>Internal Examiner</th>
                <th>External Examiner</th>
                <th style="text-align:center;">Panel Response</th>
              </tr>
            </thead>
            <tbody>
              <% if (apptList.isEmpty()) { %>
              <tr><td colspan="12" style="text-align:center;color:#6b7280;">No appointments scheduled for <%= selectedYear %>.</td></tr>
              <% } else {
                   int _no4 = 0;
                   for (Map<String,Object> r : apptList) {
                     _no4++;
                     String vs  = r.get("status") != null ? r.get("status").toString() : "";
                     boolean pd = "scheduled".equals(vs) || "letter_generated".equals(vs);
                     String vsCss = pd ? "p-done" : "appointed".equals(vs) ? "p-appt" : "p-pend";
                     int rAcc = r.get("respAccepted") instanceof Number ? ((Number)r.get("respAccepted")).intValue() : 0;
                     int rDec = r.get("respDeclined") instanceof Number ? ((Number)r.get("respDeclined")).intValue() : 0;
                     int rTot = r.get("panelTotal")   instanceof Number ? ((Number)r.get("panelTotal")).intValue()   : 0;
                     String[] pNames = {
                       r.get("chairperson")      != null ? r.get("chairperson").toString()      : "",
                       r.get("recorder")          != null ? r.get("recorder").toString()          : "",
                       r.get("internalExaminer") != null ? r.get("internalExaminer").toString() : "",
                       r.get("externalExaminer") != null ? r.get("externalExaminer").toString() : ""
                     };
                     String[] pResps = {
                       r.get("chairResponse")    != null ? r.get("chairResponse").toString()    : null,
                       r.get("recorderResponse") != null ? r.get("recorderResponse").toString() : null,
                       r.get("internalResponse") != null ? r.get("internalResponse").toString() : null,
                       r.get("externalResponse") != null ? r.get("externalResponse").toString() : null
                     };
                     String thesis = r.get("thesis") != null ? r.get("thesis").toString() : "—";
                     if (thesis.length() > 80) thesis = thesis.substring(0, 77) + "...";
              %>
              <tr>
                <td><%= _no4 %></td>
                <td style="font-weight:600;"><%= r.get("candidate") != null ? r.get("candidate") : "—" %></td>
                <td><%= r.get("matric") != null ? r.get("matric") : "—" %></td>
                <td><%= r.get("programme") != null ? r.get("programme") : "—" %></td>
                <td><%= thesis %></td>
                <td style="white-space:nowrap;"><%= r.get("vivaDate") != null ? r.get("vivaDate") : "—" %></td>
                <td class="<%= vsCss %>"><%= vs.replace("_"," ") %></td>
                <% for (int _pi = 0; _pi < 4; _pi++) {
                     String _nm = pNames[_pi]; String _rsp = pResps[_pi]; %>
                <td><% if (_nm == null || _nm.isEmpty()) { %>—<% } else { %><%= _nm %><% if ("accepted".equals(_rsp)) { %> <span class="p-acc">&#10003;</span><% } else if ("declined".equals(_rsp)) { %> <span class="p-dec">&#10007;</span><% } else { %> <span class="p-np">&#8226;</span><% } %><% } %></td>
                <% } %>
                <td style="text-align:center;">
                  <% if (rTot==0) { %>—
                  <% } else if (rDec>0) { %><span class="p-dec"><%= rDec %> Declined</span>
                  <% } else if (rAcc==rTot) { %><span class="p-acc">All Accepted</span>
                  <% } else if (rAcc>0) { %><span class="p-appt"><%= rAcc %>/<%= rTot %> Accepted</span>
                  <% } else { %><span class="p-np">Pending</span><% } %>
                </td>
              </tr>
              <% } } %>
            </tbody>
          </table>

          <%-- ── TABLE 5: Pending / Undecided Appointments ── --%>
          <div class="ps">5. Appointments Pending Decision (<%= pendingList.size() %> record<%= pendingList.size()==1?"":"s" %>)</div>
          <table class="pt">
            <thead>
              <tr>
                <th style="width:18px;">#</th>
                <th>Candidate</th>
                <th>Matric</th>
                <th>Programme</th>
                <th>Viva Date</th>
                <th>Current Status</th>
                <th>Chairperson</th>
                <th>Internal Examiner</th>
                <th>External Examiner</th>
                <th style="text-align:center;">Panel Response</th>
              </tr>
            </thead>
            <tbody>
              <% if (pendingList.isEmpty()) { %>
              <tr><td colspan="10" style="text-align:center;color:#065f46;font-weight:600;">All appointments have been decided. &#10003;</td></tr>
              <% } else {
                   int _no5 = 0;
                   for (Map<String,Object> r : pendingList) {
                     _no5++;
                     String vs5    = r.get("status") != null ? r.get("status").toString() : "";
                     String vsCss5 = "appointed".equals(vs5) ? "p-appt" : "p-pend";
                     int rAcc5 = r.get("respAccepted") instanceof Number ? ((Number)r.get("respAccepted")).intValue() : 0;
                     int rDec5 = r.get("respDeclined") instanceof Number ? ((Number)r.get("respDeclined")).intValue() : 0;
                     int rTot5 = r.get("panelTotal")   instanceof Number ? ((Number)r.get("panelTotal")).intValue()   : 0;
              %>
              <tr>
                <td><%= _no5 %></td>
                <td style="font-weight:600;"><%= r.get("candidate") != null ? r.get("candidate") : "—" %></td>
                <td><%= r.get("matric") != null ? r.get("matric") : "—" %></td>
                <td><%= r.get("programme") != null ? r.get("programme") : "—" %></td>
                <td style="white-space:nowrap;"><%= r.get("vivaDate") != null ? r.get("vivaDate") : "—" %></td>
                <td class="<%= vsCss5 %>"><%= vs5.replace("_"," ") %></td>
                <td><%= r.get("chairperson") != null && !r.get("chairperson").toString().isEmpty() ? r.get("chairperson") : "—" %></td>
                <td><%= r.get("internalExaminer") != null && !r.get("internalExaminer").toString().isEmpty() ? r.get("internalExaminer") : "—" %></td>
                <td><%= r.get("externalExaminer") != null && !r.get("externalExaminer").toString().isEmpty() ? r.get("externalExaminer") : "—" %></td>
                <td style="text-align:center;">
                  <% if (rTot5==0) { %>—
                  <% } else if (rDec5>0) { %><span class="p-dec"><%= rDec5 %> Declined</span>
                  <% } else if (rAcc5==rTot5) { %><span class="p-acc">All Accepted</span>
                  <% } else if (rAcc5>0) { %><span class="p-appt"><%= rAcc5 %>/<%= rTot5 %> Accepted</span>
                  <% } else { %><span class="p-np">Pending</span><% } %>
                </td>
              </tr>
              <% } } %>
            </tbody>
          </table>

          <%-- ── TABLE 6: Panel Members — Declined or No Response ── --%>
          <div class="ps">6. Appointments with Declined or Pending Panel Response (<%= noResponseList.size() %> record<%= noResponseList.size()==1?"":"s" %>)</div>
          <table class="pt">
            <thead>
              <tr>
                <th style="width:18px;">#</th>
                <th>Candidate</th>
                <th>Matric</th>
                <th>Viva Date</th>
                <th>Status</th>
                <th>Chairperson</th>
                <th>Secretary</th>
                <th>Internal Examiner</th>
                <th>External Examiner</th>
                <th style="text-align:center;">Accepted</th>
                <th style="text-align:center;">Declined</th>
                <th style="text-align:center;">Total</th>
              </tr>
            </thead>
            <tbody>
              <% if (noResponseList.isEmpty()) { %>
              <tr><td colspan="12" style="text-align:center;color:#065f46;font-weight:600;">All panel members have responded and accepted. &#10003;</td></tr>
              <% } else {
                   int _no6 = 0;
                   for (Map<String,Object> r : noResponseList) {
                     _no6++;
                     String vs6  = r.get("status") != null ? r.get("status").toString() : "";
                     boolean pd6 = "scheduled".equals(vs6) || "letter_generated".equals(vs6);
                     String vsCss6 = pd6 ? "p-done" : "appointed".equals(vs6) ? "p-appt" : "p-pend";
                     int rAcc6 = r.get("respAccepted") instanceof Number ? ((Number)r.get("respAccepted")).intValue() : 0;
                     int rDec6 = r.get("respDeclined") instanceof Number ? ((Number)r.get("respDeclined")).intValue() : 0;
                     int rTot6 = r.get("panelTotal")   instanceof Number ? ((Number)r.get("panelTotal")).intValue()   : 0;
                     String[] p6Names = {
                       r.get("chairperson")      != null ? r.get("chairperson").toString()      : "",
                       r.get("recorder")          != null ? r.get("recorder").toString()          : "",
                       r.get("internalExaminer") != null ? r.get("internalExaminer").toString() : "",
                       r.get("externalExaminer") != null ? r.get("externalExaminer").toString() : ""
                     };
                     String[] p6Resps = {
                       r.get("chairResponse")    != null ? r.get("chairResponse").toString()    : null,
                       r.get("recorderResponse") != null ? r.get("recorderResponse").toString() : null,
                       r.get("internalResponse") != null ? r.get("internalResponse").toString() : null,
                       r.get("externalResponse") != null ? r.get("externalResponse").toString() : null
                     };
              %>
              <tr>
                <td><%= _no6 %></td>
                <td style="font-weight:600;"><%= r.get("candidate") != null ? r.get("candidate") : "—" %></td>
                <td><%= r.get("matric") != null ? r.get("matric") : "—" %></td>
                <td style="white-space:nowrap;"><%= r.get("vivaDate") != null ? r.get("vivaDate") : "—" %></td>
                <td class="<%= vsCss6 %>"><%= vs6.replace("_"," ") %></td>
                <% for (int _pi6 = 0; _pi6 < 4; _pi6++) {
                     String _nm6 = p6Names[_pi6]; String _rsp6 = p6Resps[_pi6]; %>
                <td><% if (_nm6 == null || _nm6.isEmpty()) { %>—<% } else { %><%= _nm6 %><% if ("accepted".equals(_rsp6)) { %> <span class="p-acc">&#10003;</span><% } else if ("declined".equals(_rsp6)) { %> <span class="p-dec">&#10007;</span><% } else { %> <span class="p-np">&#8226;</span><% } %><% } %></td>
                <% } %>
                <td style="text-align:center;font-weight:700;" class="p-acc"><%= rAcc6 %></td>
                <td style="text-align:center;font-weight:700;" class="<%= rDec6>0 ? "p-dec" : "p-np" %>"><%= rDec6 %></td>
                <td style="text-align:center;"><%= rTot6 %></td>
              </tr>
              <% } } %>
            </tbody>
          </table>

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

        <!-- Page heading -->
        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3 no-print">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Appointment Statistics</h1>
            <div style="font-size:1rem;color:#6b7280;">View role frequency and appointment trends</div>
          </div>
          <div class="d-flex gap-2 align-items-center">
            <button onclick="window.print()" class="ea-btn-teal-outline" style="font-size:0.95rem;">
              <i class="bi bi-printer"></i> Print / Save as PDF
            </button>
          </div>
        </div>

        <!-- Year filter -->
        <div class="w-100 mb-4 p-3 no-print"
             style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <form class="row g-2 align-items-center" method="GET"
                action="<%= request.getContextPath() %>/dean/reports/appointments">
            <div class="col-auto">
              <label class="form-label mb-0" style="font-size:0.95rem;font-weight:600;">Select Year</label>
            </div>
            <div class="col-auto">
              <select name="year" class="form-select"
                      style="border-radius:10px;border-color:#e5e7eb;min-width:120px;"
                      onchange="this.form.submit()">
                <% if (!availYears.isEmpty()) {
                     for (int ay : availYears) { %>
                <option value="<%= ay %>" <%= ay == selectedYear ? "selected" : "" %>><%= ay %></option>
                <%   } %>
                <% } else {
                     for (int y = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR); y >= 2020; y--) { %>
                <option value="<%= y %>" <%= y == selectedYear ? "selected" : "" %>><%= y %></option>
                <%   } } %>
              </select>
            </div>
          </form>
        </div>

        <!-- Summary Cards -->
        <div class="row g-3 mb-4 no-print">
          <div class="col-lg-3 col-md-6">
            <div class="p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;border-top:4px solid #0f766e;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div style="font-size:0.88rem;color:#6b7280;margin-bottom:6px;">Total Appointments (<%= selectedYear %>)</div>
              <div style="font-size:2rem;font-weight:700;color:#0f766e;"><%= summary.getOrDefault("totalYear", 0) %></div>
            </div>
          </div>
          <div class="col-lg-3 col-md-6">
            <div class="p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;border-top:4px solid #3b82f6;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div style="font-size:0.88rem;color:#6b7280;margin-bottom:6px;">Most Active Examiner</div>
              <div style="font-size:1.3rem;font-weight:700;color:#1d4ed8;word-break:break-word;"><%= summary.getOrDefault("mostActiveExaminer", "—") %></div>
            </div>
          </div>
          <div class="col-lg-3 col-md-6">
            <div class="p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;border-top:4px solid #10b981;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div style="font-size:0.88rem;color:#6b7280;margin-bottom:6px;">Average per Month</div>
              <div style="font-size:2rem;font-weight:700;color:#059669;"><%= summary.getOrDefault("avgPerMonth", 0.0) %></div>
            </div>
          </div>
          <div class="col-lg-3 col-md-6">
            <div class="p-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;border-top:4px solid #f59e0b;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div style="font-size:0.88rem;color:#6b7280;margin-bottom:6px;">Active Departments</div>
              <div style="font-size:2rem;font-weight:700;color:#d97706;"><%= summary.getOrDefault("activeDepts", 0) %></div>
            </div>
          </div>
        </div>

        <!-- Appointment Status Breakdown -->
        <% if (!statusBreakdown.isEmpty()) { %>
        <div class="w-100 mb-4 no-print"
             style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
          <div class="d-flex align-items-center px-4 py-3" style="border-bottom:1px solid #f3f4f6;">
            <i class="bi bi-bar-chart-steps me-2" style="color:#0f766e;font-size:1.1rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Appointment Progress in <%= selectedYear %></span>
          </div>
          <div class="d-flex flex-wrap gap-3 px-4 py-3">
            <% for (Map<String,Object> sb : statusBreakdown) {
                 String sbSt  = sb.get("status") != null ? sb.get("status").toString() : "unknown";
                 int sbCnt   = sb.get("count") instanceof Number ? ((Number)sb.get("count")).intValue() : 0;
                 String sbLabel = sbSt.replace("_"," ");
                 sbLabel = sbLabel.substring(0,1).toUpperCase() + sbLabel.substring(1);
                 String sbColor, sbBg, sbBorder;
                 if ("scheduled".equals(sbSt) || "letter_generated".equals(sbSt)) {
                   sbColor="#065f46"; sbBg="#d1fae5"; sbBorder="#6ee7b7";
                 } else if ("deferred".equals(sbSt)) {
                   sbColor="#92400e"; sbBg="#fef3c7"; sbBorder="#fcd34d";
                 } else {
                   sbColor="#374151"; sbBg="#f3f4f6"; sbBorder="#d1d5db";
                 }
            %>
            <div style="display:inline-flex;align-items:center;gap:10px;padding:10px 18px;
                        background:<%= sbBg %>;border:1.5px solid <%= sbBorder %>;border-radius:12px;min-width:160px;">
              <div>
                <div style="font-size:1.6rem;font-weight:700;color:<%= sbColor %>;line-height:1.1;"><%= sbCnt %></div>
                <div style="font-size:0.78rem;font-weight:600;color:<%= sbColor %>;margin-top:2px;"><%= sbLabel %></div>
              </div>
            </div>
            <% } %>
          </div>
        </div>
        <% } %>

        <!-- Visual Charts -->
        <div class="row g-4 mb-4 no-print">
          <div class="col-lg-7">
            <div style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);padding:20px 24px 16px;">
              <div class="d-flex align-items-center mb-3">
                <i class="bi bi-graph-up-arrow me-2" style="color:#0f766e;font-size:1.1rem;"></i>
                <span class="fw-semibold" style="font-size:1.05rem;">Yearly Appointment Trends</span>
              </div>
              <canvas id="trendsChart"></canvas>
            </div>
          </div>
          <div class="col-lg-5">
            <div style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);padding:20px 24px 16px;">
              <div class="d-flex align-items-center mb-3">
                <i class="bi bi-building me-2" style="color:#0f766e;font-size:1.1rem;"></i>
                <span class="fw-semibold" style="font-size:1.05rem;">Department Breakdown</span>
              </div>
              <canvas id="deptChart"></canvas>
            </div>
          </div>
          <div class="col-12">
            <div style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);padding:20px 24px 16px;">
              <div class="d-flex align-items-center mb-3">
                <i class="bi bi-person-badge me-2" style="color:#0f766e;font-size:1.1rem;"></i>
                <span class="fw-semibold" style="font-size:1.05rem;">Staff Workload in <%= selectedYear %></span>
              </div>
              <div style="position:relative;min-height:180px;">
                <canvas id="workloadChart"></canvas>
              </div>
            </div>
          </div>
        </div>

        <!-- Examiner Role Frequency (screen) -->
        <div class="w-100 mb-4 no-print"
             style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
          <div class="d-flex align-items-center px-4 py-3" style="border-bottom:1px solid #f3f4f6;">
            <i class="bi bi-people me-2" style="color:#0f766e;font-size:1.1rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Examiner Role Frequency (All Time)</span>
          </div>
          <div class="table-responsive">
            <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.95rem;">
              <thead>
                <tr>
                  <th>Examiner Name</th>
                  <th style="text-align:center;">Chairperson</th>
                  <th style="text-align:center;">Secretary</th>
                  <th style="text-align:center;">Internal</th>
                  <th style="text-align:center;">External</th>
                  <th style="text-align:center;">Total</th>
                </tr>
              </thead>
              <tbody>
                <% if (roleFreq.isEmpty()) { %>
                <tr><td colspan="6" class="text-center py-4 text-muted">No panel data recorded yet.</td></tr>
                <% } else { for (Map<String,Object> r : roleFreq) { %>
                <tr>
                  <td style="color:#374151;"><%= r.get("name") %></td>
                  <td style="text-align:center;color:#6b7280;"><%= r.get("chair") %></td>
                  <td style="text-align:center;color:#6b7280;"><%= r.get("recorder") %></td>
                  <td style="text-align:center;color:#6b7280;"><%= r.get("internal") %></td>
                  <td style="text-align:center;color:#6b7280;"><%= r.get("external") %></td>
                  <td style="text-align:center;"><span class="fw-bold" style="color:#0f766e;"><%= r.get("total") %></span></td>
                </tr>
                <% } } %>
              </tbody>
            </table>
          </div>
        </div>

        <!-- All Appointments Table (screen) -->
        <div class="w-100 mb-4 no-print"
             style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
          <div class="d-flex align-items-center justify-content-between px-4 py-3"
               style="border-bottom:1px solid #f3f4f6;">
            <div class="d-flex align-items-center">
              <i class="bi bi-calendar2-check me-2" style="color:#0f766e;font-size:1.1rem;"></i>
              <span class="fw-semibold" style="font-size:1.05rem;">All Appointments in <%= selectedYear %></span>
            </div>
            <span style="font-size:0.87rem;color:#6b7280;"><%= apptList.size() %> record(s)</span>
          </div>
          <div class="table-responsive">
            <table class="ea-table-userlist align-middle mb-0" style="font-size:0.85rem;min-width:1100px;">
              <thead>
                <tr>
                  <th>Candidate</th>
                  <th>Matric</th>
                  <th>Programme</th>
                  <th>Viva Date</th>
                  <th>Status</th>
                  <th>Chairperson</th>
                  <th>Secretary</th>
                  <th>Internal Examiner</th>
                  <th>External Examiner</th>
                  <th style="text-align:center;">Panel Response</th>
                </tr>
              </thead>
              <tbody>
                <% if (apptList.isEmpty()) { %>
                <tr><td colspan="10" class="text-center py-4 text-muted">No appointments scheduled for <%= selectedYear %>.</td></tr>
                <% } else { for (Map<String,Object> r : apptList) {
                     String vs  = r.get("status") != null ? r.get("status").toString() : "";
                     boolean done = "scheduled".equals(vs) || "letter_generated".equals(vs);
                     String chairResp = r.get("chairResponse")    != null ? r.get("chairResponse").toString()    : null;
                     String recResp   = r.get("recorderResponse") != null ? r.get("recorderResponse").toString() : null;
                     String intResp   = r.get("internalResponse") != null ? r.get("internalResponse").toString() : null;
                     String extResp   = r.get("externalResponse") != null ? r.get("externalResponse").toString() : null;
                     int respAcc  = r.get("respAccepted") instanceof Number ? ((Number)r.get("respAccepted")).intValue() : 0;
                     int respDec  = r.get("respDeclined") instanceof Number ? ((Number)r.get("respDeclined")).intValue() : 0;
                     int panelTot = r.get("panelTotal")   instanceof Number ? ((Number)r.get("panelTotal")).intValue()   : 0;
                %>
                <tr>
                  <td style="font-weight:600;color:#105e60;"><%= r.get("candidate") != null ? r.get("candidate") : "—" %></td>
                  <td style="color:#6b7280;font-size:0.8rem;"><%= r.get("matric") != null ? r.get("matric") : "—" %></td>
                  <td style="color:#374151;"><%= r.get("programme") != null ? r.get("programme") : "—" %></td>
                  <td style="color:#374151;white-space:nowrap;"><%= r.get("vivaDate") != null ? r.get("vivaDate") : "—" %></td>
                  <td>
                    <span style="background:<%= done?"#d1fae5":"appointed".equals(vs)?"#dbeafe":"#fef3c7" %>;
                          color:<%= done?"#065f46":"appointed".equals(vs)?"#1e40af":"#92400e" %>;
                          border-radius:8px;padding:2px 8px;font-size:0.78rem;font-weight:600;white-space:nowrap;">
                      <%= vs.replace("_"," ") %>
                    </span>
                  </td>
                  <% String[] sNames = { r.get("chairperson")!=null?r.get("chairperson").toString():"", r.get("recorder")!=null?r.get("recorder").toString():"", r.get("internalExaminer")!=null?r.get("internalExaminer").toString():"", r.get("externalExaminer")!=null?r.get("externalExaminer").toString():"" };
                     String[] sResps = { chairResp, recResp, intResp, extResp };
                     for (int _pi = 0; _pi < 4; _pi++) {
                       String _nm = sNames[_pi]; String _resp = sResps[_pi]; %>
                  <td style="color:#374151;">
                    <% if (_nm==null||_nm.isEmpty()) { %>—<% } else { %>
                      <%= _nm %>
                      <% if ("accepted".equals(_resp)) { %><span style="color:#065f46;font-size:0.7rem;margin-left:3px;">&#10003;</span>
                      <% } else if ("declined".equals(_resp)) { %><span style="color:#991b1b;font-size:0.7rem;margin-left:3px;">&#10007;</span>
                      <% } else { %><span style="color:#9ca3af;font-size:0.7rem;margin-left:3px;">&#8226;</span><% } %>
                    <% } %>
                  </td>
                  <% } %>
                  <td style="text-align:center;">
                    <% if (panelTot==0) { %><span style="color:#9ca3af;">—</span>
                    <% } else if (respDec>0) { %><span style="background:#fee2e2;color:#991b1b;border-radius:8px;padding:2px 8px;font-size:0.75rem;font-weight:600;"><%= respDec %> Declined</span>
                    <% } else if (respAcc==panelTot) { %><span style="background:#d1fae5;color:#065f46;border-radius:8px;padding:2px 8px;font-size:0.75rem;font-weight:600;">All Accepted</span>
                    <% } else if (respAcc>0) { %><span style="background:#dbeafe;color:#1e40af;border-radius:8px;padding:2px 8px;font-size:0.75rem;font-weight:600;"><%= respAcc %>/<%= panelTot %> Accepted</span>
                    <% } else { %><span style="background:#f3f4f6;color:#6b7280;border-radius:8px;padding:2px 8px;font-size:0.75rem;font-weight:600;">Pending</span>
                    <% } %>
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
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
  <script>
  // Auto-print when opened from the Reports hub with ?autoprint=1
  if (new URLSearchParams(window.location.search).get('autoprint') === '1') {
    window.addEventListener('load', function() { setTimeout(window.print, 600); });
  }

  (function () {
    const trendsLabels = [<% for(int _i=0;_i<yearlyTrends.size();_i++){if(_i>0)out.print(",");out.print("\""+yearlyTrends.get(_i).get("year")+"\"");} %>];
    const trendsTotal  = [<% for(int _i=0;_i<yearlyTrends.size();_i++){if(_i>0)out.print(",");Object _v=yearlyTrends.get(_i).get("total");out.print(_v!=null?_v:0);} %>];
    const trendsPhd    = [<% for(int _i=0;_i<yearlyTrends.size();_i++){if(_i>0)out.print(",");Object _v=yearlyTrends.get(_i).get("phd");out.print(_v!=null?_v:0);} %>];
    const trendsMst    = [<% for(int _i=0;_i<yearlyTrends.size();_i++){if(_i>0)out.print(",");Object _v=yearlyTrends.get(_i).get("masters");out.print(_v!=null?_v:0);} %>];
    const deptLabels   = [<% for(int _i=0;_i<deptStats.size();_i++){if(_i>0)out.print(",");Object _d=deptStats.get(_i).get("department");String _dn=_d!=null?_d.toString().replace("\\","\\\\").replace("\"","\\\""):"Unknown";out.print("\""+_dn+"\"");} %>];
    const deptTotals   = [<% for(int _i=0;_i<deptStats.size();_i++){if(_i>0)out.print(",");Object _v=deptStats.get(_i).get("total");out.print(_v!=null?_v:0);} %>];
    const staffLabels  = [<% for(int _i=0;_i<roleFreqYear.size();_i++){if(_i>0)out.print(",");Object _n=roleFreqYear.get(_i).get("name");String _sn=_n!=null?_n.toString().replace("\\","\\\\").replace("\"","\\\""):"";out.print("\""+_sn+"\"");} %>];
    const staffChair   = [<% for(int _i=0;_i<roleFreqYear.size();_i++){if(_i>0)out.print(",");Object _v=roleFreqYear.get(_i).get("chair");out.print(_v!=null?_v:0);} %>];
    const staffSec     = [<% for(int _i=0;_i<roleFreqYear.size();_i++){if(_i>0)out.print(",");Object _v=roleFreqYear.get(_i).get("recorder");out.print(_v!=null?_v:0);} %>];
    const staffInt     = [<% for(int _i=0;_i<roleFreqYear.size();_i++){if(_i>0)out.print(",");Object _v=roleFreqYear.get(_i).get("internal");out.print(_v!=null?_v:0);} %>];
    const staffExt     = [<% for(int _i=0;_i<roleFreqYear.size();_i++){if(_i>0)out.print(",");Object _v=roleFreqYear.get(_i).get("external");out.print(_v!=null?_v:0);} %>];

    const trendsEl = document.getElementById('trendsChart');
    if (trendsEl && trendsLabels.length > 0) {
      new Chart(trendsEl, {
        data: {
          labels: trendsLabels,
          datasets: [
            { type:'bar',  label:'Total',   data:trendsTotal, backgroundColor:'rgba(15,118,110,0.18)', borderColor:'#0f766e', borderWidth:2, borderRadius:6, order:2 },
            { type:'line', label:'PhD',     data:trendsPhd,   borderColor:'#3b82f6', backgroundColor:'rgba(59,130,246,0.08)', borderWidth:2, pointRadius:4, tension:0.3, order:1 },
            { type:'line', label:'Masters', data:trendsMst,   borderColor:'#f59e0b', backgroundColor:'rgba(245,158,11,0.08)',  borderWidth:2, pointRadius:4, tension:0.3, order:1 }
          ]
        },
        options: {
          responsive:true, maintainAspectRatio:true,
          plugins:{ legend:{ position:'bottom', labels:{ boxWidth:12, font:{size:12} } } },
          scales:{ y:{ beginAtZero:true, ticks:{precision:0}, grid:{color:'#f3f4f6'} }, x:{ grid:{display:false} } }
        }
      });
    }

    const deptEl = document.getElementById('deptChart');
    if (deptEl && deptLabels.length > 0) {
      new Chart(deptEl, {
        type:'doughnut',
        data:{ labels:deptLabels, datasets:[{ data:deptTotals,
          backgroundColor:['#0f766e','#3b82f6','#f59e0b','#10b981','#8b5cf6','#ec4899','#f97316','#06b6d4','#14b8a6','#a855f7'],
          borderWidth:2, borderColor:'#fff', hoverOffset:6 }] },
        options:{ responsive:true, maintainAspectRatio:true, cutout:'65%',
          plugins:{ legend:{ position:'bottom', labels:{ boxWidth:12, font:{size:11}, padding:10 } } } }
      });
    }

    const workEl = document.getElementById('workloadChart');
    if (workEl && staffLabels.length > 0) {
      workEl.parentElement.style.height = Math.max(180, staffLabels.length * 40) + 'px';
      new Chart(workEl, {
        type:'bar',
        data:{ labels:staffLabels,
          datasets:[
            { label:'Chairperson', data:staffChair, backgroundColor:'#0f766e', borderRadius:3 },
            { label:'Secretary',   data:staffSec,   backgroundColor:'#3b82f6', borderRadius:3 },
            { label:'Internal',    data:staffInt,   backgroundColor:'#f59e0b', borderRadius:3 },
            { label:'External',    data:staffExt,   backgroundColor:'#ec4899', borderRadius:3 }
          ] },
        options:{
          indexAxis:'y', responsive:true, maintainAspectRatio:false,
          plugins:{ legend:{ position:'bottom', labels:{ boxWidth:12, font:{size:12} } } },
          scales:{ x:{ stacked:true, beginAtZero:true, ticks:{precision:0}, grid:{color:'#f3f4f6'} },
                   y:{ stacked:true, grid:{display:false}, ticks:{font:{size:11}} } }
        }
      });
    }
  })();
  </script>
</body>
</html>
