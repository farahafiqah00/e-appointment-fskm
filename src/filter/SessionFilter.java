package filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Enforces login for all application URLs.
 * Public paths (login, password reset, external examiner/panel token flows, static assets) bypass the check.
 */
@WebFilter(filterName = "SessionFilter", urlPatterns = {"/*"})
public class SessionFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String ctx  = req.getContextPath();
        String path = req.getRequestURI().substring(ctx.length());

        // Allow public paths through without a session
        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user_id") != null) {
            chain.doFilter(request, response);
        } else {
            // Preserve the intended URL so LoginServlet can redirect back after login
            String query = req.getQueryString();
            String intended = req.getRequestURI() + (query != null ? "?" + query : "");
            resp.sendRedirect(ctx + "/login.jsp?returnUrl=" + java.net.URLEncoder.encode(intended, "UTF-8"));
        }
    }

    private boolean isPublic(String path) {
        // Root / welcome page — index.jsp redirects to login or dashboard
        if (path.isEmpty() || path.equals("/")) return true;
        if (path.equals("/index.jsp"))           return true;

        // First-time setup (only works when DB is empty)
        if (path.equals("/setup.jsp"))             return true;
        if (path.equals("/SetupServlet"))          return true;

        // Login / auth
        if (path.equals("/login.jsp"))            return true;
        if (path.equals("/LoginServlet"))          return true;
        if (path.equals("/forgotPassword.jsp"))    return true;
        if (path.equals("/ForgotPasswordServlet")) return true;
        if (path.equals("/resetPassword.jsp"))     return true;
        if (path.equals("/ResetPasswordServlet"))  return true;

        // External token-based endpoints (no user account required)
        if (path.equals("/examinerVerify.jsp"))       return true;
        if (path.equals("/ExaminerVerifyServlet"))     return true;
        if (path.equals("/panelResponse.jsp"))         return true;
        if (path.equals("/PanelResponseServlet"))      return true;
        if (path.equals("/PanelBankDetailsServlet"))   return true;

        // Static resources
        if (path.startsWith("/css/"))    return true;
        if (path.startsWith("/js/"))     return true;
        if (path.startsWith("/image/"))  return true;
        if (path.startsWith("/images/")) return true;
        if (path.startsWith("/fonts/"))  return true;

        return false;
    }

    @Override public void init(FilterConfig cfg) {}
    @Override public void destroy() {}
}
