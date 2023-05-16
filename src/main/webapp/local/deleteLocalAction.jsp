<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%
	// 1. 유효성 검사
	// 세션값, localName
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		// 세션값이 없으면 home으로
		return;
	} else if(request.getParameter("localName") == null
			|| request.getParameter("localName").equals("")) {
		response.sendRedirect(request.getContextPath() + "/local/localList.jsp");
		// localName값이 없으면 localList로
		return;
	}
	String memberId = (String)session.getAttribute("loginMemberId");
	String localName = request.getParameter("localName");
	System.out.println(memberId + " <- deleteLocalAction session loginMemberId");
	System.out.println(localName + " <- deleteLocalAction localName");
	
	// 2. delete
	// 2-1. 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-2. 쿼리 작성
	String sql = "DELETE FROM local WHERE local_name = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, localName);
	System.out.println(stmt + " <- deleteLocalAction stmt");
	
	// 2-3. 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	String msg = null;
	if(row == 1) { // 성공시 localList로
		System.out.println(row + " <- deleteLocalAction 성공");
		msg = URLEncoder.encode("카테고리가 삭제되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/localList.jsp?msg=" + msg);
		return;
	} else {
		System.out.println(row + " <- deleteLocalAction 성공");
		msg = URLEncoder.encode("카테고리가 삭제되지 않았습니다 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/localList.jsp?msg=" + msg);
		return;
	}
%>