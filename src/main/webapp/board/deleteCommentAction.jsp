<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%
	// 1. 유효성 검사
	// 세션값, 요청값 (commentNo, boardNo, memberId)
	String msg = null;
	if(session.getAttribute("loginMemberId") == null
			|| request.getParameter("commentNo") == null
			|| request.getParameter("commentNo").equals("")
			|| request.getParameter("boardNo") == null
			|| request.getParameter("boardNo").equals("")
			|| request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")) {
		msg = URLEncoder.encode("비정상적인 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg=" + msg);
		return;
	}
	// null이거나 공백이 아니면 값 불러오기
	String sessionId = (String)session.getAttribute("loginMemberId");
	String memberId = request.getParameter("memberId");
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	// 세션 아이디와 memberId가 일치하는지 확인
	if(!sessionId.equals(memberId)) {
		msg = URLEncoder.encode("비정상적인 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg=" + msg);
		return;
	}
	// 디버깅
	System.out.println(sessionId + " <- updateBoardAction sessionId");
	System.out.println(memberId + " <- updateBoardAction memberId");
	System.out.println(commentNo + " <- updateBoardAction commentNo");
	System.out.println(boardNo + " <- updateBoardAction boardNo");
	
	// 2. 모델값
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리 작성
	String sql = "DELETE FROM comment WHERE comment_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, commentNo);
	System.out.println(stmt + " <- deleteCommentAction stmt");
	
	// 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	String commentMsg = null;
	if(row == 1) {
		System.out.println(row + " <- deleteCommentAction 성공");
		commentMsg = URLEncoder.encode("댓글이 삭제되었습니다","utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo + "&commentMsg=" + commentMsg);
		return;
	} else {
		System.out.println(row + " <- deleteCommentAction 실패");
		commentMsg = URLEncoder.encode("댓글이 삭제되지 않았습니다 다시 시도해주세요","utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo + "&commentMsg=" + commentMsg);
		return;
	}
%>