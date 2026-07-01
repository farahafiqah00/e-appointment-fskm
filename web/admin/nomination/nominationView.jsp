<%--
  Admin: detail view of a single nomination with its documents. The fromReport flag
  adjusts the back-link so users return to the unverified report instead of the nomination list.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  model.Nomination n = (model.Nomination) request.getAttribute("nomination");
  java.util.List<model.Document> docs = (java.util.List<model.Document>) request.getAttribute("documents");
  if (n == null) { response.sendRedirect(request.getContextPath() + "/NominationListServlet"); return; }
  String st = n.getStatus() != null ? n.getStatus() : "pending";
  String fullName = (String) session.getAttribute("full_name"); if (fullName == null) fullName = "Admin";
  String fromCtxNv = request.getParameter("from") != null ? request.getParameter("from").trim() : "";
  boolean fromReport = "unverifiedReport".equals(fromCtxNv);
  String reportFrom = request.getParameter("reportFrom") != null ? request.getParameter("reportFrom").trim() : "examiner";
  String backUrl = fromReport
      ? request.getContextPath() + "/UnverifiedReportServlet?from=" + reportFrom
      : request.getContextPath() + "/NominationListServlet";
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nomination Details - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  </head>
  <body class="admin">

    <jsp:include page="/includes/topbar.jsp" />

    <div class="layout ea-layout">
      <% request.setAttribute("activeSection", fromReport ? reportFrom : "examiner"); request.setAttribute("activeSubSection", "examinerNominations"); %>
      <jsp:include page="/admin/sidebar.jsp" />

      <main class="content ea-content" style="max-width:none;">
        <div class="ea-main-content-centered d-flex flex-column w-100" style="align-items:stretch;max-width:900px;margin:0 auto;">

          <!-- Page Header -->
          <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-3">
            <div>
              <a href="<%= backUrl %>" class="btn-ea-back mb-2">
                <i class="bi bi-arrow-left"></i> <%= fromReport ? "Back to Unverified Report" : "Back to Nominations" %>
              </a>
              <h1 style="font-size:2rem;font-weight:700;color:#105e60;margin-bottom:4px;">Nomination Details</h1>
              <div style="font-size:1rem;color:#6b7280;">Review examiner nomination submitted by academician</div>
            </div>
            <div>
              <% if ("verified".equals(st)) { %>
              <span style="background:#dcfce7;color:#16a34a;padding:6px 18px;border-radius:20px;font-size:0.95rem;font-weight:600;">Verified</span>
              <% } else if ("needs_correction".equals(st)) { %>
              <span style="background:#fee2e2;color:#dc2626;padding:6px 18px;border-radius:20px;font-size:0.95rem;font-weight:600;">Needs Correction</span>
              <% } else { %>
              <span style="background:#fef3c7;color:#d97706;padding:6px 18px;border-radius:20px;font-size:0.95rem;font-weight:600;">Pending Review</span>
              <% } %>
            </div>
          </div>

          <!-- Examiner Info Card -->
          <div class="w-100 mb-4 p-4"
               style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <div class="d-flex align-items-center gap-2 mb-4 pb-2" style="border-bottom:2px solid #f3f4f6;">
              <span style="background:#105e60;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;flex-shrink:0;">
                <i class="bi bi-person"></i>
              </span>
              <span style="font-size:1.05rem;font-weight:700;color:#105e60;">Examiner Information</span>
            </div>
            <div class="row g-4">
              <div class="col-md-6">
                <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Examiner Name</div>
                <div style="font-size:1.05rem;font-weight:600;color:#111827;"><%= n.getExaminerName() != null ? n.getExaminerName() : "—" %></div>
              </div>
              <div class="col-md-6">
                <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">University / Organisation</div>
                <div style="font-size:1rem;color:#374151;"><%= n.getExaminerAffiliation() != null ? n.getExaminerAffiliation() : "—" %></div>
              </div>
              <div class="col-md-6">
                <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Nominated By</div>
                <div style="font-size:1rem;color:#374151;"><%= n.getNominatorName() != null ? n.getNominatorName() : "—" %></div>
              </div>
              <div class="col-md-6">
                <div style="font-size:0.82rem;font-weight:600;color:#9ca3af;text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px;">Submission Date</div>
                <div style="font-size:1rem;color:#374151;"><%= n.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd MMMM yyyy").format(n.getCreatedAt()) : "—" %></div>
              </div>
            </div>
          </div>

          <!-- Documents Card -->
          <div class="w-100 mb-4 p-4"
               style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <div class="d-flex align-items-center gap-2 mb-4 pb-2" style="border-bottom:2px solid #f3f4f6;">
              <span style="background:#105e60;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;flex-shrink:0;">
                <i class="bi bi-file-earmark"></i>
              </span>
              <span style="font-size:1.05rem;font-weight:700;color:#105e60;">Submitted Documents</span>
            </div>
            <% if (docs != null && !docs.isEmpty()) {
               for (model.Document d : docs) { %>
            <div class="d-flex align-items-center gap-3 mb-2 p-3"
                 style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px;">
              <i class="bi bi-file-earmark-pdf" style="color:#ef4444;font-size:1.4rem;flex-shrink:0;"></i>
              <a href="<%= request.getContextPath() %>/DownloadDocumentServlet?id=<%= d.getId() %>"
                 class="text-decoration-none fw-semibold" style="color:#105e60;"><%= d.getFilename() %></a>
            </div>
            <% } } else { %>
            <p class="text-muted mb-0"><i class="bi bi-info-circle me-1"></i>No documents uploaded for this nomination.</p>
            <% } %>
          </div>

          <!-- Verification Card (hidden if already verified) -->
          <% if (!"verified".equals(st)) { %>
          <div class="w-100 mb-4 p-4"
               style="background:#fff;border:1px solid #e5e7eb;border-radius:16px;box-shadow:0 2px 8px rgba(0,0,0,0.04);">
            <div class="d-flex align-items-center gap-2 mb-4 pb-2" style="border-bottom:2px solid #f3f4f6;">
              <span style="background:#105e60;color:#fff;width:28px;height:28px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;font-size:0.85rem;flex-shrink:0;">
                <i class="bi bi-clipboard-check"></i>
              </span>
              <span style="font-size:1.05rem;font-weight:700;color:#105e60;">Verification Decision</span>
            </div>
            <form method="POST" action="<%= request.getContextPath() %>/VerifyNominationServlet">
              <input type="hidden" name="id" value="<%= n.getId() %>">
              <div class="mb-4">
                <label class="form-label fw-semibold" style="color:#374151;">
                  Remarks <span class="text-muted fw-normal" style="font-size:0.9rem;">(optional — visible to academician)</span>
                </label>
                <textarea name="remarks" class="form-control" rows="3"
                          style="border-radius:10px;border-color:#e5e7eb;"
                          placeholder="e.g. Examiner does not meet rank requirement / Please provide updated CV..."><%= n.getRemarks() != null ? n.getRemarks() : "" %></textarea>
              </div>
              <div class="d-flex gap-3 flex-wrap">
                <button name="action" value="verify" type="submit"
                        class="ea-btn-primary-action d-inline-flex align-items-center gap-2">
                  <i class="bi bi-check-circle"></i> Verify Nomination
                </button>
                <button name="action" value="under_review" type="submit"
                        class="d-inline-flex align-items-center gap-2 btn"
                        style="background:#eff6ff;color:#1d4ed8;border:1px solid #bfdbfe;border-radius:10px;padding:10px 20px;font-weight:600;">
                  <i class="bi bi-hourglass-split"></i> Mark Under Review
                </button>
                <button name="action" value="needs_correction" type="submit"
                        class="d-inline-flex align-items-center gap-2 btn"
                        style="background:#fef3c7;color:#92400e;border:1px solid #fde68a;border-radius:10px;padding:10px 20px;font-weight:600;">
                  <i class="bi bi-exclamation-circle"></i> Needs Correction
                </button>
              </div>
            </form>
          </div>
          <% } else { %>
          <div class="d-flex align-items-center gap-3 p-4 mb-4"
               style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:16px;color:#166534;">
            <i class="bi bi-check-circle-fill" style="font-size:1.5rem;color:#16a34a;flex-shrink:0;"></i>
            <div>
              <div class="fw-semibold">Nomination Verified</div>
              <div style="font-size:0.92rem;">This examiner is in the approved pool and can be assigned to a viva appointment.</div>
            </div>
          </div>
          <% } %>

        </div>
      </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function () {
      var btnCorrection = document.querySelector('button[value="needs_correction"]');
      if (btnCorrection) {
        btnCorrection.addEventListener('click', function (e) {
          var remarks = document.querySelector('textarea[name="remarks"]');
          if (!remarks || remarks.value.trim() === '') {
            e.preventDefault();
            remarks.focus();
            remarks.style.borderColor = '#ef4444';
            remarks.style.boxShadow   = '0 0 0 3px rgba(239,68,68,0.15)';
            var msg = remarks.nextElementSibling;
            if (!msg || !msg.classList.contains('ea-remarks-error')) {
              msg = document.createElement('div');
              msg.className = 'ea-remarks-error';
              msg.style.cssText = 'color:#dc2626;font-size:0.82rem;margin-top:4px;';
              msg.textContent = 'Please describe what correction is needed before flagging.';
              remarks.parentNode.insertBefore(msg, remarks.nextSibling);
            }
          }
        });
      }
    });
  </script>
  </body>
</html>
