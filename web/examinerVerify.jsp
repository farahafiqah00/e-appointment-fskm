<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.ExternalExaminer, model.Document, java.text.SimpleDateFormat, java.util.List" %>
<%--
  Public examiner self-verification page.
  No login required — access is controlled entirely by the one-time token.
  Token states: invalid | expired | pending | already_confirmed | discrepancy_reported
--%>
<%
    String tokenStatus = (String)  request.getAttribute("tokenStatus");
    ExternalExaminer ee = (ExternalExaminer) request.getAttribute("examiner");
    String token        = (String)  request.getAttribute("token");
    String flashResult  = (String)  request.getAttribute("flashResult");
    @SuppressWarnings("unchecked")
    List<Document> examinerDocs = (List<Document>) request.getAttribute("examinerDocs");
    if (examinerDocs == null) examinerDocs = new java.util.ArrayList<>();
    if (tokenStatus == null) tokenStatus = "invalid";
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Verify Your Examination Profile - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    body { background: #f0fdf4; font-family: 'Inter', sans-serif; min-height: 100vh; }
    .vfy-header   { background: #105e60; color: #fff; padding: 22px 0; text-align: center; }
    .vfy-logo     { font-size: 1.3rem; font-weight: 800; letter-spacing: -0.5px; }
    .vfy-sub      { font-size: 0.88rem; color: #a7f3d0; margin-top: 2px; }
    .vfy-card     { background: #fff; border: 1px solid #e5e7eb; border-radius: 16px; padding: 32px 36px; margin-bottom: 20px; box-shadow: 0 2px 12px rgba(0,0,0,0.04); }
    .vfy-sec      { font-size: 0.95rem; font-weight: 700; color: #105e60; border-bottom: 1px solid #f3f4f6; padding-bottom: 10px; margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
    .vfy-label    { font-size: 0.82rem; font-weight: 600; color: #6b7280; text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 3px; }
    .vfy-value    { font-size: 0.97rem; color: #111827; padding: 9px 14px; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px; min-height: 40px; }
    .vfy-empty    { color: #9ca3af; font-style: italic; }
    .btn-confirm  { background: #059669; color: #fff; border: none; border-radius: 10px; padding: 13px 40px; font-size: 1rem; font-weight: 700; cursor: pointer; }
    .btn-confirm:hover { background: #047857; color: #fff; }
    .btn-report   { background: #fff; color: #dc2626; border: 2px solid #dc2626; border-radius: 10px; padding: 11px 30px; font-size: 0.95rem; font-weight: 600; cursor: pointer; }
    .btn-report:hover { background: #fef2f2; }
    .vfy-state-card { max-width: 540px; margin: 80px auto; text-align: center; }
    .vfy-state-icon { font-size: 3.5rem; margin-bottom: 16px; }
    textarea.vfy-report-box { border: 1px solid #d1d5db; border-radius: 8px; padding: 12px; width: 100%; font-size: 0.93rem; resize: vertical; min-height: 100px; }
    textarea.vfy-report-box:focus { outline: none; border-color: #0f766e; box-shadow: 0 0 0 3px rgba(15,118,110,0.1); }
    .report-section { display: none; margin-top: 24px; background: #fef2f2; border: 1px solid #fca5a5; border-radius: 12px; padding: 20px; }
    .flash-success { background: #ecfdf5; border: 1px solid #6ee7b7; border-radius: 12px; color: #065f46; padding: 16px 20px; display: flex; align-items: center; gap: 10px; margin-bottom: 24px; }
    .flash-report  { background: #fffbeb; border: 1px solid #fcd34d; border-radius: 12px; color: #92400e; padding: 16px 20px; display: flex; align-items: center; gap: 10px; margin-bottom: 24px; }
  </style>
</head>
<body>

  <!-- Header -->
  <div class="vfy-header">
    <div class="vfy-logo"><i class="bi bi-mortarboard-fill me-2"></i>E-Appointment FSKM</div>
    <div class="vfy-sub">Examiner Profile Verification</div>
  </div>

  <div class="container py-5" style="max-width: 760px;">

    <%-- ── Invalid token ── --%>
    <% if ("invalid".equals(tokenStatus)) { %>
    <div class="vfy-state-card vfy-card text-center">
      <div class="vfy-state-icon text-danger"><i class="bi bi-shield-exclamation"></i></div>
      <h2 style="color:#111827;font-weight:700;">Invalid Link</h2>
      <p class="text-muted">This verification link is not valid or has already been used incorrectly. Please use the exact link from the email you received.</p>
    </div>

    <%-- ── Expired token ── --%>
    <% } else if ("expired".equals(tokenStatus)) { %>
    <div class="vfy-state-card vfy-card text-center">
      <div class="vfy-state-icon" style="color:#d97706;"><i class="bi bi-clock-history"></i></div>
      <h2 style="color:#111827;font-weight:700;">Link Expired</h2>
      <p class="text-muted">This verification link has expired (links are valid for 7 days). Please contact the person who nominated you to request a new link.</p>
    </div>

    <%-- ── Examiner info page (pending / already_confirmed / discrepancy_reported) ── --%>
    <% } else if (ee != null) {
         String displayName = (ee.getTitle() != null && !ee.getTitle().isEmpty() ? ee.getTitle() + " " : "") + (ee.getName() != null ? ee.getName() : "");
         String confirmedDateStr = ee.getConfirmedAt() != null
             ? new SimpleDateFormat("dd MMM yyyy, HH:mm").format(ee.getConfirmedAt()) : null;
    %>

    <!-- Page title -->
    <div class="text-center mb-4">
      <h1 style="font-size:1.7rem;font-weight:800;color:#105e60;">Review Your Examination Profile</h1>
      <p class="text-muted" style="font-size:0.97rem;">Please verify that all information below is accurate. This record will be used for your viva examination panel appointment.</p>
    </div>

    <%-- Flash messages after POST --%>
    <% if ("confirmed".equals(flashResult)) { %>
    <div class="flash-success"><i class="bi bi-check-circle-fill" style="font-size:1.3rem;color:#10b981;"></i>
      <div><strong>Thank you!</strong> Your profile has been confirmed. We will use this information for your viva appointment.</div>
    </div>
    <% } else if ("reported".equals(flashResult)) { %>
    <div class="flash-report"><i class="bi bi-exclamation-triangle-fill" style="font-size:1.3rem;color:#f59e0b;"></i>
      <div><strong>Discrepancy reported.</strong> The nominator has been notified and will contact you to correct the details.</div>
    </div>
    <% } %>

    <%-- Already confirmed notice --%>
    <% if ("already_confirmed".equals(tokenStatus)) { %>
    <div class="flash-success"><i class="bi bi-check-circle-fill" style="font-size:1.3rem;color:#10b981;"></i>
      <div><strong>Already confirmed</strong><%= confirmedDateStr != null ? " on " + confirmedDateStr : "" %>. Your information is on record.</div>
    </div>
    <% } else if ("discrepancy_reported".equals(tokenStatus)) { %>
    <div class="flash-report"><i class="bi bi-exclamation-triangle-fill" style="font-size:1.3rem;color:#f59e0b;"></i>
      <div><strong>You previously reported a discrepancy.</strong> Please wait for the nominator to contact you.</div>
    </div>
    <% } %>

    <!-- Personal Information -->
    <div class="vfy-card">
      <div class="vfy-sec"><i class="bi bi-person-circle"></i> Personal Information</div>
      <div class="row g-3">
        <div class="col-md-6">
          <div class="vfy-label">Full Name (with Title)</div>
          <div class="vfy-value"><%= displayName.trim().isEmpty() ? "<span class='vfy-empty'>Not provided</span>" : escapeHtml(displayName) %></div>
        </div>
        <div class="col-md-3">
          <div class="vfy-label">Gender</div>
          <div class="vfy-value"><%= ee.getGender() != null && !ee.getGender().isEmpty() ? escapeHtml(ee.getGender()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
        <div class="col-md-3">
          <div class="vfy-label">Nationality</div>
          <div class="vfy-value"><%= ee.getNationality() != null && !ee.getNationality().isEmpty() ? escapeHtml(ee.getNationality()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
        <div class="col-md-6">
          <div class="vfy-label">IC / Passport Number</div>
          <div class="vfy-value"><%= ee.getIcPassport() != null && !ee.getIcPassport().isEmpty() ? escapeHtml(ee.getIcPassport()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
        <div class="col-md-6">
          <div class="vfy-label">Country</div>
          <div class="vfy-value"><%= ee.getCountry() != null && !ee.getCountry().isEmpty() ? escapeHtml(ee.getCountry()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
        <div class="col-md-6">
          <div class="vfy-label">Email Address</div>
          <div class="vfy-value"><%= ee.getEmail() != null ? escapeHtml(ee.getEmail()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
        <div class="col-md-6">
          <div class="vfy-label">Phone Number</div>
          <div class="vfy-value"><%= ee.getPhone() != null && !ee.getPhone().isEmpty() ? escapeHtml(ee.getPhone()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
      </div>
    </div>

    <!-- Academic / Professional Details -->
    <div class="vfy-card">
      <div class="vfy-sec"><i class="bi bi-building"></i> Academic &amp; Professional Details</div>
      <div class="row g-3">
        <div class="col-md-6">
          <div class="vfy-label">University / Institution</div>
          <div class="vfy-value"><%= ee.getAffiliation() != null && !ee.getAffiliation().isEmpty() ? escapeHtml(ee.getAffiliation()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
        <div class="col-md-6">
          <div class="vfy-label">Faculty / Department</div>
          <div class="vfy-value"><%= ee.getFaculty() != null && !ee.getFaculty().isEmpty() ? escapeHtml(ee.getFaculty()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
        <div class="col-md-6">
          <div class="vfy-label">Position / Designation</div>
          <div class="vfy-value"><%= ee.getPosition() != null && !ee.getPosition().isEmpty() ? escapeHtml(ee.getPosition()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
        <div class="col-md-6">
          <div class="vfy-label">Highest Qualification</div>
          <div class="vfy-value"><%= ee.getQualification() != null && !ee.getQualification().isEmpty() ? escapeHtml(ee.getQualification()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
        <div class="col-12">
          <div class="vfy-label">Field of Specialization</div>
          <div class="vfy-value"><%= ee.getSpecialization() != null && !ee.getSpecialization().isEmpty() ? escapeHtml(ee.getSpecialization()) : "<span class='vfy-empty'>—</span>" %></div>
        </div>
      </div>
    </div>

    <%-- Supporting Documents — always show if we have docs --%>
    <% if (!examinerDocs.isEmpty()) { %>
    <div class="vfy-card">
      <div class="vfy-sec"><i class="bi bi-file-earmark-text"></i> Supporting Documents</div>
      <p style="font-size:0.9rem;color:#374151;margin-bottom:14px;">The following files were submitted along with your nomination. You may download and review them.</p>
      <% for (Document doc : examinerDocs) {
           String docType = doc.getFileType() != null ? doc.getFileType() : "";
           String iconCls = "cv".equals(docType) ? "bi-file-earmark-person" : "bi-file-earmark-text";
           String iconColor = "cv".equals(docType) ? "#0f766e" : "#2563eb";
           String label = "cv".equals(docType) ? "CV" : "qualification".equals(docType) ? "Qualification Proof" : docType;
      %>
      <div class="d-flex align-items-center gap-3 mb-2 p-3"
           style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;">
        <i class="bi <%= iconCls %>" style="color:<%= iconColor %>;font-size:1.3rem;flex-shrink:0;"></i>
        <div style="flex:1;min-width:0;">
          <div style="font-size:0.9rem;font-weight:600;color:#111827;word-break:break-all;"><%= escapeHtml(doc.getFilename()) %></div>
          <div style="font-size:0.75rem;color:#9ca3af;text-transform:capitalize;"><%= escapeHtml(label) %></div>
        </div>
        <a href="<%= request.getContextPath() %>/DownloadDocumentServlet?id=<%= doc.getId() %>"
           class="btn btn-sm d-inline-flex align-items-center gap-1"
           style="background:#f0fdf4;color:#16a34a;border:1px solid #bbf7d0;border-radius:8px;font-size:0.8rem;white-space:nowrap;">
          <i class="bi bi-download"></i> Download
        </a>
      </div>
      <% } %>
    </div>
    <% } %>

    <%-- Actions — only show if pending --%>
    <% if ("pending".equals(tokenStatus) && !"confirmed".equals(flashResult) && !"reported".equals(flashResult)) { %>
    <div class="vfy-card">
      <div class="vfy-sec"><i class="bi bi-check2-square"></i> Confirm Your Information</div>
      <p style="color:#374151;font-size:0.95rem;">Is all the information above correct?</p>

      <!-- Confirm button -->
      <form method="POST" action="<%= request.getContextPath() %>/ExaminerVerifyServlet">
        <input type="hidden" name="token"  value="<%= escapeHtml(token) %>">
        <input type="hidden" name="action" value="confirm">
        <button type="submit" class="btn-confirm">
          <i class="bi bi-check-circle me-2"></i>Yes, my information is correct
        </button>
      </form>

      <hr style="border:none;border-top:1px solid #f3f4f6;margin:20px 0;">

      <!-- Report discrepancy toggle -->
      <p style="font-size:0.9rem;color:#6b7280;">If something is wrong, click below to report it.</p>
      <button type="button" class="btn-report" onclick="document.getElementById('reportSection').style.display='block';this.style.display='none';">
        <i class="bi bi-exclamation-triangle me-1"></i>No, I have corrections to report
      </button>

      <div id="reportSection" class="report-section">
        <form method="POST" action="<%= request.getContextPath() %>/ExaminerVerifyServlet">
          <input type="hidden" name="token"  value="<%= escapeHtml(token) %>">
          <input type="hidden" name="action" value="report">
          <label style="font-weight:600;color:#b91c1c;font-size:0.95rem;">Please describe what needs to be corrected:</label>
          <textarea name="discrepancyNotes" class="vfy-report-box mt-2" maxlength="1000"
                    placeholder="e.g. My faculty name is incorrect, my qualification should be PhD not Master's..." required></textarea>
          <div class="mt-3">
            <button type="submit" class="btn btn-danger" style="border-radius:10px;padding:10px 28px;font-weight:600;">
              <i class="bi bi-send me-1"></i>Submit Report
            </button>
          </div>
        </form>
      </div>
    </div>
    <% } %>

    <% } %>

    <!-- Footer -->
    <div class="text-center mt-4" style="font-size:0.82rem;color:#9ca3af;">
      &copy; E-Appointment FSKM &mdash; Faculty of Computer and Mathematical Sciences, UMT
    </div>

  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<%!
  private static String escapeHtml(String s) {
      if (s == null) return "";
      return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
  }
%>
