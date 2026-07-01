<%--
  Admin: letter preview page — shows the generated appointment letter, manages the approval
  workflow (request signer / sign / send emails), and includes bilingual letter templates as
  fragments. Also used as the Dean/signer read-only review view when isAdminView=false.
--%>
<%@ page import="model.VivaAppointment, java.util.List, java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  VivaAppointment a = (VivaAppointment) request.getAttribute("appointment");
  if (a == null) {
    response.sendRedirect(request.getContextPath() + "/admin/appointments");
    return;
  }
  String fullName  = (String) session.getAttribute("full_name"); if (fullName == null) fullName = "Admin";
  String adminEmail = (String) session.getAttribute("email"); if (adminEmail == null) adminEmail = "fskm@umt.edu.my";
  String _lpListUrl = request.getAttribute("listUrl") != null ? (String) request.getAttribute("listUrl") : "";
  String _lpListUrlEncoded = !_lpListUrl.isEmpty() ? java.net.URLEncoder.encode(_lpListUrl, "UTF-8") : "";
  Integer currentUserId = null;
  if (session.getAttribute("user_id") instanceof Number) {
    currentUserId = ((Number) session.getAttribute("user_id")).intValue();
  }
  String currentRoleName = (String) session.getAttribute("role_name");
  boolean isAdminView = "Admin".equals(currentRoleName);
  List<Map<String,Object>> members = a.getPanelMembers();
  List<Map<String,Object>> eligibleSigners = (List<Map<String,Object>>) request.getAttribute("eligibleSigners");
  Map<String,Object> letterApproval = (Map<String,Object>) request.getAttribute("letterApproval");
  String approvalStatus = letterApproval != null && letterApproval.get("status") != null ? letterApproval.get("status").toString() : "none";
  boolean approvalSigned = "signed".equalsIgnoreCase(approvalStatus);
  boolean approvalPending = "pending".equalsIgnoreCase(approvalStatus);
  Integer assignedSignerUserId = null;
  if (letterApproval != null && letterApproval.get("signer_user_id") instanceof Number) {
    assignedSignerUserId = ((Number) letterApproval.get("signer_user_id")).intValue();
  }
  boolean canCurrentUserSign = approvalPending && assignedSignerUserId != null && currentUserId != null && assignedSignerUserId.intValue() == currentUserId.intValue();
  String approvalMsg = (String) request.getAttribute("approvalMsg");
  String approvalError = (String) request.getAttribute("approvalError");
  String today   = new java.text.SimpleDateFormat("dd MMMM yyyy").format(new java.util.Date());
  String vivaDate = a.getScheduledAt() != null
      ? new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(a.getScheduledAt()) : "—";  int signedCount = 0;
  if (members != null) {
    for (Map<String,Object> m : members) {
      if (Boolean.TRUE.equals(m.get("letter_signed"))) signedCount++;
    }
  }
  int totalCount = members != null ? members.size() : 0;
  int sentCount = 0;
  int _unsentCount = 0;
  if (members != null) {
    for (Map<String,Object> m : members) {
      boolean _mSent = Boolean.TRUE.equals(m.get("letter_sent"));
      if (_mSent) sentCount++;
      else _unsentCount++;
    }
  }
  // ── Dynamic signer display variables (used by included letter templates) ──
  String signerDisplayName    = "";
  String signerDisplayRole_MS = "Dekan";
  String signerDisplayRole_EN = "Dean";
  String signerDisplayEmail   = "fskm@umt.edu.my";
  String signerDisplayPhone   = "09 6333974";
  // Hijri date (Malaysia timezone)
  String todayHijri;
  try {
    java.time.chrono.HijrahDate _hd = java.time.chrono.HijrahDate.now(java.time.ZoneId.of("Asia/Kuala_Lumpur"));
    String[] _hm = {"Muharram","Safar","Rabiul Awal","Rabiul Akhir","Jamadil Awal","Jamadil Akhir","Rejab","Syaaban","Ramadan","Syawal","Zulkaedah","Zulhijjah"};
    todayHijri = _hd.get(java.time.temporal.ChronoField.DAY_OF_MONTH) + " " + _hm[_hd.get(java.time.temporal.ChronoField.MONTH_OF_YEAR) - 1] + " " + _hd.get(java.time.temporal.ChronoField.YEAR) + "H";
  } catch (Exception _hijriEx) { todayHijri = "[ Tarikh Hijri ]"; }
  if (letterApproval != null) {
    String _sAcTitle = letterApproval.get("signer_academic_title") != null ? letterApproval.get("signer_academic_title").toString().trim() : "";
    String _sName    = letterApproval.get("signer_name")           != null ? letterApproval.get("signer_name").toString().trim()           : "";
    String _sLabel   = letterApproval.get("signer_label")          != null ? letterApproval.get("signer_label").toString().trim()          : "";
    String _sEmail   = letterApproval.get("signer_email")          != null ? letterApproval.get("signer_email").toString().trim()          : "";
    String _sPhone   = letterApproval.get("signer_phone")          != null ? letterApproval.get("signer_phone").toString().trim()          : "";
    signerDisplayName = (_sAcTitle.isEmpty() ? "" : _sAcTitle.toUpperCase() + " ") + _sName.toUpperCase();
    if (!_sEmail.isEmpty()) signerDisplayEmail = _sEmail;
    if (!_sPhone.isEmpty()) signerDisplayPhone = _sPhone;
    if ("Dean".equalsIgnoreCase(_sLabel)) {
      signerDisplayRole_MS = "Dekan";
      signerDisplayRole_EN = "Dean";
    } else if ("TDA".equalsIgnoreCase(_sLabel)) {
      signerDisplayRole_MS = "Timbalan Dekan (Akademik dan Hal Ehwal Pelajar)";
      signerDisplayRole_EN = "Deputy Dean (Academic and Student Affairs)";
    } else if ("TDB".equalsIgnoreCase(_sLabel)) {
      signerDisplayRole_MS = "Timbalan Dekan (Penyelidikan dan Inovasi)";
      signerDisplayRole_EN = "Deputy Dean (Research and Innovation)";
    } else if (!_sLabel.isEmpty()) {
      signerDisplayRole_MS = _sLabel;
      signerDisplayRole_EN = _sLabel;
    }
  }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Appointment Letters - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    @media print {
      .no-print { display: none !important; }
      .topbar { display: none !important; }
      body { background: #fff !important; overflow: visible !important; height: auto !important; }
      #mainLayout { height: auto !important; overflow: visible !important; display: block !important; max-width: 100% !important; }
      #letterScrollArea { overflow: visible !important; height: auto !important; background: #fff !important; flex: none !important; width: 100% !important; }
      .tab-pane:not(.active) { display: none !important; }
      .letter-paper { box-shadow: none !important; border: none !important; margin: 0 !important; max-width:100% !important; font-family: Calibri, 'Calibri', sans-serif !important; font-size: 11pt !important; }
      .letter-section-break { page-break-before: always; break-before: page; }
      hr.section-divider { display: none !important; }
    }
    @media screen {
      body { overflow: hidden; height: 100vh; }
    }
    .letter-paper {
      --lp: 56px;
      background: #fff;
      max-width: 760px;
      margin: 2rem auto;
      padding: 0 var(--lp) 48px;
      border: 1px solid #e5e7eb;
      border-radius: 12px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.07);
      overflow: hidden;
      font-family: Calibri, 'Calibri', sans-serif;
      font-size: 11pt;
      line-height: 1.8;
      color: #111;
    }
    .letter-paper h2 { font-size: 1.1rem; text-align: center; font-weight: bold; margin-bottom: 1.5rem; }
    .letter-paper .label { font-weight: bold; }
    #letterTabsWrap { overflow-x: auto; -webkit-overflow-scrolling: touch; }
    #letterTabs { flex-wrap: nowrap; min-width: max-content; border-bottom: none; }
    #letterTabs .nav-link { color: #374151; font-size: 0.85rem; padding: 0.55rem 1.1rem; text-align: left; white-space: nowrap; border: 1px solid transparent; border-bottom: 2px solid transparent; }
    #letterTabs .nav-link.active { color: #0f766e; border-bottom-color: #0f766e; font-weight: 600; background: #fff; }
    #letterTabs .nav-link .role-tag { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; letter-spacing: .05em; color: #0f766e; display: block; line-height: 1; margin-bottom: 2px; }
    #letterTabs .nav-link:not(.active) .role-tag { color: #9ca3af; }
    .letter-tabs-outer { background:#fff; border:1px solid #e5e7eb; border-radius:12px 12px 0 0; border-bottom: 2px solid #e5e7eb; }
    .signed-badge { display:inline-flex;align-items:center;gap:4px;background:#dcfce7;color:#15803d;padding:2px 8px;border-radius:12px;font-size:0.75rem;font-weight:600; }
    .pending-badge { display:inline-flex;align-items:center;gap:4px;background:#fef3c7;color:#92400e;padding:2px 8px;border-radius:12px;font-size:0.75rem;font-weight:600; }
  </style>
</head>
<body style="background:#f3f4f6;">

  <!-- Topbar -->
  <jsp:include page="/includes/topbar.jsp" />


  <!-- Action bar (fixed) — clean: Back + Print only -->
  <div class="no-print d-flex align-items-center justify-content-between px-4 py-3"
       style="position:fixed;top:64px;left:0;right:0;z-index:998;background:#fff;border-bottom:1px solid #e5e7eb;box-shadow:0 2px 8px rgba(0,0,0,0.06);">
    <a href="<%= request.getContextPath() %>/admin/appointment/decision?id=<%= a.getId() %><%= !_lpListUrlEncoded.isEmpty() ? "&listUrl=" + _lpListUrlEncoded : "" %>"
       class="btn-ea-back">
      <i class="bi bi-arrow-left"></i> Back to Decision
    </a>
    <div class="d-flex align-items-center gap-3">
      <% if (approvalSigned) { %>
      <span style="font-size:0.82rem;font-weight:600;padding:4px 12px;border-radius:20px;background:#dcfce7;color:#15803d;">
        <i class="bi bi-patch-check-fill me-1"></i>Letter Approved — emails can be sent
      </span>
      <% } else if (approvalPending) { %>
      <span style="font-size:0.82rem;font-weight:600;padding:4px 12px;border-radius:20px;background:#fef3c7;color:#92400e;">
        <i class="bi bi-hourglass-split me-1"></i>Awaiting signer approval
      </span>
      <% } else { %>
      <span style="font-size:0.82rem;font-weight:600;padding:4px 12px;border-radius:20px;background:#f3f4f6;color:#6b7280;">
        <i class="bi bi-clock me-1"></i>Approval not yet requested
      </span>
      <% } %>
      <% if (totalCount > 0) { %>
      <span style="font-size:0.82rem;font-weight:600;color:<%= sentCount == totalCount ? "#15803d" : "#2563eb" %>;">
        <i class="bi bi-envelope-<%= sentCount == totalCount ? "check-fill" : "arrow-up" %> me-1"></i>
        Sent <%= sentCount %>/<%= totalCount %>
      </span>
      <% } %>
      <button onclick="window.print()" class="ea-btn-teal-outline">
        <i class="bi bi-printer"></i> Print / PDF
      </button>
    </div>
  </div>

  <div class="no-print" style="height:136px;"></div>

  <% if (approvalMsg != null && !approvalMsg.isEmpty()) { %>
  <div class="no-print" style="max-width:1300px;margin:0.75rem auto 0;padding:0 1.5rem;">
    <div class="d-flex align-items-center gap-3 px-4 py-3" style="background:#f0fdf4;border:1.5px solid #86efac;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.04);">
      <i class="bi bi-check-circle-fill" style="color:#16a34a;font-size:1.2rem;flex-shrink:0;"></i>
      <span style="font-weight:600;color:#15803d;font-size:0.95rem;"><%= approvalMsg %></span>
    </div>
  </div>
  <% } %>
  <% if (approvalError != null && !approvalError.isEmpty()) { %>
  <div class="no-print" style="max-width:1300px;margin:0.75rem auto 0;padding:0 1.5rem;">
    <div class="d-flex align-items-center gap-3 px-4 py-3" style="background:#fff5f5;border:1.5px solid #fca5a5;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,0.04);">
      <i class="bi bi-exclamation-triangle-fill" style="color:#dc2626;font-size:1.2rem;flex-shrink:0;"></i>
      <span style="font-weight:600;color:#b91c1c;font-size:0.95rem;"><%= approvalError %></span>
    </div>
  </div>
  <% } %>

  <!-- Hidden Bootstrap tabs (driven by sidebar select) -->
  <ul class="nav" id="letterTabs" role="tablist" style="display:none;">
    <% if (members != null) { for (int i = 0; i < members.size(); i++) {
         Map<String,Object> mi0 = members.get(i); %>
    <li class="nav-item" role="presentation">
      <button class="nav-link <%= i == 0 ? "active" : "" %>"
              id="tab-<%= i %>" data-bs-toggle="tab" data-bs-target="#letter-<%= i %>"
              type="button" role="tab"
              data-label="<%= (mi0.get("name") != null ? mi0.get("name") : "") %> (<%= (mi0.get("role") != null ? mi0.get("role") : "") %>)">
      </button>
    </li>
    <% } } %>
  </ul>

  <% if (members == null || members.isEmpty()) { %>
  <div style="max-width:800px;margin:2rem auto;padding:0 1.5rem;">
    <div class="alert alert-warning"><i class="bi bi-exclamation-triangle me-1"></i>No panel members assigned yet.</div>
  </div>
  <% } else { %>

  <!-- ── Main layout: sidebar + letter ── -->
  <div id="mainLayout" style="display:flex;gap:0;max-width:1300px;margin:0 auto;height:calc(100vh - 136px);overflow:hidden;">

    <!-- ══ LEFT PANEL ══════════════════════════════════════════════════════ -->
    <div class="no-print" style="width:300px;flex-shrink:0;overflow-y:auto;border-right:1px solid #e5e7eb;background:#fff;">

      <!-- 1. Approval section -->
      <div style="padding:14px 16px;border-bottom:1px solid #f0f0f0;background:<%= approvalSigned ? "#f0fdf4" : (approvalPending ? "#fffbeb" : "#f9fafb") %>;">
        <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:8px;">Letter Approval</div>
        <% if (letterApproval == null) { %>
        <div style="font-size:0.82rem;color:#9ca3af;margin-bottom:10px;">No signer assigned yet.</div>
        <% } else if (approvalSigned) { %>
        <div style="font-size:0.83rem;color:#15803d;font-weight:600;margin-bottom:4px;">
          <i class="bi bi-patch-check-fill me-1"></i>Signed &amp; Approved
        </div>
        <div style="font-size:0.78rem;color:#374151;margin-bottom:2px;"><%= letterApproval.get("signer_label") %> — <%= letterApproval.get("signer_name") %></div>
        <% if (letterApproval.get("signed_at") != null) { %>
        <div style="font-size:0.74rem;color:#9ca3af;margin-bottom:8px;"><%= new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(letterApproval.get("signed_at")) %></div>
        <% } %>
        <% if (isAdminView && _unsentCount > 0) { %>
        <div style="background:#ecfdf5;border:1px solid #6ee7b7;border-radius:8px;padding:9px 11px;margin-bottom:8px;">
          <div style="font-size:0.76rem;font-weight:700;color:#065f46;margin-bottom:3px;"><i class="bi bi-send me-1"></i><%= _unsentCount %> email<%= _unsentCount != 1 ? "s" : "" %> ready to send</div>
          <div style="font-size:0.72rem;color:#064e3b;line-height:1.5;">Select the member below and click <strong>Send Email</strong>.</div>
        </div>
        <% } %>
        <% } else if (approvalPending) { %>
        <div style="font-size:0.83rem;color:#92400e;font-weight:600;margin-bottom:4px;">
          <i class="bi bi-hourglass-split me-1"></i>Awaiting Signature
        </div>
        <div style="font-size:0.78rem;color:#374151;"><%= letterApproval.get("signer_label") %> — <%= letterApproval.get("signer_name") %></div>
        <% } %>

        <% if (isAdminView) {
             String _approvalConfirmMsg = approvalSigned
               ? "Change the assigned signer? The new signer will receive an email to review and re-approve the letters."
               : "Send all " + totalCount + " panel letter(s) for the signer to review and approve.";
             boolean _collapseSignerForm = approvalSigned;
        %>
        <% if (_collapseSignerForm) { %>
        <button type="button" onclick="document.getElementById('_reassignWrap').style.display = document.getElementById('_reassignWrap').style.display === 'none' ? 'block' : 'none';"
                style="width:100%;background:transparent;border:1px dashed #d1d5db;border-radius:8px;padding:5px 10px;font-size:0.76rem;color:#6b7280;text-align:left;cursor:pointer;margin-top:4px;">
          <i class="bi bi-person-gear me-1"></i>Change Signer <span style="color:#9ca3af;">(only if reassigning)</span>
        </button>
        <div id="_reassignWrap" style="display:none;margin-top:6px;">
        <% } %>
        <form method="POST" action="<%= request.getContextPath() %>/admin/appointment/letter/approval/request" style="margin-top:<%= _collapseSignerForm ? "0" : "10px" %>;"
              onsubmit="return confirm('<%= _approvalConfirmMsg %>');">
          <input type="hidden" name="appointment_id" value="<%= a.getId() %>">
          <select name="signer_user_id" id="signerSelect" style="width:100%;border:1.5px solid #d1d5db;border-radius:8px;padding:6px 10px;font-size:0.82rem;color:#111827;background:#fff;margin-bottom:8px;" onchange="previewSigner(this)">
            <% if (eligibleSigners != null && !eligibleSigners.isEmpty()) {
                 for (Map<String,Object> s : eligibleSigners) {
                   int uid = ((Number) s.get("user_id")).intValue();
                   boolean selected = assignedSignerUserId != null && uid == assignedSignerUserId.intValue();
                   String sTitle = s.get("title") != null ? s.get("title").toString().trim() : "";
                   String sEmail = s.get("email") != null ? s.get("email").toString().trim() : "";
                   String sLabel = s.get("label") != null ? s.get("label").toString().trim() : "";
                   String sName  = s.get("name")  != null ? s.get("name").toString().trim()  : "";
                   String sDisplayName = (sTitle.isEmpty() ? "" : sTitle.toUpperCase() + " ") + sName.toUpperCase();
            %>
            <option value="<%= uid %>" <%= selected ? "selected" : "" %>
                    data-label="<%= sLabel %>"
                    data-displayname="<%= sDisplayName %>"
                    data-email="<%= sEmail %>"><%= sLabel %> — <%= sTitle.isEmpty() ? sName : sTitle + " " + sName %></option>
            <% } } else { %><option value="">No eligible signer</option><% } %>
          </select>
          <button type="submit" class="btn btn-sm w-100" <%= (eligibleSigners == null || eligibleSigners.isEmpty()) ? "disabled" : "" %>
                  style="border-radius:8px;background:#0f766e;color:#fff;font-weight:600;font-size:0.82rem;padding:0.38rem 0;">
            <i class="bi bi-send-check me-1"></i><%= approvalSigned ? "Re-assign Signer" : (approvalPending ? "Resend for Signature" : "Send for Approval") %>
          </button>
        </form>
        <% if (_collapseSignerForm) { %></div><% } %>
        <% } %>
      </div>

      <!-- 2. Member selector -->
      <div style="padding:12px 16px;border-bottom:1px solid #f0f0f0;">
        <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:8px;">
          Panel Member
          <% if (totalCount > 0) { %>
          <span style="float:right;font-size:0.72rem;font-weight:600;padding:1px 8px;border-radius:10px;background:<%= sentCount==totalCount ? "#dcfce7" : "#eff6ff" %>;color:<%= sentCount==totalCount ? "#15803d" : "#1d4ed8" %>;"><%= sentCount %>/<%= totalCount %> sent</span>
          <% } %>
        </div>
        <select id="memberSelect" onchange="switchMember(this.value)"
                style="width:100%;border:1.5px solid #d1d5db;border-radius:9px;padding:7px 10px;font-size:0.85rem;color:#111827;background:#fff;cursor:pointer;outline:none;font-weight:500;">
          <% for (int j = 0; j < members.size(); j++) {
               Map<String,Object> mj = members.get(j);
               String jRole = mj.get("role") != null ? mj.get("role").toString() : "—";
               String jName = mj.get("name") != null ? mj.get("name").toString() : "—";
               boolean jSent   = Boolean.TRUE.equals(mj.get("letter_sent"));
               boolean jSigned = Boolean.TRUE.equals(mj.get("letter_signed"));
          %>
          <option value="<%= j %>"><%= jRole %> — <%= jName %><%= jSent ? " ✉" : "" %><%= jSigned ? " ✓" : "" %></option>
          <% } %>
        </select>
      </div>

      <!-- 3. Per-member info (updates when member changes, rendered per tab) -->
      <% for (int i = 0; i < members.size(); i++) {
           Map<String,Object> mi = members.get(i);
           String role = mi.get("role") != null ? mi.get("role").toString() : "—";
           String name = mi.get("name") != null ? mi.get("name").toString() : "—";
           boolean isSigned = Boolean.TRUE.equals(mi.get("letter_signed"));
           boolean isSent   = Boolean.TRUE.equals(mi.get("letter_sent"));
           String memberEmail = mi.get("email") != null ? mi.get("email").toString() : "";
           int panelId = mi.get("panel_id") != null ? ((Number) mi.get("panel_id")).intValue() : 0;
           String miTitle = mi.get("title") != null ? mi.get("title").toString().trim() : "";
           boolean isExternalRole0 = "External Examiner".equals(role);
           Object eeId0 = mi.get("external_examiner_id");
      %>
      <div id="sidebar-member-<%= i %>" style="<%= i != 0 ? "display:none;" : "" %>">

        <!-- Member name header -->
        <div style="padding:10px 16px;border-bottom:1px solid #f0f0f0;background:#f8fafc;">
          <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:#0f766e;"><%= role %></div>
          <div style="font-size:0.88rem;font-weight:600;color:#111827;line-height:1.4;margin-top:2px;"><%= name %></div>
        </div>

        <!-- Email send -->
        <div style="padding:12px 16px;border-bottom:1px solid #f0f0f0;background:<%= isSent ? "#f0f9ff" : "#fff" %>;">
          <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:6px;">Appointment Email</div>
          <div style="display:flex;align-items:center;gap:6px;margin-bottom:8px;">
            <i class="bi bi-<%= isSent ? "envelope-check-fill" : "envelope" %>" style="color:<%= isSent ? "#2563eb" : "#9ca3af" %>;"></i>
            <span style="font-size:0.82rem;color:<%= isSent ? "#2563eb" : "#6b7280" %>;font-weight:600;"><%= isSent ? "Email sent" : "Not sent yet" %></span>
          </div>
          <% if (!memberEmail.isEmpty()) { %>
          <div style="font-size:0.74rem;color:#9ca3af;margin-bottom:8px;word-break:break-all;"><%= memberEmail %></div>
          <% } %>
          <% if (memberEmail.isEmpty()) { %>
          <div style="font-size:0.74rem;color:#b91c1c;font-weight:600;margin-bottom:6px;">No email on record</div>
          <% if (isAdminView && isExternalRole0 && eeId0 != null) { %>
          <form method="POST" action="<%= request.getContextPath() %>/admin/external-examiner/update-email" style="margin:0;">
            <input type="hidden" name="external_examiner_id" value="<%= eeId0 %>">
            <input type="hidden" name="appointment_id" value="<%= a.getId() %>">
            <div style="display:flex;gap:4px;align-items:center;">
              <input type="email" name="email" required placeholder="Enter email address"
                     style="flex:1;font-size:0.76rem;padding:4px 8px;border:1px solid #d1d5db;border-radius:6px;min-width:0;">
              <button type="submit" class="btn btn-sm"
                      style="font-size:0.74rem;padding:4px 8px;background:#2563eb;color:#fff;border:none;border-radius:6px;white-space:nowrap;">
                Save
              </button>
            </div>
          </form>
          <% } %>
          <% } else if (isAdminView) { %>
          <form method="POST" action="<%= request.getContextPath() %>/admin/appointment/letter/send" style="margin:0;"
                onsubmit="return confirm('<%= isSent ? "Resend the appointment letter email to " + name + "?" : "Send appointment letter email to " + name + " (" + role + ")?\n\nThis will send the letter to: " + memberEmail %>');">
            <input type="hidden" name="panel_id" value="<%= panelId %>">
            <input type="hidden" name="appointment_id" value="<%= a.getId() %>">
            <button type="submit" class="btn btn-sm w-100" <%= approvalSigned ? "" : "disabled" %>
                    title="<%= approvalSigned ? "" : "Approval required before sending." %>"
                    style="border-radius:8px;font-size:0.82rem;font-weight:600;padding:0.38rem 0;
                           background:<%= isSent ? "#fff" : (approvalSigned ? "#2563eb" : "#e5e7eb") %>;
                           color:<%= isSent ? "#374151" : (approvalSigned ? "#fff" : "#9ca3af") %>;
                           border:1.5px solid <%= isSent ? "#d1d5db" : (approvalSigned ? "#2563eb" : "#e5e7eb") %>;">
              <i class="bi bi-envelope-arrow-up me-1"></i><%= isSent ? "Resend Email" : "Send Email" %>
            </button>
          </form>
          <% if (!approvalSigned) { %><div style="font-size:0.71rem;color:#9ca3af;margin-top:5px;">Awaiting signer approval first.</div><% } %>
          <% } %>
        </div>

        <% if (isExternalRole0) {
          String panelResp0    = mi.get("panel_response")  != null ? mi.get("panel_response").toString()  : "";
          String rejectReason0 = mi.get("rejection_reason")!= null ? mi.get("rejection_reason").toString() : "";
          Object sentAt0       = mi.get("letter_sent_at");
          Object respondedAt0  = mi.get("responded_at");
          boolean respAccepted = "accepted".equals(panelResp0);
          boolean respDeclined = "declined".equals(panelResp0);
          boolean responded    = respAccepted || respDeclined;
        %>
        <!-- Examiner Response (External only) -->
        <div style="padding:12px 16px;border-bottom:1px solid #f0f0f0;
                    background:<%= respAccepted ? "#f0fdf4" : respDeclined ? "#fef2f2" : "#fffbeb" %>;">
          <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:6px;">Examiner Response</div>
          <div style="display:flex;align-items:center;gap:6px;margin-bottom:<%= responded ? "8px" : "0" %>;">
            <% if (respAccepted) { %>
              <i class="bi bi-check-circle-fill" style="color:#16a34a;"></i>
              <span style="font-size:0.82rem;color:#15803d;font-weight:600;">Accepted</span>
              <% if (respondedAt0 != null) { %><span style="font-size:0.72rem;color:#9ca3af;margin-left:auto;"><%= respondedAt0 %></span><% } %>
            <% } else if (respDeclined) { %>
              <i class="bi bi-x-circle-fill" style="color:#b91c1c;"></i>
              <span style="font-size:0.82rem;color:#991b1b;font-weight:600;">Declined</span>
              <% if (respondedAt0 != null) { %><span style="font-size:0.72rem;color:#9ca3af;margin-left:auto;"><%= respondedAt0 %></span><% } %>
            <% } else if (sentAt0 != null) { %>
              <i class="bi bi-clock-history" style="color:#d97706;"></i>
              <span style="font-size:0.82rem;color:#92400e;font-weight:600;">Awaiting response</span>
            <% } else { %>
              <i class="bi bi-dash-circle" style="color:#d1d5db;"></i>
              <span style="font-size:0.82rem;color:#9ca3af;font-weight:600;">Not applicable (email not sent)</span>
            <% } %>
          </div>
          <% if (respDeclined && !rejectReason0.isEmpty()) { %>
          <div style="background:#fee2e2;border-radius:6px;padding:7px 10px;font-size:0.8rem;color:#7f1d1d;margin-top:4px;">
            <div style="font-weight:700;font-size:0.72rem;color:#b91c1c;margin-bottom:2px;">Reason</div>
            <%= rejectReason0.replace("<","&lt;").replace(">","&gt;") %>
          </div>
          <% } %>
        </div>
        <% } %>

        <!-- Panel signed copy -->
        <div style="padding:12px 16px;border-bottom:1px solid #f0f0f0;background:<%= isSigned ? "#f0fdf4" : "#fff" %>;">
          <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:6px;">Signed Copy Returned</div>
          <div style="display:flex;align-items:center;gap:6px;margin-bottom:8px;">
            <i class="bi bi-<%= isSigned ? "check-circle-fill" : "hourglass-split" %>" style="color:<%= isSigned ? "#16a34a" : "#d97706" %>;"></i>
            <span style="font-size:0.82rem;color:<%= isSigned ? "#15803d" : "#92400e" %>;font-weight:600;"><%= isSigned ? "Received" : "Awaiting" %></span>
          </div>
          <% if (isAdminView) { %>
          <form method="POST" action="<%= request.getContextPath() %>/admin/appointment/letter/sign" style="margin:0;"
                onsubmit="return confirm('<%= isSigned ? "Unmark signed copy for " + name + "?" : "Mark signed copy received from " + name + "?" %>');">
            <input type="hidden" name="panel_id" value="<%= panelId %>">
            <input type="hidden" name="appointment_id" value="<%= a.getId() %>">
            <input type="hidden" name="action" value="<%= isSigned ? "unsign" : "sign" %>">
            <button type="submit" class="btn btn-sm w-100"
                    style="border-radius:8px;font-size:0.82rem;font-weight:600;padding:0.38rem 0;
                           background:<%= isSigned ? "#fff" : "#0f766e" %>;color:<%= isSigned ? "#6b7280" : "#fff" %>;
                           border:1.5px solid <%= isSigned ? "#d1d5db" : "#0f766e" %>;">
              <i class="bi bi-<%= isSigned ? "x-circle" : "check2-circle" %> me-1"></i><%= isSigned ? "Unmark Signed" : "Mark as Signed" %>
            </button>
          </form>
          <% } else { %>
          <div style="font-size:0.72rem;color:#9ca3af;">Managed by admin.</div>
          <% } %>
        </div>

        <%-- Internal member quick response (if logged-in user is the assigned internal member) --%>
        <% if (!isExternalRole0) {
             Object intUidObj = mi.get("internal_user_id");
             Integer intUid = intUidObj instanceof Number ? ((Number) intUidObj).intValue() : null;
             String panelResp0 = mi.get("panel_response") != null ? mi.get("panel_response").toString() : "";
             boolean responded = "accepted".equals(panelResp0) || "declined".equals(panelResp0);
             if (intUid != null && currentUserId != null && intUid.equals(currentUserId) && !responded) {
        %>
        <div style="padding:12px 16px;border-bottom:1px solid #f0f0f0;background:#fff;">
          <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:6px;">Your Response</div>
          <form method="POST" action="<%= request.getContextPath() %>/PanelMemberResponseServlet" onsubmit="return confirm('Confirm acceptance of this viva appointment?');" style="margin-bottom:8px;">
            <input type="hidden" name="panel_id" value="<%= panelId %>">
            <input type="hidden" name="action" value="accept">
            <button type="submit" class="btn btn-sm w-100" style="border-radius:8px;background:#0f766e;color:#fff;font-weight:600;">
              <i class="bi bi-check-circle-fill me-1"></i>Accept this Appointment
            </button>
          </form>
          <button class="btn btn-sm w-100" style="border-radius:8px;background:#fff;border:1.5px solid #fca5a5;color:#b91c1c;font-weight:600;" onclick="document.getElementById('decline-form-<%= panelId %>').style.display='block';">Decline this Appointment</button>
          <div id="decline-form-<%= panelId %>" style="display:none;margin-top:8px;">
            <form method="POST" action="<%= request.getContextPath() %>/PanelMemberResponseServlet" onsubmit="return confirm('Confirm declining this appointment?');">
              <input type="hidden" name="panel_id" value="<%= panelId %>">
              <input type="hidden" name="action" value="decline">
              <textarea name="rejection_reason" class="form-control mb-2" placeholder="Please provide reason for declining" required style="min-height:80px;border-radius:8px;"></textarea>
              <button type="submit" class="btn btn-sm w-100" style="border-radius:8px;background:#b91c1c;color:#fff;font-weight:600;">Submit Decline</button>
            </form>
          </div>
        </div>
        <%   }
           }
        %>

        <% if (isExternalRole0) { %>
        <!-- Language selector (External only) -->
        <div style="padding:12px 16px 24px;">
          <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:8px;">Language</div>
          <div style="display:flex;flex-direction:column;gap:6px;" id="langTabs-<%= i %>" role="tablist">
            <button class="btn btn-sm active" id="en-tab-<%= i %>" data-bs-toggle="pill"
                    data-bs-target="#letter-en-<%= i %>" type="button" role="tab"
                    style="border-radius:8px;font-size:0.83rem;font-weight:600;padding:0.38rem 0.8rem;border:1.5px solid #0f766e;color:#fff;background:#0f766e;text-align:left;">
              🇬🇧 English
            </button>
            <button class="btn btn-sm" id="ms-tab-<%= i %>" data-bs-toggle="pill"
                    data-bs-target="#letter-ms-<%= i %>" type="button" role="tab"
                    style="border-radius:8px;font-size:0.83rem;font-weight:600;padding:0.38rem 0.8rem;border:1.5px solid #d1d5db;color:#6b7280;background:#fff;text-align:left;">
              🇲🇾 Bahasa Melayu
            </button>
          </div>
        </div>
        <% } %>

      </div><!-- end sidebar-member-i -->
      <% } %>

    </div><!-- end left panel -->

    <!-- ══ RIGHT: Letter content ══════════════════════════════════════════ -->
    <div style="flex:1;overflow-y:auto;background:#f3f4f6;" id="letterScrollArea">
      <div class="tab-content" id="letterTabContent">
        <% for (int i = 0; i < members.size(); i++) {
             Map<String,Object> mi = members.get(i);
             String role = mi.get("role") != null ? mi.get("role").toString() : "—";
             String name = mi.get("name") != null ? mi.get("name").toString() : "—";
             boolean isSigned = Boolean.TRUE.equals(mi.get("letter_signed"));
             boolean isSent   = Boolean.TRUE.equals(mi.get("letter_sent"));
             String memberEmail = mi.get("email") != null ? mi.get("email").toString() : "";
             int panelId = mi.get("panel_id") != null ? ((Number) mi.get("panel_id")).intValue() : 0;
        %>
        <%
          String miTitle       = mi.get("title")      != null ? mi.get("title").toString().trim()      : "";
          String miAffiliation = mi.get("affiliation") != null ? mi.get("affiliation").toString().trim() : "";
          String miCountry     = mi.get("country")     != null ? mi.get("country").toString().trim()     : "";
          boolean isExternalRole = "External Examiner".equals(role);
          String candidateProgram   = a.getCandidateProgram()   != null ? a.getCandidateProgram()   : "";
          String candidateProgramMS = a.getCandidateProgramMS() != null ? a.getCandidateProgramMS() : "";
          String candidateProgramLevel = a.getCandidateProgramLevel();
          boolean isPhD;
          if ("Master".equalsIgnoreCase(candidateProgramLevel)) { isPhD = false; }
          else if ("PhD".equalsIgnoreCase(candidateProgramLevel)) { isPhD = true; }
          else { String sniff = candidateProgram.toLowerCase(); isPhD = sniff.contains("doctor") || sniff.contains("phd") || sniff.contains("falsafah"); }
          String degreeLabelEN = isPhD ? "Doctor of Philosophy" : "Master";
          String degreeLabelMS = isPhD ? "Doktor Falsafah" : "Sarjana";
          String salutation = miTitle.isEmpty() ? (isExternalRole ? "Sir/Madam" : "Dr.") : miTitle;
          String confirmDeadlineLabel = a.getScheduledAt() != null ? new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)").format(new java.util.Date(a.getScheduledAt().getTime() - 14L*24*60*60*1000)) : "[ to be confirmed ]";
          String reportDeadlineLabel  = a.getScheduledAt() != null ? new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)").format(new java.util.Date(a.getScheduledAt().getTime() - 7L*24*60*60*1000))  : "[ to be confirmed ]";
          String vivaDayLabel = a.getScheduledAt() != null ? new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)").format(a.getScheduledAt()) : "[ to be confirmed ]";
          String honorariumEN = isExternalRole ? "You will receive an honorarium payment of MYR600.00." : "You will receive an honorarium payment of RM600.";
          String honorariumMS = isExternalRole ? "YBrs. akan menerima imbuhan bayaran (honorarium) sebanyak MYR600.00." : "YBrs. akan menerima imbuhan bayaran (honorarium) sebanyak RM600.";
          String formRefEN = isExternalRole ? "PG-16a" : "UMT/B/PG-16c";
          String formRefMS = isExternalRole ? "PG-16a" : "UMT/B/PG-16c";
        %>
        <div class="tab-pane <%= i == 0 ? "show active" : "" %>" id="letter-<%= i %>" role="tabpanel">
          <% if (isExternalRole) { %>
          <div class="tab-content" id="langTabContent-<%= i %>">
            <div class="tab-pane show active" id="letter-en-<%= i %>" role="tabpanel">
              <%@ include file="letter/tmpl-external-en.jsp" %>
            </div>
            <div class="tab-pane" id="letter-ms-<%= i %>" role="tabpanel">
              <%@ include file="letter/tmpl-external-ms.jsp" %>
            </div>
          </div>
          <% } else if ("Chairperson".equals(role)) { %>
            <%@ include file="letter/tmpl-chair-ms.jsp" %>
          <% } else if ("Secretary".equals(role)) { %>
            <%@ include file="letter/tmpl-secretary-ms.jsp" %>
          <% } else { %>
            <%@ include file="letter/tmpl-internal-ms.jsp" %>
          <% } %>
        </div>
        <% } %>
      </div>
    </div><!-- end right -->
  </div><!-- end main layout -->
  <% } %>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function switchMember(idx) {
      // switch Bootstrap tab
      var tab = document.getElementById('tab-' + idx);
      if (tab) bootstrap.Tab.getOrCreateInstance(tab).show();
      // show/hide sidebar member sections
      document.querySelectorAll('[id^="sidebar-member-"]').forEach(function(el) {
        el.style.display = 'none';
      });
      var sm = document.getElementById('sidebar-member-' + idx);
      if (sm) sm.style.display = 'block';
      // scroll letter area to top
      var area = document.getElementById('letterScrollArea');
      if (area) area.scrollTop = 0;
    }
    // ── Live signer preview: updates letter signature when dropdown changes ──
    var ROLE_MAP = {
      'Dean': { ms: 'Dekan', en: 'Dean' },
      'TDA':  { ms: 'Timbalan Dekan (Akademik dan Hal Ehwal Pelajar)', en: 'Deputy Dean (Academic and Student Affairs)' },
      'TDB':  { ms: 'Timbalan Dekan (Penyelidikan dan Inovasi)',        en: 'Deputy Dean (Research and Innovation)' }
    };
    function previewSigner(sel) {
      var opt   = sel.options[sel.selectedIndex];
      var label = opt.getAttribute('data-label') || '';
      var displayName = opt.getAttribute('data-displayname') || '';
      var email = opt.getAttribute('data-email') || '';
      var roles = ROLE_MAP[label] || { ms: label, en: label };

      // Update all name/role/email nodes in the rendered letter templates
      document.querySelectorAll('.letter-signer-name').forEach(function(el) {
        el.textContent = displayName || '[ DEKAN / TIMBALAN DEKAN ]';
      });
      document.querySelectorAll('.letter-signer-role-ms').forEach(function(el) {
        el.textContent = roles.ms;
      });
      document.querySelectorAll('.letter-signer-role-en').forEach(function(el) {
        el.textContent = roles.en;
      });
      document.querySelectorAll('.letter-signer-email-link').forEach(function(el) {
        el.href = 'mailto:' + email;
        el.textContent = email || 'fskm@umt.edu.my';
      });
    }
    document.addEventListener('DOMContentLoaded', function() {
      // Fire once on load so the letter reflects the currently-selected signer
      var signerSel = document.getElementById('signerSelect');
      if (signerSel) previewSigner(signerSel);

      document.querySelectorAll('#letterTabs .nav-link').forEach(function(btn) {
        btn.addEventListener('shown.bs.tab', function() {
          var idxStr = btn.id.replace('tab-', '');
          var sel = document.getElementById('memberSelect');
          if (sel) sel.value = idxStr;
          document.querySelectorAll('[id^="sidebar-member-"]').forEach(function(el) { el.style.display = 'none'; });
          var sm = document.getElementById('sidebar-member-' + idxStr);
          if (sm) sm.style.display = 'block';
        });
      });
      // Language toggle styling
      document.querySelectorAll('[data-bs-toggle="pill"]').forEach(function(btn) {
        btn.addEventListener('shown.bs.tab', function() {
          var group = btn.closest('[role="tablist"]');
          if (!group) return;
          group.querySelectorAll('[data-bs-toggle="pill"]').forEach(function(b) {
            var active = b === btn;
            b.style.background  = active ? '#0f766e' : '#fff';
            b.style.color       = active ? '#fff'    : '#6b7280';
            b.style.borderColor = active ? '#0f766e' : '#d1d5db';
          });
        });
      });
    });
  </script>
</body>
</html>
