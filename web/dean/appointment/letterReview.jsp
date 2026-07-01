<%--
  Dean/TDA/TDB: read-only letter review and sign-off page. Shows the bilingual letter preview
  and a signature upload/confirm form. Served by LetterPreviewServlet at /appointment/letter/review.
--%>
<%@ page import="model.VivaAppointment, java.util.List, java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  VivaAppointment a = (VivaAppointment) request.getAttribute("appointment");
  if (a == null) {
    response.sendRedirect(request.getContextPath() + "/DeanDashboardServlet");
    return;
  }
  String fullName = (String) session.getAttribute("full_name"); if (fullName == null) fullName = "Dean";
  String adminEmail = (String) session.getAttribute("email"); if (adminEmail == null) adminEmail = "fskm@umt.edu.my";
  Integer currentUserId = null;
  if (session.getAttribute("user_id") instanceof Number) {
    currentUserId = ((Number) session.getAttribute("user_id")).intValue();
  }
  List<Map<String,Object>> members = a.getPanelMembers();
  Map<String,Object> letterApproval = (Map<String,Object>) request.getAttribute("letterApproval");
  String approvalStatus = letterApproval != null && letterApproval.get("status") != null ? letterApproval.get("status").toString() : "none";
  boolean approvalSigned = "signed".equalsIgnoreCase(approvalStatus);
  boolean approvalPending = "pending".equalsIgnoreCase(approvalStatus);
  Integer assignedSignerUserId = null;
  if (letterApproval != null && letterApproval.get("signer_user_id") instanceof Number) {
    assignedSignerUserId = ((Number) letterApproval.get("signer_user_id")).intValue();
  }
  boolean canCurrentUserSign = approvalPending && assignedSignerUserId != null && currentUserId != null
      && assignedSignerUserId.intValue() == currentUserId.intValue();
  String approvalMsg   = (String) request.getAttribute("approvalMsg");
  String approvalError = (String) request.getAttribute("approvalError");
  String signerStoredSignature = (String) request.getAttribute("signerStoredSignature");
  String today   = new java.text.SimpleDateFormat("dd MMMM yyyy").format(new java.util.Date());
  String vivaDate = a.getScheduledAt() != null
      ? new java.text.SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(a.getScheduledAt()) : "—";
  int signedCount = 0;
  int totalCount  = members != null ? members.size() : 0;
  int sentCount   = letterApproval != null && request.getAttribute("letterSentCount") instanceof Number
      ? ((Number) request.getAttribute("letterSentCount")).intValue() : 0;
  if (members != null) {
    for (Map<String,Object> m : members) {
      if (Boolean.TRUE.equals(m.get("letter_signed"))) signedCount++;
    }
  }
  // ── Dynamic signer display variables (shared with included letter templates) ──
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
      signerDisplayRole_MS = "Dekan"; signerDisplayRole_EN = "Dean";
    } else if ("TDA".equalsIgnoreCase(_sLabel)) {
      signerDisplayRole_MS = "Timbalan Dekan (Akademik dan Hal Ehwal Pelajar)";
      signerDisplayRole_EN = "Deputy Dean (Academic and Student Affairs)";
    } else if ("TDB".equalsIgnoreCase(_sLabel)) {
      signerDisplayRole_MS = "Timbalan Dekan (Penyelidikan dan Inovasi)";
      signerDisplayRole_EN = "Deputy Dean (Research and Innovation)";
    } else if (!_sLabel.isEmpty()) {
      signerDisplayRole_MS = _sLabel; signerDisplayRole_EN = _sLabel;
    }
  }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Letter Review - E-Appointment FSKM</title>
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
    /* Member dropdown tabs (hidden, controlled by select) */
    #letterTabs { display: none; }
    /* Teal color vars */
    :root { --teal: #0f766e; }
  </style>
</head>
<body style="background:#f3f4f6;">

  <jsp:include page="/includes/topbar.jsp" />

  <!-- Action bar (fixed) — Back + Print only -->
  <div class="no-print d-flex align-items-center justify-content-between px-4 py-3"
       style="position:fixed;top:64px;left:0;right:0;z-index:998;background:#fff;border-bottom:1px solid #e5e7eb;box-shadow:0 2px 8px rgba(0,0,0,0.06);">
    <a href="<%= request.getContextPath() %>/DeanDashboardServlet" class="btn-ea-back">
      <i class="bi bi-arrow-left me-1"></i> Back to Dashboard
    </a>
    <button onclick="window.print()" class="ea-btn-teal-outline">
      <i class="bi bi-printer me-1"></i> Print / PDF
    </button>
  </div>

  <div class="no-print" style="height:136px;"></div>

  <!-- Alert messages -->
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

  <!-- Hidden Bootstrap tabs -->
  <ul class="nav" id="letterTabs" role="tablist" style="display:none;">
    <% if (members != null) { for (int i = 0; i < members.size(); i++) {
         Map<String,Object> mi0 = members.get(i); %>
    <li class="nav-item" role="presentation">
      <button class="nav-link <%= i == 0 ? "active" : "" %>"
              id="tab-<%= i %>" data-bs-toggle="tab" data-bs-target="#letter-<%= i %>"
              type="button" role="tab">
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

      <!-- 0. Appointment info header -->
      <div style="padding:14px 16px;border-bottom:1px solid #e5e7eb;background:linear-gradient(135deg,#0f766e 0%,#0d9488 100%);">
        <div style="font-size:0.64rem;font-weight:700;text-transform:uppercase;letter-spacing:.1em;color:rgba(255,255,255,0.7);margin-bottom:6px;">Viva Appointment</div>
        <div style="font-size:0.95rem;font-weight:700;color:#fff;line-height:1.3;margin-bottom:2px;">
          <%= a.getCandidateName() != null ? a.getCandidateName() : "—" %>
        </div>
        <% if (a.getCandidateStudentId() != null) { %>
        <div style="font-size:0.75rem;color:rgba(255,255,255,0.8);margin-bottom:6px;"><%= a.getCandidateStudentId() %></div>
        <% } %>
        <% if (a.getCandidateProgram() != null && !a.getCandidateProgram().isEmpty()) { %>
        <div style="font-size:0.74rem;color:rgba(255,255,255,0.85);background:rgba(255,255,255,0.15);border-radius:5px;padding:2px 8px;display:inline-block;margin-bottom:6px;">
          <%= a.getCandidateProgram() %>
        </div>
        <% } %>
        <div style="display:flex;flex-direction:column;gap:3px;margin-top:4px;">
          <div style="font-size:0.74rem;color:rgba(255,255,255,0.9);">
            <i class="bi bi-calendar-event me-1"></i>
            <%= vivaDate %>
          </div>
          <% String venue = a.getVenue(); if (venue != null && !venue.isEmpty()) { %>
          <div style="font-size:0.74rem;color:rgba(255,255,255,0.9);">
            <i class="bi bi-geo-alt me-1"></i><%= venue %>
          </div>
          <% } %>
        </div>
      </div>

      <!-- 1. Approval section -->
      <div style="padding:14px 16px;border-bottom:1px solid #f0f0f0;background:<%= approvalSigned ? "#f0fdf4" : (approvalPending ? "#fffbeb" : "#f9fafb") %>;">
        <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:8px;">Letter Approval</div>
        <% if (letterApproval == null) { %>
        <div style="font-size:0.82rem;color:#9ca3af;margin-bottom:6px;">No signer assigned yet. Admin will notify you.</div>
        <% } else if (approvalSigned) { %>
        <div style="font-size:0.83rem;color:#15803d;font-weight:600;margin-bottom:4px;">
          <i class="bi bi-patch-check-fill me-1"></i>Signed &amp; Approved
        </div>
        <div style="font-size:0.78rem;color:#374151;margin-bottom:2px;"><%= letterApproval.get("signer_label") %> — <%= letterApproval.get("signer_name") %></div>
        <% if (letterApproval.get("signed_at") != null) { %>
        <div style="font-size:0.74rem;color:#9ca3af;margin-bottom:8px;"><%= new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(letterApproval.get("signed_at")) %></div>
        <% } %>
        <div style="font-size:0.74rem;color:#15803d;font-weight:600;padding:5px 8px;background:#dcfce7;border-radius:7px;">
          <i class="bi bi-check2-circle me-1"></i>Admin can now send panel emails.
        </div>
        <% } else if (approvalPending) { %>
        <div style="font-size:0.83rem;color:#92400e;font-weight:600;margin-bottom:4px;">
          <i class="bi bi-hourglass-split me-1"></i>Awaiting Your Signature
        </div>
        <div style="font-size:0.78rem;color:#374151;margin-bottom:10px;">Assigned to: <strong><%= letterApproval.get("signer_label") %></strong></div>
        <% if (canCurrentUserSign) { %>
        <form method="POST" action="<%= request.getContextPath() %>/appointment/letter/approval/sign"
              enctype="multipart/form-data" style="margin:0;"
              onsubmit="return confirm('Sign and approve this appointment letter?\n\nThis approves emails for all panel members and notifies the admin.');">
          <input type="hidden" name="appointment_id" value="<%= a.getId() %>">
          <div style="margin-bottom:10px;">
            <label style="font-size:0.75rem;font-weight:600;color:#374151;display:block;margin-bottom:4px;">
              <i class="bi bi-image me-1"></i>Signature
            </label>
            <% if (signerStoredSignature != null && !signerStoredSignature.isEmpty()) {
                 java.io.File _storedFile = new java.io.File(application.getRealPath("/uploads/signatures"), signerStoredSignature);
                 if (_storedFile.exists()) { %>
            <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;padding:8px 10px;margin-bottom:8px;">
              <div style="font-size:0.72rem;color:#15803d;font-weight:600;margin-bottom:5px;"><i class="bi bi-check-circle-fill me-1"></i>Stored signature will be used</div>
              <img src="<%= request.getContextPath() %>/uploads/signatures/<%= signerStoredSignature %>"
                   alt="Your stored signature" style="max-height:52px;max-width:180px;display:block;border:1px solid #d1fae5;border-radius:5px;padding:2px;background:#fff;">
            </div>
            <div style="font-size:0.72rem;color:#9ca3af;margin-bottom:6px;">Upload a new image below to replace it:</div>
            <% } } %>
            <input type="file" name="signature_image" id="sigFileInput" accept="image/png,image/jpeg,image/gif"
                   onchange="previewSig(this)" style="display:none;">
            <div id="sigDropZone" onclick="document.getElementById('sigFileInput').click()"
                 style="border:1.5px dashed #d1d5db;border-radius:10px;padding:14px 10px;text-align:center;
                        cursor:pointer;background:#fafafa;transition:border-color 0.2s,background 0.2s;">
              <i class="bi bi-cloud-arrow-up" style="font-size:1.4rem;color:#9ca3af;display:block;margin-bottom:4px;"></i>
              <div style="font-size:0.75rem;color:#6b7280;font-weight:500;">Click to choose image</div>
              <div style="font-size:0.68rem;color:#9ca3af;margin-top:2px;">PNG, JPG, GIF</div>
            </div>
            <div id="sigPreviewWrap" style="display:none;margin-top:8px;text-align:center;">
              <img id="sigPreviewImg" src="" alt="Signature preview"
                   style="max-height:64px;max-width:200px;border:1px solid #e5e7eb;border-radius:6px;padding:3px;background:#fff;">
              <div style="margin-top:4px;">
                <button type="button" onclick="clearSig()"
                        style="border:none;background:none;color:#9ca3af;font-size:0.75rem;cursor:pointer;">
                  &#x2715; Remove
                </button>
              </div>
            </div>
          </div>
          <button type="submit" class="btn btn-sm w-100"
                  style="border-radius:8px;background:#0f766e;color:#fff;font-weight:600;font-size:0.85rem;padding:0.42rem 0;">
            <i class="bi bi-pen-fill me-1"></i> Sign &amp; Approve Letter
          </button>
        </form>
        <% } else { %>
        <div style="font-size:0.74rem;color:#9ca3af;margin-top:4px;">You are not the assigned signer.</div>
        <% } %>
        <% } else { %>
        <div style="font-size:0.82rem;color:#9ca3af;">No signer assigned yet.</div>
        <% } %>
      </div>

      <!-- 2. Panel email progress -->
      <% if (totalCount > 0) { %>
      <div style="padding:12px 16px;border-bottom:1px solid #f0f0f0;">
        <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:6px;">
          Admin Email Progress
        </div>
        <div style="display:flex;align-items:center;gap:8px;">
          <i class="bi bi-envelope-<%= sentCount == totalCount ? "check-fill" : "arrow-up" %>" style="color:<%= sentCount == totalCount ? "#15803d" : "#2563eb" %>;font-size:1rem;"></i>
          <span style="font-size:0.85rem;font-weight:600;color:<%= sentCount == totalCount ? "#15803d" : "#374151" %>;">
            <%= sentCount %>/<%= totalCount %> emails sent
          </span>
        </div>
        <div style="font-size:0.72rem;color:#9ca3af;margin-top:4px;">Admin sends individual emails per panel member after approval.</div>
      </div>
      <% } %>

      <!-- 3. Member selector -->
      <div style="padding:12px 16px;border-bottom:1px solid #f0f0f0;">
        <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:8px;">Panel Member</div>
        <select id="memberSelect" onchange="switchMember(this.value)"
                style="width:100%;border:1.5px solid #d1d5db;border-radius:9px;padding:7px 10px;font-size:0.85rem;color:#111827;background:#fff;cursor:pointer;outline:none;font-weight:500;">
          <% for (int j = 0; j < members.size(); j++) {
               Map<String,Object> mj = members.get(j);
               String jRole = mj.get("role") != null ? mj.get("role").toString() : "—";
               String jName = mj.get("name") != null ? mj.get("name").toString() : "—";
               boolean jSent = Boolean.TRUE.equals(mj.get("letter_sent"));
          %>
          <option value="<%= j %>"><%= jRole %> — <%= jName %><%= jSent ? " ✉" : "" %></option>
          <% } %>
        </select>
      </div>

      <!-- 4. Per-member info -->
      <% for (int i = 0; i < members.size(); i++) {
           Map<String,Object> mi = members.get(i);
           String role = mi.get("role") != null ? mi.get("role").toString() : "—";
           String name = mi.get("name") != null ? mi.get("name").toString() : "—";
           boolean isSent = Boolean.TRUE.equals(mi.get("letter_sent"));
           String memberEmail = mi.get("email") != null ? mi.get("email").toString() : "";
           String miTitle = mi.get("title") != null ? mi.get("title").toString().trim() : "";
           boolean isExternalRole0 = "External Examiner".equals(role);
      %>
      <div id="sidebar-member-<%= i %>" style="<%= i != 0 ? "display:none;" : "" %>">

        <!-- Member name header -->
        <div style="padding:10px 16px;border-bottom:1px solid #f0f0f0;background:#f8fafc;">
          <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:#0f766e;"><%= role %></div>
          <div style="font-size:0.88rem;font-weight:600;color:#111827;line-height:1.4;margin-top:2px;"><%= name %></div>
        </div>

        <!-- Email status (read-only) -->
        <div style="padding:12px 16px;border-bottom:1px solid #f0f0f0;background:<%= isSent ? "#f0f9ff" : "#fff" %>;">
          <div style="font-size:0.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:#6b7280;margin-bottom:6px;">Appointment Email</div>
          <div style="display:flex;align-items:center;gap:6px;margin-bottom:6px;">
            <i class="bi bi-<%= isSent ? "envelope-check-fill" : "envelope" %>" style="color:<%= isSent ? "#2563eb" : "#9ca3af" %>;"></i>
            <span style="font-size:0.82rem;font-weight:600;color:<%= isSent ? "#2563eb" : "#6b7280" %>;"><%= isSent ? "Email sent by admin" : "Not sent yet" %></span>
          </div>
          <% if (!memberEmail.isEmpty()) { %>
          <div style="font-size:0.74rem;color:#9ca3af;word-break:break-all;"><%= memberEmail %></div>
          <% } %>
        </div>

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
             String role  = mi.get("role")  != null ? mi.get("role").toString()  : "—";
             String name  = mi.get("name")  != null ? mi.get("name").toString()  : "—";
             boolean isSent = Boolean.TRUE.equals(mi.get("letter_sent"));
             String memberEmail = mi.get("email") != null ? mi.get("email").toString() : "";
             int panelId = mi.get("panel_id") != null ? ((Number) mi.get("panel_id")).intValue() : 0;
        %>
        <%
          String miTitle       = mi.get("title")       != null ? mi.get("title").toString().trim()       : "";
          String miAffiliation = mi.get("affiliation")  != null ? mi.get("affiliation").toString().trim() : "";
          String miCountry     = mi.get("country")      != null ? mi.get("country").toString().trim()     : "";
          boolean isExternalRole = "External Examiner".equals(role);
          String candidateProgram      = a.getCandidateProgram()   != null ? a.getCandidateProgram()   : "";
          String candidateProgramMS    = a.getCandidateProgramMS() != null ? a.getCandidateProgramMS() : "";
          String candidateProgramLevel = a.getCandidateProgramLevel();
          boolean isPhD;
          if ("Master".equalsIgnoreCase(candidateProgramLevel)) {
              isPhD = false;
          } else if ("PhD".equalsIgnoreCase(candidateProgramLevel)) {
              isPhD = true;
          } else {
              String sniff = candidateProgram.toLowerCase();
              isPhD = sniff.contains("doctor") || sniff.contains("phd") || sniff.contains("falsafah");
          }
          String degreeLabelEN  = isPhD ? "Doctor of Philosophy" : "Master";
          String degreeLabelMS  = isPhD ? "Doktor Falsafah" : "Sarjana";
          String salutation     = miTitle.isEmpty() ? (isExternalRole ? "Sir/Madam" : "Dr.") : miTitle;
          String confirmDeadlineLabel = a.getScheduledAt() != null
              ? new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)").format(new java.util.Date(a.getScheduledAt().getTime() - 14L*24*60*60*1000))
              : "[ to be confirmed ]";
          String reportDeadlineLabel  = a.getScheduledAt() != null
              ? new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)").format(new java.util.Date(a.getScheduledAt().getTime() - 7L*24*60*60*1000))
              : "[ to be confirmed ]";
          String vivaDayLabel = a.getScheduledAt() != null
              ? new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)").format(a.getScheduledAt())
              : "[ to be confirmed ]";
          String honorariumEN = isExternalRole ? "You will receive an honorarium payment of MYR600.00." : "You will receive an honorarium payment of RM600.";
          String honorariumMS = isExternalRole ? "YBrs. akan menerima imbuhan bayaran (honorarium) sebanyak MYR600.00." : "YBrs. akan menerima imbuhan bayaran (honorarium) sebanyak RM600.";
          String formRefEN    = isExternalRole ? "PG-16a" : "UMT/B/PG-16c";
          String formRefMS    = isExternalRole ? "PG-16a" : "UMT/B/PG-16c";
        %>
        <div class="tab-pane <%= i == 0 ? "show active" : "" %>" id="letter-<%= i %>" role="tabpanel">
          <% if (isExternalRole) { %>
          <div class="tab-content" id="langTabContent-<%= i %>">
            <div class="tab-pane show active" id="letter-en-<%= i %>" role="tabpanel">
              <%@ include file="/admin/appointment/letter/tmpl-external-en.jsp" %>
            </div>
            <div class="tab-pane" id="letter-ms-<%= i %>" role="tabpanel">
              <%@ include file="/admin/appointment/letter/tmpl-external-ms.jsp" %>
            </div>
          </div>
          <% } else if ("Chairperson".equals(role)) { %>
            <%@ include file="/admin/appointment/letter/tmpl-chair-ms.jsp" %>
          <% } else if ("Secretary".equals(role)) { %>
            <%@ include file="/admin/appointment/letter/tmpl-secretary-ms.jsp" %>
          <% } else { %>
            <%@ include file="/admin/appointment/letter/tmpl-internal-ms.jsp" %>
          <% } %>
        </div>
        <% } %>
      </div>
    </div><!-- end right -->

  </div><!-- end main layout -->
  <% } %>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function previewSig(input) {
      var wrap = document.getElementById('sigPreviewWrap');
      var img  = document.getElementById('sigPreviewImg');
      var zone = document.getElementById('sigDropZone');
      if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
          img.src = e.target.result;
          wrap.style.display = 'block';
          if (zone) zone.style.display = 'none';
        };
        reader.readAsDataURL(input.files[0]);
      } else {
        wrap.style.display = 'none';
        if (zone) zone.style.display = 'block';
      }
    }
    function clearSig() {
      document.getElementById('sigFileInput').value = '';
      document.getElementById('sigPreviewWrap').style.display = 'none';
      document.getElementById('sigDropZone').style.display = 'block';
    }
    (function(){
      var zone = document.getElementById('sigDropZone');
      if (!zone) return;
      zone.addEventListener('mouseenter', function(){ this.style.borderColor='#0f766e'; this.style.background='#f0fdf4'; });
      zone.addEventListener('mouseleave', function(){ this.style.borderColor='#d1d5db'; this.style.background='#fafafa'; });
      zone.addEventListener('dragover',   function(e){ e.preventDefault(); this.style.borderColor='#0f766e'; this.style.background='#f0fdf4'; });
      zone.addEventListener('dragleave',  function(){ this.style.borderColor='#d1d5db'; this.style.background='#fafafa'; });
      zone.addEventListener('drop', function(e){
        e.preventDefault();
        this.style.borderColor='#d1d5db'; this.style.background='#fafafa';
        var inp = document.getElementById('sigFileInput');
        inp.files = e.dataTransfer.files;
        previewSig(inp);
      });
    })();
    function switchMember(idx) {
      var tab = document.getElementById('tab-' + idx);
      if (tab) bootstrap.Tab.getOrCreateInstance(tab).show();
      document.querySelectorAll('[id^="sidebar-member-"]').forEach(function(el) { el.style.display = 'none'; });
      var sm = document.getElementById('sidebar-member-' + idx);
      if (sm) sm.style.display = 'block';
      var area = document.getElementById('letterScrollArea');
      if (area) area.scrollTop = 0;
    }
    document.addEventListener('DOMContentLoaded', function() {
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
