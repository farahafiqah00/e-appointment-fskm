<%--
  Internal panel member letter preview page (login required). Renders the appointment letter
  for the logged-in internal examiner/chair after they click the email link.
--%>
<%@ page import="model.VivaAppointment, java.util.Map" pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%
  if (session == null || session.getAttribute("user_id") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  VivaAppointment a = (VivaAppointment) request.getAttribute("appointment");
  @SuppressWarnings("unchecked")
  Map<String,Object> mi = (Map<String,Object>) request.getAttribute("member");
  if (a == null || mi == null) {
    response.sendRedirect(request.getContextPath() + "/academician/my-appointments");
    return;
  }

  // ── UI variables (used only within this page) ───────────────────────────────
  String role      = mi.get("member_role") != null ? mi.get("member_role").toString() : "—";
  String name      = mi.get("user_name")   != null ? mi.get("user_name").toString()
                   : (mi.get("ee_name")    != null ? mi.get("ee_name").toString() : "—");
  String miTitle   = mi.get("user_title")  != null ? mi.get("user_title").toString().trim()
                   : (mi.get("ee_title")   != null ? mi.get("ee_title").toString().trim() : "");
  String panelId   = mi.get("panel_id")    != null ? mi.get("panel_id").toString() : "0";
  String panelResp = mi.get("panel_response") != null ? mi.get("panel_response").toString() : "";
  boolean responded = !panelResp.isEmpty();
  String result = request.getParameter("result");
  String error  = request.getParameter("error");

  // ── Letter template variables → stored as request attributes ────────────────
  String lv_today              = new java.text.SimpleDateFormat("dd MMMM yyyy").format(new java.util.Date());
  String lv_salutation         = name; // name already contains the title prefix from SQL
  String lv_candidateProgram   = a.getCandidateProgram() != null ? a.getCandidateProgram() : "";
  String lv_candidateProgramLevel = a.getCandidateProgramLevel();
  boolean isPhD;
  if ("Master".equalsIgnoreCase(lv_candidateProgramLevel)) {
    isPhD = false;
  } else if ("PhD".equalsIgnoreCase(lv_candidateProgramLevel)) {
    isPhD = true;
  } else {
    String sniff = lv_candidateProgram.toLowerCase();
    isPhD = sniff.contains("doctor") || sniff.contains("phd") || sniff.contains("falsafah");
  }
  String lv_degreeLabelMS    = isPhD ? "Doktor Falsafah" : "Sarjana";
  String lv_degreeLabelEN    = isPhD ? "Doctor of Philosophy" : "Master";
  boolean isExternalRole     = "External Examiner".equals(role);
  String lv_miAffiliation    = mi.get("affiliation") != null ? mi.get("affiliation").toString().trim() : "";
  String lv_miCountry        = mi.get("country")     != null ? mi.get("country").toString().trim()     : "";
  String lv_memberEmail      = mi.get("user_email")  != null ? mi.get("user_email").toString()
                             : (mi.get("ee_email")   != null ? mi.get("ee_email").toString() : "");
  String lv_honorariumMS     = isExternalRole ? "YBrs. akan menerima imbuhan bayaran (honorarium) sebanyak MYR600.00."
                                              : "YBrs. akan menerima imbuhan bayaran (honorarium) sebanyak RM600.";
  String lv_honorariumEN     = isExternalRole ? "You will receive an honorarium payment of MYR600.00."
                                              : "You will receive an honorarium payment of RM600.";
  String lv_formRefMS        = isExternalRole ? "PG-16a" : "UMT/B/PG-16c";
  String lv_formRefEN        = isExternalRole ? "PG-16a" : "UMT/B/PG-16c";
  String lv_confirmDeadlineLabel = a.getScheduledAt() != null
      ? new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)").format(new java.util.Date(a.getScheduledAt().getTime() - 14L*24*60*60*1000))
      : "[ to be confirmed ]";
  String lv_reportDeadlineLabel  = a.getScheduledAt() != null
      ? new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)").format(new java.util.Date(a.getScheduledAt().getTime() - 7L*24*60*60*1000))
      : "[ to be confirmed ]";
  String lv_vivaDayLabel = a.getScheduledAt() != null
      ? new java.text.SimpleDateFormat("dd MMMM yyyy (EEEE)").format(a.getScheduledAt())
      : "[ to be confirmed ]";

  boolean lv_approvalSigned      = false;
  Map<String,Object> letterApproval = a.getLetterApproval();
  String lv_signerDisplayName    = "";
  String lv_signerDisplayRole_MS = "Dekan";
  String lv_signerDisplayRole_EN = "Dean";
  String lv_signerDisplayEmail   = "fskm@umt.edu.my";
  if (letterApproval != null) {
    String _st = letterApproval.get("signer_academic_title") != null ? letterApproval.get("signer_academic_title").toString().trim() : "";
    String _sn = letterApproval.get("signer_name")           != null ? letterApproval.get("signer_name").toString().trim()           : "";
    String _sl = letterApproval.get("signer_label")          != null ? letterApproval.get("signer_label").toString().trim()          : "";
    String _se = letterApproval.get("signer_email")          != null ? letterApproval.get("signer_email").toString().trim()          : "";
    lv_approvalSigned = "signed".equalsIgnoreCase(letterApproval.get("status") != null ? letterApproval.get("status").toString() : "");
    lv_signerDisplayName = (_st.isEmpty() ? "" : _st.toUpperCase() + " ") + _sn.toUpperCase();
    if (!_se.isEmpty()) lv_signerDisplayEmail = _se;
    if ("TDA".equalsIgnoreCase(_sl)) {
      lv_signerDisplayRole_MS = "Timbalan Dekan (Akademik dan Hal Ehwal Pelajar)";
      lv_signerDisplayRole_EN = "Deputy Dean (Academic and Student Affairs)";
    } else if ("TDB".equalsIgnoreCase(_sl)) {
      lv_signerDisplayRole_MS = "Timbalan Dekan (Penyelidikan dan Inovasi)";
      lv_signerDisplayRole_EN = "Deputy Dean (Research and Innovation)";
    }
  }

  // Set all letter vars as request attributes so wrapper JSPs can read them
  request.setAttribute("lv_today",                lv_today);
  request.setAttribute("lv_miTitle",              miTitle);
  request.setAttribute("lv_name",                 name);
  request.setAttribute("lv_miAffiliation",         lv_miAffiliation);
  request.setAttribute("lv_miCountry",            lv_miCountry);
  request.setAttribute("lv_salutation",           lv_salutation);
  request.setAttribute("lv_candidateProgram",     lv_candidateProgram);
  request.setAttribute("lv_degreeLabelMS",        lv_degreeLabelMS);
  request.setAttribute("lv_degreeLabelEN",        lv_degreeLabelEN);
  request.setAttribute("lv_memberEmail",          lv_memberEmail);
  request.setAttribute("lv_honorariumMS",         lv_honorariumMS);
  request.setAttribute("lv_honorariumEN",         lv_honorariumEN);
  request.setAttribute("lv_formRefMS",            lv_formRefMS);
  request.setAttribute("lv_formRefEN",            lv_formRefEN);
  request.setAttribute("lv_confirmDeadlineLabel", lv_confirmDeadlineLabel);
  request.setAttribute("lv_reportDeadlineLabel",  lv_reportDeadlineLabel);
  request.setAttribute("lv_vivaDayLabel",         lv_vivaDayLabel);
  request.setAttribute("lv_approvalSigned",       lv_approvalSigned);
  request.setAttribute("letterApproval",          letterApproval);
  request.setAttribute("lv_signerDisplayName",    lv_signerDisplayName);
  request.setAttribute("lv_signerDisplayRole_MS", lv_signerDisplayRole_MS);
  request.setAttribute("lv_signerDisplayRole_EN", lv_signerDisplayRole_EN);
  request.setAttribute("lv_signerDisplayEmail",   lv_signerDisplayEmail);

  // Determine which wrapper to use (stored as request attribute to survive across segments)
  String letterWrapperPath;
  if (isExternalRole) {
    letterWrapperPath = "/panel/letter/external-en.jsp";
  } else if ("Chairperson".equals(role)) {
    letterWrapperPath = "/panel/letter/chair-ms.jsp";
  } else if ("Secretary".equals(role)) {
    letterWrapperPath = "/panel/letter/secretary-ms.jsp";
  } else {
    letterWrapperPath = "/panel/letter/internal-ms.jsp";
  }
  request.setAttribute("_letterWrapperPath", letterWrapperPath);
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Appointment Letter — Member View</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    body { background: #f3f4f6; font-family: 'Inter', Arial, sans-serif; }
    @media print {
      .no-print { display: none !important; }
      .topbar { display: none !important; }
      .sidebar { display: none !important; }
      .response-card { display: none !important; }
      html, body { margin: 0 !important; padding: 0 !important; background: #fff !important; }
      .ea-layout, .layout { display: block !important; margin: 0 !important; padding: 0 !important; }
      .ea-content, .content { display: block !important; margin: 0 !important; padding: 0 !important; width: 100% !important; }
      .ea-content > div { margin: 0 !important; padding: 0 16px !important; max-width: 100% !important; }
      .mb-4 { margin: 0 !important; }
      .letter-paper { box-shadow: none !important; border: none !important; margin: 0 auto !important; }
    }
    .letter-paper {
      --lp: 52px;
      background: #fff;
      max-width: 740px;
      margin: 0 auto 32px;
      padding: 0 var(--lp) 48px;
      border: 1px solid #e5e7eb;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.07);
      overflow: hidden;
      font-family: Calibri, 'Times New Roman', serif;
      font-size: 11pt;
      line-height: 1.8;
      color: #111;
    }
    .letter-paper h2 { font-size: 1.05rem; text-align: center; font-weight: bold; margin-bottom: 1.2rem; }
    .letter-signer-name   { font-weight: 700; }
    .letter-signer-role-ms, .letter-signer-role-en { font-size: 0.95rem; }
    .letter-signer-email-link { color: #0f766e; }
    .response-card {
      background: #fff;
      border: 1px solid #e5e7eb;
      border-radius: 16px;
      padding: 28px 32px;
      max-width: 740px;
      margin: 0 auto 28px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.05);
    }
  </style>
</head>
<body>
  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout ea-layout">
    <% request.setAttribute("activeSection", "myAppointments"); %>
    <% if ("Dean".equals(session.getAttribute("role_name"))) { %>
      <jsp:include page="/dean/sidebar.jsp" />
    <% } else { %>
      <jsp:include page="/academician/sidebar.jsp" />
    <% } %>

    <main class="content ea-content">
      <div style="max-width:800px;margin:0 auto;padding:0 16px 48px;">

        <!-- Back -->
        <div class="no-print mb-3">
          <a href="<%= request.getContextPath() %>/academician/my-appointments" class="btn-ea-back">
            <i class="bi bi-arrow-left me-1"></i>Back to My Appointments
          </a>
        </div>

        <!-- ── Appointment Info Header ── -->
        <div class="no-print mb-4" style="background:linear-gradient(135deg,#0f766e 0%,#0d9488 100%);border-radius:16px;padding:24px 28px;color:#fff;box-shadow:0 4px 16px rgba(15,118,110,0.18);">
          <div style="font-size:0.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.12em;color:rgba(255,255,255,0.65);margin-bottom:6px;">Your Role in This Viva</div>
          <div style="font-size:1.2rem;font-weight:800;margin-bottom:12px;"><%= role %></div>
          <div style="display:flex;gap:20px;flex-wrap:wrap;font-size:0.88rem;color:rgba(255,255,255,0.92);">
            <span><i class="bi bi-person-fill me-1"></i><strong><%= a.getCandidateName() != null ? a.getCandidateName() : "—" %></strong>
              <% if (a.getCandidateStudentId() != null) { %><span style="opacity:.75;"> (<%= a.getCandidateStudentId() %>)</span><% } %>
            </span>
            <% if (a.getCandidateProgram() != null && !a.getCandidateProgram().isEmpty()) { %>
            <span><i class="bi bi-mortarboard me-1"></i><%= a.getCandidateProgram() %></span>
            <% } %>
            <span><i class="bi bi-calendar-event me-1"></i>
              <%= a.getScheduledAt() != null ? new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(a.getScheduledAt()) : "Date TBD" %>
            </span>
            <% if (a.getVenue() != null && !a.getVenue().isEmpty()) { %>
            <span><i class="bi bi-geo-alt me-1"></i><%= a.getVenue() %></span>
            <% } %>
          </div>
        </div>

        <!-- ── Success / error alerts ── -->
        <% if ("ok".equals(result)) { %>
        <div class="no-print mb-3 d-flex align-items-center gap-2 px-4 py-3" style="background:#f0fdf4;border:1.5px solid #bbf7d0;border-radius:12px;">
          <i class="bi bi-check-circle-fill" style="color:#15803d;font-size:1.1rem;"></i>
          <span style="font-weight:600;color:#15803d;">Your response has been recorded successfully.</span>
        </div>
        <% } %>
        <% if ("needReason".equals(error)) { %>
        <div class="no-print mb-3 d-flex align-items-center gap-2 px-4 py-3" style="background:#fef2f2;border:1.5px solid #fecaca;border-radius:12px;">
          <i class="bi bi-exclamation-triangle-fill" style="color:#b91c1c;font-size:1.1rem;"></i>
          <span style="font-weight:600;color:#b91c1c;">Please provide a reason when declining.</span>
        </div>
        <% } %>

        <!-- ── Response status badge (if already responded) ── -->
        <% if (responded) { %>
        <div class="no-print mb-4">
          <% if ("accepted".equals(panelResp)) { %>
          <div class="d-flex align-items-center gap-3 px-4 py-3" style="background:#f0fdf4;border:1.5px solid #86efac;border-radius:12px;">
            <div style="width:40px;height:40px;background:#dcfce7;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
              <i class="bi bi-check-circle-fill" style="color:#15803d;font-size:1.2rem;"></i>
            </div>
            <div>
              <div style="font-weight:700;color:#15803d;font-size:0.95rem;">You accepted this appointment</div>
              <% Object respAt = mi.get("responded_at"); if (respAt != null) { %>
              <div style="color:#166534;font-size:0.82rem;">Responded on <%= new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(respAt) %></div>
              <% } %>
            </div>
          </div>
          <% } else if ("declined".equals(panelResp)) { %>
          <div class="px-4 py-3" style="background:#fef2f2;border:1.5px solid #fca5a5;border-radius:12px;">
            <div class="d-flex align-items-center gap-3 mb-2">
              <div style="width:40px;height:40px;background:#fee2e2;border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                <i class="bi bi-x-circle-fill" style="color:#b91c1c;font-size:1.2rem;"></i>
              </div>
              <div>
                <div style="font-weight:700;color:#b91c1c;font-size:0.95rem;">You declined this appointment</div>
                <% Object respAt2 = mi.get("responded_at"); if (respAt2 != null) { %>
                <div style="color:#991b1b;font-size:0.82rem;">Responded on <%= new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(respAt2) %></div>
                <% } %>
              </div>
            </div>
            <% String rej = mi.get("rejection_reason") != null ? mi.get("rejection_reason").toString() : ""; if (!rej.isEmpty()) { %>
            <div style="color:#7f1d1d;font-size:0.88rem;padding:8px 12px;background:#fff5f5;border-radius:8px;"><strong>Reason:</strong> <%= rej %></div>
            <% } %>
          </div>
          <% } %>
        </div>
        <% } %>

        <!-- ── Letter Preview ── -->
        <div class="mb-4">
          <div class="d-flex align-items-center justify-content-between mb-3 no-print">
            <div>
              <div style="font-size:1.05rem;font-weight:700;color:#111827;">Appointment Letter</div>
              <div style="font-size:0.84rem;color:#6b7280;">Official letter from Faculty of Computer and Mathematical Sciences, UMT</div>
            </div>
            <button onclick="window.print()" class="ea-btn-teal-outline no-print">
              <i class="bi bi-printer me-1"></i>Print / PDF
            </button>
          </div>

          <%-- Dynamic include: wrapper JSP handles variable declarations + static template include --%>
          <% pageContext.include((String) request.getAttribute("_letterWrapperPath")); %>
        </div>

        <!-- ── Response area ── -->
        <div class="response-card no-print">
          <% if (!responded) { %>
            <div style="margin-bottom:20px;">
              <div style="font-size:1.05rem;font-weight:700;color:#111827;margin-bottom:4px;">Respond to Appointment</div>
              <div style="font-size:0.88rem;color:#6b7280;">Please confirm your participation within <strong>seven (7) working days</strong> of receiving this letter.</div>
            </div>
            <div style="display:flex;gap:16px;flex-wrap:wrap;align-items:flex-start;">
              <!-- Accept -->
              <form method="POST" action="<%= request.getContextPath() %>/PanelMemberResponseServlet"
                    onsubmit="return confirm('Confirm that you ACCEPT this appointment?');" style="margin:0;flex-shrink:0;">
                <input type="hidden" name="panel_id" value="<%= panelId %>">
                <input type="hidden" name="action"   value="accept">
                <input type="hidden" name="return_to" value="member">
                <button type="submit" style="background:#0f766e;color:#fff;border:none;padding:13px 28px;border-radius:10px;font-weight:700;font-size:0.95rem;cursor:pointer;display:flex;align-items:center;gap:8px;line-height:1;">
                  <i class="bi bi-check-circle-fill" style="font-size:1.1rem;"></i> Accept Appointment
                </button>
              </form>
              <!-- Decline -->
              <div style="flex:1;min-width:260px;">
                <form method="POST" action="<%= request.getContextPath() %>/PanelMemberResponseServlet"
                      onsubmit="return confirmDecline();" style="margin:0;">
                  <input type="hidden" name="panel_id"  value="<%= panelId %>">
                  <input type="hidden" name="action"    value="decline">
                  <input type="hidden" name="return_to" value="member">
                  <textarea id="declineReason" name="rejection_reason" rows="3"
                            placeholder="Reason for declining (required before submitting)"
                            style="width:100%;border:1.5px solid #e5e7eb;border-radius:10px;padding:11px 14px;font-size:0.9rem;margin-bottom:10px;resize:vertical;outline:none;font-family:inherit;color:#374151;"
                            onfocus="this.style.borderColor='#0f766e'" onblur="this.style.borderColor='#e5e7eb'"></textarea>
                  <div style="text-align:right;">
                    <button type="submit" style="background:#fff;color:#b91c1c;border:1.5px solid #fca5a5;padding:10px 22px;border-radius:10px;font-weight:700;font-size:0.9rem;cursor:pointer;display:inline-flex;align-items:center;gap:7px;">
                      <i class="bi bi-x-circle-fill"></i> Decline Appointment
                    </button>
                  </div>
                </form>
              </div>
            </div>
          <% } else { %>
            <div class="d-flex align-items-center gap-3">
              <div>
                <div style="font-weight:700;color:#374151;font-size:0.95rem;">Response submitted</div>
                <div style="font-size:0.85rem;color:#6b7280;">Your response has been recorded. The admin has been notified.</div>
              </div>
            </div>
          <% } %>
        </div>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    function confirmDecline() {
      var reason = document.getElementById('declineReason').value.trim();
      if (!reason) {
        document.getElementById('declineReason').style.borderColor = '#b91c1c';
        document.getElementById('declineReason').focus();
        return false;
      }
      return confirm('Confirm that you DECLINE this appointment?\n\nReason: ' + reason);
    }
  </script>
</body>
</html>
