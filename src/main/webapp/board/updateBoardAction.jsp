<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%
	//method가 post방식이므로 인코딩
	request.setCharacterEncoding("utf-8");

	// 1. 유효성 검사
	// 세션값, 요청값 (boardNo, memberId)
	String msg = null;
	if(session.getAttribute("loginMemberId") == null
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
	// 세션 아이디와 memberId가 일치하는지 확인
	if(!sessionId.equals(memberId)) {
		msg = URLEncoder.encode("비정상적인 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp?msg=" + msg);
		return;
	}
	// 나머지 요청값도 검사
	// localName, boardTitle, boardContent
	if(request.getParameter("localName") == null
			|| request.getParameter("localName").equals("")) {
		msg = URLEncoder.encode("카테고리를 선택해주세요","utf-8");
	} else if(request.getParameter("boardTitle") == null
			|| request.getParameter("boardTitle").equals("")) {
		msg = URLEncoder.encode("제목을 입력해주세요","utf-8");
	} else if(request.getParameter("boardContent") == null
			|| request.getParameter("boardContent").equals("")) {
		msg = URLEncoder.encode("내용을 입력해주세요","utf-8");
	}
	if(msg != null) {
		response.sendRedirect(request.getContextPath() + "/board/updateBoardForm.jsp?boardNo=" + boardNo + "&memberId=" + memberId + "&msg=" + msg);
		return;
	}
	// null이거나 공백이 아니면 값 불러오기
	String localName = request.getParameter("localName");
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	// 디버깅
	System.out.println(sessionId + " <- updateBoardAction sessionId");
	System.out.println(memberId + " <- updateBoardAction memberId");
	System.out.println(boardNo + " <- updateBoardAction boardNo");
	System.out.println(localName + " <- updateBoardAction localName");
	System.out.println(boardTitle + " <- updateBoardAction boardTitle");
	System.out.println(boardContent + " <- updateBoardAction boardContent");
	
	// 2. 모델값
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리 작성
	String sql = "UPDATE board SET local_name = ?, board_title = ?, board_content = ?, updatedate = NOW() WHERE board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, localName);
	stmt.setString(2, boardTitle);
	stmt.setString(3, boardContent);
	stmt.setInt(4, boardNo);
	
	// 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	if(row == 1) {
		System.out.println(row + " <- updateBoardAction 성공");
		String boardMsg = URLEncoder.encode("게시글이 수정되었습니다","utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo + "&boardMsg=" + boardMsg);
		return;
	} else {
		System.out.println(row + " <- updateBoardAction 실패");
		msg = URLEncoder.encode("게시글이 수정되지 않았습니다 다시 시도해주세요","utf-8");
		response.sendRedirect(request.getContextPath() + "/board/updateBoardForm.jsp?boardNo=" + boardNo + "&memberId=" + memberId + "&msg=" + msg);
		return;
	}
%>