<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Reset Password - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="login">
  <%
    String tokenError = (String) request.getAttribute("tokenError");
    String formError  = (String) request.getAttribute("formError");
    String resetToken = (String) request.getAttribute("resetToken");
  %>
  <div class="login-wrapper">
    <div class="login-card">
      <div class="login-brand">
        <div class="brand-inner">
          <img src="/web/images/umt-logo.png" alt="UMT" style="max-width:140px;margin-bottom:18px" onerror="this.style.display='none'">
          <h2 style="color:var(--primary);font-weight:800;">E-Appointment FSKM</h2>
          <p class="muted">Faculty of Computer Science and Mathematics</p>
        </div>
      </div>

      <div class="login-form">
        <div style="max-width:520px;margin:0 auto;padding-top:12px">

          <% if (tokenError != null) { %>
          <div style="text-align:center;padding:24px 0;">
            <i class="bi bi-exclamation-circle-fill" style="font-size:2.5rem;color:#dc2626;"></i>
            <h5 style="font-weight:700;color:#111827;margin-top:12px;">Link Expired or Invalid</h5>
            <p style="color:#6b7280;font-size:0.93rem;margin-bottom:20px;"><%= tokenError %></p>
            <a href="<%= request.getContextPath() %>/ForgotPasswordServlet"
               class="btn btn-primary-action w-100" style="border-radius:10px;font-weight:600;">
              Request a New Link
            </a>
            <a href="<%= request.getContextPath() %>/login.jsp"
               class="d-block text-center mt-3 small-foot">
              <i class="bi bi-arrow-left me-1"></i>Back to Login
            </a>
          </div>
          <% } else { %>

          <h5 style="font-weight:700;color:#111827;margin-bottom:4px;">Set New Password</h5>
          <p style="color:#6b7280;font-size:0.92rem;margin-bottom:20px;">
            Enter and confirm your new password below.
          </p>

          <% if (formError != null) { %>
          <div class="alert alert-danger py-2" style="font-size:0.9rem;"><%= formError %></div>
          <% } %>

          <form method="POST" action="<%= request.getContextPath() %>/ResetPasswordServlet">
            <input type="hidden" name="token" value="<%= resetToken != null ? resetToken : "" %>">

            <div class="mb-3">
              <label class="form-label small-foot">New Password</label>
              <div class="input-with-icon">
                <div class="icon"><i class="bi bi-lock"></i></div>
                <input type="password" name="newPassword" class="form-control"
                       placeholder="Minimum 6 characters" required autofocus minlength="6">
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label small-foot">Confirm New Password</label>
              <div class="input-with-icon">
                <div class="icon"><i class="bi bi-lock-fill"></i></div>
                <input type="password" name="confirmPassword" class="form-control"
                       placeholder="Re-enter your new password" required minlength="6">
              </div>
            </div>

            <div class="d-grid mt-3">
              <button type="submit" class="btn btn-primary-action btn-lg action-card">
                Reset Password
              </button>
            </div>
          </form>

          <a href="<%= request.getContextPath() %>/login.jsp"
             class="d-block text-center mt-3 small-foot">
            <i class="bi bi-arrow-left me-1"></i>Back to Login
          </a>
          <% } %>

        </div>
      </div>
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
