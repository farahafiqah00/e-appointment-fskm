<%-- Academician: read-only detail view of one of the current user's nominations with examiner profile and attached documents. --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, java.util.Map, model.Nomination, model.Document" %>
<%
    String loggedInName = (String) session.getAttribute("full_name");
    if (loggedInName == null) loggedInName = "Academician";

    Nomination nom = (Nomination) request.getAttribute("nomination");
    @SuppressWarnings("unchecked")
    Map<String,Object> ee = (Map<String,Object>) request.getAttribute("examiner");
    @SuppressWarnings("unchecked")
    List<Document> docs   = (List<Document>) request.getAttribute("documents");
    String candidateName  = (String) request.getAttribute("candidateName");

    if (nom == null) { response.sendRedirect(request.getContextPath() + "/MyNominationsServlet"); return; }

    String st = nom.getStatus() != null ? nom.getStatus() : "submitted";
    boolean canEdit = "needs_correction".equals(st);
    String adminRemarks = "needs_correction".equals(st) && nom.getRemarks() != null ? nom.getRemarks() : "";

    String fTitle         = ee != null && ee.get("title")             != null ? ee.get("title").toString()             : "";
    String fName          = ee != null && ee.get("name")              != null ? ee.get("name").toString()              : "";
    String fGender        = ee != null && ee.get("gender")            != null ? ee.get("gender").toString()            : "";
    String fNationality   = ee != null && ee.get("nationality")       != null ? ee.get("nationality").toString()       : "";
    String fIcPassport    = ee != null && ee.get("ic_passport")       != null ? ee.get("ic_passport").toString()       : "";
    String fUniversity    = ee != null && ee.get("affiliation")       != null ? ee.get("affiliation").toString()       : "";
    String fFaculty       = ee != null && ee.get("faculty")           != null ? ee.get("faculty").toString()           : "";
    String fCountry       = ee != null && ee.get("country")           != null ? ee.get("country").toString()           : "";
    String fEmail         = ee != null && ee.get("email")             != null ? ee.get("email").toString()             : "";
    String fPhone         = ee != null && ee.get("phone")             != null ? ee.get("phone").toString()             : "";
    String fQualification = ee != null && ee.get("qualification")     != null ? ee.get("qualification").toString()     : "";
    String fPosition      = ee != null && ee.get("position")          != null ? ee.get("position").toString()          : "";
    String fSpecName      = ee != null && ee.get("specialization_name") != null ? ee.get("specialization_name").toString() : "";
    String fExpName       = ee != null && ee.get("expertise_name")    != null ? ee.get("expertise_name").toString()    : "";
    String fDivName       = ee != null && ee.get("division_name")     != null ? ee.get("division_name").toString()     : "";
    String fAreaName      = ee != null && ee.get("area_name")         != null ? ee.get("area_name").toString()         : "";

    String submittedDate  = nom.getCreatedAt() != null
        ? new java.text.SimpleDateFormat("dd MMMM yyyy").format(nom.getCreatedAt()) : "—";

    // Badge
    String bgColor, textColor, statusLabel;
    if ("verified".equals(st)) {
        bgColor = "#dcfce7"; textColor = "#16a34a"; statusLabel = "Verified";
    } else if ("needs_correction".equals(st)) {
        bgColor = "#fee2e2"; textColor = "#dc2626"; statusLabel = "Needs Correction";
    } else if ("under_review".equals(st)) {
        bgColor = "#fef3c7"; textColor = "#d97706"; statusLabel = "Under Review";
    } else {
        bgColor = "#dbeafe"; textColor = "#1d4ed8"; statusLabel = "Submitted";
    }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>View Nomination - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    .vn-card { background:#fff; border:1px solid #e5e7eb; border-radius:16px; padding:28px 32px; margin-bottom:20px; }
    .vn-section-title { font-size:1rem; font-weight:700; color:#105e60; display:flex; align-items:center; gap:8px; margin-bottom:20px; padding-bottom:10px; border-bottom:1px solid #f3f4f6; }
    .vn-field-label { font-size:0.78rem; font-weight:600; color:#9ca3af; text-transform:uppercase; letter-spacing:.06em; margin-bottom:4px; }
    .vn-field-value { font-size:0.97rem; color:#111827; font-weight:500; }
    .vn-field-value.muted { color:#6b7280; font-weight:400; }
    .vn-divider { border:none; border-top:1px solid #f3f4f6; margin:18px 0; }
    .vn-back { display:inline-flex; align-items:center; gap:8px; color:#374151; font-size:0.88rem; font-weight:500; text-decoration:none; margin-bottom:20px; background:#f9fafb; border:1.5px solid #e5e7eb; border-radius:8px; padding:7px 14px; transition:all 0.2s; }
    .vn-back:hover { color:#0f766e; border-color:#0f766e; background:#f0fdf4; }
    .correction-banner { background:#fef2f2; border:1.5px solid #fca5a5; border-radius:12px; padding:16px 20px; margin-bottom:24px; }
  </style>
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout">
    <% request.setAttribute("activeSection", "myNominations"); %>
    <% if ("Dean".equals(session.getAttribute("role_name"))) { %>
    <jsp:include page="/dean/sidebar.jsp" />
    <% } else { %>
    <jsp:include page="/academician/sidebar.jsp" />
    <% } %>

    <main class="content" style="max-width:none;">
      <div style="max-width:860px;margin:0 auto;">

        <a href="<%= request.getContextPath() %>/MyNominationsServlet" class="vn-back">
          <i class="bi bi-arrow-left-short" style="font-size:1.1rem;"></i> Back to My Nominations
        </a>

        <div class="d-flex align-items-start justify-content-between flex-wrap gap-3 mb-4">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Nomination Details</h1>
            <div style="font-size:1rem;color:#6b7280;">Read-only view of your submitted nomination</div>
          </div>
          <div class="d-flex align-items-center gap-2">
            <span style="background:<%= bgColor %>;color:<%= textColor %>;padding:6px 18px;border-radius:20px;font-size:0.95rem;font-weight:600;"><%= statusLabel %></span>
            <% if (canEdit) { %>
            <a href="<%= request.getContextPath() %>/EditNominationServlet?id=<%= nom.getId() %>"
               class="ea-btn-primary-action d-inline-flex align-items-center gap-2" style="text-decoration:none;">
              <i class="bi bi-pencil-square"></i> Edit &amp; Resubmit
            </a>
            <% } %>
          </div>
        </div>

        <!-- Admin correction banner -->
        <% if (!adminRemarks.isEmpty()) { %>
        <div class="correction-banner">
          <div style="display:flex;align-items:center;gap:8px;font-weight:600;color:#b91c1c;margin-bottom:6px;">
            <i class="bi bi-exclamation-triangle-fill"></i> Admin Remarks / Correction Required
          </div>
          <div style="font-size:0.92rem;color:#7f1d1d;white-space:pre-wrap;"><%= adminRemarks.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;") %></div>
        </div>
        <% } %>

        <!-- Nomination Info -->
        <div class="vn-card">
          <div class="vn-section-title"><i class="bi bi-calendar3"></i> Nomination Information</div>
          <div class="row g-4">
            <div class="col-md-6">
              <div class="vn-field-label">Candidate</div>
              <% if (candidateName != null) { %>
              <div class="vn-field-value"><%= candidateName %></div>
              <% } else { %>
              <div class="vn-field-value muted" style="font-style:italic;">Assigned upon appointment</div>
              <% } %>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Submission Date</div>
              <div class="vn-field-value muted"><%= submittedDate %></div>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Role Nominated</div>
              <div class="vn-field-value">External Examiner</div>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Status</div>
              <div><span style="background:<%= bgColor %>;color:<%= textColor %>;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;"><%= statusLabel %></span></div>
            </div>
          </div>
        </div>

        <!-- Examiner Personal Info -->
        <div class="vn-card">
          <div class="vn-section-title"><i class="bi bi-person"></i> A. Examiner Personal &amp; Professional Information</div>

          <div style="font-size:0.88rem;font-weight:600;color:#374151;margin-bottom:12px;">Basic Information</div>
          <div class="row g-3 mb-3">
            <div class="col-md-4">
              <div class="vn-field-label">Title</div>
              <div class="vn-field-value muted"><%= fTitle.isEmpty() ? "—" : fTitle %></div>
            </div>
            <div class="col-md-8">
              <div class="vn-field-label">Full Name</div>
              <div class="vn-field-value"><%= fName.isEmpty() ? "—" : fName %></div>
            </div>
            <div class="col-md-4">
              <div class="vn-field-label">Gender</div>
              <div class="vn-field-value muted"><%= fGender.isEmpty() ? "—" : fGender %></div>
            </div>
            <div class="col-md-4">
              <div class="vn-field-label">Nationality</div>
              <div class="vn-field-value muted"><%= fNationality.isEmpty() ? "—" : fNationality %></div>
            </div>
            <div class="col-md-4">
              <div class="vn-field-label">IC / Passport No.</div>
              <div class="vn-field-value muted"><%= fIcPassport.isEmpty() ? "—" : fIcPassport %></div>
            </div>
          </div>

          <hr class="vn-divider">
          <div style="font-size:0.88rem;font-weight:600;color:#374151;margin-bottom:12px;">Institutional Information</div>
          <div class="row g-3 mb-3">
            <div class="col-md-6">
              <div class="vn-field-label">University / Organisation</div>
              <div class="vn-field-value"><%= fUniversity.isEmpty() ? "—" : fUniversity %></div>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Faculty / Department</div>
              <div class="vn-field-value muted"><%= fFaculty.isEmpty() ? "—" : fFaculty %></div>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Country</div>
              <div class="vn-field-value muted"><%= fCountry.isEmpty() ? "—" : fCountry %></div>
            </div>
          </div>

          <hr class="vn-divider">
          <div style="font-size:0.88rem;font-weight:600;color:#374151;margin-bottom:12px;">Research Field</div>
          <div class="row g-3 mb-3">
            <div class="col-md-6">
              <div class="vn-field-label">Specialization</div>
              <div class="vn-field-value muted"><%= fSpecName.isEmpty() ? "—" : fSpecName %></div>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Expertise</div>
              <div class="vn-field-value muted"><%= fExpName.isEmpty() ? "—" : fExpName %></div>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Division / Research Group</div>
              <div class="vn-field-value muted"><%= fDivName.isEmpty() ? "—" : fDivName %></div>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Area of Research</div>
              <div class="vn-field-value muted"><%= fAreaName.isEmpty() ? "—" : fAreaName %></div>
            </div>
          </div>

          <hr class="vn-divider">
          <div style="font-size:0.88rem;font-weight:600;color:#374151;margin-bottom:12px;">Academic &amp; Professional Details</div>
          <div class="row g-3 mb-3">
            <div class="col-md-6">
              <div class="vn-field-label">Highest Qualification</div>
              <div class="vn-field-value muted"><%= fQualification.isEmpty() ? "—" : fQualification %></div>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Current Position</div>
              <div class="vn-field-value muted"><%= fPosition.isEmpty() ? "—" : fPosition %></div>
            </div>
          </div>

          <hr class="vn-divider">
          <div style="font-size:0.88rem;font-weight:600;color:#374151;margin-bottom:12px;">Contact Information</div>
          <div class="row g-3">
            <div class="col-md-6">
              <div class="vn-field-label">Email Address</div>
              <div class="vn-field-value muted"><%= fEmail.isEmpty() ? "—" : fEmail %></div>
            </div>
            <div class="col-md-6">
              <div class="vn-field-label">Contact Number</div>
              <div class="vn-field-value muted"><%= fPhone.isEmpty() ? "—" : fPhone %></div>
            </div>
          </div>
        </div>

        <!-- Supporting Documents -->
        <div class="vn-card">
          <div class="vn-section-title"><i class="bi bi-file-earmark-text"></i> B. Supporting Documents</div>
          <% if (docs != null && !docs.isEmpty()) {
               for (Document d : docs) {
                 String icon = "cv".equals(d.getFileType()) ? "bi-file-earmark-person" : "bi-file-earmark-text"; %>
          <div class="d-flex align-items-center gap-3 mb-2 p-3"
               style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;">
            <i class="bi <%= icon %>" style="color:#0f766e;font-size:1.4rem;flex-shrink:0;"></i>
            <div>
              <div class="fw-semibold" style="font-size:0.93rem;color:#111827;"><%= d.getFilename() %></div>
              <div style="font-size:0.78rem;color:#9ca3af;text-transform:capitalize;"><%= d.getFileType() != null ? d.getFileType().replace("_"," ") : "" %></div>
            </div>
            <a href="<%= request.getContextPath() %>/<%= d.getFilepath() != null ? d.getFilepath() : "#" %>"
               download class="ms-auto btn btn-sm"
               style="background:#f0fdf4;color:#16a34a;border:1px solid #bbf7d0;border-radius:8px;font-size:0.82rem;">
              <i class="bi bi-download me-1"></i> Download
            </a>
          </div>
          <% } } else { %>
          <p class="text-muted mb-0"><i class="bi bi-info-circle me-1"></i>No documents uploaded for this nomination.</p>
          <% } %>
        </div>

        <!-- Bottom action -->
        <% if (canEdit) { %>
        <div class="d-flex justify-content-end gap-3 mt-2 mb-5">
          <a href="<%= request.getContextPath() %>/MyNominationsServlet" class="btn-ea-back">
            <i class="bi bi-arrow-left me-1"></i> Back</a>
          <a href="<%= request.getContextPath() %>/EditNominationServlet?id=<%= nom.getId() %>"
             class="ea-btn-primary-action d-inline-flex align-items-center gap-2" style="text-decoration:none;">
            <i class="bi bi-pencil-square"></i> Edit &amp; Resubmit
          </a>
        </div>
        <% } else { %>
        <div class="d-flex justify-content-start mt-2 mb-5">
          <a href="<%= request.getContextPath() %>/MyNominationsServlet" class="btn-ea-back">
            <i class="bi bi-arrow-left me-1"></i> Back
          </a>
        </div>
        <% } %>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
