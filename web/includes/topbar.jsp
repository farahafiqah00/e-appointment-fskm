<%-- Shared topbar include: shows role + name on profile page, only name on other pages --%>
<%
  String fullName = (String) session.getAttribute("full_name");
  String role = (String) session.getAttribute("role_name");
  String title = (String) session.getAttribute("staff_title");
  if (title == null || title.trim().isEmpty()) {
    title = (String) session.getAttribute("title_name");
  }
  if (title == null || title.trim().isEmpty()) {
    title = (String) session.getAttribute("title");
  }
  if (fullName == null || fullName.trim().isEmpty()) {
    fullName = "User";
  }
  if (role == null) {
    role = "User";
  }
  String displayName = (title != null && !title.trim().isEmpty()) ? title.trim() + " " + fullName : fullName;

  // Check if this is a profile page
  String requestUri = request.getRequestURI();
  boolean isProfilePage = requestUri.contains("ProfileServlet") || requestUri.contains("userProfile.jsp");
%>
<div class="topbar d-flex align-items-center px-4">
  <button class="sidebar-toggle" id="sidebarToggleBtn" aria-label="Toggle navigation"><i class="bi bi-list"></i></button>
  <div class="d-flex align-items-center"><div class="brand">E-Appointment FSKM</div></div>
  <div class="ms-auto d-flex align-items-center topbar-account">
    <% if (isProfilePage) { %>
      <div class="me-2 fw-semibold" style="color:#556168;"><%= role %></div>
      <div class="me-2" style="color:#d1d5db;">|</div>
    <% } %>
    <div class="me-2 account-name">
      <div><%= displayName %></div>
    </div>
    <div class="me-2" style="color:#d1d5db;">|</div>
    <div class="account-logout"><a href="<%= request.getContextPath() %>/LogoutServlet" class="text-decoration-none d-flex align-items-center gap-1"><i class="bi bi-box-arrow-right"></i> Logout</a></div>
  </div>
</div>
