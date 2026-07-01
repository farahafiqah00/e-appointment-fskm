<%-- Academician: form to correct an examiner profile that the current user nominated. --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null) fullName = "Academician";

    @SuppressWarnings("unchecked")
    Map<String,Object> ex = (Map<String,Object>) request.getAttribute("examiner");
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> specializations = (List<Map<String,Object>>) request.getAttribute("specializations");
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> expertiseList   = (List<Map<String,Object>>) request.getAttribute("expertiseList");
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> divisionList    = (List<Map<String,Object>>) request.getAttribute("divisionList");
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> areaList        = (List<Map<String,Object>>) request.getAttribute("areaList");
    if (specializations == null) specializations = new java.util.ArrayList<>();
    if (expertiseList   == null) expertiseList   = new java.util.ArrayList<>();
    if (divisionList    == null) divisionList    = new java.util.ArrayList<>();
    if (areaList        == null) areaList        = new java.util.ArrayList<>();

    if (ex == null) {
        response.sendRedirect(request.getContextPath() + "/academician/examiners");
        return;
    }

    String exId          = ex.get("id").toString();
    String exName        = ex.get("name")        != null ? ex.get("name").toString()        : "";
    String exAffil       = ex.get("affiliation") != null ? ex.get("affiliation").toString() : "";
    String exEmail       = ex.get("email")       != null ? ex.get("email").toString()       : "";
    String exPhone       = ex.get("phone")       != null ? ex.get("phone").toString()       : "";
    String exSpecId      = ex.get("specialization_id") != null ? ex.get("specialization_id").toString() : "";
    String exExpId       = ex.get("expertise_id")      != null ? ex.get("expertise_id").toString()      : "";
    String exDivId       = ex.get("division_id")       != null ? ex.get("division_id").toString()       : "";
    String exAreaId      = ex.get("area_id")           != null ? ex.get("area_id").toString()           : "";
    String exSpecName    = ex.get("specialization_name") != null ? ex.get("specialization_name").toString() : "";
    String exExpName     = ex.get("expertise_name")      != null ? ex.get("expertise_name").toString()      : "";
    String exDivName     = ex.get("division_name")       != null ? ex.get("division_name").toString()       : "";
    String exAreaName    = ex.get("area_name")           != null ? ex.get("area_name").toString()            : "";
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Edit Examiner - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout">
    <% request.setAttribute("activeSection", "examinerList"); %>
    <jsp:include page="/academician/sidebar.jsp" />

    <main class="content ea-content" style="max-width:none;">
      <div style="max-width:860px;margin:0 auto;">

        <!-- Page Header -->
        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Edit Examiner</h1>
            <div style="font-size:1rem;color:#6b7280;">Update information for your nominated examiner.</div>
          </div>
          <a href="<%= request.getContextPath() %>/academician/examiners"
             class="d-inline-flex align-items-center gap-2 text-decoration-none"
             style="color:#374151;font-size:0.88rem;font-weight:500;background:#f9fafb;border:1.5px solid #e5e7eb;border-radius:8px;padding:7px 14px;transition:all 0.2s;"
             onmouseover="this.style.color='#0f766e';this.style.borderColor='#0f766e';this.style.background='#f0fdf4';"
             onmouseout="this.style.color='#374151';this.style.borderColor='#e5e7eb';this.style.background='#f9fafb';">
            <i class="bi bi-arrow-left-short" style="font-size:1.1rem;"></i> Back to Examiner Directory
          </a>
        </div>

        <!-- Form -->
        <form method="POST" action="<%= request.getContextPath() %>/academician/examiner/edit">
          <input type="hidden" name="id" value="<%= exId %>">

          <!-- Personal Information -->
          <div class="w-100 mb-4 p-4"
               style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <div class="d-flex align-items-center gap-2 mb-4 pb-2" style="border-bottom:2px solid #f3f4f6;">
              <span style="background:#105e60;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;font-weight:700;flex-shrink:0;">
                <i class="bi bi-person"></i>
              </span>
              <span style="font-size:1.05rem;font-weight:700;color:#105e60;">Personal & Contact Information</span>
            </div>
            <div class="row g-4">
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="color:#374151;">Full Name <span class="text-danger">*</span></label>
                <input type="text" name="name" class="form-control" style="border-radius:10px;border-color:#e5e7eb;"
                       value="<%= exName %>" required placeholder="e.g. Prof. Dr. Ahmad Zaki">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="color:#374151;">Affiliation / University</label>
                <input type="text" name="affiliation" class="form-control" style="border-radius:10px;border-color:#e5e7eb;"
                       value="<%= exAffil %>" placeholder="e.g. Universiti Malaya">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="color:#374151;">Email</label>
                <input type="email" name="email" class="form-control" style="border-radius:10px;border-color:#e5e7eb;"
                       value="<%= exEmail %>" placeholder="e.g. examiner@university.edu">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="color:#374151;">Phone</label>
                <input type="tel" name="phone" class="form-control" style="border-radius:10px;border-color:#e5e7eb;"
                       value="<%= exPhone %>" placeholder="e.g. +60123456789">
              </div>
            </div>
          </div>

          <!-- Research Specialization -->
          <div class="w-100 mb-4 p-4"
               style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <div class="d-flex align-items-center gap-2 mb-4 pb-2" style="border-bottom:2px solid #f3f4f6;">
              <span style="background:#0369a1;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;font-weight:700;flex-shrink:0;">
                <i class="bi bi-mortarboard"></i>
              </span>
              <span style="font-size:1.05rem;font-weight:700;color:#0369a1;">Research Specialization</span>
            </div>

            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="color:#374151;">Specialization</label>
                <select name="specializationId" id="sel_spec" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                  <option value="">Select Specialization</option>
                  <% for (Map<String,Object> s : specializations) {
                       int sid = ((Number)s.get("id")).intValue();
                       boolean sel = String.valueOf(sid).equals(exSpecId); %>
                  <option value="<%= sid %>" data-name="<%= ((String)s.get("name")).replace("\"","&quot;") %>"
                          <%= sel ? "selected" : "" %>><%= s.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="color:#374151;">Expertise</label>
                <select name="expertiseId" id="sel_expertise" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                  <option value="">— select specialization first —</option>
                  <% for (Map<String,Object> e2 : expertiseList) {
                       int eid = ((Number)e2.get("id")).intValue();
                       int espec = ((Number)e2.get("specialization_id")).intValue();
                       boolean sel = String.valueOf(eid).equals(exExpId); %>
                  <option value="<%= eid %>" data-spec="<%= espec %>" <%= sel ? "selected" : "" %>><%= e2.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="color:#374151;">Division / Group</label>
                <select name="divisionId" id="sel_division" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                  <option value="">— select expertise first —</option>
                  <% for (Map<String,Object> dv : divisionList) {
                       int dvid = ((Number)dv.get("id")).intValue();
                       int dvSpec = ((Number)dv.get("specialization_id")).intValue();
                       Object dvExpObj = dv.get("expertise_id");
                       int dvExp = dvExpObj != null ? ((Number)dvExpObj).intValue() : 0;
                       boolean sel = String.valueOf(dvid).equals(exDivId); %>
                  <option value="<%= dvid %>" data-expertise="<%= dvExp %>" <%= sel ? "selected" : "" %>><%= dv.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold" style="color:#374151;">Area</label>
                <select name="areaId" id="sel_area" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                  <option value="">— select division first —</option>
                  <% for (Map<String,Object> ar : areaList) {
                       int arid = ((Number)ar.get("id")).intValue();
                       int arDiv = ar.get("division_id") != null ? ((Number)ar.get("division_id")).intValue() : 0;
                       boolean sel = String.valueOf(arid).equals(exAreaId); %>
                  <option value="<%= arid %>" data-division="<%= arDiv %>" <%= sel ? "selected" : "" %>><%= ar.get("name") %></option>
                  <% } %>
                </select>
              </div>
            </div>
          </div>

          <!-- Actions -->
          <div class="d-flex gap-3 justify-content-end mb-5">
            <a href="<%= request.getContextPath() %>/academician/examiners" class="btn-ea-back">Cancel</a>
            <button type="submit" class="ea-btn-primary-action d-inline-flex align-items-center gap-2" style="border-radius:10px;">
              <i class="bi bi-floppy-fill"></i> Save Changes
            </button>
          </div>
        </form>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
  (function () {
    var selSpec      = document.getElementById('sel_spec');
    var selExpertise = document.getElementById('sel_expertise');
    var selDivision  = document.getElementById('sel_division');
    var selArea      = document.getElementById('sel_area');

    // Snapshot all dependent options (excluding placeholder at index 0)
    var allExpertise = Array.from(selExpertise.querySelectorAll('option[data-spec]'));
    var allDivision  = Array.from(selDivision.querySelectorAll('option[data-expertise]'));
    var allArea      = Array.from(selArea.querySelectorAll('option[data-division]'));

    function rebuildSelect(select, options, filterAttr, filterValue, emptyLabel) {
      var prev = select.value;
      while (select.options.length > 1) select.remove(1);
      if (!filterValue) {
        select.options[0].text = '\u2014 select previous level first \u2014';
        select.value = ''; select.disabled = true; return;
      }
      select.options[0].text = emptyLabel;
      select.disabled = false;
      var matched = options.filter(function(o) {
        return String(o.getAttribute(filterAttr)) === String(filterValue);
      });
      matched.forEach(function(o) { select.appendChild(o.cloneNode(true)); });
      if (matched.length === 0) {
        var ng = document.createElement('option');
        ng.value = ''; ng.text = '\u2014 none available \u2014'; ng.disabled = true;
        select.appendChild(ng);
      }
      var stillValid = Array.from(select.options).some(function(o) { return o.value === prev; });
      select.value = (stillValid && prev) ? prev : '';
    }

    selSpec.addEventListener('change', function () {
      rebuildSelect(selExpertise, allExpertise, 'data-spec',      this.value, 'Select expertise');
      rebuildSelect(selDivision,  allDivision,  'data-expertise', '',         'Select division');
      rebuildSelect(selArea,      allArea,      'data-division',  '',         'Select area');
    });
    selExpertise.addEventListener('change', function () {
      rebuildSelect(selDivision, allDivision, 'data-expertise', this.value, 'Select division');
      rebuildSelect(selArea,     allArea,     'data-division',  '',         'Select area');
    });
    selDivision.addEventListener('change', function () {
      rebuildSelect(selArea, allArea, 'data-division', this.value, 'Select area');
    });

    // On load: re-trigger cascade to correctly show current values
    if (selSpec.value) {
      var currentSpec = selSpec.value;
      var currentExp  = selExpertise.value;
      var currentDiv  = selDivision.value;
      var currentArea = selArea.value;
      rebuildSelect(selExpertise, allExpertise, 'data-spec',      currentSpec, 'Select expertise');
      selExpertise.value = currentExp;
      rebuildSelect(selDivision,  allDivision,  'data-expertise', currentExp,  'Select division');
      selDivision.value = currentDiv;
      rebuildSelect(selArea,      allArea,      'data-division',  currentDiv,  'Select area');
      selArea.value = currentArea;
    }
  })();
  </script>
</body>
</html>
