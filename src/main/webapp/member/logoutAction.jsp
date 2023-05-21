<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 한글 깨지지 않게 인코딩
	request.setCharacterEncoding("utf-8");

	session.invalidate(); // 기존 세션을 지우고 갱신
	response.sendRedirect(request.getContextPath() + "/home.jsp");
%>