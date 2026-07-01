<%-- Academician/Dean: view own academic staff profile (read-only for regular users; edit link shown for admins). --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String acStaffName = (String) session.getAttribute("full_name");
    if (acStaffName == null) acStaffName = "Admin";
    String _sessionRole = (String) session.getAttribute("role_name");
    String _displayRole = _sessionRole;
    if ("System Administrator".equals(_sessionRole) || "Administrator".equalsIgnoreCase(_sessionRole) || "System Admin".equalsIgnoreCase(_sessionRole)) {
      _displayRole = "Admin";
    }
%>
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Academic Staff Details - E-Appointment FSKM</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/styles.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  </head>
  <body class="admin">
    <jsp:include page="/includes/topbar.jsp" />

    <div class="container mt-5">
      <div class="row">
        <div class="col-lg-5 d-none d-lg-block">
          <div class="card" style="border-radius:18px; padding:28px; box-shadow: 0 12px 30px rgba(16,94,96,0.06);">
            <div class="text-center py-4">
              <img src="/web/images/umt-logo.png" alt="UMT" style="max-width:120px;" onerror="this.style.display='none'">
              <h2 style="color:var(--primary); margin-top:18px; font-weight:800">E-Appointment System</h2>
              <p class="muted">Faculty of Computer Science and Mathematics</p>
            </div>
            <hr />
            <p class="muted">Use this form to add or update academic staff records used for internal examiner selection and appointment letters.</p>
            <ul>
              <li>Link to an existing user account (optional)</li>
              <li>Select specialization first to narrow expertise and division</li>
              <li>Fields reflect database values where possible</li>
            </ul>
          </div>
        </div>

        <div class="col-lg-7">
          <div class="card" style="border-radius:14px; box-shadow:0 8px 22px rgba(11,115,101,0.06)">
            <div class="card-body" style="padding:28px">
              <h3 class="card-title" style="font-weight:800"><i class="bi bi-person-plus-fill" style="margin-right:8px;color:var(--primary)"></i> Add Academic Staff</h3>
              <p class="muted">Add new academic staff to the internal examiner pool</p>

              <%
                String userId = request.getParameter("userId") != null ? request.getParameter("userId") : "";
                dao.AcademicStaffDAO dao = new dao.AcademicStaffDAO();
                java.util.List<String> departments = dao.getDepartments();
                java.util.List<java.util.Map<String,Object>> specs = dao.getSpecializations();
                java.util.List<java.util.Map<String,Object>> expertise = dao.getExpertise();
                java.util.List<java.util.Map<String,Object>> divisions = dao.getDivisions();
                java.util.List<java.util.Map<String,Object>> users = dao.getUserAccountsByRole("Academician");
              %>

              <form method="POST" action="<%= request.getContextPath() %>/SaveAcademicServlet">
                <input type="hidden" name="userId" value="<%= userId %>">

                <div class="mb-3">
                  <label class="form-label">Staff ID</label>
                  <input type="text" name="staffId" class="form-control" value="<%= (userId.isEmpty() ? "" : "UMT" + userId) %>" />
                </div>

                <div class="mb-3">
                  <label class="form-label">Full Name</label>
                  <input type="text" name="fullName" class="form-control" required />
                </div>

                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Department</label>
                    <select name="department" class="form-select">
                      <option value="">Select Department</option>
                      <% for (String d : departments) { %>
                        <option value="<%= d %>"><%= d %></option>
                      <% } %>
                    </select>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Faculty</label>
                    <input type="text" name="faculty" class="form-control" value="Faculty of Computer Science and Mathematics" />
                  </div>
                </div>

                <div class="mb-3">
                  <label class="form-label">Academic Status</label>
                  <select name="academicStatus" class="form-select">
                    <option>Active</option>
                    <option>On Leave</option>
                    <option>Retired</option>
                  </select>
                </div>

                <div class="mb-3">
                  <label class="form-label">Area of Specialization</label>
                  <select id="specialization" name="specialization_id" class="form-select">
                    <option value="">Select Specialization</option>
                    <% for (java.util.Map<String,Object> s : specs) { %>
                      <option value="<%= s.get("id") %>"><%= s.get("name") %></option>
                    <% } %>
                  </select>
                </div>

                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Expertise</label>
                    <select id="expertise" name="expertise_id" class="form-select">
                      <option value="">Select Expertise</option>
                      <% for (java.util.Map<String,Object> e : expertise) { %>
                        <option data-spec="<%= e.get("specialization_id") %>" value="<%= e.get("id") %>"><%= e.get("name") %></option>
                      <% } %>
                    </select>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Group / Division</label>
                    <select id="division" name="division_id" class="form-select">
                      <option value="">Select Group</option>
                      <% for (java.util.Map<String,Object> g : divisions) { %>
                        <option data-spec="<%= g.get("specialization_id") %>" value="<%= g.get("id") %>"><%= g.get("name") %></option>
                      <% } %>
                    </select>
                  </div>
                </div>

                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Highest Qualification</label>
                    <select name="qualification" class="form-select">
                      <option value="">Select Qualification</option>
                      <option>PhD</option>
                      <option>Master</option>
                      <option>Bachelor</option>
                    </select>
                  </div>
                  <div class="col-md-6 mb-3">
                    <label class="form-label">Academic Rank</label>
                    <select name="rank" class="form-select">
                      <option value="">Select Rank</option>
                      <option>Professor</option>
                      <option>Associate Professor</option>
                      <option>Senior Lecturer</option>
                      <option>Lecturer</option>
                    </select>
                  </div>
                </div>

                <div class="mb-3">
                  <label class="form-label">Years of Experience</label>
                  <input type="number" name="years_experience" class="form-control" min="0" />
                </div>

                <div class="mb-3">
                  <label class="form-label">Linked User Account</label>
                  <select name="linked_user_id" class="form-select">
                    <option value="">No Linked Account</option>
                    <% for (java.util.Map<String,Object> u : users) { %>
                      <option value="<%= u.get("id") %>"><%= u.get("full_name") %> (<%= u.get("username") %>)</option>
                    <% } %>
                  </select>
                </div>

                <div class="d-flex justify-content-end gap-2">
                  <a href="<%= request.getContextPath() %>/admin/adminDashboard.jsp" class="btn btn-outline-action">Cancel</a>
                  <button class="btn btn-primary-action"><i class="bi bi-save" style="margin-right:8px"></i> Save Academic Staff</button>
                </div>
              </form>

            </div>
          </div>
        </div>
      </div>
    </div>

    <script>
      // client-side filtering: when specialization changes, filter expertise & divisions
      $(function(){
        function filterBySpec(specId){
          if(!specId){
            $('#expertise option').show();
            $('#division option').show();
            return;
          }
          $('#expertise option').each(function(){
            var s = $(this).data('spec');
            $(this).toggle(s == specId);
          });
          $('#division option').each(function(){
            var s = $(this).data('spec');
            $(this).toggle(s == specId);
          });
        }
        $('#specialization').on('change', function(){ filterBySpec(parseInt(this.value) || null); });
        // initialize
        filterBySpec($('#specialization').val() ? parseInt($('#specialization').val()) : null);
      });
    </script>
  </body>
</html>
