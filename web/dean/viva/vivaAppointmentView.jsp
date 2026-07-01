<%-- Dean: detail view of a single viva appointment showing candidate info, panel, schedule, and letter status. --%>
<%@ page import="model.VivaAppointment, java.util.List, java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null) fullName = "Dean";
    VivaAppointment a = (VivaAppointment) request.getAttribute("appointment");

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> roleHistory = (List<Map<String,Object>>) request.getAttribute("roleHistory");
    if (roleHistory == null) roleHistory = new java.util.ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>View Appointment Details - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout">
    <% request.setAttribute("activeSection", "viva"); request.setAttribute("activeSubSection", "deanVivaAppointments"); %>
    <jsp:include page="/dean/sidebar.jsp" />

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;max-width:960px;margin:0 auto;">

        <% if (a == null) { %>
        <div class="alert alert-warning mt-4">
          Appointment not found.
          <a href="<%= request.getContextPath() %>/AppointmentListServlet">Back to list</a>
        </div>
        <% } else { %>

        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">View Appointment Details</h1>
            <div style="font-size:1rem;color:#6b7280;">Read-only view for governance reference</div>
          </div>
          <div>
            <a href="<%= request.getContextPath() %>/AppointmentListServlet" class="btn-ea-back">
              <i class="bi bi-arrow-left"></i> Back to list
            </a>
          </div>
        </div>

        <!-- Candidate Information Card -->
        <div class="w-100 mb-4 p-4"
             style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center mb-3">
            <i class="bi bi-person me-2" style="color:#0f766e;font-size:1.15rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Candidate Information</span>
          </div>
          <div class="row g-3">
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Candidate Name</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getCandidateName() != null ? a.getCandidateName() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Matric Number</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getCandidateStudentId() != null ? a.getCandidateStudentId() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Programme</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getCandidateProgram() != null ? a.getCandidateProgram() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Thesis Title</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getThesisTitle() != null ? a.getThesisTitle() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Supervisor Name</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getSupervisorName() != null ? a.getSupervisorName() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Appointment Status</div>
              <div style="margin-top:4px;">
                <% String apptSt = a.getStatus() != null ? a.getStatus() : "pending";
                   if ("scheduled".equals(apptSt)) { %>
                <span style="background:#dbeafe;color:#1d4ed8;padding:4px 14px;border-radius:20px;font-size:0.9rem;font-weight:600;">Scheduled</span>
                <% } else if ("letter_generated".equals(apptSt)) { %>
                <span style="background:#dcfce7;color:#16a34a;padding:4px 14px;border-radius:20px;font-size:0.9rem;font-weight:600;">Letter Generated</span>
                <% } else if ("deferred".equals(apptSt)) { %>
                <span style="background:#f3f4f6;color:#6b7280;padding:4px 14px;border-radius:20px;font-size:0.9rem;font-weight:600;">Deferred</span>
                <% } else if ("pending".equals(apptSt)) { %>
                <span style="background:#fff7ed;color:#c2410c;padding:4px 14px;border-radius:20px;font-size:0.9rem;font-weight:600;">Pending Schedule</span>
                <% } else { %>
                <span style="background:#f3f4f6;color:#6b7280;padding:4px 14px;border-radius:20px;font-size:0.9rem;font-weight:600;"><%= apptSt %></span>
                <% } %>
              </div>
            </div>
          </div>
        </div>

        <!-- Panel Members Card -->
        <div class="w-100 mb-4 p-4"
             style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center mb-3">
            <i class="bi bi-people me-2" style="color:#0f766e;font-size:1.15rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Decided Panel Members</span>
          </div>
          <% boolean hasPanel = a.getChairpersonName() != null || a.getRecorderName() != null
                             || a.getInternalExaminerName() != null || a.getExternalExaminerName() != null; %>
          <% if (!hasPanel) { %>
          <div class="text-muted" style="font-size:0.92rem;"><i class="bi bi-info-circle me-1"></i>No panel members assigned yet.</div>
          <% } else { %>
          <div class="row g-3">
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Chairperson</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getChairpersonName() != null ? a.getChairpersonName() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Secretary</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getRecorderName() != null ? a.getRecorderName() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">Internal Examiner</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getInternalExaminerName() != null ? a.getInternalExaminerName() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;color:#9ca3af;font-weight:600;text-transform:uppercase;letter-spacing:.04em;">External Examiner</div>
              <div style="font-size:1rem;color:#111827;margin-top:2px;"><%= a.getExternalExaminerName() != null ? a.getExternalExaminerName() : "—" %></div>
            </div>
          </div>
          <% } %>
        </div>

        <!-- Examiner Role History Card -->
        <div class="w-100 mb-4 p-4"
             style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <div class="d-flex align-items-center mb-1">
            <i class="bi bi-clock-history me-2" style="color:#0f766e;font-size:1.15rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Examiner Role History</span>
          </div>
          <div class="mb-3" style="font-size:0.88rem;color:#9ca3af;">How many times each person has served in each role for this candidate's panel sessions.</div>
          <% if (roleHistory.isEmpty()) { %>
          <div class="text-muted" style="font-size:0.92rem;"><i class="bi bi-info-circle me-1"></i>No previous panel records found.</div>
          <% } else { %>
          <div class="table-responsive">
            <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.95rem;">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Previous Role</th>
                  <th>Times Served</th>
                </tr>
              </thead>
              <tbody>
                <% for (Map<String,Object> h : roleHistory) { %>
                <tr>
                  <td class="fw-semibold" style="color:#111827;"><%= h.get("name") %></td>
                  <td style="color:#6b7280;"><%= h.get("role") %></td>
                  <td><span style="background:#f3f4f6;color:#374151;padding:2px 10px;border-radius:20px;font-size:0.85rem;font-weight:600;"><%= h.get("frequency") %> times</span></td>
                </tr>
                <% } %>
              </tbody>
            </table>
          </div>
          <% } %>
        </div>

        <% } %>
      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
