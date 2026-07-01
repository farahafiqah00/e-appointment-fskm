<%-- Academician: list of nominations submitted by the current user with text and status filters. --%>
<%@ page import="java.util.List, model.Nomination" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String fullName = (String) session.getAttribute("full_name");
    if (fullName == null) fullName = "Academician";
    String q       = request.getParameter("q")      != null ? request.getParameter("q").trim()      : "";
    String statusF = request.getParameter("status") != null ? request.getParameter("status").trim() : "";

    @SuppressWarnings("unchecked")
    List<Nomination> nominations = (List<Nomination>) request.getAttribute("nominations");
    if (nominations == null) nominations = new java.util.ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My Nominations - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>.role-switcher-btn{background:#fff;border:1.5px solid #d1d5db;border-radius:10px;padding:6px 36px 6px 14px;font-size:0.95rem;font-weight:600;color:#111827;cursor:pointer;appearance:none;-webkit-appearance:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24'%3E%3Cpath d='M7 10l5 5 5-5z' fill='%236b7280'/%3E%3C/svg%3E");background-repeat:no-repeat;background-position:right 10px center;}</style>
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

    <main class="content ea-content" style="max-width:none;">
      <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;">

        <!-- Page Header -->
        <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
          <div>
            <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">My Examiner Nominations</h1>
            <div style="font-size:1rem;color:#6b7280;">Track your examiner nomination submissions</div>
          </div>
          <a href="<%= request.getContextPath() %>/SubmitNominationServlet"
             class="ea-btn-primary-action d-flex align-items-center gap-2" style="text-decoration:none;">
            <i class="bi bi-plus-circle"></i> New Nomination
          </a>
        </div>

        <!-- Flash messages -->
        <% String successParam = request.getParameter("success"); String resubmitParam = request.getParameter("resubmit"); String errorParam = request.getParameter("error");
           String emailSentParam = request.getParameter("emailSent"); String emailErrorParam = request.getParameter("emailError");
           String deletedParam = request.getParameter("deleted"); String deleteErrorParam = request.getParameter("deleteError"); %>
        <% if ("1".equals(successParam)) { %>
        <div class="d-flex align-items-center gap-3 mb-3 px-4 py-3"
             style="background:#f0fdf4;border:1.5px solid #86efac;border-radius:12px;color:#166534;">
          <i class="bi bi-check-circle-fill" style="font-size:1.15rem;color:#16a34a;flex-shrink:0;"></i>
          <span style="font-size:0.92rem;font-weight:500;">Nomination submitted successfully. A verification email has been sent to the examiner.</span>
        </div>
        <% } else if ("1".equals(resubmitParam)) { %>
        <div class="d-flex align-items-center gap-3 mb-3 px-4 py-3"
             style="background:#f0fdf4;border:1.5px solid #86efac;border-radius:12px;color:#166534;">
          <i class="bi bi-check-circle-fill" style="font-size:1.15rem;color:#16a34a;flex-shrink:0;"></i>
          <span style="font-size:0.92rem;font-weight:500;">Nomination resubmitted successfully and is now under review.</span>
        </div>
        <% } else if ("forbidden".equals(errorParam)) { %>
        <div class="alert alert-danger d-flex align-items-center gap-2 mb-3" style="border-radius:10px;">
          <i class="bi bi-exclamation-circle-fill"></i> You do not have permission to edit that nomination.
        </div>
        <% } else if ("noteditable".equals(errorParam)) { %>
        <div class="alert alert-warning d-flex align-items-center gap-2 mb-3" style="border-radius:10px;">
          <i class="bi bi-exclamation-triangle-fill"></i> That nomination cannot be edited in its current status.
        </div>
        <% } else if ("1".equals(deletedParam)) { %>
        <div class="d-flex align-items-center gap-3 mb-3 px-4 py-3"
             style="background:#f0fdf4;border:1.5px solid #86efac;border-radius:12px;color:#166534;">
          <i class="bi bi-trash-fill" style="font-size:1.15rem;color:#16a34a;flex-shrink:0;"></i>
          <span style="font-size:0.92rem;font-weight:500;">Nomination deleted successfully.</span>
        </div>
        <% } else if ("1".equals(deleteErrorParam)) { %>
        <div class="alert alert-danger d-flex align-items-center gap-2 mb-3" style="border-radius:10px;">
          <i class="bi bi-exclamation-circle-fill"></i> Could not delete the nomination. Please try again.
        </div>
        <% } %>
        <% if ("1".equals(emailSentParam)) { %>
        <div class="d-flex align-items-center gap-3 mb-3 px-4 py-3"
             style="background:#f0fdf4;border:1.5px solid #86efac;border-radius:12px;color:#166534;">
          <i class="bi bi-envelope-check-fill" style="font-size:1.15rem;color:#16a34a;flex-shrink:0;"></i>
          <span style="font-size:0.92rem;font-weight:500;">Verification email sent to the examiner successfully.</span>
        </div>
        <% } else if ("1".equals(emailErrorParam)) { %>
        <div class="alert alert-danger d-flex align-items-center gap-2 mb-3" style="border-radius:10px;">
          <i class="bi bi-exclamation-circle-fill"></i> Could not send the verification email. Please try again later.
        </div>
        <% } %>

        <!-- Search & Filter Bar -->
        <div class="w-100 mb-4 p-3" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
          <form class="row g-2 align-items-center" method="GET" action="<%= request.getContextPath() %>/MyNominationsServlet">
            <div class="col-lg-6 col-md-12">
              <div class="input-group" style="border:1.5px solid #e5e7eb;border-radius:10px;overflow:hidden;">
                <span class="input-group-text bg-transparent border-0"><i class="bi bi-search text-muted"></i></span>
                <input class="form-control border-0 ps-0" name="q" value="<%= q %>"
                       placeholder="Search by candidate, examiner, or university..."
                       style="font-size:0.97rem;box-shadow:none;">
              </div>
            </div>
            <div class="col-lg-4 col-md-8">
              <select name="status" class="form-select" style="border-radius:10px;border-color:#e5e7eb;">
                <option value="">All Status</option>
                <option value="submitted"         <%= "submitted".equals(statusF)         ? "selected" : "" %>>Submitted</option>
                <option value="under_review"      <%= "under_review".equals(statusF)      ? "selected" : "" %>>Under Review</option>
                <option value="needs_correction"  <%= "needs_correction".equals(statusF)  ? "selected" : "" %>>Needs Correction</option>
                <option value="pending_examiner"  <%= "pending_examiner".equals(statusF)  ? "selected" : "" %>>Awaiting Examiner</option>
                <option value="verified"          <%= "verified".equals(statusF)          ? "selected" : "" %>>Verified</option>
              </select>
            </div>
            <div class="col-lg-2 col-md-4 d-flex gap-2">
              <button type="submit" class="ea-btn-icon w-100" title="Search"><i class="bi bi-search"></i></button>
              <% if (!q.isEmpty() || !statusF.isEmpty()) { %>
              <a href="<%= request.getContextPath() %>/MyNominationsServlet"
                 class="ea-btn-icon w-100 text-decoration-none text-center"
                 style="display:inline-flex;align-items:center;justify-content:center;" title="Clear">
                <i class="bi bi-x-lg"></i>
              </a>
              <% } %>
            </div>
          </form>
        </div>

        <!-- Nominations Table -->
        <div class="w-100 mb-4" style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);overflow:hidden;">
          <div class="d-flex align-items-center px-4 py-3" style="border-bottom:1px solid #f3f4f6;">
            <i class="bi bi-file-earmark-text me-2" style="color:#0f766e;font-size:1.1rem;"></i>
            <span class="fw-semibold" style="font-size:1.05rem;">Nominations (<%= nominations.size() %>)</span>
          </div>
          <div class="table-responsive">
            <table class="ea-table-userlist align-middle mb-0 w-100" style="font-size:0.97rem;">
              <thead>
                <tr>
                  <th style="width:20%;">Candidate Name</th>
                  <th style="width:20%;">Examiner Name</th>
                  <th style="width:18%;">University</th>
                  <th style="width:20%;">Nomination Status</th>
                  <th style="width:11%;">Submitted Date</th>
                  <th style="width:11%;">Actions</th>
                </tr>
              </thead>
              <tbody>
                <% if (nominations.isEmpty()) { %>
                <tr>
                  <td colspan="6" class="text-center py-5 text-muted">
                    <i class="bi bi-file-earmark-text d-block mb-2" style="font-size:2rem;color:#d1d5db;"></i>
                    No nominations found.
                  </td>
                </tr>
                <% } else { for (Nomination n : nominations) {
                     String ns = n.getStatus() != null ? n.getStatus() : "submitted";
                     String submittedDate = n.getCreatedAt() != null
                         ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(n.getCreatedAt()) : "—";

                     // Badge colours
                     String bgColor, textColor, label;
                     if ("verified".equals(ns)) {
                         bgColor = "#dcfce7"; textColor = "#16a34a"; label = "Verified";
                     } else if ("needs_correction".equals(ns)) {
                         bgColor = "#fee2e2"; textColor = "#dc2626"; label = "Needs Correction";
                     } else if ("under_review".equals(ns)) {
                         bgColor = "#fef3c7"; textColor = "#d97706"; label = "Under Review";
                     } else if ("pending_examiner".equals(ns)) {
                         bgColor = "#ede9fe"; textColor = "#7c3aed"; label = "Awaiting Examiner";
                     } else {
                         bgColor = "#dbeafe"; textColor = "#1d4ed8"; label = "Submitted";
                     }
                     boolean canEdit = "pending_examiner".equals(ns) || "submitted".equals(ns) || "needs_correction".equals(ns);
                     boolean canDelete = "pending_examiner".equals(ns) || "submitted".equals(ns) || "needs_correction".equals(ns);
                %>
                <tr>
                  <td><div class="fw-semibold" style="color:#111827;"><% if (n.getCandidateName() != null) { %><%= n.getCandidateName() %><% } else { %><span style="color:#9ca3af;font-style:italic;font-weight:400;">Not yet assigned</span><% } %></div></td>
                  <td><span style="color:#374151;"><%= n.getExaminerName()       != null ? n.getExaminerName()       : "—" %></span></td>
                  <td><span style="color:#6b7280;"><%= n.getExaminerAffiliation() != null ? n.getExaminerAffiliation() : "—" %></span></td>
                  <td>
                    <span style="background:<%= bgColor %>;color:<%= textColor %>;padding:3px 12px;border-radius:20px;font-size:0.85rem;font-weight:600;">
                      <%= label %>
                    </span>
                    <% if ("needs_correction".equals(ns)
                            && (n.getDiscrepancyNotes() == null || n.getDiscrepancyNotes().isEmpty())
                            && n.getRemarks() != null && !n.getRemarks().isEmpty()) { %>
                    <div class="mt-1">
                      <span style="background:#fee2e2;color:#b91c1c;padding:2px 10px;border-radius:20px;font-size:0.76rem;font-weight:600;"
                            title="<%= n.getRemarks().replace("\"", "&quot;") %>" data-bs-toggle="tooltip">
                        <i class="bi bi-shield-exclamation me-1"></i>Admin: <%= n.getRemarks().length() > 40 ? n.getRemarks().substring(0,40) + "…" : n.getRemarks() %>
                      </span>
                    </div>
                    <% } else if (n.isExaminerConfirmed()) { %>
                    <div class="mt-1">
                      <span style="background:#dcfce7;color:#16a34a;padding:2px 10px;border-radius:20px;font-size:0.76rem;font-weight:600;">
                        <i class="bi bi-check-circle-fill me-1"></i>Examiner Confirmed
                      </span>
                    </div>
                    <% } else if (n.getDiscrepancyNotes() != null && !n.getDiscrepancyNotes().isEmpty()) { %>
                    <div class="mt-1">
                      <span style="background:#fef3c7;color:#92400e;padding:2px 10px;border-radius:20px;font-size:0.76rem;font-weight:600;"
                            title="<%= n.getDiscrepancyNotes().replace("\"", "&quot;") %>" data-bs-toggle="tooltip">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i>Discrepancy Reported
                      </span>
                    </div>
                    <% } else { %>
                    <div class="mt-1">
                      <span style="background:#f3f4f6;color:#9ca3af;padding:2px 10px;border-radius:20px;font-size:0.76rem;font-weight:500;">
                        <i class="bi bi-envelope me-1"></i>Awaiting Confirmation
                      </span>
                    </div>
                    <% } %>
                  </td>
                  <td style="color:#6b7280;"><%= submittedDate %></td>
                  <td>
                    <div class="d-flex gap-1 flex-wrap">
                      <a href="<%= request.getContextPath() %>/ViewMyNominationServlet?id=<%= n.getId() %>"
                         class="ea-btn-icon" title="View" style="font-size:1rem;padding:0.4em 0.7em;text-decoration:none;">
                        <i class="bi bi-eye"></i>
                      </a>
                      <% if (canEdit) { %>
                      <a href="<%= request.getContextPath() %>/EditNominationServlet?id=<%= n.getId() %>"
                         class="ea-btn-icon" title="Edit" style="font-size:1rem;padding:0.4em 0.7em;text-decoration:none;">
                        <i class="bi bi-pencil-square"></i>
                      </a>
                      <% } %>
                      <% if (canDelete) { %>
                      <form method="POST" action="<%= request.getContextPath() %>/DeleteNominationServlet" style="display:inline;margin:0;"
                            onsubmit="return confirm('Delete this nomination? This cannot be undone.');">
                        <input type="hidden" name="nominationId" value="<%= n.getId() %>">
                        <button type="submit" class="ea-btn-icon" title="Delete Nomination"
                                style="font-size:1rem;padding:0.4em 0.7em;color:#dc2626;">
                          <i class="bi bi-trash3"></i>
                        </button>
                      </form>
                      <% } %>
                      <% if (!n.isExaminerConfirmed() && n.getExaminerEmail() != null && !n.getExaminerEmail().isEmpty()) { %>
                      <form method="POST" action="<%= request.getContextPath() %>/SendVerificationEmailServlet" style="display:inline;margin:0;">
                        <input type="hidden" name="nominationId" value="<%= n.getId() %>">
                        <button type="submit" class="ea-btn-icon" title="Send/Resend Verification Email" style="font-size:1rem;padding:0.4em 0.7em;">
                          <i class="bi bi-envelope-arrow-up"></i>
                        </button>
                      </form>
                      <% } %>
                    </div>
                  </td>
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
  <script>
    // Enable Bootstrap tooltips (used for discrepancy notes)
    document.addEventListener('DOMContentLoaded', function () {
      var tooltipEls = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
      tooltipEls.forEach(function (el) { new bootstrap.Tooltip(el); });
    });
  </script>
</body>
</html>
