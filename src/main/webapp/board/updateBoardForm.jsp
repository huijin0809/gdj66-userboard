<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	// 한글 깨지지 않게 인코딩
	request.setCharacterEncoding("utf-8");

	// 1. 유효성 검사
	// 세션값, 요청값 (boardNo, memberId)
	if(session.getAttribute("loginMemberId") == null
			|| request.getParameter("boardNo") == null
			|| request.getParameter("boardNo").equals("")
			|| request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")) {
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
	// 일치하면 boardNo도 불러오기
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	System.out.println(sessionId + " <- updateBoardForm sessionId");
	System.out.println(memberId + " <- updateBoardForm memberId");
	System.out.println(boardNo + " <- updateBoardForm boardNo");
	
	// 2. 모델값
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-1) 수정 전 입력값 조회를 위한 쿼리 작성
	// SELECT * FROM board WHERE board_no = ?
	String sql = "SELECT board_no boardNo, local_name localName, member_id memberId, board_title boardTitle, board_content boardContent, createdate, updatedate FROM board WHERE board_no = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	ResultSet rs = stmt.executeQuery();
	
	// 2-2) Vo타입으로 바꾸기
	Board board = null;
	if(rs.next()) {
		board = new Board();
		board.setBoardNo(rs.getInt("boardNo"));
		board.setLocalName(rs.getString("localName"));
		board.setMemberId(rs.getString("memberId"));
		board.setBoardTitle(rs.getString("boardTitle"));
		board.setBoardContent(rs.getString("boardContent"));
		board.setCreatedate(rs.getString("createdate"));
		board.setUpdatedate(rs.getString("updatedate"));
	}
	
	// 2-3) 카테고리 칼럼 조회를 위한 쿼리 작성
	String localSql = "SELECT local_name localName FROM local";
	PreparedStatement localStmt = conn.prepareStatement(localSql);
	ResultSet localRs = localStmt.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>updateBoardForm.jsp</title>
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
	<!---------------------- 게시글 update form 시작 ---------------------->
	<h1>Edit Post</h1>
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
		<form action="<%=request.getContextPath()%>/board/updateBoardAction.jsp" method="post">
			<table class="table container">
				<tr>
					<th class="table-secondary">글번호</th>
					<td>
						<!-- 글번호는 수정불가 (readonly) -->
						<input type="number" name="boardNo" value="<%=board.getBoardNo()%>" class="form-control" readonly>
					<td>
				</tr>
				<tr>
					<th class="table-secondary">카테고리</th>
					<td>
						<select name="localName" class="form-select" id="exampleSelect1">
							<%
								// 수정 전 카테고리 표시
								while(localRs.next()) {
							%>
								<option value="<%=localRs.getString("localName")%>" <%if(localRs.getString("localName").equals(board.getLocalName())){%> selected <%}%>>
									<%=localRs.getString("localName")%>
								</option>
							<%
								}
							%>
						</select>
					</td>
				</tr>
				<tr>
					<th class="table-secondary">작성자</th>
					<td>
						<!-- 작성자는 수정불가 (readonly) -->
						<input type="text" name="memberId" value="<%=board.getMemberId()%>" class="form-control" readonly>
					</td>
				</tr>
				<tr>
					<th class="table-secondary">제목</th>
					<td>
						<input type="text" name="boardTitle" class="form-control" value="<%=board.getBoardTitle()%>">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">내용</th>
					<td>
						<textarea rows="10" cols="190" name="boardContent"><%=board.getBoardContent()%></textarea>
					</td>
				</tr>
			</table>
			<a href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=boardNo%>" class="btn btn-secondary">
				취소
			</a>
			<button type="submit" class="btn btn-outline-secondary">수정</button>
		</form>
	<!---------------------- 게시글 update form 끝 ---------------------->
</div>

<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>
</html>