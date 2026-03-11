%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.socialmedia.util.DBUtil" %>
<%@page import="jakarta.servlet.http.HttpSession" %>
<%@page import="jakarta.servlet.http.HttpServletRequest" %>
<%@page import="jakarta.servlet.http.HttpServletResponse" %>
<%
    HttpSession sessionn = request.getSession(false);
    if (sessionn != null) {
        sessionn.invalidate();
    }
    response.sendRedirect("index.jsp");
%>
