<%@ page contentType="text/html;charset=UTF-8" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess != null && sess.getAttribute("user_id") != null) {
        String role = (String) sess.getAttribute("role_name");
        if ("Dean".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/DeanDashboardServlet");
        } else if ("Academician".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/AcademicianDashboardServlet");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/adminDashboard.jsp");
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
%>
