<%-- Academician: multi-step form for submitting a new examiner nomination with CV/qualification upload. --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null) fullName = "Academician";
    String error = (String) request.getAttribute("error");
    List<Map<String,Object>> specializations = (List<Map<String,Object>>) request.getAttribute("specializations");
    List<Map<String,Object>> expertiseList   = (List<Map<String,Object>>) request.getAttribute("expertiseList");
    List<Map<String,Object>> divisionList    = (List<Map<String,Object>>) request.getAttribute("divisionList");
    List<Map<String,Object>> areaList        = (List<Map<String,Object>>) request.getAttribute("areaList");
    @SuppressWarnings("unchecked")
    List<String> examinerTitles = (List<String>) request.getAttribute("examinerTitles");
    @SuppressWarnings("unchecked")
    List<String> qualifications = (List<String>) request.getAttribute("qualifications");
    @SuppressWarnings("unchecked")
    List<String> academicRanks  = (List<String>) request.getAttribute("academicRanks");
    @SuppressWarnings("unchecked")
    List<String> genders        = (List<String>) request.getAttribute("genders");
    if (specializations == null) specializations = new java.util.ArrayList<>();
    if (expertiseList   == null) expertiseList   = new java.util.ArrayList<>();
    if (divisionList    == null) divisionList    = new java.util.ArrayList<>();
    if (areaList        == null) areaList        = new java.util.ArrayList<>();
    if (examinerTitles  == null) { examinerTitles = new java.util.ArrayList<>(); examinerTitles.addAll(java.util.Arrays.asList("Dr.","Prof. Dr.","Assoc. Prof. Dr.","Prof.","Mr.","Mrs.","Ms.")); }
    if (qualifications  == null) { qualifications = new java.util.ArrayList<>(); qualifications.addAll(java.util.Arrays.asList("PhD","Postdoctoral","Master's","Bachelor's","Other")); }
    if (academicRanks   == null) { academicRanks  = new java.util.ArrayList<>(); academicRanks.addAll(java.util.Arrays.asList("Professor","Associate Professor","Senior Lecturer","Lecturer","Research Fellow","Postdoctoral Researcher")); }
    if (genders         == null) { genders        = new java.util.ArrayList<>(); genders.addAll(java.util.Arrays.asList("Male","Female","Other")); }
    @SuppressWarnings("unchecked")
    List<String> nationalities = (List<String>) request.getAttribute("nationalities");
    if (nationalities == null) { nationalities = new java.util.ArrayList<>(); nationalities.addAll(java.util.Arrays.asList("Malaysian","Bruneian","Singaporean","Indonesian","Thai","Filipino","Vietnamese","Chinese","Japanese","Korean","Indian","Pakistani","Bangladeshi","Yemeni","Saudi Arabian","Nigerian","Ghanaian","British","American","Australian","Canadian","Other")); }
    @SuppressWarnings("unchecked")
    List<String> countries = (List<String>) request.getAttribute("countries");
    if (countries == null) { countries = new java.util.ArrayList<>(); countries.addAll(java.util.Arrays.asList("Malaysia","Brunei","Singapore","Indonesia","Thailand","Philippines","Vietnam","China","Japan","South Korea","India","Pakistan","Bangladesh","Yemen","Saudi Arabia","Nigeria","Ghana","United Kingdom","United States","Australia","Canada","Germany","France","New Zealand")); }
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> universities = (List<Map<String,Object>>) request.getAttribute("universities");
    if (universities == null) universities = new java.util.ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Submit Nomination - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    .role-switcher-btn{background:#fff;border:1.5px solid #d1d5db;border-radius:10px;padding:6px 36px 6px 14px;font-size:0.95rem;font-weight:600;color:#111827;cursor:pointer;appearance:none;-webkit-appearance:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24'%3E%3Cpath d='M7 10l5 5 5-5z' fill='%236b7280'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 10px center;}
    .sn-card { background:#fff; border:1px solid #e5e7eb; border-radius:16px; padding:28px 32px; margin-bottom:20px; }
    .sn-section-title { font-size:1rem; font-weight:600; color:#105e60; display:flex; align-items:center; gap:8px; margin-bottom:20px; padding-bottom:10px; border-bottom:1px solid #f3f4f6; }
    .sn-sub-title { font-size:0.95rem; font-weight:600; color:#374151; display:flex; align-items:center; gap:8px; margin:20px 0 14px; }
    .sn-label { font-size:0.88rem; font-weight:600; color:#374151; margin-bottom:5px; }
    .sn-hint { font-size:0.78rem; color:#e07b54; margin-top:4px; display:flex; align-items:center; gap:4px; }
    .sn-input { border:1px solid #d1d5db; border-radius:8px; padding:10px 14px; font-size:0.92rem; width:100%; background:#fff; color:#111827; }
    .sn-input:focus { outline:none; border-color:#0f766e; box-shadow:0 0 0 3px rgba(15,118,110,0.08); }
    .sn-input[readonly] { background:#f3f4f6; color:#6b7280; cursor:not-allowed; }
    .sn-input:disabled  { background:#f3f4f6; color:#9ca3af; cursor:not-allowed; }
    .sn-select { appearance:none; background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24'%3E%3Cpath d='M7 10l5 5 5-5z' fill='%236b7280'/%3E%3C/svg%3E"); background-repeat:no-repeat; background-position:right 12px center; }
    .sn-info-box { background:#eff6ff; border:1.5px solid #93c5fd; border-radius:12px; padding:18px 22px; margin-bottom:20px; }
    .sn-info-box ul { margin:8px 0 0 0; padding-left:20px; color:#1d4ed8; font-size:0.875rem; }
    .sn-info-box ul li { margin-bottom:4px; }
    .sn-drop-zone { border:2px dashed #cbd5e1; border-radius:10px; padding:36px 20px; text-align:center; cursor:pointer; transition:border-color .2s; position:relative; }
    .sn-drop-zone:hover, .sn-drop-zone.dragover { border-color:#0f766e; background:#f0fdf4; }
    .sn-drop-zone input[type=file] { position:absolute; inset:0; opacity:0; cursor:pointer; width:100%; height:100%; }
    .sn-drop-icon { font-size:1.8rem; color:#94a3b8; display:block; margin-bottom:8px; }
    .sn-drop-label { font-size:0.92rem; font-weight:600; color:#0f766e; }
    .sn-drop-hint { font-size:0.8rem; color:#94a3b8; margin-top:4px; }
    .sn-file-list { margin-top:10px; text-align:left; }
    .sn-file-item { display:flex; align-items:center; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; padding:6px 10px; font-size:0.83rem; color:#374151; margin-top:6px; }
    .sn-divider { border:none; border-top:1px solid #f3f4f6; margin:18px 0; }
    .sn-back { display:inline-flex; align-items:center; gap:8px; color:#374151; font-size:0.88rem; font-weight:500; text-decoration:none; margin-bottom:20px; background:#f9fafb; border:1.5px solid #e5e7eb; border-radius:8px; padding:7px 14px; transition:all 0.2s; }
    .sn-back:hover { color:#0f766e; border-color:#0f766e; background:#f0fdf4; }
  </style>
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout">
    <% request.setAttribute("activeSection", "submitNomination"); %>
    <% if ("Dean".equals(session.getAttribute("role_name"))) { %>
    <jsp:include page="/dean/sidebar.jsp" />
    <% } else { %>
    <jsp:include page="/academician/sidebar.jsp" />
    <% } %>

    <main class="content" style="max-width:none;">
      <div style="max-width:860px;margin:0 auto;">

    <!-- Back link -->
    <a href="<%= request.getContextPath() %>/MyNominationsServlet" class="sn-back">
      <i class="bi bi-arrow-left-short" style="font-size:1.1rem;"></i> Back to My Nominations
    </a>

    <!-- Page heading -->
    <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Thesis External Examiner Nomination Form</h1>
    <div style="font-size:1rem;color:#6b7280;margin-bottom:24px;">Submit new external examiner nomination</div>

    <!-- Error -->
    <% if (error != null) { %>
    <div class="alert alert-danger d-flex align-items-center gap-2 mb-4" style="border-radius:10px;">
      <i class="bi bi-exclamation-circle-fill"></i> <%= error %>
    </div>
    <% } %>

    <!-- Important Information -->
    <div class="sn-info-box">
      <div style="display:flex;align-items:center;gap:8px;font-weight:600;color:#1d4ed8;">
        <i class="bi bi-info-circle"></i> Important Information
      </div>
      <ul>
        <li>Fields marked with * are required and will be used in official appointment letters</li>
        <li>Both CV and Qualification Proof documents are mandatory</li>
        <li>Ensure all information is accurate before submission</li>
      </ul>
    </div>

    <form action="<%= request.getContextPath() %>/SubmitNominationServlet" method="POST" enctype="multipart/form-data" id="nominationForm">

      <!-- SECTION 1: Nomination Information -->
      <div class="sn-card">
        <div class="sn-section-title">
          <i class="bi bi-calendar3"></i> Nomination Information
        </div>

        <div class="mb-3">
          <div class="sn-label">Role Nominated *</div>
          <input type="text" class="sn-input" value="External Examiner" readonly>
          <div class="sn-hint"><i class="bi bi-bookmark"></i> This nomination is for External Examiner role</div>
        </div>

        <div class="mb-1">
          <div class="sn-label">Additional Remarks (Optional)</div>
          <textarea name="remarks" class="sn-input" rows="3" placeholder="Any additional information or justification for this nomination..."></textarea>
        </div>
      </div>

      <!-- SECTION 2: Examiner Info -->
      <div class="sn-card">
        <div class="sn-section-title">
          <i class="bi bi-person"></i> A. Examiner Personal &amp; Professional Information
        </div>

        <!-- Basic Information -->
        <div class="sn-sub-title"><i class="bi bi-person"></i> Basic Information</div>
        <div class="row g-3 mb-3">
          <div class="col-md-6">
            <div class="sn-label">Title / Designation *</div>
            <div style="position:relative;">
              <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
              <input type="text" name="title" id="titleSearch" autocomplete="off" class="sn-input" required
                     style="padding-left:32px;"
                     placeholder="Select title">
              <ul id="titleDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                     background:#fff;border:1px solid #d1d5db;border-radius:8px;
                     box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                     list-style:none;max-height:200px;overflow-y:auto;"></ul>
            </div>
            <div class="sn-hint"><i class="bi bi-bookmark"></i> Used in letter heading</div>
          </div>
          <div class="col-md-6">
            <div class="sn-label">Full Name *</div>
            <input type="text" name="full_name" class="sn-input" placeholder="e.g. Ahmad bin Abdullah / Nur Farah binti Ahmad / Prof. John Smith" required>
            <div class="sn-hint"><i class="bi bi-bookmark"></i> Used in salutation</div>
          </div>
        </div>
        <div class="row g-3 mb-1">
          <div class="col-md-4">
            <div class="sn-label">Gender (Optional)</div>
            <div style="position:relative;">
              <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
              <input type="text" name="gender" id="genderSearch" autocomplete="off" class="sn-input"
                     style="padding-left:32px;"
                     placeholder="Select gender">
              <ul id="genderDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                     background:#fff;border:1px solid #d1d5db;border-radius:8px;
                     box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                     list-style:none;max-height:200px;overflow-y:auto;"></ul>
            </div>
          </div>
          <div class="col-md-4">
            <div class="sn-label">Nationality</div>
            <div style="position:relative;">
              <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
              <input type="text" name="nationality" id="natSearch" autocomplete="off" class="sn-input"
                     style="padding-left:32px;"
                     placeholder="Type to search...">
              <ul id="natDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                     background:#fff;border:1px solid #d1d5db;border-radius:8px;
                     box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                     list-style:none;max-height:200px;overflow-y:auto;"></ul>
            </div>
          </div>
          <div class="col-md-4">
            <div class="sn-label">IC / Passport No. (Optional)</div>
            <input type="text" name="ic_passport" class="sn-input" placeholder="Confidential">
          </div>
        </div>

        <hr class="sn-divider">

        <!-- Institutional Information -->
        <div class="sn-sub-title"><i class="bi bi-building"></i> Institutional Information</div>
        <div class="row g-3 mb-3">
          <div class="col-md-6">
            <div class="sn-label">University / Organisation *</div>
            <div style="position:relative;">
              <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
              <input type="text" name="university" id="univSearch" autocomplete="off" class="sn-input" required
                     style="padding-left:32px;"
                     placeholder="Type to search university...">
              <ul id="univDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                     background:#fff;border:1px solid #d1d5db;border-radius:8px;
                     box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                     list-style:none;max-height:200px;overflow-y:auto;"></ul>
            </div>
            <div class="sn-hint"><i class="bi bi-bookmark"></i> Used in letter</div>
          </div>
          <div class="col-md-6">
            <div class="sn-label">Faculty / Department</div>
            <input type="text" name="faculty" class="sn-input" placeholder="e.g., Faculty of Computer Science">
          </div>
        </div>
        <div class="mb-1">
          <div class="sn-label">Country *</div>
          <div style="position:relative;">
            <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
            <input type="text" name="country" id="countrySearch" autocomplete="off" class="sn-input" required
                   style="padding-left:32px;"
                   placeholder="Type to search country...">
            <ul id="countryDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                   background:#fff;border:1px solid #d1d5db;border-radius:8px;
                   box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                   list-style:none;max-height:200px;overflow-y:auto;"></ul>
          </div>
          <div class="sn-hint"><i class="bi bi-bookmark"></i> Appears in letter</div>
        </div>

        <hr class="sn-divider">

        <!-- Academic & Professional Details (4-level cascade) -->
        <div class="sn-sub-title"><i class="bi bi-diagram-3"></i> Research Field &mdash; Specialization &rarr; Expertise &rarr; Division &rarr; Area</div>

        <div class="row g-3 mb-3">
          <!-- Level 1: Specialization -->
          <div class="col-md-6">
            <div class="sn-label">Specialization <span class="text-danger">*</span></div>
            <div style="position:relative;">
              <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
              <input type="text" id="specSearch" autocomplete="off" class="sn-input"
                     style="padding-left:32px;" placeholder="Select specialization">
              <input type="hidden" name="specialization_id" id="specIdHidden">
              <input type="hidden" name="specialization" id="specNameHidden">
              <ul id="specDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                     background:#fff;border:1px solid #d1d5db;border-radius:8px;
                     box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                     list-style:none;max-height:200px;overflow-y:auto;"></ul>
            </div>
            <div class="sn-hint"><i class="bi bi-diagram-3"></i> Top-level research category</div>
          </div>

          <!-- Level 2: Expertise -->
          <div class="col-md-6">
            <div class="sn-label">Expertise</div>
            <div style="position:relative;">
              <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
              <input type="text" id="expSearch" autocomplete="off" class="sn-input"
                     style="padding-left:32px;" placeholder="— select specialization first —" disabled>
              <input type="hidden" name="expertise_id" id="expIdHidden">
              <ul id="expDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                     background:#fff;border:1px solid #d1d5db;border-radius:8px;
                     box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                     list-style:none;max-height:200px;overflow-y:auto;"></ul>
            </div>
            <div class="sn-hint">Filtered by specialization</div>
          </div>

          <!-- Level 3: Division -->
          <div class="col-md-6">
            <div class="sn-label">Division / Research Group</div>
            <div style="position:relative;">
              <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
              <input type="text" id="divSearch" autocomplete="off" class="sn-input"
                     style="padding-left:32px;" placeholder="— select expertise first —" disabled>
              <input type="hidden" name="division_id" id="divIdHidden">
              <ul id="divDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                     background:#fff;border:1px solid #d1d5db;border-radius:8px;
                     box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                     list-style:none;max-height:200px;overflow-y:auto;"></ul>
            </div>
            <div class="sn-hint">Filtered by expertise</div>
          </div>

          <!-- Level 4: Area -->
          <div class="col-md-6">
            <div class="sn-label">Area of Research</div>
            <div style="position:relative;">
              <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
              <input type="text" id="areaSearch" autocomplete="off" class="sn-input"
                     style="padding-left:32px;" placeholder="— select division first —" disabled>
              <input type="hidden" name="area_id" id="areaIdHidden">
              <ul id="areaDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                     background:#fff;border:1px solid #d1d5db;border-radius:8px;
                     box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                     list-style:none;max-height:200px;overflow-y:auto;"></ul>
            </div>
            <div class="sn-hint">Filtered by division</div>
          </div>
        </div>

        <div class="sn-sub-title"><i class="bi bi-mortarboard"></i> Academic &amp; Professional Details</div>
        <div class="row g-3 mb-3">
          <div class="col-md-6">
            <div class="sn-label">Highest Qualification</div>
            <div style="position:relative;">
              <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
              <input type="text" name="qualification" id="qualSearch" autocomplete="off" class="sn-input"
                     style="padding-left:32px;"
                     placeholder="Select qualification">
              <ul id="qualDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                     background:#fff;border:1px solid #d1d5db;border-radius:8px;
                     box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                     list-style:none;max-height:200px;overflow-y:auto;"></ul>
            </div>
          </div>
        </div>
        <div class="mb-1">
          <div class="sn-label">Current Position *</div>
          <div style="position:relative;">
            <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
            <input type="text" name="position" id="posSearch" autocomplete="off" class="sn-input" required
                   style="padding-left:32px;"
                   placeholder="Select rank">
            <ul id="posDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                   background:#fff;border:1px solid #d1d5db;border-radius:8px;
                   box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                   list-style:none;max-height:200px;overflow-y:auto;"></ul>
          </div>
          <div class="sn-hint"><i class="bi bi-bookmark"></i> Appears in letter</div>
        </div>

        <hr class="sn-divider">

        <!-- Contact Information -->
        <div class="sn-sub-title"><i class="bi bi-envelope"></i> Contact Information</div>
        <div class="row g-3 mb-1">
          <div class="col-md-6">
            <div class="sn-label">Email Address *</div>
            <input type="email" name="email" class="sn-input" placeholder="examiner@university.edu" required>
            <div class="sn-hint"><i class="bi bi-bookmark"></i> Used for contact</div>
          </div>
          <div class="col-md-6">
            <div class="sn-label">Contact Number</div>
            <input type="tel" name="phone" class="sn-input" placeholder="e.g. +60123456789">
          </div>
        </div>
      </div>

      <!-- SECTION 3: Supporting Documents -->
      <div class="sn-card">
        <div class="sn-section-title">
          <i class="bi bi-file-earmark-text"></i> C. Supporting Documents (Mandatory)
        </div>

        <!-- CV Upload -->
        <div class="mb-4">
          <div class="sn-label">Curriculum Vitae (CV) *</div>
          <div class="sn-drop-zone" id="cvZone">
            <input type="file" name="cv_file" id="cvInput" multiple accept=".pdf,.doc,.docx" required>
            <i class="bi bi-cloud-upload sn-drop-icon"></i>
            <div class="sn-drop-label">Upload CV</div>
            <div class="sn-drop-hint">PDF, DOC, DOCX (MAX. 10MB each)</div>
          </div>
          <div class="sn-file-list" id="cvFileList"></div>
        </div>

        <!-- Qualification Proof Upload -->
        <div class="mb-2">
          <div class="sn-label">Qualification Proof (Certificates) *</div>
          <div class="sn-drop-zone" id="qualZone">
            <input type="file" name="qual_file" id="qualInput" multiple accept=".pdf,.doc,.docx" required>
            <i class="bi bi-cloud-upload sn-drop-icon"></i>
            <div class="sn-drop-label">Upload Certificates</div>
            <div class="sn-drop-hint">PDF, DOC, DOCX (MAX. 10MB each)</div>
          </div>
          <div class="sn-file-list" id="qualFileList"></div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="d-flex justify-content-end gap-3 mt-2 mb-5">
        <a href="<%= request.getContextPath() %>/MyNominationsServlet" class="btn-ea-back">Cancel</a>
        <button type="submit" class="ea-btn-primary-action">
          <i class="bi bi-send"></i> Submit Nomination
        </button>
      </div>

    </form>
      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    (function(){
      var btn = document.getElementById('sidebarToggleBtn');
      var overlay = document.getElementById('sidebarOverlay');
      if(btn){ btn.addEventListener('click', function(){ document.body.classList.toggle('sidebar-open'); }); }
      if(overlay){ overlay.addEventListener('click', function(){ document.body.classList.remove('sidebar-open'); }); }
    })();

    function initDropZone(zoneId, inputId, listId) {
      var zone  = document.getElementById(zoneId);
      var input = document.getElementById(inputId);
      var list  = document.getElementById(listId);
      var accumulated = []; // tracked File objects

      function syncInput() {
        var dt = new DataTransfer();
        accumulated.forEach(function(f){ dt.items.add(f); });
        input.files = dt.files;
      }

      function renderFiles() {
        list.innerHTML = '';
        if (accumulated.length === 0) return;
        accumulated.forEach(function(f, idx) {
          var item = document.createElement('div');
          item.className = 'sn-file-item d-flex align-items-center justify-content-between';
          item.style.cssText = 'gap:10px;padding:8px 14px;margin-top:6px;background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;';
          item.innerHTML =
            '<div class="d-flex align-items-center gap-2" style="min-width:0;">' +
              '<i class="bi bi-file-earmark-pdf" style="color:#ef4444;font-size:1.15rem;flex-shrink:0;"></i>' +
              '<span style="font-size:0.85rem;font-weight:600;color:#111827;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + f.name + '</span>' +
              '<span style="color:#9ca3af;font-size:0.78rem;flex-shrink:0;">(' + (f.size/1024).toFixed(0) + ' KB)</span>' +
            '</div>' +
            '<button type="button" title="Remove" style="background:none;border:none;color:#ef4444;cursor:pointer;padding:2px 6px;border-radius:6px;font-size:1.05rem;line-height:1;box-shadow:none;"' +
              ' onclick="removeFile(' + JSON.stringify(zoneId) + ',' + idx + ')">' +
              '<i class="bi bi-x-circle-fill"></i>' +
            '</button>';
          list.appendChild(item);
        });
      }

      input.addEventListener('change', function() {
        Array.from(input.files).forEach(function(f){
          // avoid duplicates by name+size
          var dup = accumulated.some(function(x){ return x.name===f.name && x.size===f.size; });
          if (!dup) accumulated.push(f);
        });
        syncInput();
        renderFiles();
      });

      zone.addEventListener('dragover',  function(e){ e.preventDefault(); zone.classList.add('dragover'); });
      zone.addEventListener('dragleave', function(){  zone.classList.remove('dragover'); });
      zone.addEventListener('drop', function(e){
        e.preventDefault(); zone.classList.remove('dragover');
        Array.from(e.dataTransfer.files).forEach(function(f){
          var dup = accumulated.some(function(x){ return x.name===f.name && x.size===f.size; });
          if (!dup) accumulated.push(f);
        });
        syncInput();
        renderFiles();
      });

      // expose remove function on window keyed by zone id
      if (!window._dropZones) window._dropZones = {};
      window._dropZones[zoneId] = { accumulated: accumulated, syncInput: syncInput, renderFiles: renderFiles };
    }

    window.removeFile = function(zoneId, idx) {
      var z = window._dropZones[zoneId];
      if (!z) return;
      z.accumulated.splice(idx, 1);
      z.syncInput();
      z.renderFiles();
    };

    initDropZone('cvZone',   'cvInput',   'cvFileList');
    initDropZone('qualZone', 'qualInput', 'qualFileList');

    // Validate required fields before submit
    document.getElementById('nominationForm').addEventListener('submit', function(e) {
      if (!document.getElementById('specIdHidden').value) {
        e.preventDefault(); alert('Please select a Specialization.'); return;
      }
      var cvInput   = document.getElementById('cvInput');
      var qualInput = document.getElementById('qualInput');
      if (!cvInput.files || cvInput.files.length === 0) {
        e.preventDefault();
        alert('Please upload at least one CV file.');
        return;
      }
      if (!qualInput.files || qualInput.files.length === 0) {
        e.preventDefault();
        alert('Please upload at least one Qualification Proof file.');
      }
    });

    // ── Nationality + Country type-search ────────────────────────────────
    function makeTypeSearch(inputId, dropdownId, dataArray, onSelect) {
      var inp = document.getElementById(inputId);
      var ddl = document.getElementById(dropdownId);
      if (!inp) return;
      function render(q) {
        var lower = q.toLowerCase();
        var matches = q.length === 0 ? dataArray : dataArray.filter(function(v){ return v.toLowerCase().indexOf(lower) !== -1; });
        ddl.innerHTML = '';
        if (!matches.length) { ddl.style.display = 'none'; return; }
        matches.forEach(function(v) {
          var li = document.createElement('li');
          li.style.cssText = 'padding:8px 12px;cursor:pointer;font-size:0.91rem;border-bottom:1px solid #f3f4f6;';
          li.textContent = v;
          li.addEventListener('mousedown', function(e){ e.preventDefault(); inp.value = v; ddl.style.display = 'none'; if (typeof onSelect === 'function') onSelect(v); });
          li.addEventListener('mouseover', function(){ this.style.background = '#f0f9ff'; });
          li.addEventListener('mouseout',  function(){ this.style.background = ''; });
          ddl.appendChild(li);
        });
        ddl.style.display = 'block';
      }
      inp.addEventListener('input', function(){ render(this.value.trim()); });
      inp.addEventListener('focus', function(){ render(this.value.trim()); });
      document.addEventListener('click', function(e){
        if (!inp.contains(e.target) && !ddl.contains(e.target)) ddl.style.display = 'none';
      });
    }
    var natData   = [<% for (int ni = 0; ni < nationalities.size(); ni++) { out.print((ni>0?",":"") + "\"" + nationalities.get(ni).replace("\"","\\\"") + "\""); } %>];
    var cData     = [<% for (int ci = 0; ci < countries.size(); ci++) { out.print((ci>0?",":"") + "\"" + countries.get(ci).replace("\"","\\\"") + "\""); } %>];
    var univNames = [<% for (int ui = 0; ui < universities.size(); ui++) { out.print((ui>0?",":"") + "\"" + universities.get(ui).get("name").toString().replace("\"","\\\"") + "\""); } %>];
    var univCountryMap = {<% boolean uf=true; for (Map<String,Object> uu : universities) { if(!uf)out.print(","); uf=false; String un=uu.get("name").toString().replace("\"","\\\""); String uc=uu.get("country")!=null?uu.get("country").toString().replace("\"","\\\""):""; out.print("\""+un+"\":\""+uc+"\""); } %>};
    var titleData  = [<% for (int ti = 0; ti < examinerTitles.size(); ti++) { out.print((ti>0?",":"") + "\"" + examinerTitles.get(ti).replace("\"","\\\"") + "\""); } %>];
    var genderData = [<% for (int gi = 0; gi < genders.size(); gi++) { out.print((gi>0?",":"") + "\"" + genders.get(gi).replace("\"","\\\"") + "\""); } %>];
    var qualData   = [<% for (int qi = 0; qi < qualifications.size(); qi++) { out.print((qi>0?",":"") + "\"" + qualifications.get(qi).replace("\"","\\\"") + "\""); } %>];
    var posData    = [<% for (int pi = 0; pi < academicRanks.size(); pi++) { out.print((pi>0?",":"") + "\"" + academicRanks.get(pi).replace("\"","\\\"") + "\""); } %>];
    makeTypeSearch('natSearch',     'natDropdown',     natData,    null);
    makeTypeSearch('countrySearch', 'countryDropdown', cData,      null);
    makeTypeSearch('univSearch',    'univDropdown',    univNames,  function(v){ var c=univCountryMap[v]; if(c) document.getElementById('countrySearch').value=c; });
    makeTypeSearch('titleSearch',   'titleDropdown',   titleData,  null);
    makeTypeSearch('genderSearch',  'genderDropdown',  genderData, null);
    makeTypeSearch('qualSearch',    'qualDropdown',    qualData,   null);
    makeTypeSearch('posSearch',     'posDropdown',     posData,    null);

    // \u2500\u2500 4-level cascade comboboxes \u2500\u2500\u2500\u2500
    function makeCascadeBox(inputId, dropdownId, hiddenId, onSelect) {
      var inp = document.getElementById(inputId);
      var ddl = document.getElementById(dropdownId);
      var hid = hiddenId ? document.getElementById(hiddenId) : null;
      if (!inp) return null;
      var currentItems = [];
      function render(q) {
        var lower = q ? q.toLowerCase() : '';
        var matches = lower.length === 0 ? currentItems
          : currentItems.filter(function(item){ return item.name.toLowerCase().indexOf(lower) !== -1; });
        ddl.innerHTML = '';
        if (!matches.length) { ddl.style.display = 'none'; return; }
        matches.forEach(function(item) {
          var li = document.createElement('li');
          li.style.cssText = 'padding:8px 12px;cursor:pointer;font-size:0.91rem;border-bottom:1px solid #f3f4f6;';
          li.textContent = item.name;
          li.addEventListener('mousedown', function(e) {
            e.preventDefault(); inp.value = item.name;
            if (hid) hid.value = item.id;
            ddl.style.display = 'none';
            if (typeof onSelect === 'function') onSelect(item);
          });
          li.addEventListener('mouseover', function(){ this.style.background = '#f0f9ff'; });
          li.addEventListener('mouseout',  function(){ this.style.background = ''; });
          ddl.appendChild(li);
        });
        ddl.style.display = 'block';
      }
      inp.addEventListener('input', function(){ if (!inp.disabled) render(this.value.trim()); });
      inp.addEventListener('focus', function(){ if (!inp.disabled) render(this.value.trim()); });
      inp.addEventListener('blur', function(){
        setTimeout(function() {
          ddl.style.display = 'none';
          if (inp.value && currentItems.length > 0 && !currentItems.some(function(i){ return i.name === inp.value; })) {
            inp.value = ''; if (hid) hid.value = '';
          }
        }, 200);
      });
      document.addEventListener('click', function(e){
        if (!inp.contains(e.target) && !ddl.contains(e.target)) ddl.style.display = 'none';
      });
      return {
        clear:    function() { inp.value=''; if(hid) hid.value=''; currentItems=[]; ddl.style.display='none'; },
        disable:  function() { inp.placeholder='\u2014 select previous level first \u2014'; inp.disabled=true; inp.value=''; if(hid) hid.value=''; currentItems=[]; },
        enable:   function(items, ph) { currentItems=items||[]; inp.disabled=false; inp.placeholder=ph||'Type to search...'; },
        setValue: function(id, name) { inp.value=name; if(hid) hid.value=id; }
      };
    }
    var specData = [<%for(int si=0;si<specializations.size();si++){Map<String,Object> sp=specializations.get(si);int spId=((Number)sp.get("id")).intValue();String spN=sp.get("name").toString().replace("\"","\\\"");out.print((si>0?",":"")+"{"+"\"id\":"+spId+",\"name\":\""+spN+"\""+"}");} %>];
    var expData  = [<%for(int ei=0;ei<expertiseList.size();ei++){Map<String,Object> ex=expertiseList.get(ei);int exId=((Number)ex.get("id")).intValue();int exSp=((Number)ex.get("specialization_id")).intValue();String exN=ex.get("name").toString().replace("\"","\\\"");out.print((ei>0?",":"")+"{"+"\"id\":"+exId+",\"name\":\""+exN+"\",\"spec_id\":"+exSp+"}");} %>];
    var divData  = [<%for(int di=0;di<divisionList.size();di++){Map<String,Object> dv=divisionList.get(di);int dvId=((Number)dv.get("id")).intValue();int dvEp=dv.get("expertise_id")!=null?((Number)dv.get("expertise_id")).intValue():0;String dvN=dv.get("name").toString().replace("\"","\\\"");out.print((di>0?",":"")+"{"+"\"id\":"+dvId+",\"name\":\""+dvN+"\",\"exp_id\":"+dvEp+"}");} %>];
    var areaData = [<%for(int ai=0;ai<areaList.size();ai++){Map<String,Object> ar=areaList.get(ai);int arId=((Number)ar.get("id")).intValue();int arDv=ar.get("division_id")!=null?((Number)ar.get("division_id")).intValue():0;String arN=ar.get("name").toString().replace("\"","\\\"");out.print((ai>0?",":"")+"{"+"\"id\":"+arId+",\"name\":\""+arN+"\",\"div_id\":"+arDv+"}");} %>];
    var specBox = makeCascadeBox('specSearch','specDropdown','specIdHidden', function(item){
      document.getElementById('specNameHidden').value = item.name;
      expBox.clear(); divBox.clear(); areaBox.clear();
      var ei = expData.filter(function(e){ return e.spec_id===item.id; });
      if(ei.length) expBox.enable(ei,'Select expertise'); else expBox.disable();
      divBox.disable(); areaBox.disable();
    });
    var expBox = makeCascadeBox('expSearch','expDropdown','expIdHidden', function(item){
      divBox.clear(); areaBox.clear();
      var di = divData.filter(function(d){ return d.exp_id===item.id; });
      if(di.length) divBox.enable(di,'Select division'); else divBox.disable();
      areaBox.disable();
    });
    var divBox = makeCascadeBox('divSearch','divDropdown','divIdHidden', function(item){
      areaBox.clear();
      var ai = areaData.filter(function(a){ return a.div_id===item.id; });
      if(ai.length) areaBox.enable(ai,'Select area'); else areaBox.disable();
    });
    var areaBox = makeCascadeBox('areaSearch','areaDropdown','areaIdHidden',null);
    specBox.enable(specData,'Select specialization');
    expBox.disable(); divBox.disable(); areaBox.disable();
  </script>
</body>
</html>
