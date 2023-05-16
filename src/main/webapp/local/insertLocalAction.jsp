<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%
	// 1. 유효성 검사
	// 세션
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	String memberId = (String)session.getAttribute("loginMemberId");
	// 요청값
	String msg = null;
	if(request.getParameter("localName") == null
			|| request.getParameter("localName").equals("")) {
		msg = URLEncoder.encode("카테고리 이름이 입력되지 않았습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/insertLocalForm.jsp?msg=" + msg);
		return;
	}
	String localName = request.getParameter("localName");
	// 디버깅
	System.out.println(memberId + " <- insertLocalAction session loginMemberId");
	System.out.println(localName + " <- insertLocalAction localName");
	
	// 2. 모델값 구하기
	// 2-1. 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-2. localName 중복검사
	// 해당 localName이 데이터에 존재하는지(where) count 해본다
	String countSql = "SELECT count(*) FROM local WHERE local_name = ?";
	PreparedStatement countStmt = conn.prepareStatement(countSql);
	countStmt.setString(1, localName);
	System.out.println(countStmt + " <- insertLocalAction count stmt");
	ResultSet countRs = countStmt.executeQuery();
	
	// 갯수 확인
	int cnt = 0;
	if(countRs.next()) {
		cnt = countRs.getInt("count(*)");
		// 해당 localName의 갯수를 cnt 변수에 저장
		// 0일 경우 중복 없음 
	}
	
	// 0보다 클 경우 중복 있음 // form으로 리다이렉션
	if(cnt > 0) {
		System.out.println(cnt + " <- insertLocalAction 중복된 카테고리 갯수");
		msg = URLEncoder.encode("이미 존재하는 이름입니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/insertLocalForm.jsp?msg=" + msg);
		return;
	} else {
		System.out.println("insertLocalAction 중복된 카테고리 없음");
	}
	
	// 2-3. 쿼리 작성
	String sql = "INSERT INTO local(local_name, createdate, updatedate) VALUES(?, NOW(), NOW())";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, localName);
	System.out.println(stmt + " <- insertLocalAction stmt");
	
	// 2-4. 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	if(row == 1) { // 성공시 localList로
		System.out.println(row + " <- insertLocalAction 성공");
		msg = URLEncoder.encode("카테고리가 생성되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/localList.jsp?msg=" + msg);
		return;
	} else { // 실패시 Form으로
		System.out.println(row + " <- insertLocalAction 실패");
		msg = URLEncoder.encode("카테고리가 생성되지 않았습니다 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/local/insertLocalForm.jsp?msg=" + msg);
		return;
	}
%>