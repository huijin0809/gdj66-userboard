<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	//1. 유효성 검사
	// 세션값, 요청값 (boardNo, memberId)
	if(session.getAttribute("loginMemberId") == null
			|| request.getParameter("boardNo") == null
			|| request.getParameter("boardNo").equals("")
			|| request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")
			|| request.getParameter("commentNo") == null
			|| request.getParameter("commentNo").equals("")) {
		String msg = URLEncoder.encode("비정상적인 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	// null이거나 공백이 아니면 값 불러오기
	String sessionId = (String)session.getAttribute("loginMemberId");
	String memberId = request.getParameter("memberId");
	// 세션 아이디와 memberId가 일치하는지 확인
	if(!sessionId.equals(memberId)) {
		String msg = URLEncoder.encode("비정상적인 접근입니다","utf-8");
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}
	// 일치하면 나머지 값도 불러오기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int commentNo = Integer.parseInt(request.getParameter("commentNo"));
	System.out.println(sessionId + " <- updateBoardForm sessionId");
	System.out.println(memberId + " <- updateBoardForm memberId");
	System.out.println(boardNo + " <- updateBoardForm boardNo");
	System.out.println(commentNo + " <- updateBoardForm commentNo");
	
	// 2. 모델값
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-1) 수정 전 입력값 조회를 위한 쿼리 작성
	// SELECT * FROM comment WHERE comment_no = ?
	String sql = "SELECT comment_no commentNo, board_no boardNo, comment_content commentContent, member_id memberId, createdate, updatedate FROM comment WHERE comment_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, commentNo);
	ResultSet rs = stmt.executeQuery();
	
	// 2-2) Vo타입으로 바꾸기
	Comment comment = null;
	if(rs.next()) {
		comment = new Comment();
		comment.setCommentNo(rs.getInt("commentNo"));
		comment.setBoardNo(rs.getInt("boardNo"));
		comment.setCommentContent(rs.getString("commentContent"));
		comment.setMemberId(rs.getString("memberId"));
		comment.setCreatedate(rs.getString("createdate"));
		comment.setUpdatedate(rs.getString("updatedate"));
	}
	
	// 2-3) 해당 boardNo의 게시글 상세보기 - boardOne
	// SELECT * FROM board WHERE board_no = ?
	String boardOneSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate createdate, updatedate updatedate FROM board WHERE board_no = ?";
	PreparedStatement boardOneStmt = conn.prepareStatement(boardOneSql);
	boardOneStmt.setInt(1, boardNo);
	ResultSet boardOneRs = boardOneStmt.executeQuery();
	
	// Vo타입으로 바꾸기
	Board board = null;
	if(boardOneRs.next()) {
		board = new Board();
		board.setBoardNo(boardOneRs.getInt("boardNo"));
		board.setLocalName(boardOneRs.getString("localName"));
		board.setBoardTitle(boardOneRs.getString("boardTitle"));
		board.setBoardContent(boardOneRs.getString("boardContent"));
		board.setMemberId(boardOneRs.getString("memberId"));
		board.setCreatedate(boardOneRs.getString("createdate"));
		board.setUpdatedate(boardOneRs.getString("updatedate"));
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>updateCommentForm.jsp</title>
	<!-- Bootswatch 사용 -->
	<link href="<%=request.getContextPath()%>/bootstrap.min.css" rel="stylesheet">
	<!-- 폰트 변경 -->
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Gowun+Dodum&display=swap" rel="stylesheet">
<style>
	.krFont {
		font-family: 'Gowun Dodum', sans-serif;
	}
	a {
		text-decoration-line: none;
	}
</style>
</head>
<body>
<div> <!-- mainmenu include -->
	<jsp:include page="/inc/mainmenu.jsp"></jsp:include>
</div>

<div class="container mt-5 krFont">
	<!-------------------------------------------------- 게시글 상세보기 boardOne모델 출력------------------------------------------------------>
	<h1>Post</h1>
	<table class="table container">
		<tr>
			<th class="table-dark">글번호</th>
			<td>No.<%=board.getBoardNo()%></td>
		</tr>
		<tr>
			<th class="table-dark">카테고리</th>
			<td><%=board.getLocalName()%></td>
		</tr>
		<tr>
			<th class="table-dark">작성자</th>
			<td><%=board.getMemberId()%></td>
		</tr>
		<tr>
			<th class="table-dark">제목</th>
			<td><%=board.getBoardTitle()%></td>
		</tr>
		<tr>
			<th class="table-dark">내용</th>
			<td><%=board.getBoardContent()%></td>
		</tr>
		<tr>
			<th class="table-dark">작성일자</th>
			<td><%=board.getCreatedate()%></td>
		</tr>
		<tr>
			<th class="table-dark">수정일자</th>
			<td><%=board.getUpdatedate()%></td>
		</tr>
	</table>
	<!-------------------------------------------------- 게시글 상세보기 boardOne모델 끝 ------------------------------------------------------>
	<br>
	<!---------------------- 댓글 update form 시작 ---------------------->
	<h1>Edit Comment</h1>
		<!-- 실패시 에러메세지 출력 -->
		<div class="text-danger">
			<%
				if(request.getParameter("msg") != null) {
			%>
					<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div>
		<form action="<%=request.getContextPath()%>/board/updateCommentAction.jsp" method="post">
			<input type="hidden" name="commentNo" value="<%=comment.getCommentNo()%>">
			<input type="hidden" name="boardNo" value="<%=comment.getBoardNo()%>">
			<table class="table container">
				<tr>
					<th class="table-dark">댓글 내용</th>
					<td>
						<textarea rows="5" cols="100" name="commentContent"><%=comment.getCommentContent()%></textarea>
					</td>
				</tr>
				<tr>
					<th class="table-dark">작성자</th>
					<td>
						<input type="text" name="memberId" value="<%=comment.getMemberId()%>" readonly>
					</td>
				</tr>
				<tr>
					<th class="table-dark">작성일자</th>
					<td>
						<%=comment.getCreatedate()%>
					</td>
				</tr>
				<tr>
					<th class="table-dark">수정일자</th>
					<td>
						<%=comment.getUpdatedate()%>
					</td>
				</tr>
			</table>
			<a href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=boardNo%>" class="btn btn-secondary">
				취소
			</a>
			<button type="submit" class="btn btn-outline-secondary">수정</button>
		</form>
	<!---------------------- 댓글 update form 끝 ---------------------->
</div>

<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>
</html>