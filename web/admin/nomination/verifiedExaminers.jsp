<%--
  Admin: searchable directory of verified examiners with multi-dimensional filters
  (specialization, expertise, division, area) powered by VerifiedExaminerServlet.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
  String fullName = (String) session.getAttribute("full_name"); if (fullName == null) fullName = "Admin";
  List<model.ExternalExaminer> ex = (List<model.ExternalExaminer>) request.getAttribute("examiners");
  List<Map<String,Object>> specs  = (List<Map<String,Object>>) request.getAttribute("specializations");
  List<Map<String,Object>> exps   = (List<Map<String,Object>>) request.getAttribute("expertises");
  List<Map<String,Object>> divs   = (List<Map<String,Object>>) request.getAttribute("divisions");
  List<Map<String,Object>> arList = (List<Map<String,Object>>) request.getAttribute("areas");
  if (ex     == null) ex     = new java.util.ArrayList<>();
  if (specs  == null) specs  = new java.util.ArrayList<>();
  if (exps   == null) exps   = new java.util.ArrayList<>();
  if (divs   == null) divs   = new java.util.ArrayList<>();
  if (arList == null) arList = new java.util.ArrayList<>();
  String q      = request.getParameter("q")        != null ? request.getParameter("q").trim()        : "";
  String specId = request.getParameter("spec_id")  != null ? request.getParameter("spec_id").trim()  : "";
  String expId  = request.getParameter("exp_id")   != null ? request.getParameter("exp_id").trim()   : "";
  String divId  = request.getParameter("div_id")   != null ? request.getParameter("div_id").trim()   : "";
  String areaId = request.getParameter("area_id")  != null ? request.getParameter("area_id").trim()  : "";
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Verified Examiners - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  </head>
  <body class="admin">

    <jsp:include page="/includes/topbar.jsp" />

    <div class="layout ea-layout">
      <% request.setAttribute("activeSection", "examiner"); request.setAttribute("activeSubSection", "verifiedExaminers"); %>
      <jsp:include page="/admin/sidebar.jsp" />

      <main class="content ea-content" style="max-width:none;">
        <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

          <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
            <div>
              <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Verified Examiners</h1>
              <div style="font-size:1rem;color:#6b7280;">Examiners whose nominations have been verified and are eligible for appointment</div>
            </div>
          </div>

          <!-- Search & Filter -->
          <div class="w-100 mb-4 p-3" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <form class="row g-2 align-items-center" method="GET" action="<%= request.getContextPath() %>/VerifiedExaminerServlet">
              <div class="col-lg-4 col-md-12">
                <div class="input-group" style="border:1.5px solid #e5e7eb;border-radius:10px;overflow:hidden;">
                  <span class="input-group-text bg-transparent border-0"><i class="bi bi-search text-muted"></i></span>
                  <input class="form-control border-0 ps-0" name="q" value="<%= q %>" placeholder="Search by name or university..." style="font-size:0.97rem;box-shadow:none;">
                </div>
              </div>
              <div class="col-lg-2 col-md-6">
                <select name="spec_id" class="form-select" style="border-radius:10px;border-color:#e5e7eb;font-size:0.93rem;">
                  <option value="">All Specializations</option>
                  <% for (Map<String,Object> sp : specs) { %>
                  <option value="<%= sp.get("id") %>" <%= specId.equals(String.valueOf(sp.get("id"))) ? "selected" : "" %>><%= sp.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-lg-2 col-md-6">
                <select name="exp_id" class="form-select" style="border-radius:10px;border-color:#e5e7eb;font-size:0.93rem;">
                  <option value="">All Expertise</option>
                  <% for (Map<String,Object> ep : exps) { %>
                  <option value="<%= ep.get("id") %>" <%= expId.equals(String.valueOf(ep.get("id"))) ? "selected" : "" %>><%= ep.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-lg-2 col-md-6">
                <select name="div_id" class="form-select" style="border-radius:10px;border-color:#e5e7eb;font-size:0.93rem;">
                  <option value="">All Divisions</option>
                  <% for (Map<String,Object> dv : divs) { %>
                  <option value="<%= dv.get("id") %>" <%= divId.equals(String.valueOf(dv.get("id"))) ? "selected" : "" %>><%= dv.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-lg-1 col-md-6">
                <select name="area_id" class="form-select" style="border-radius:10px;border-color:#e5e7eb;font-size:0.93rem;">
                  <option value="">All Areas</option>
                  <% for (Map<String,Object> ar : arList) { %>
                  <option value="<%= ar.get("id") %>" <%= areaId.equals(String.valueOf(ar.get("id"))) ? "selected" : "" %>><%= ar.get("name") %></option>
                  <% } %>
                </select>
              </div>
              <div class="col-lg-1 col-md-12 d-flex gap-2">
                <button type="submit" class="ea-btn-icon w-100" title="Search"><i class="bi bi-search"></i></button>
                <% if (!q.isEmpty() || !specId.isEmpty() || !expId.isEmpty() || !divId.isEmpty() || !areaId.isEmpty()) { %>
                <a href="<%= request.getContextPath() %>/VerifiedExaminerServlet" class="ea-btn-icon w-100 text-decoration-none text-center" style="display:inline-flex;align-items:center;justify-content:center;" title="Clear"><i class="bi bi-x-lg"></i></a>
                <% } %>
              </div>
            </form>
          </div>

          <!-- Examiners Table -->
          <div class="w-100 mb-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
            <div class="d-flex align-items-center px-4 py-3" style="border-bottom:1px solid #f3f4f6;">
              <i class="bi bi-patch-check me-2" style="color:#0f766e;font-size:1.1rem;"></i>
              <span class="fw-semibold" style="font-size:1.05rem;">Verified Examiners (<%= ex.size() %>)</span>
            </div>
            <div class="table-responsive">
              <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.97rem;">
                <thead>
                  <tr>
                    <th>Examiner Name</th>
                    <th>University / Organisation</th>
                    <th>Specialization</th>
                    <th>Expertise</th>
                    <th>Division / Group</th>
                    <th>Area</th>
                    <th>Country</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <% if (ex.isEmpty()) { %>
                  <tr><td colspan="8" class="text-center py-5 text-muted"><i class="bi bi-patch-check d-block mb-2" style="font-size:2rem;color:#d1d5db;"></i>No verified examiners found.</td></tr>
                  <% } else { for (model.ExternalExaminer e : ex) {
                       String specName = e.getSpecialization() != null && !e.getSpecialization().isEmpty() ? e.getSpecialization() : null;
                       String expName  = e.getQualification()  != null && !e.getQualification().isEmpty()  ? e.getQualification()  : null;
                       String divName  = e.getFaculty()        != null && !e.getFaculty().isEmpty()        ? e.getFaculty()        : null;
                       String areaName = e.getIcPassport()     != null && !e.getIcPassport().isEmpty()     ? e.getIcPassport()     : null;
                  %>
                  <tr>
                    <td><div class="fw-semibold" style="color:#111827;"><%= (e.getTitle() != null && !e.getTitle().isEmpty() ? e.getTitle() + " " : "") + (e.getName() != null ? e.getName() : "&mdash;") %></div></td>
                    <td><span style="color:#6b7280;"><%= e.getAffiliation() != null ? e.getAffiliation() : "&mdash;" %></span></td>
                    <td><span style="color:#374151;font-size:0.9rem;"><%= specName != null ? specName : "&mdash;" %></span></td>
                    <td><span style="color:#374151;font-size:0.9rem;"><%= expName  != null ? expName  : "&mdash;" %></span></td>
                    <td><span style="color:#374151;font-size:0.9rem;"><%= divName  != null ? divName  : "&mdash;" %></span></td>
                    <td><span style="color:#374151;font-size:0.9rem;"><%= areaName != null ? areaName : "&mdash;" %></span></td>
                    <td><span style="color:#6b7280;"><%= e.getCountry() != null ? e.getCountry() : "&mdash;" %></span></td>
                    <td><span style="background:#dcfce7;color:#16a34a;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">Verified</span></td>
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
  </body>
</html>
