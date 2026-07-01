<%-- Dean: list of viva appointments for candidates that the logged-in Dean supervises. --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.VivaAppointment, java.text.SimpleDateFormat" %>
<%
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null) fullName = "Dean";

    @SuppressWarnings("unchecked")
    List<VivaAppointment> appointments = (List<VivaAppointment>) request.getAttribute("appointments");
    if (appointments == null) appointments = new java.util.ArrayList<>();

    SimpleDateFormat dtFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My Students' Viva Schedule - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout">
    <% request.setAttribute("activeSection", "myStudentsViva"); %>
    <jsp:include page="/dean/sidebar.jsp" />

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

        <!-- Page Header -->
        <div class="mb-4">
          <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">My Students' Viva Schedule</h1>
          <div style="font-size:1rem;color:#6b7280;">Viva appointments for candidates you supervise.</div>
        </div>

        <% if (appointments.isEmpty()) { %>
        <!-- Empty State -->
        <div class="text-center py-5" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <i class="bi bi-calendar-x d-block mb-3" style="font-size:3rem;color:#d1d5db;"></i>
          <div style="font-size:1.05rem;font-weight:600;color:#374151;">No scheduled viva appointments yet</div>
          <div style="font-size:0.92rem;color:#9ca3af;margin-top:6px;">Appointments will appear here once they are scheduled for your candidates.</div>
        </div>
        <% } else { %>
        <!-- Appointment Cards -->
        <% for (VivaAppointment appt : appointments) {
             String scheduledStr = appt.getScheduledAt() != null ? dtFmt.format(appt.getScheduledAt()) : "Not scheduled";
             String venue = appt.getVenue() != null && !appt.getVenue().isEmpty() ? appt.getVenue() : "Not specified";
             String status = appt.getStatus() != null ? appt.getStatus() : "";
             String thesis = appt.getThesisTitle() != null && !appt.getThesisTitle().isEmpty() ? appt.getThesisTitle() : "—";
             String program = appt.getCandidateProgram() != null && !appt.getCandidateProgram().isEmpty() ? appt.getCandidateProgram() : "—";
             String studentId = appt.getCandidateStudentId() != null ? appt.getCandidateStudentId() : "—";
             String chair = appt.getChairpersonName() != null ? appt.getChairpersonName() : "—";
             String intNames = appt.getInternalExaminerName() != null && !appt.getInternalExaminerName().isEmpty() ? appt.getInternalExaminerName() : "—";
             String extNames = appt.getExternalExaminerName() != null && !appt.getExternalExaminerName().isEmpty() ? appt.getExternalExaminerName() : "—";

             String statusBg    = "#f3f4f6"; String statusColor = "#6b7280";
             String statusLabel = status;
             if ("scheduled".equalsIgnoreCase(status))  { statusBg = "#dbeafe"; statusColor = "#1d4ed8"; statusLabel = "Scheduled"; }
             else if ("completed".equalsIgnoreCase(status)) { statusBg = "#dcfce7"; statusColor = "#16a34a"; statusLabel = "Completed"; }
             else if ("pending".equalsIgnoreCase(status))   { statusBg = "#fef9c3"; statusColor = "#a16207"; statusLabel = "Pending"; }
             else if ("cancelled".equalsIgnoreCase(status)) { statusBg = "#fee2e2"; statusColor = "#dc2626"; statusLabel = "Cancelled"; }
        %>
        <div class="w-100 mb-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
          <!-- Card header -->
          <div class="d-flex align-items-center justify-content-between px-4 py-3" style="background:#f8fffe;border-bottom:1px solid #e5e7eb;">
            <div class="d-flex align-items-center gap-3">
              <div style="width:42px;height:42px;border-radius:50%;background:#105e60;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
                <i class="bi bi-person-fill" style="color:#fff;font-size:1.15rem;"></i>
              </div>
              <div>
                <div class="fw-bold" style="font-size:1.05rem;color:#111827;"><%= appt.getCandidateName() != null ? appt.getCandidateName() : "Unknown" %></div>
                <div style="font-size:0.84rem;color:#6b7280;"><%= studentId %> &bull; <%= program %></div>
              </div>
            </div>
            <span style="background:<%= statusBg %>;color:<%= statusColor %>;padding:4px 14px;border-radius:20px;font-size:0.83rem;font-weight:600;">
              <%= statusLabel %>
            </span>
          </div>
          <!-- Card body -->
          <div class="px-4 py-4">
            <!-- Thesis title -->
            <div class="mb-3">
              <span class="fw-semibold" style="font-size:0.82rem;color:#9ca3af;text-transform:uppercase;letter-spacing:.05em;">Thesis Title</span>
              <div style="font-size:0.97rem;color:#111827;margin-top:3px;"><em><%= thesis %></em></div>
            </div>
            <div class="row g-3">
              <!-- Date & Time -->
              <div class="col-md-4">
                <div class="p-3 h-100" style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;">
                  <div class="d-flex align-items-center gap-2 mb-1">
                    <i class="bi bi-calendar-event" style="color:#16a34a;font-size:1rem;"></i>
                    <span class="fw-semibold" style="font-size:0.82rem;color:#166534;text-transform:uppercase;letter-spacing:.05em;">Date & Time</span>
                  </div>
                  <div style="font-size:0.93rem;color:#111827;font-weight:600;"><%= scheduledStr %></div>
                </div>
              </div>
              <!-- Venue -->
              <div class="col-md-4">
                <div class="p-3 h-100" style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:12px;">
                  <div class="d-flex align-items-center gap-2 mb-1">
                    <i class="bi bi-geo-alt" style="color:#2563eb;font-size:1rem;"></i>
                    <span class="fw-semibold" style="font-size:0.82rem;color:#1d4ed8;text-transform:uppercase;letter-spacing:.05em;">Venue</span>
                  </div>
                  <div style="font-size:0.93rem;color:#111827;font-weight:600;"><%= venue %></div>
                </div>
              </div>
              <!-- Chairperson -->
              <div class="col-md-4">
                <div class="p-3 h-100" style="background:#fdf4ff;border:1px solid #e9d5ff;border-radius:12px;">
                  <div class="d-flex align-items-center gap-2 mb-1">
                    <i class="bi bi-person-badge" style="color:#9333ea;font-size:1rem;"></i>
                    <span class="fw-semibold" style="font-size:0.82rem;color:#7e22ce;text-transform:uppercase;letter-spacing:.05em;">Chairperson</span>
                  </div>
                  <div style="font-size:0.93rem;color:#111827;font-weight:600;"><%= chair %></div>
                </div>
              </div>
              <!-- Internal Examiners -->
              <div class="col-md-6">
                <div class="p-3" style="background:#f8fafc;border:1px solid #e5e7eb;border-radius:12px;">
                  <div class="d-flex align-items-center gap-2 mb-2">
                    <i class="bi bi-people" style="color:#0f766e;font-size:1rem;"></i>
                    <span class="fw-semibold" style="font-size:0.82rem;color:#0f766e;text-transform:uppercase;letter-spacing:.05em;">Internal Examiner(s)</span>
                  </div>
                  <% String[] intArr = intNames.split(",");
                     for (String n : intArr) {
                       if (n.trim().isEmpty()) continue; %>
                  <div style="font-size:0.9rem;color:#374151;padding:2px 0;"><i class="bi bi-person me-1 text-muted"></i><%= n.trim() %></div>
                  <% } if ("—".equals(intNames)) { %><div style="font-size:0.9rem;color:#9ca3af;">—</div><% } %>
                </div>
              </div>
              <!-- External Examiners -->
              <div class="col-md-6">
                <div class="p-3" style="background:#f8fafc;border:1px solid #e5e7eb;border-radius:12px;">
                  <div class="d-flex align-items-center gap-2 mb-2">
                    <i class="bi bi-person-lines-fill" style="color:#b45309;font-size:1rem;"></i>
                    <span class="fw-semibold" style="font-size:0.82rem;color:#b45309;text-transform:uppercase;letter-spacing:.05em;">External Examiner(s)</span>
                  </div>
                  <% String[] extArr = extNames.split(",");
                     for (String n : extArr) {
                       if (n.trim().isEmpty()) continue; %>
                  <div style="font-size:0.9rem;color:#374151;padding:2px 0;"><i class="bi bi-person me-1 text-muted"></i><%= n.trim() %></div>
                  <% } if ("—".equals(extNames)) { %><div style="font-size:0.9rem;color:#9ca3af;">—</div><% } %>
                </div>
              </div>
            </div>
          </div>
        </div>
        <% } %>
        <% } %>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
