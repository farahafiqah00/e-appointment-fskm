<%--
  Admin: combined Add/Edit viva candidate form. isEdit=true when the candidate attribute is
  set by EditCandidateServlet; form action and heading change accordingly.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Candidate, model.CoSupervisor, java.util.List, java.util.Map, dao.AcademicStaffDAO" %>
<%
    String sessionName = (String) session.getAttribute("full_name");
    if (sessionName == null || sessionName.trim().isEmpty()) sessionName = "Admin";

    // Determine edit vs add mode
    Candidate editC = (Candidate) request.getAttribute("candidate");
    boolean isEdit  = (editC != null);

    // Pre-filled values
    String prefFullName       = isEdit && editC.getFullName()      != null ? editC.getFullName()      : "";
    String prefStudentId      = isEdit && editC.getStudentId()     != null ? editC.getStudentId()     : "";
    String prefThesisTitle    = isEdit && editC.getThesisTitle()   != null ? editC.getThesisTitle()   : "";
    String prefSupervisorName = isEdit && editC.getSupervisorName()!= null ? editC.getSupervisorName(): "";
    Integer prefSupervisorId  = isEdit ? editC.getSupervisorId() : null;
    String prefContactEmail   = isEdit && editC.getContactEmail()  != null ? editC.getContactEmail()  : "";
    String prefNationality    = isEdit && editC.getNationality()   != null ? editC.getNationality()   : "";
    String prefStatus         = isEdit && editC.getStatus()        != null ? editC.getStatus()        : "prepared";
    Integer prefProgramId     = isEdit ? editC.getProgramId() : null;

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> programs = (List<Map<String,Object>>) request.getAttribute("programs");
    if (programs == null) {
        programs = new java.util.ArrayList<>();
        try (java.sql.Connection conn = util.DBConnection.getConnection()) {
            // Try with level column; fall back if not yet added
            try (java.sql.PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, code, name, level FROM program ORDER BY level, name");
                 java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new java.util.LinkedHashMap<>();
                    m.put("id",    rs.getInt("id"));
                    m.put("code",  rs.getString("code"));
                    m.put("name",  rs.getString("name"));
                    m.put("level", rs.getString("level"));
                    programs.add(m);
                }
            } catch (Exception e1) {
                // level column doesn't exist yet — retry without it
                programs.clear();
                try (java.sql.PreparedStatement ps = conn.prepareStatement(
                        "SELECT id, code, name FROM program ORDER BY name");
                     java.sql.ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String,Object> m = new java.util.LinkedHashMap<>();
                        m.put("id",    rs.getInt("id"));
                        m.put("code",  rs.getString("code"));
                        m.put("name",  rs.getString("name"));
                        m.put("level", null);
                        programs.add(m);
                    }
                } catch (Exception ignore) {}
            }
        } catch (Exception ignore) {}
    }
    // Determine pre-selected level: use model's programLevel first (set via findById JOIN)
    String prefLevel = isEdit && editC.getProgramLevel() != null ? editC.getProgramLevel() : "";
    if (prefLevel.isEmpty() && prefProgramId != null) {
        for (Map<String,Object> p : programs) {
            if (prefProgramId.equals(p.get("id"))) {
                Object lvl = p.get("level"); if (lvl != null) prefLevel = (String) lvl; break;
            }
        }
    }

    // Load nationality dropdown options
    List<String> nationalities = new java.util.ArrayList<>();
    try { nationalities = new AcademicStaffDAO().getNationalities(); } catch (Exception ignore) {}
    if (nationalities.isEmpty()) { nationalities.addAll(java.util.Arrays.asList("Malaysian","Bruneian","Singaporean","Indonesian","Thai","Filipino","Vietnamese","Chinese","Japanese","Korean","Indian","Pakistani","Bangladeshi","Yemeni","Saudi Arabian","Nigerian","Ghanaian","British","American","Australian","Canadian","Other")); }

    // Load academic staff for supervisor dropdown and internal co-sv picker
    List<Map<String,Object>> staffList = new java.util.ArrayList<>();
    try (java.sql.Connection conn = util.DBConnection.getConnection();
         java.sql.PreparedStatement ps = conn.prepareStatement(
             "SELECT a.id, TRIM(CONCAT(COALESCE(CONCAT(a.title, ' '), ''), COALESCE(a.full_name, u.full_name, ''))) AS display_name, " +
             "COALESCE(a.department, '') AS department, COALESCE(a.academic_rank, '') AS rank " +
             "FROM academic_staff a LEFT JOIN `user` u ON u.id = a.user_id " +
             "WHERE a.status = 'active' ORDER BY display_name")) {
        try (java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> m = new java.util.LinkedHashMap<>();
                m.put("id",   rs.getInt("id"));
                m.put("name", rs.getString("display_name") != null ? rs.getString("display_name") : "");
                m.put("dept", rs.getString("department")   != null ? rs.getString("department")   : "");
                m.put("rank", rs.getString("rank")         != null ? rs.getString("rank")         : "");
                staffList.add(m);
            }
        }
    } catch (Exception ignore) {}

    // Build staff JSON for JS (used in co-sv internal picker)
    StringBuilder staffJsonSb = new StringBuilder("[");
    for (Map<String,Object> st : staffList) {
        staffJsonSb.append("{\"id\":").append(st.get("id"))
                   .append(",\"name\":\"").append(((String)st.get("name")).replace("\"","\\\"")).append("\"")
                   .append(",\"dept\":\"").append(((String)st.get("dept")).replace("\"","\\\"")).append("\"")
                   .append("},");
    }
    if (staffJsonSb.length() > 1) staffJsonSb.deleteCharAt(staffJsonSb.length()-1);
    staffJsonSb.append("]");

    // Build program JSON for JS cascade (level → programme)
    StringBuilder programJsonSb = new StringBuilder("[");
    for (Map<String,Object> prog : programs) {
        String pname  = prog.get("name")  != null ? (String) prog.get("name")  : "";
        String plevel = prog.get("level") != null ? (String) prog.get("level") : "";
        programJsonSb.append("{\"id\":").append(prog.get("id"))
                     .append(",\"name\":\"").append(pname.replace("\\","\\\\").replace("\"","\\\"")).append("\"")
                     .append(",\"level\":\"").append(plevel).append("\"},");
    }
    if (programJsonSb.length() > 1) programJsonSb.deleteCharAt(programJsonSb.length()-1);
    programJsonSb.append("]");

    List<CoSupervisor> prefCoSups = isEdit ? editC.getCoSupervisors() : new java.util.ArrayList<>();
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= isEdit ? "Edit" : "Add" %> Viva Candidate - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
      .cosv-tag {
        display:inline-flex;align-items:center;gap:6px;
        background:#e5f7f5;border:1px solid #a7f3d0;
        border-radius:20px;padding:5px 14px;font-size:0.9rem;color:#065f46;
      }
      .cosv-tag.internal { background:#eff6ff;border-color:#bfdbfe;color:#1d4ed8; }
      .cosv-add-form {
        background:#f9fafb;border:1px solid #e5e7eb;
        border-radius:14px;padding:20px 24px;margin-top:12px;
      }
    </style>
  </head>
  <body class="admin">

    <jsp:include page="/includes/topbar.jsp" />

    <div class="layout ea-layout">
      <% request.setAttribute("activeSection", "viva"); request.setAttribute("activeSubSection", "addViva"); %>
      <jsp:include page="/admin/sidebar.jsp" />

      <main class="content ea-content" style="max-width:none;">
        <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;max-width:900px;margin:0 auto;">

          <!-- Page Header -->
          <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
            <div>
              <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">
                <%= isEdit ? "Edit Viva Candidate" : "Add Viva Candidate" %>
              </h1>
              <div style="font-size:1rem;color:#6b7280;">Manually key in data from PG system</div>
            </div>
            <a href="<%= request.getContextPath() %>/CandidateListServlet" class="btn-ea-back">
              <i class="bi bi-arrow-left"></i> Back to list
            </a>
          </div>

          <!-- Form -->
          <form method="POST" id="candidateForm"
                action="<%= request.getContextPath() + (isEdit ? "/EditCandidateServlet" : "/AddCandidateServlet") %>">
            <% if (isEdit) { %><input type="hidden" name="id" value="<%= editC.getId() %>"><% } %>
            <!-- co-sv count updated by JS before submit -->
            <input type="hidden" name="cosvCount" id="cosvCount" value="0">

            <!-- â”€â”€ Candidate Information â”€â”€ -->
            <div class="w-100 mb-4 p-4"
                 style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div class="d-flex align-items-center gap-2 mb-4 pb-2" style="border-bottom:2px solid #f3f4f6;">
                <span style="background:#105e60;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;font-weight:700;flex-shrink:0;">
                  <i class="bi bi-mortarboard"></i>
                </span>
                <span style="font-size:1.05rem;font-weight:700;color:#105e60;">Candidate Information</span>
              </div>

              <div class="row g-4">
                <div class="col-md-6">
                  <label class="form-label fw-semibold" style="color:#374151;">Candidate Name <span class="text-danger">*</span></label>
                  <input type="text" name="fullName" class="form-control"
                         style="border-radius:10px;border-color:#e5e7eb;"
                         value="<%= prefFullName %>" required
                         placeholder="e.g. Ahmad bin Abdullah / Nur Farah binti Ahmad">
                </div>

                <div class="col-md-6">
                  <label class="form-label fw-semibold" style="color:#374151;">Matric Number <span class="text-danger">*</span></label>
                  <input type="text" name="studentId" id="studentIdInput" class="form-control"
                         style="border-radius:10px;border-color:#e5e7eb;"
                         value="<%= prefStudentId %>" required
                         placeholder="e.g. P19001">
                </div>

                <div class="col-md-6">
                  <label class="form-label fw-semibold" style="color:#374151;">Degree Level <span class="text-danger">*</span></label>
                  <div style="position:relative;">
                    <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
                    <input type="text" id="degreeLevelSearch" autocomplete="off" class="form-control"
                           style="border-radius:10px;border-color:#e5e7eb;padding-left:32px;" placeholder="-- Select Level --">
                    <input type="hidden" id="degreeLevelValue" value="<%= prefLevel %>">
                    <ul id="degreeLevelDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                           background:#fff;border:1px solid #d1d5db;border-radius:8px;
                           box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                           list-style:none;max-height:200px;overflow-y:auto;"></ul>
                  </div>
                </div>

                <div class="col-md-6">
                  <label class="form-label fw-semibold" style="color:#374151;">Programme <span class="text-danger">*</span></label>
                  <div style="position:relative;">
                    <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
                    <input type="text" id="progSearch" autocomplete="off" class="form-control"
                           style="border-radius:10px;border-color:#e5e7eb;padding-left:32px;"
                           placeholder="-- Select Level first --" disabled>
                    <input type="hidden" name="programId" id="progIdHidden" value="<%= prefProgramId != null ? prefProgramId : "" %>">
                    <ul id="progDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                           background:#fff;border:1px solid #d1d5db;border-radius:8px;
                           box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                           list-style:none;max-height:200px;overflow-y:auto;"></ul>
                  </div>
                </div>

                <div class="col-md-6">
                  <label class="form-label fw-semibold" style="color:#374151;">Viva Status</label>
                  <div style="padding:4px 0;">
                    <% if ("appointed".equals(prefStatus)) { %>
                    <span style="background:#dbeafe;color:#1d4ed8;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Appointed</span>
                    <% } else if ("completed".equals(prefStatus)) { %>
                    <span style="background:#dcfce7;color:#16a34a;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Completed</span>
                    <% } else { %>
                    <span style="background:#fef3c7;color:#d97706;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Prepared</span>
                    <% } %>
                  </div>
                </div>

                <div class="col-12">
                  <label class="form-label fw-semibold" style="color:#374151;">Thesis Title <span class="text-danger">*</span></label>
                  <textarea name="thesisTitle" class="form-control" rows="3" required
                            style="border-radius:10px;border-color:#e5e7eb;"
                            placeholder="Enter the full thesis title (will appear in ALL CAPS on the appointment letter)"><%= prefThesisTitle %></textarea>
                </div>

                <!-- Contact Email -->
                <div class="col-md-6">
                  <label class="form-label fw-semibold" style="color:#374151;">Contact Email</label>
                  <input type="email" name="contactEmail" class="form-control"
                         style="border-radius:10px;border-color:#e5e7eb;"
                         value="<%= prefContactEmail %>"
                         placeholder="e.g. student@umt.edu.my">
                </div>

                <!-- Nationality -->
                <div class="col-md-6">
                  <label class="form-label fw-semibold" style="color:#374151;">Nationality</label>
                  <div style="position:relative;">
                    <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
                    <input type="text" name="nationality" id="natSearch" autocomplete="off" class="form-control"
                           style="border-radius:10px;border-color:#e5e7eb;padding-left:32px;"
                           placeholder="Type to search..."
                           value="<%= prefNationality %>">
                    <ul id="natDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                           background:#fff;border:1px solid #d1d5db;border-radius:8px;
                           box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                           list-style:none;max-height:200px;overflow-y:auto;"></ul>
                  </div>
                </div>
              </div>
            </div>

            <!-- â”€â”€ Supervisor â”€â”€ -->
            <div class="w-100 mb-4 p-4"
                 style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div class="d-flex align-items-center gap-2 mb-4 pb-2" style="border-bottom:2px solid #f3f4f6;">
                <span style="background:#0369a1;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;font-weight:700;flex-shrink:0;">
                  <i class="bi bi-person-workspace"></i>
                </span>
                <span style="font-size:1.05rem;font-weight:700;color:#0369a1;">Supervisor</span>
              </div>

              <!-- Hidden fields submitted to server -->
              <input type="hidden" name="supervisorId"   id="supervisorIdHidden"   value="<%= prefSupervisorId   != null ? prefSupervisorId   : "" %>">
              <input type="hidden" name="supervisorName" id="supervisorNameHidden" value="<%= prefSupervisorName != null ? prefSupervisorName : "" %>">

              <div class="row g-3">
                <!-- Searchable combobox -->
                <div class="col-md-6" style="position:relative;">
                  <label class="form-label fw-semibold" style="color:#374151;">Select Supervisor <span class="text-danger">*</span></label>
                  <div style="position:relative;">
                    <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;"><i class="bi bi-search"></i></span>
                    <input type="text" id="svSearch" autocomplete="off" class="form-control"
                           style="border-radius:10px;border-color:#e5e7eb;padding-left:36px;"
                           placeholder="Type to search supervisor name..."
                           value="<%
                             if (prefSupervisorId != null && !prefSupervisorName.isEmpty()) {
                               out.print(prefSupervisorName);
                             } else if (prefSupervisorId == null && !prefSupervisorName.isEmpty()) {
                               out.print(prefSupervisorName);
                             }
                           %>">
                    <ul id="svDropdown"
                        style="display:none;position:absolute;z-index:9999;width:100%;max-height:220px;overflow-y:auto;
                               background:#fff;border:1px solid #e5e7eb;border-radius:10px;
                               box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;list-style:none;"></ul>
                  </div>
                  <div class="form-text text-muted">Only active academic staff members can be selected as supervisor.
                    <span id="svManualHint" style="display:none;"> &mdash; No match? <a href="#" id="svManualLink" style="color:#0369a1;">Enter name manually</a>.</span>
                  </div>
                </div>

                <!-- Selected badge -->
                <div class="col-md-6 d-flex align-items-center" id="svSelectedBadgeCol" style="<%= prefSupervisorId != null ? "" : "display:none!important;" %>">
                  <div id="svSelectedBadge"
                       style="background:#e0f2fe;border:1px solid #bae6fd;border-radius:10px;padding:10px 16px;
                              display:flex;align-items:center;gap:10px;width:100%;">
                    <i class="bi bi-person-check-fill" style="color:#0369a1;font-size:1.2rem;"></i>
                    <div style="flex:1;min-width:0;">
                      <div id="svBadgeName" style="font-weight:600;color:#0c4a6e;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                        <%= prefSupervisorName %>
                      </div>
                      <div style="font-size:0.8rem;color:#0369a1;">Supervisor selected</div>
                    </div>
                    <button type="button" onclick="svClear()" style="background:none;border:none;color:#ef4444;font-size:1.1rem;padding:0;cursor:pointer;" title="Clear"><i class="bi bi-x-circle-fill"></i></button>
                  </div>
                </div>

                <!-- Manual name input (shown when no staff match) -->
                <div class="col-md-6" id="supervisorManualDiv" style="display:none;">
                  <label class="form-label fw-semibold" style="color:#374151;">Supervisor Name <span style="font-size:0.8rem;color:#9ca3af;">(not in staff list)</span></label>
                  <input type="text" id="supervisorNameInput" class="form-control"
                         style="border-radius:10px;border-color:#e5e7eb;"
                         placeholder="e.g. Prof. Dr. Ahmad"
                         value="<%= prefSupervisorId == null ? prefSupervisorName : "" %>"
                         oninput="svManualInput(this)">
                  <div class="form-text text-muted">Used when supervisor has no account in the system yet.</div>
                </div>
              </div>
            </div>

            <!-- â”€â”€ Co-Supervisors â”€â”€ -->
            <div class="w-100 mb-4 p-4"
                 style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <div class="d-flex align-items-center gap-2 mb-3 pb-2" style="border-bottom:2px solid #f3f4f6;">
                <span style="background:#7c3aed;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;font-weight:700;flex-shrink:0;">
                  <i class="bi bi-people-fill"></i>
                </span>
                <span style="font-size:1.05rem;font-weight:700;color:#7c3aed;">Co-Supervisors</span>
                <span style="font-size:0.85rem;color:#9ca3af;margin-left:4px;">(optional)</span>
              </div>

              <!-- Existing co-sv tags (pre-loaded for edit mode) -->
              <div id="cosvTagsContainer" class="d-flex flex-wrap gap-2 mb-3">
                <% int cosvIdx = 0; for (CoSupervisor cs : prefCoSups) { if (cs == null) continue;
                     String csType = cs.getCosvType() != null ? cs.getCosvType() : "external";
                     String csName = cs.getName() != null ? cs.getName() : "";
                     String csAff  = cs.getDisplayAffiliation() != null ? cs.getDisplayAffiliation() : "";
                %>
                <div class="cosv-tag <%= "internal".equals(csType) ? "internal" : "" %>" id="cosvTag_<%= cosvIdx %>">
                  <% if ("internal".equals(csType)) { %>
                  <i class="bi bi-person-badge-fill" style="font-size:0.85rem;"></i>
                  <% } else { %>
                  <i class="bi bi-globe2" style="font-size:0.85rem;"></i>
                  <% } %>
                  <span><strong><%= csName %></strong><% if (!csAff.isEmpty()) { %> &mdash; <span style="font-size:0.82rem;opacity:0.8;"><%= csAff %></span><% } %></span>
                  <!-- Hidden inputs for form submission -->
                  <input type="hidden" name="cosv_type_<%= cosvIdx %>"        value="<%= csType %>">
                  <input type="hidden" name="cosv_name_<%= cosvIdx %>"        value="<%= csName %>">
                  <input type="hidden" name="cosv_internal_id_<%= cosvIdx %>" value="<%= cs.getInternalStaffId() != null ? cs.getInternalStaffId() : "" %>">
                  <input type="hidden" name="cosv_university_<%= cosvIdx %>"  value="<%= cs.getUniversityName() != null ? cs.getUniversityName() : "" %>">
                  <input type="hidden" name="cosv_faculty_<%= cosvIdx %>"     value="<%= cs.getFaculty() != null ? cs.getFaculty() : "" %>">
                  <input type="hidden" name="cosv_programme_<%= cosvIdx %>"   value="<%= cs.getProgramme() != null ? cs.getProgramme() : "" %>">
                  <input type="hidden" name="cosv_country_<%= cosvIdx %>"     value="<%= cs.getCountry() != null ? cs.getCountry() : "" %>">
                  <input type="hidden" name="cosv_email_<%= cosvIdx %>"       value="<%= cs.getEmail() != null ? cs.getEmail() : "" %>">
                  <button type="button" class="btn-close btn-close-sm" style="font-size:0.55rem;"
                          onclick="removeCosvTag(<%= cosvIdx %>)" aria-label="Remove"></button>
                </div>
                <% cosvIdx++; } %>
              </div>

              <!-- Add co-sv inline form (collapsed by default) -->
              <button type="button" class="btn btn-outline-secondary btn-sm d-inline-flex align-items-center gap-1"
                      style="border-radius:8px;" onclick="toggleCosvForm()">
                <i class="bi bi-plus-circle" id="cosvToggleIcon"></i>
                <span id="cosvToggleLabel">Add Co-Supervisor</span>
              </button>

              <div id="cosvAddForm" class="cosv-add-form mt-3" style="display:none;">
                <div class="row g-3">
                  <!-- Type selector -->
                  <div class="col-12">
                    <label class="form-label fw-semibold" style="color:#374151;font-size:0.92rem;">Type</label>
                    <div class="d-flex gap-4">
                      <div class="form-check">
                        <input class="form-check-input" type="radio" name="_cosvTypeRadio" id="cosvTypeInternal"
                               value="internal" onchange="onCosvTypeChange('internal')">
                        <label class="form-check-label" for="cosvTypeInternal">
                          <i class="bi bi-person-badge-fill text-primary me-1"></i> Internal (in system)
                        </label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="radio" name="_cosvTypeRadio" id="cosvTypeExternal"
                               value="external" onchange="onCosvTypeChange('external')" checked>
                        <label class="form-check-label" for="cosvTypeExternal">
                          <i class="bi bi-globe2 text-success me-1"></i> External / Other Faculty
                        </label>
                      </div>
                    </div>
                  </div>

                  <!-- Internal: searchable staff combobox -->
                  <div id="cosvInternalDiv" class="col-md-8" style="display:none;">
                    <label class="form-label fw-semibold" style="color:#374151;font-size:0.92rem;">Select Staff</label>
                    <div style="position:relative;">
                      <span style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:#9ca3af;pointer-events:none;font-size:0.85rem;"><i class="bi bi-search"></i></span>
                      <input type="text" id="cosvStaffSearch" autocomplete="off" class="form-control"
                             style="border-radius:8px;border-color:#e5e7eb;padding-left:32px;" placeholder="-- Search academic staff --">
                      <input type="hidden" id="cosvInternalIdHidden">
                      <input type="hidden" id="cosvInternalNameHidden">
                      <ul id="cosvStaffDropdown" style="display:none;position:absolute;z-index:300;width:100%;
                             background:#fff;border:1px solid #d1d5db;border-radius:8px;
                             box-shadow:0 4px 16px rgba(0,0,0,0.10);padding:4px 0;margin:2px 0 0;
                             list-style:none;max-height:200px;overflow-y:auto;"></ul>
                    </div>
                  </div>

                  <!-- External fields -->
                  <div id="cosvExternalDiv" class="col-12">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <label class="form-label fw-semibold" style="color:#374151;font-size:0.92rem;">Full Name <span class="text-danger">*</span></label>
                        <input type="text" id="cosvExtName" class="form-control" style="border-radius:8px;border-color:#e5e7eb;"
                               placeholder="e.g. Prof. Dr. James Smith">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-semibold" style="color:#374151;font-size:0.92rem;">Email</label>
                        <input type="email" id="cosvExtEmail" class="form-control" style="border-radius:8px;border-color:#e5e7eb;"
                               placeholder="e.g. james@uni.edu">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-semibold" style="color:#374151;font-size:0.92rem;">University <span class="text-danger">*</span></label>
                        <input type="text" id="cosvExtUniversity" class="form-control" style="border-radius:8px;border-color:#e5e7eb;"
                               placeholder="e.g. Universiti Malaya">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-semibold" style="color:#374151;font-size:0.92rem;">Faculty / Department</label>
                        <input type="text" id="cosvExtFaculty" class="form-control" style="border-radius:8px;border-color:#e5e7eb;"
                               placeholder="e.g. Faculty of Engineering">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-semibold" style="color:#374151;font-size:0.92rem;">Programme</label>
                        <input type="text" id="cosvExtProgramme" class="form-control" style="border-radius:8px;border-color:#e5e7eb;"
                               placeholder="e.g. PhD Computer Science">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-semibold" style="color:#374151;font-size:0.92rem;">Country</label>
                        <input type="text" id="cosvExtCountry" class="form-control" style="border-radius:8px;border-color:#e5e7eb;"
                               placeholder="e.g. Malaysia">
                      </div>
                    </div>
                  </div>

                  <!-- Add / Cancel buttons -->
                  <div class="col-12 d-flex gap-2 pt-1">
                    <button type="button" class="btn btn-sm ea-btn-primary-action d-inline-flex align-items-center gap-1"
                            style="border-radius:8px;" onclick="addCosvEntry()">
                      <i class="bi bi-plus-lg"></i> Add
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-secondary d-inline-flex align-items-center gap-1"
                            style="border-radius:8px;" onclick="toggleCosvForm()">
                      Cancel
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Form Actions -->
            <div class="d-flex gap-3 justify-content-end mb-5">
              <a href="<%= request.getContextPath() %>/CandidateListServlet" class="btn-ea-back">
                Cancel
              </a>
              <button type="submit" class="ea-btn-primary-action d-inline-flex align-items-center gap-2"
                      style="border-radius:10px;">
                <i class="bi bi-floppy-fill"></i>
                <%= isEdit ? "Update Candidate" : "Save Candidate" %>
              </button>
            </div>
          </form>

        </div>
      </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    // â”€â”€ Staff data for internal co-sv picker â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    var staffData = <%= staffJsonSb.toString() %>;

    // â”€â”€ Supervisor dropdown logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    function onSupervisorChange(sel) { /* replaced by combobox below */ }

    // â"€â"€ Supervisor searchable combobox â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    (function() {
      var svSearch     = document.getElementById('svSearch');
      var svDropdown   = document.getElementById('svDropdown');
      var svIdHidden   = document.getElementById('supervisorIdHidden');
      var svNameHidden = document.getElementById('supervisorNameHidden');
      var svBadgeCol   = document.getElementById('svSelectedBadgeCol');
      var svBadgeName  = document.getElementById('svBadgeName');
      var svManualDiv  = document.getElementById('supervisorManualDiv');
      var svManualInp  = document.getElementById('supervisorNameInput');
      var svManualHint = document.getElementById('svManualHint');
      var svManualLink = document.getElementById('svManualLink');

      function showBadge(id, name) {
        svIdHidden.value   = id;
        svNameHidden.value = name;
        svBadgeName.textContent = name;
        svBadgeCol.style.display = '';
        svManualDiv.style.display = 'none';
        svManualHint.style.display = 'none';
        svSearch.value = name;
        svSearch.style.borderColor = '#86efac';
        svDropdown.style.display = 'none';
      }

      window.svClear = function() {
        svIdHidden.value   = '';
        svNameHidden.value = '';
        svSearch.value     = '';
        svSearch.style.borderColor = '';
        svBadgeCol.style.display   = 'none';
        svManualDiv.style.display  = 'none';
        svManualHint.style.display = 'none';
        svSearch.focus();
      };

      window.svManualInput = function(inp) {
        svIdHidden.value   = '';
        svNameHidden.value = inp.value.trim();
      };

      if (svManualLink) {
        svManualLink.addEventListener('click', function(e) {
          e.preventDefault();
          svManualDiv.style.display = '';
          svManualHint.style.display = 'none';
          svManualInp.focus();
        });
      }

      function renderDropdown(q) {
        var lower = q.toLowerCase();
        var matches = staffData.filter(function(s) {
          return s.name.toLowerCase().indexOf(lower) !== -1 ||
                 (s.dept && s.dept.toLowerCase().indexOf(lower) !== -1);
        });
        svDropdown.innerHTML = '';
        if (!matches.length) {
          svManualHint.style.display = '';
          svDropdown.style.display = 'none';
          return;
        }
        svManualHint.style.display = 'none';
        matches.slice(0, 40).forEach(function(s) {
          var li = document.createElement('li');
          li.style.cssText = 'padding:9px 14px;cursor:pointer;font-size:0.93rem;border-bottom:1px solid #f3f4f6;';
          li.innerHTML = '<span style="font-weight:600;color:#0c4a6e;">' + s.name + '</span>' +
                         (s.dept ? ' <span style="font-size:0.8rem;color:#6b7280;">&mdash; ' + s.dept + '</span>' : '');
          li.addEventListener('mousedown', function(e) { e.preventDefault(); showBadge(s.id, s.name); });
          li.addEventListener('mouseover',  function() { this.style.background = '#f0f9ff'; });
          li.addEventListener('mouseout',   function() { this.style.background = ''; });
          svDropdown.appendChild(li);
        });
        svDropdown.style.display = 'block';
      }

      svSearch.addEventListener('input', function() {
        var q = this.value.trim();
        if (!q) {
          svIdHidden.value = ''; svNameHidden.value = '';
          svBadgeCol.style.display = 'none';
          svDropdown.style.display = 'none';
          svManualHint.style.display = 'none';
          return;
        }
        renderDropdown(q);
      });

      svSearch.addEventListener('focus', function() {
        if (this.value.trim().length >= 1) renderDropdown(this.value.trim());
      });

      document.addEventListener('click', function(e) {
        if (!svSearch.contains(e.target) && !svDropdown.contains(e.target))
          svDropdown.style.display = 'none';
      });

      if (svIdHidden.value) {
        svBadgeCol.style.display = '';
        svSearch.style.borderColor = '#86efac';
      }
    })();

    // â”€â”€ Co-supervisor logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    var cosvCount = <%= prefCoSups != null ? prefCoSups.size() : 0 %>;
    document.getElementById('cosvCount').value = cosvCount;

    function toggleCosvForm() {
      var form = document.getElementById('cosvAddForm');
      var icon  = document.getElementById('cosvToggleIcon');
      var label = document.getElementById('cosvToggleLabel');
      if (form.style.display === 'none') {
        form.style.display = '';
        icon.className  = 'bi bi-dash-circle';
        label.textContent = 'Cancel';
        // Reset form fields
        document.getElementById('cosvTypeExternal').checked = true;
        onCosvTypeChange('external');
        clearCosvForm();
      } else {
        form.style.display = 'none';
        icon.className  = 'bi bi-plus-circle';
        label.textContent = 'Add Co-Supervisor';
      }
    }

    function onCosvTypeChange(type) {
      document.getElementById('cosvInternalDiv').style.display  = (type === 'internal') ? '' : 'none';
      document.getElementById('cosvExternalDiv').style.display  = (type === 'external') ? '' : 'none';
    }

    function clearCosvForm() {
      document.getElementById('cosvStaffSearch').value      = '';
      document.getElementById('cosvInternalIdHidden').value   = '';
      document.getElementById('cosvInternalNameHidden').value = '';
      document.getElementById('cosvExtName').value        = '';
      document.getElementById('cosvExtEmail').value       = '';
      document.getElementById('cosvExtUniversity').value  = '';
      document.getElementById('cosvExtFaculty').value     = '';
      document.getElementById('cosvExtProgramme').value   = '';
      document.getElementById('cosvExtCountry').value     = '';
    }

    function addCosvEntry() {
      var isInternal = document.getElementById('cosvTypeInternal').checked;
      var idx = cosvCount;

      var name = '', staffId = '', university = '', faculty = '', programme = '', country = '', email = '';

      if (isInternal) {
        staffId = document.getElementById('cosvInternalIdHidden').value;
        name    = document.getElementById('cosvInternalNameHidden').value;
        if (!staffId) { alert('Please select a staff member.'); return; }
      } else {
        name       = document.getElementById('cosvExtName').value.trim();
        university = document.getElementById('cosvExtUniversity').value.trim();
        faculty    = document.getElementById('cosvExtFaculty').value.trim();
        programme  = document.getElementById('cosvExtProgramme').value.trim();
        country    = document.getElementById('cosvExtCountry').value.trim();
        email      = document.getElementById('cosvExtEmail').value.trim();
        if (!name) { alert('Please enter the co-supervisor name.'); return; }
        if (!university) { alert('Please enter the university name for external co-supervisor.'); return; }
      }

      var type = isInternal ? 'internal' : 'external';

      // Build tag HTML
      var tag = document.createElement('div');
      tag.className = 'cosv-tag' + (isInternal ? ' internal' : '');
      tag.id = 'cosvTag_' + idx;

      var iconHtml = isInternal
        ? '<i class="bi bi-person-badge-fill" style="font-size:0.85rem;"></i>'
        : '<i class="bi bi-globe2" style="font-size:0.85rem;"></i>';

      var affLine = '';
      if (isInternal) {
        // find dept from staffData
        for (var i = 0; i < staffData.length; i++) {
          if (String(staffData[i].id) === String(staffId)) {
            if (staffData[i].dept) affLine = staffData[i].dept;
            break;
          }
        }
      } else {
        affLine = university + (faculty ? ', ' + faculty : '');
      }

      var nameSpan = '<strong>' + escHtml(name) + '</strong>'
        + (affLine ? ' &mdash; <span style="font-size:0.82rem;opacity:0.8;">' + escHtml(affLine) + '</span>' : '');

      tag.innerHTML = iconHtml + '<span>' + nameSpan + '</span>'
        + '<input type="hidden" name="cosv_type_' + idx + '" value="' + escHtml(type) + '">'
        + '<input type="hidden" name="cosv_name_' + idx + '" value="' + escHtml(name) + '">'
        + '<input type="hidden" name="cosv_internal_id_' + idx + '" value="' + escHtml(staffId) + '">'
        + '<input type="hidden" name="cosv_university_' + idx + '" value="' + escHtml(university) + '">'
        + '<input type="hidden" name="cosv_faculty_' + idx + '" value="' + escHtml(faculty) + '">'
        + '<input type="hidden" name="cosv_programme_' + idx + '" value="' + escHtml(programme) + '">'
        + '<input type="hidden" name="cosv_country_' + idx + '" value="' + escHtml(country) + '">'
        + '<input type="hidden" name="cosv_email_' + idx + '" value="' + escHtml(email) + '">'
        + '<button type="button" class="btn-close btn-close-sm" style="font-size:0.55rem;" onclick="removeCosvTag(' + idx + ')" aria-label="Remove"></button>';

      document.getElementById('cosvTagsContainer').appendChild(tag);
      cosvCount++;
      document.getElementById('cosvCount').value = cosvCount;

      clearCosvForm();
      // Keep form open for adding more
    }

    function removeCosvTag(idx) {
      var tag = document.getElementById('cosvTag_' + idx);
      if (tag) tag.remove();
      // Renumber: collect all remaining tags and re-index hidden inputs
      var container = document.getElementById('cosvTagsContainer');
      var tags = container.querySelectorAll('.cosv-tag');
      cosvCount = 0;
      tags.forEach(function(t) {
        var inputs = t.querySelectorAll('input[type=hidden]');
        inputs.forEach(function(inp) {
          inp.name = inp.name.replace(/_\d+$/, '_' + cosvCount);
        });
        t.id = 'cosvTag_' + cosvCount;
        cosvCount++;
      });
      document.getElementById('cosvCount').value = cosvCount;
    }

    function escHtml(str) {
      if (!str) return '';
      return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    // ── Nationality type-search ───────────────────────────────────────────
    (function() {
      var natSearch   = document.getElementById('natSearch');
      var natDropdown = document.getElementById('natDropdown');
      if (!natSearch) return;
      var natData = [<% for (int ni = 0; ni < nationalities.size(); ni++) { out.print((ni>0?",":"") + "\"" + nationalities.get(ni).replace("\"","\\\"") + "\""); } %>];
      function renderNat(q) {
        var lower = q.toLowerCase();
        var matches = q.length === 0 ? natData : natData.filter(function(n){ return n.toLowerCase().indexOf(lower) !== -1; });
        natDropdown.innerHTML = '';
        if (!matches.length) { natDropdown.style.display = 'none'; return; }
        matches.forEach(function(n) {
          var li = document.createElement('li');
          li.style.cssText = 'padding:8px 12px;cursor:pointer;font-size:0.91rem;border-bottom:1px solid #f3f4f6;';
          li.textContent = n;
          li.addEventListener('mousedown', function(e){ e.preventDefault(); natSearch.value = n; natDropdown.style.display = 'none'; });
          li.addEventListener('mouseover', function(){ this.style.background = '#f0f9ff'; });
          li.addEventListener('mouseout',  function(){ this.style.background = ''; });
          natDropdown.appendChild(li);
        });
        natDropdown.style.display = 'block';
      }
      natSearch.addEventListener('input', function(){ renderNat(this.value.trim()); });
      natSearch.addEventListener('focus', function(){ renderNat(this.value.trim()); });
      document.addEventListener('click', function(e){
        if (!natSearch.contains(e.target) && !natDropdown.contains(e.target)) natDropdown.style.display = 'none';
      });
    })();

    // ── Cascading Level → Programme dropdown ─────────────────────────────
    var programData = <%= programJsonSb.toString() %>;
    var prefProgId  = <%= prefProgramId != null ? prefProgramId : "null" %>;

    // Degree Level combobox
    (function() {
      var degreeLevelData = [
        {id:'PhD',    name:'Doctor of Philosophy (PhD)'},
        {id:'Master', name:'Master'}
      ];
      var lvlSearch   = document.getElementById('degreeLevelSearch');
      var lvlHidden   = document.getElementById('degreeLevelValue');
      var lvlDropdown = document.getElementById('degreeLevelDropdown');
      if (!lvlSearch) return;

      function renderLvl(q) {
        var lower = q ? q.toLowerCase() : '';
        var matches = lower ? degreeLevelData.filter(function(d){ return d.name.toLowerCase().indexOf(lower) !== -1; }) : degreeLevelData;
        lvlDropdown.innerHTML = '';
        if (!matches.length) { lvlDropdown.style.display = 'none'; return; }
        matches.forEach(function(d) {
          var li = document.createElement('li');
          li.style.cssText = 'padding:10px 14px;cursor:pointer;font-size:0.92rem;border-bottom:1px solid #f3f4f6;';
          li.textContent = d.name;
          li.addEventListener('mousedown', function(e) {
            e.preventDefault();
            lvlSearch.value = d.name;
            lvlHidden.value = d.id;
            lvlDropdown.style.display = 'none';
            filterPrograms(d.id, null);
            updateMatricPlaceholder(d.id);
          });
          li.addEventListener('mouseover', function(){ this.style.background = '#f0f9ff'; });
          li.addEventListener('mouseout',  function(){ this.style.background = ''; });
          lvlDropdown.appendChild(li);
        });
        lvlDropdown.style.display = 'block';
      }

      lvlSearch.addEventListener('input', function(){ renderLvl(this.value.trim()); });
      lvlSearch.addEventListener('focus', function(){ renderLvl(this.value.trim()); });
      lvlSearch.addEventListener('blur', function(){
        setTimeout(function() {
          lvlDropdown.style.display = 'none';
          var matched = degreeLevelData.filter(function(d){ return d.name === lvlSearch.value; })[0];
          if (!matched) { lvlSearch.value = lvlHidden.value ? (degreeLevelData.filter(function(d){ return d.id === lvlHidden.value; })[0] || {name:''}).name : ''; }
        }, 200);
      });
      document.addEventListener('click', function(e){
        if (!lvlSearch.contains(e.target) && !lvlDropdown.contains(e.target)) lvlDropdown.style.display = 'none';
      });

      // Pre-fill on load (edit mode)
      if (lvlHidden.value) {
        var entry = degreeLevelData.filter(function(d){ return d.id === lvlHidden.value; })[0];
        if (entry) lvlSearch.value = entry.name;
      }
    })();

    // Programme combobox
    var currentProgItems = [];
    var progSearch   = document.getElementById('progSearch');
    var progIdHidden = document.getElementById('progIdHidden');
    var progDropdown = document.getElementById('progDropdown');

    function renderProgDropdown(q) {
      var lower = q ? q.toLowerCase() : '';
      var matches = lower ? currentProgItems.filter(function(p){ return p.name.toLowerCase().indexOf(lower) !== -1; }) : currentProgItems;
      progDropdown.innerHTML = '';
      if (!matches.length) { progDropdown.style.display = 'none'; return; }
      matches.forEach(function(p) {
        var li = document.createElement('li');
        li.style.cssText = 'padding:10px 14px;cursor:pointer;font-size:0.92rem;border-bottom:1px solid #f3f4f6;';
        li.textContent = p.name;
        li.addEventListener('mousedown', function(e) {
          e.preventDefault();
          progSearch.value = p.name;
          progIdHidden.value = p.id;
          progDropdown.style.display = 'none';
        });
        li.addEventListener('mouseover', function(){ this.style.background = '#f0f9ff'; });
        li.addEventListener('mouseout',  function(){ this.style.background = ''; });
        progDropdown.appendChild(li);
      });
      progDropdown.style.display = 'block';
    }

    if (progSearch) {
      progSearch.addEventListener('input', function(){ if (!progSearch.disabled) renderProgDropdown(this.value.trim()); });
      progSearch.addEventListener('focus', function(){ if (!progSearch.disabled) renderProgDropdown(this.value.trim()); });
      progSearch.addEventListener('blur', function(){
        setTimeout(function() {
          progDropdown.style.display = 'none';
          if (progSearch.value && currentProgItems.length && !currentProgItems.some(function(p){ return p.name === progSearch.value; })) {
            progSearch.value = ''; progIdHidden.value = '';
          }
        }, 200);
      });
      document.addEventListener('click', function(e){
        if (!progSearch.contains(e.target) && !progDropdown.contains(e.target)) progDropdown.style.display = 'none';
      });
    }

    function filterPrograms(level, keepId) {
      var hasLevelData = programData.length > 0 && programData.some(function(p){ return p.level && p.level.length > 0; });
      var matched = programData.filter(function(p) {
        if (!level) return false;
        if (!hasLevelData) return true;
        if (!p.level) return false;
        return p.level === level;
      });
      currentProgItems = matched;
      if (!level) {
        progSearch.placeholder = '-- Select Level first --';
        progSearch.disabled = true;
        progSearch.value = ''; progIdHidden.value = '';
        return;
      }
      progSearch.disabled = false;
      progSearch.placeholder = matched.length ? '-- Select Programme --' : '-- No programmes for this level --';
      if (keepId !== null && keepId !== undefined) {
        var found = matched.filter(function(p){ return String(p.id) === String(keepId); })[0];
        if (found) { progSearch.value = found.name; progIdHidden.value = found.id; }
        else { progSearch.value = ''; progIdHidden.value = ''; }
      } else {
        progSearch.value = ''; progIdHidden.value = '';
      }
    }

    function updateMatricPlaceholder(level) {
      var matricInput = document.getElementById('studentIdInput');
      if (matricInput) matricInput.placeholder = 'e.g. P19001';
    }

    // Initialise on page load
    (function() {
      var lvlHidden = document.getElementById('degreeLevelValue');
      if (lvlHidden && lvlHidden.value) {
        filterPrograms(lvlHidden.value, prefProgId);
        updateMatricPlaceholder(lvlHidden.value);
      }
    })();

    // COSV Internal Staff combobox
    (function() {
      var cosvSearch    = document.getElementById('cosvStaffSearch');
      var cosvIdHid     = document.getElementById('cosvInternalIdHidden');
      var cosvNameHid   = document.getElementById('cosvInternalNameHidden');
      var cosvDropdown  = document.getElementById('cosvStaffDropdown');
      if (!cosvSearch) return;

      function renderCosvDropdown(q) {
        var lower = q ? q.toLowerCase() : '';
        var matches = lower ? staffData.filter(function(s){
          return s.name.toLowerCase().indexOf(lower) !== -1 || (s.dept && s.dept.toLowerCase().indexOf(lower) !== -1);
        }) : staffData;
        cosvDropdown.innerHTML = '';
        if (!matches.length) { cosvDropdown.style.display = 'none'; return; }
        matches.forEach(function(s) {
          var li = document.createElement('li');
          li.style.cssText = 'padding:8px 12px;cursor:pointer;font-size:0.91rem;border-bottom:1px solid #f3f4f6;';
          li.textContent = s.name + (s.dept ? ' (' + s.dept + ')' : '');
          li.addEventListener('mousedown', function(e) {
            e.preventDefault();
            cosvSearch.value  = s.name + (s.dept ? ' (' + s.dept + ')' : '');
            cosvIdHid.value   = s.id;
            cosvNameHid.value = s.name;
            cosvDropdown.style.display = 'none';
          });
          li.addEventListener('mouseover', function(){ this.style.background = '#f0f9ff'; });
          li.addEventListener('mouseout',  function(){ this.style.background = ''; });
          cosvDropdown.appendChild(li);
        });
        cosvDropdown.style.display = 'block';
      }

      cosvSearch.addEventListener('input', function(){ renderCosvDropdown(this.value.trim()); });
      cosvSearch.addEventListener('focus', function(){ renderCosvDropdown(this.value.trim()); });
      cosvSearch.addEventListener('blur', function(){
        setTimeout(function(){ cosvDropdown.style.display = 'none'; }, 200);
      });
      document.addEventListener('click', function(e){
        if (!cosvSearch.contains(e.target) && !cosvDropdown.contains(e.target)) cosvDropdown.style.display = 'none';
      });
    })();
    </script>
  </body>
</html>
