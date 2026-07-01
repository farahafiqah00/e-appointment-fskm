<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Forgot Password - E-Appointment FSKM</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body class="login">
  <%
    boolean sent  = "1".equals(request.getParameter("sent"));
    boolean error = "1".equals(request.getParameter("error"));
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

          <% if (sent) { %>
          <div style="text-align:center;padding:24px 0;">
            <i class="bi bi-envelope-check-fill" style="font-size:2.5rem;color:#0f766e;"></i>
            <h5 style="font-weight:700;color:#111827;margin-top:12px;">Check Your Email</h5>
            <p style="color:#6b7280;font-size:0.93rem;margin-bottom:20px;">
              If that email address is registered and active, a password reset link has been sent.
              The link expires in <strong>30 minutes</strong>.
            </p>
            <p style="color:#6b7280;font-size:0.85rem;">Didn't receive it? Check your spam folder or try again.</p>
            <a href="<%= request.getContextPath() %>/ForgotPasswordServlet"
               class="btn btn-primary-action w-100 mt-2" style="border-radius:10px;font-weight:600;">
              Try Again
            </a>
            <a href="<%= request.getContextPath() %>/login.jsp"
               class="d-block text-center mt-3 small-foot">
              <i class="bi bi-arrow-left me-1"></i>Back to Login
            </a>
          </div>
          <% } else { %>

          <h5 style="font-weight:700;color:#111827;margin-bottom:4px;">Forgot Password?</h5>
          <p style="color:#6b7280;font-size:0.92rem;margin-bottom:20px;">
            Enter your registered email address. We'll send you a link to reset your password.
          </p>

          <% if (error) { %>
          <div class="alert alert-danger py-2" style="font-size:0.9rem;">
            Please enter a valid email address.
          </div>
          <% } %>

          <form method="POST" action="<%= request.getContextPath() %>/ForgotPasswordServlet">
            <div class="mb-3">
              <label class="form-label small-foot">Email Address</label>
              <div class="input-with-icon">
                <div class="icon"><i class="bi bi-envelope"></i></div>
                <input type="email" name="email" class="form-control"
                       placeholder="your@email.com" required autofocus>
              </div>
            </div>

            <div class="d-grid mt-3">
              <button type="submit" class="btn btn-primary-action btn-lg action-card">
                Send Reset Link
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
