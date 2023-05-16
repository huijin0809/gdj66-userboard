<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.net.*"%>
<%@ page import = "vo.*" %>
<%@ page import = "java.sql.*" %>
<%
	//콘솔창 출력 색상 지정
	final String RED = "\u001B[31m";
	final String BG_RED = "\u001B[41m";
	final String GREEN = "\u001B[32m";
	final String BG_GREEN = "\u001B[42m";
	final String RESET = "\u001B[0m";
	
	// 인코딩
	request.setCharacterEncoding("utf-8");

	// 1) 요청값 유효성 검사
	// boardNo, memberId, commentContent
	System.out.println(RED + request.getParameter("boardNo") + " <- insertCommentAction param boardNo");
	System.out.println(request.getParameter("memberId") + " <- insertCommentAction param memberId");
	System.out.println(request.getParameter("commentContent") + " <- insertCommentAction param commentContent" + RESET);
	
	// boardNo, memberId
	if(request.getParameter("boardNo") == null
			|| request.getParameter("boardNo").equals("")
			|| request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	// null이거나 공백이 아니면 값 변수에 받기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	String memberId = request.getParameter("memberId");
	
	// commentContent
	if(request.getParameter("commentContent") == null
			|| request.getParameter("commentContent").equals("")) {
		String msg = URLEncoder.encode("댓글 내용을 입력해주세요!", "utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo + "&msg=" + msg);
		return;
	}
	// null이거나 공백이 아니면 값 변수에 받기
	String commentContent = request.getParameter("commentContent");
	
	// 디버깅
	System.out.println(GREEN + boardNo + " <- insertCommentAction boardNo");
	System.out.println(memberId + " <- insertCommentAction memberId");
	System.out.println(commentContent + " <- insertCommentAction commentContent" + RESET);
	
	// 파라미터값 클래스에 저장
	Comment paramComment = new Comment();
	paramComment.setBoardNo(boardNo);
	paramComment.setMemberId(memberId); 
	paramComment.setCommentContent(commentContent); 
	
	// 2) insert
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리 작성
	// INSERT INTO comment(board_no, comment_content, member_id, createdate, updatedate) VALUES(?, ?, ?, NOW(), NOW())
	String sql = "INSERT INTO comment(board_no, comment_content, member_id, createdate, updatedate) VALUES(?, ?, ?, NOW(), NOW())";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, paramComment.getBoardNo());
	stmt.setString(2, paramComment.getCommentContent());
	stmt.setString(3, paramComment.getMemberId());
	System.out.println(BG_GREEN + stmt + " <- insertCommentAction stmt");
	
	// 쿼리가 잘 실행되었는지 확인
	// 해당 boardNo의 boardOne 페이지로 리다이렉션
	int row = stmt.executeUpdate(); // 1이면 1행 성공
	if(row == 1) {
		System.out.println("insertCommentAction 댓글 입력 성공" + RESET);
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo);
		return;
	} else {
		System.out.println(BG_RED + "insertCommentAction 댓글 입력 실패" + RESET);
		String msg = URLEncoder.encode("댓글이 등록되지 않았습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/board/boardOne.jsp?boardNo=" + boardNo + "&msg=" + msg);
		return;
	}
%>