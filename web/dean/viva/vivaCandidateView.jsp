<%-- Dean: read-only detail view of a viva candidate (same as admin view but with dean navigation). --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Candidate, model.CoSupervisor, dao.CandidateDAO, java.util.List" %>
<%
    String sessionName = (String) session.getAttribute("full_name");
    if (sessionName == null || sessionName.trim().isEmpty()) sessionName = "Dean";

    String idStr = request.getParameter("id") != null ? request.getParameter("id").trim() : "";
    Candidate c = null;
    if (!idStr.isEmpty()) {
        try { c = new CandidateDAO().findById(Integer.parseInt(idStr)); } catch (Exception ignore) {}
    }
    if (c == null) {
        response.sendRedirect(request.getContextPath() + "/CandidateListServlet");
        return;
    }
    String displayStatus = c.getStatus() != null ? c.getStatus().toLowerCase() : "prepared";
    String progDisplay   = c.getDisplayProgram();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Candidate Details - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="admin">

  <jsp:include page="/includes/topbar.jsp" />

  <div class="layout">
    <% request.setAttribute("activeSection", "viva"); request.setAttribute("activeSubSection", "deanVivaCandidates"); %>
    <jsp:include page="/dean/sidebar.jsp" />

    <main class="content ea-content">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="max-width:900px;margin:0 auto;">

        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Candidate Details</h1>
            <div style="font-size:1rem;color:#6b7280;">Read-only view</div>
          </div>
          <div>
            <a href="<%= request.getContextPath() %>/CandidateListServlet" class="btn-ea-back">
              <i class="bi bi-arrow-left"></i> Back to list
            </a>
          </div>
        </div>

        <!-- Detail Card -->
        <div class="w-100 mb-4 p-4"
             style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">

          <div class="d-flex align-items-center gap-2 mb-4 pb-2" style="border-bottom:2px solid #f3f4f6;">
            <span style="background:#105e60;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;font-weight:700;flex-shrink:0;">
              <i class="bi bi-mortarboard"></i>
            </span>
            <span style="font-size:1.05rem;font-weight:700;color:#105e60;">Candidate Information</span>
          </div>

          <div class="row g-3">

            <div class="col-md-6">
              <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Candidate Name</div>
              <div style="font-size:1.05rem;font-weight:600;color:#111827;"><%= c.getFullName() != null ? c.getFullName() : "—" %></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Viva Status</div>
              <div>
                <% if ("appointed".equals(displayStatus)) { %>
                <span style="background:#dbeafe;color:#1d4ed8;padding:4px 14px;border-radius:20px;font-size:0.9rem;font-weight:600;">Appointed</span>
                <% } else if ("completed".equals(displayStatus)) { %>
                <span style="background:#dcfce7;color:#16a34a;padding:4px 14px;border-radius:20px;font-size:0.9rem;font-weight:600;">Completed</span>
                <% } else { %>
                <span style="background:#fef3c7;color:#d97706;padding:4px 14px;border-radius:20px;font-size:0.9rem;font-weight:600;">Pending</span>
                <% } %>
              </div>
            </div>

            <div class="col-md-6">
              <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Matric Number</div>
              <div><code style="background:#f3f4f6;padding:4px 10px;border-radius:6px;font-size:0.93rem;color:#374151;"><%= c.getStudentId() != null ? c.getStudentId() : "—" %></code></div>
            </div>
            <div class="col-md-6">
              <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Programme</div>
              <div>
                <% if (!progDisplay.isEmpty()) { %>
                <span style="background:#e5f7f5;color:#0f766e;padding:4px 12px;border-radius:20px;font-size:0.9rem;font-weight:500;"><%= progDisplay %></span>
                <% } else { %>
                <span style="color:#9ca3af;">—</span>
                <% } %>
              </div>
            </div>

            <div class="col-12">
              <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Thesis Title</div>
              <div style="color:#374151;line-height:1.6;"><%= c.getThesisTitle() != null ? c.getThesisTitle() : "—" %></div>
            </div>

            <div class="col-md-6">
              <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Supervisor</div>
              <div style="color:#374151;"><%= c.getSupervisorName() != null ? c.getSupervisorName() : "—" %></div>
            </div>

            <div class="col-md-6">
              <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Contact Email</div>
              <div>
                <% if (c.getContactEmail() != null && !c.getContactEmail().isEmpty()) { %>
                <a href="mailto:<%= c.getContactEmail() %>" style="color:#0f766e;"><%= c.getContactEmail() %></a>
                <% } else { %>
                <span style="color:#9ca3af;">—</span>
                <% } %>
              </div>
            </div>

            <% List<CoSupervisor> coSups = c.getCoSupervisors();
               if (coSups != null && !coSups.isEmpty()) { %>
            <div class="col-12">
              <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:8px;">Co-Supervisors</div>
              <div class="d-flex flex-wrap gap-2">
                <% for (CoSupervisor cs : coSups) { if (cs == null || (cs.getName() == null || cs.getName().trim().isEmpty())) continue;
                     boolean csInternal = "internal".equals(cs.getCosvType());
                     String csAff = cs.getDisplayAffiliation(); %>
                <span style="<%= csInternal ? "background:#eff6ff;border:1px solid #bfdbfe;color:#1d4ed8;" : "background:#e5f7f5;border:1px solid #a7f3d0;color:#065f46;" %> padding:4px 14px;border-radius:20px;font-size:0.9rem;display:inline-flex;align-items:center;gap:6px;">
                  <i class="<%= csInternal ? "bi bi-person-badge-fill" : "bi bi-globe2" %>" style="font-size:0.82rem;"></i>
                  <span><strong><%= cs.getName() %></strong><% if (csAff != null && !csAff.isEmpty()) { %> &mdash; <span style="font-size:0.8rem;opacity:0.8;"><%= csAff %></span><% } %></span>
                </span>
                <% } %>
              </div>
            </div>
            <% } %>

            <div class="col-md-6">
              <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Added On</div>
              <div style="color:#6b7280;font-size:0.93rem;">
                <%= c.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(c.getCreatedAt()) : "—" %>
              </div>
            </div>

          </div>
        </div>

      </div>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
