<%--
  Login page. Accepts an optional returnUrl query param (from LoginServlet or email action links)
  so the user is redirected back to the intended page after successful authentication.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>E-Appointment System - Login</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=<%= System.currentTimeMillis() %>">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
  <body class="login">
    <div class="login-wrapper">
      <div class="login-card">
        <div class="login-brand">
          <div class="brand-inner">
            <img src="<%= request.getContextPath() %>/image/logo.png"
               alt="UMT" style="max-width:140px;margin-bottom:18px"
               onerror="this.style.display='none'">
            <h2 style="color:var(--primary); font-weight:800;">E-Appointment FSKM</h2>
            <p class="muted">Faculty of Computer Science and Mathematics</p>
          </div>
        </div>

        <div class="login-form">
          <form method="POST" action="LoginServlet">
            <%-- Pass returnUrl through form so LoginServlet can redirect back after login --%>
            <% String _returnUrl = request.getParameter("returnUrl"); %>
            <% if (_returnUrl != null && !_returnUrl.isEmpty()) { %>
            <input type="hidden" name="returnUrl" value="<%= _returnUrl.replace("\"", "&quot;") %>">
            <% } %>
            <div style="max-width:520px;margin:0 auto;padding-top:12px">
              <div class="mb-4">
                <label class="form-label small-foot">Email</label>
                <div class="input-with-icon">
                  <div class="icon"><i class="bi bi-envelope"></i></div>
                  <input type="email" name="email" class="form-control" placeholder="admin@umt.edu" required>
                </div>
              </div>

              <div class="mb-3">
                <label class="form-label small-foot">Password</label>
                <div class="input-with-icon">
                  <div class="icon"><i class="bi bi-lock"></i></div>
                  <input type="password" name="password" class="form-control" placeholder="Password" required>
                </div>
              </div>

              <div>
                <% String error = request.getParameter("error"); String msg = request.getParameter("msg"); Object att = request.getAttribute("errorMessage"); %>
                <% if (att != null) { %>
                  <div class="alert alert-danger py-2"> <%= att.toString() %> </div>
                <% } else if (error != null) { %>
                  <div class="alert alert-danger py-2"><%= (msg!=null?msg:"Invalid login") %></div>
                <% } else if ("1".equals(request.getParameter("setup"))) { %>
                  <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;padding:14px 16px;display:flex;align-items:center;gap:12px;margin-bottom:4px;">
                    <i class="bi bi-check-circle-fill" style="color:#16a34a;font-size:1.5rem;flex-shrink:0;"></i>
                    <div>
                      <div style="font-weight:700;color:#166534;font-size:0.93rem;">Administrator account created</div>
                      <div style="color:#166534;font-size:0.82rem;opacity:0.85;">Check your email for the temporary password.</div>
                    </div>
                  </div>
                <% } else if ("1".equals(request.getParameter("reset"))) { %>
                  <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;padding:14px 16px;display:flex;align-items:center;gap:12px;margin-bottom:4px;">
                    <i class="bi bi-check-circle-fill" style="color:#16a34a;font-size:1.5rem;flex-shrink:0;"></i>
                    <div>
                      <div style="font-weight:700;color:#166534;font-size:0.93rem;">Password reset successfully</div>
                      <div style="color:#166534;font-size:0.82rem;opacity:0.85;">You can now log in with your new password.</div>
                    </div>
                  </div>
                <% } %>
              </div>

              <div class="d-grid mt-3">
                <button type="submit" class="btn btn-primary-action btn-lg action-card">Login</button>
              </div>

              <div class="d-flex justify-content-between align-items-center mt-3">
                <a href="<%= request.getContextPath() %>/ForgotPasswordServlet" class="small-foot">Forgot password?</a>
                <a href="#" class="small-foot" data-bs-toggle="modal" data-bs-target="#helpModal">Need help?</a>
              </div>

              <div class="text-center mt-4 small-foot">Secure login &middot; Protected by UMT</div>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Need Help Modal -->
    <div class="modal fade" id="helpModal" tabindex="-1" aria-labelledby="helpModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:16px;border:none;box-shadow:0 8px 40px rgba(0,0,0,0.12);">
          <div class="modal-body text-center p-4">
            <i class="bi bi-question-circle-fill" style="font-size:2rem;color:#0f766e;"></i>
            <h5 class="mt-2 mb-1" style="font-weight:700;color:#111827;">Need Help?</h5>
            <p class="text-muted mb-3" style="font-size:0.92rem;">For assistance with the E-Appointment FSKM system, please contact the faculty office.</p>
            <div style="background:#f0fdf4;border:1px solid #bbf7d0;border-radius:10px;padding:12px 16px;text-align:left;font-size:0.88rem;color:#065f46;">
              <div><i class="bi bi-building me-2"></i><strong>Fakulti Sains Komputer dan Matematik</strong></div>
              <div class="mt-1"><i class="bi bi-geo-alt me-2"></i>Universiti Malaysia Terengganu, 21030 Kuala Nerus</div>
              <div class="mt-1"><i class="bi bi-telephone me-2"></i><strong>Tel:</strong> 09-633 3222</div>
              <div class="mt-1"><i class="bi bi-envelope me-2"></i><strong>Email:</strong> fskm@umt.edu.my</div>
              <div class="mt-1"><i class="bi bi-globe me-2"></i><strong>Web:</strong> www.umt.edu.my</div>
            </div>
            <button type="button" class="btn btn-primary-action mt-3 w-100" data-bs-dismiss="modal" style="border-radius:10px;font-weight:600;">Close</button>
          </div>
        </div>
      </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  </body>
</html>
