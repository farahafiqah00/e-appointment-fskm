<%--
  Admin: standalone edit form for an existing viva candidate (populated from EditCandidateServlet).
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  model.Candidate candidate = (model.Candidate) request.getAttribute("candidate");
  String idVal = candidate != null ? String.valueOf(candidate.getId()) : "";
  String fullNameVal = candidate != null ? candidate.getFullName() : "";
  String studentIdVal = candidate != null ? candidate.getStudentId() : "";
  String programVal = candidate != null ? candidate.getProgram() : "";
  String thesisVal = candidate != null ? candidate.getThesisTitle() : "";
  String supervisorVal = candidate != null ? candidate.getSupervisorName() : "";
  String statusVal = candidate != null ? candidate.getStatus() : "prepared";
  String currentUserName = (String) session.getAttribute("full_name");
  if (currentUserName == null || currentUserName.trim().isEmpty()) {
      currentUserName = "Admin";
  }
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Edit Viva Candidate</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  </head>
  <body class="admin">
    <jsp:include page="/includes/topbar.jsp" />

    <div class="layout ea-layout">
      <% request.setAttribute("activeSection", "viva"); request.setAttribute("activeSubSection", "viewViva"); %>
      <jsp:include page="/admin/sidebar.jsp" />
      <main class="content">
      <div class="card mx-auto" style="max-width:760px;">
        <div class="card-body">
          <h4 class="card-title">Edit Viva Candidate</h4>
          <form method="POST" action="<%= request.getContextPath() %>/EditCandidateServlet">
            <input type="hidden" name="id" value="<%= idVal %>">
            <div class="mb-3">
              <label class="form-label">Candidate Name</label>
              <input type="text" class="form-control" value="<%= fullNameVal %>" readonly>
            </div>
            <div class="mb-3">
              <label class="form-label">Matric Number</label>
              <input type="text" class="form-control" value="<%= studentIdVal %>" readonly>
            </div>
            <div class="mb-3">
              <label class="form-label">Programme</label>
              <input type="text" name="program" class="form-control" value="<%= programVal %>">
            </div>
            <div class="mb-3">
              <label class="form-label">Thesis Title</label>
              <input type="text" name="thesisTitle" class="form-control" value="<%= thesisVal %>">
            </div>
            <div class="mb-3">
              <label class="form-label">Supervisor</label>
              <input type="text" name="supervisorName" class="form-control" value="<%= supervisorVal %>">
            </div>
            <div class="mb-3">
              <label class="form-label">Viva Status</label>
              <select name="status" class="form-select">
                <option value="prepared" <%= "prepared".equalsIgnoreCase(statusVal) ? "selected" : "" %>>Prepared</option>
                <option value="appointed" <%= "appointed".equalsIgnoreCase(statusVal) ? "selected" : "" %>>Appointed</option>
                <option value="completed" <%= "completed".equalsIgnoreCase(statusVal) ? "selected" : "" %>>Completed</option>
              </select>
            </div>
            <div class="d-flex gap-2">
              <button class="btn btn-primary" type="submit">Update</button>
              <a href="<%= request.getContextPath() %>/CandidateListServlet" class="btn btn-secondary">Cancel</a>
            </div>
          </form>
        </div>
      </div>
      </main>
    </div>
  </body>
</html>
