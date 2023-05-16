<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	//method가 post방식이므로 인코딩
	request.setCharacterEncoding("utf-8");

	// 1. 유효성 검사
	// 1-1) 세션값 또는 memberId
	if(session.getAttribute("loginMemberId") == null
			|| request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	// 1-2) 요청값
	String msg = null;
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
		response.sendRedirect(request.getContextPath() + "/board/insertBoardForm.jsp?msg=" + msg);
		return;
	}
	
	// 1-3) null이거나 공백이 아니면 값 불러오기
	String memberId = request.getParameter("memberId");
	String localName = request.getParameter("localName");
	String boardTitle = request.getParameter("boardTitle");
	String boardContent = request.getParameter("boardContent");
	System.out.println(memberId + " <- insertBoardAction memberId");
	System.out.println(localName + " <- insertBoardAction localName");
	System.out.println(boardTitle + " <- insertBoardAction boardTitle");
	System.out.println(boardContent + " <- insertBoardAction boardContent");
	
	// 1-4) 파라미터값 클래스에 저장
	Board paramBoard = new Board();
	paramBoard.setMemberId(memberId);
	paramBoard.setLocalName(localName);
	paramBoard.setBoardTitle(boardTitle);
	paramBoard.setBoardContent(boardContent);
	
	// 2. 모델값 구하기
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-1) 쿼리 작성
	String sql = "INSERT INTO board(local_name, board_title, board_content, member_id, createdate, updatedate) VALUES(?,?,?,?,NOW(),NOW())";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, paramBoard.getLocalName());
	stmt.setString(2, paramBoard.getBoardTitle());
	stmt.setString(3, paramBoard.getBoardContent());
	stmt.setString(4, paramBoard.getMemberId());
	System.out.println(stmt + " <- insertBoardAction stmt");
	
	// 2-2) 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	if(row == 1) {
		System.out.println(row + " <- insertBoardAction 성공");
		msg = URLEncoder.encode("게시글이 작성되었습니다","utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	} else {
		System.out.println(row + " <- insertBoardAction 실패");
		msg = URLEncoder.encode("게시글이 작성에 실패하였습니다 다시 시도해주세요","utf-8");
		response.sendRedirect(request.getContextPath() + "/insertBoardForm.jsp?msg=" + msg);
		return;
	}
%>