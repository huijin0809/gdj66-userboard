<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	// 한글 깨지지 않게 인코딩
	request.setCharacterEncoding("utf-8");

	//콘솔창 출력 색상 지정
	final String RED = "\u001B[31m";
	final String BG_RED = "\u001B[41m";
	final String GREEN = "\u001B[32m";
	final String BG_GREEN = "\u001B[42m";
	final String RESET = "\u001B[0m";
	
	// 1) 요청값 유효성 검사
	// 세션값
	String sessionId = "";
	if(session.getAttribute("loginMemberId") != null) {
		sessionId = (String)session.getAttribute("loginMemberId");
	}
	// currentPage, rowPerPage, boardNo
	System.out.println(RED + request.getParameter("currentPage") + " <- boardOne param currentPage");
	System.out.println(request.getParameter("rowPerPage") + " <- boardOne param rowPerPage");
	System.out.println(request.getParameter("boardNo") + " <- boardOne param boardNo" + RESET);

	// boardNo가 null이거나 공백이면 home으로 리다이렉션
	if(request.getParameter("boardNo") == null
			|| request.getParameter("boardNo").equals("")) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	// currentPage
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	// rowPerPage
	int rowPerPage = 10;
	if(request.getParameter("rowPerPage") != null) {
		rowPerPage = Integer.parseInt(request.getParameter("rowPerPage"));
	}
	// 디버깅
	System.out.println(GREEN + currentPage + " <- boardOne currentPage");
	System.out.println(rowPerPage + " <- boardOne rowPerPage");
	System.out.println(boardNo + " <- boardOne boardNo" + RESET);
	
	// 2) 모델값 구하기
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-1) 해당 boardNo의 게시글 상세보기 - boardOne
	// SELECT * FROM board WHERE board_no = ?
	PreparedStatement boardOneStmt = null;
	ResultSet boardOneRs = null;
	String boardOneSql = "SELECT board_no boardNo, local_name localName, board_title boardTitle, board_content boardContent, member_id memberId, createdate createdate, updatedate updatedate FROM board WHERE board_no = ?";
	boardOneStmt = conn.prepareStatement(boardOneSql);
	boardOneStmt.setInt(1, boardNo);
	System.out.println(BG_GREEN + boardOneStmt + " <- boardOne boardOneStmt");
	
	// Vo타입으로 바꾸기
	boardOneRs = boardOneStmt.executeQuery();
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
	
	// 2-2) 해당 boardNo의 댓글 리스트 출력 - commentList
	// 모델값을 구하기 위한 변수 추가
	int startRow = (currentPage - 1) * rowPerPage;
	
	// 쿼리 작성 // 작성일자 순으로 내림차순 정렬
	// SELECT comment_content, member_id, createdate, updatedate FROM comment WHERE board_no = ? ORDER BY createdate DESC LIMIT ?, ?
	PreparedStatement commentListStmt = null;
	ResultSet commentListRs = null;
	String commentListSql = "SELECT comment_no commentNo, comment_content commentContent, member_id memberId, createdate createdate, updatedate updatedate FROM comment WHERE board_no = ? ORDER BY createdate DESC LIMIT ?, ?";
	commentListStmt = conn.prepareStatement(commentListSql);
	commentListStmt.setInt(1, boardNo);
	commentListStmt.setInt(2, startRow);
	commentListStmt.setInt(3, rowPerPage);
	System.out.println(commentListStmt + " <- boardOne commentListStmt");
	
	// Vo타입의 ArrayList로 바꾸기
	commentListRs = commentListStmt.executeQuery();
	ArrayList<Comment> commentList = new ArrayList<Comment>();
	while(commentListRs.next()) {
		Comment c = new Comment();
		c.setCommentNo(commentListRs.getInt("commentNo"));
		c.setCommentContent(commentListRs.getString("commentContent"));
		c.setMemberId(commentListRs.getString("memberId"));
		c.setCreatedate(commentListRs.getString("createdate"));
		c.setUpdatedate(commentListRs.getString("updatedate"));
		commentList.add(c);
	}
	// 디버깅
	System.out.println(BG_RED + commentList + " <- boardOne commentList");
	System.out.println(commentList.size() + " <- boardOne commentList.size" + RESET);
	
	// 2-3) 페이징을 위한 모델값 구하기
	// 모델값을 구하기 위한 변수 추가
	int totalCount = 0;
	int lastPage = 0;
	
	// 해당 boardNo의 댓글의 총 갯수를 구하는 쿼리 작성
	PreparedStatement commentPageStmt = null;
	ResultSet commentPageRs = null;
	String commentPageSql = "SELECT count(*) FROM comment WHERE board_no = ?";
	commentPageStmt = conn.prepareStatement(commentPageSql);
	commentPageStmt.setInt(1, boardNo);
	System.out.println(BG_GREEN + commentPageStmt + " <- boardOne commentPageStmt" + RESET);
	
	// totalCount
	commentPageRs = commentPageStmt.executeQuery();
	if(commentPageRs.next()) {
		// 결과값을 변수에 저장
		totalCount = commentPageRs.getInt("count(*)");
	}
	System.out.println(GREEN + totalCount + " <- boardOne totalCount");
	
	// lastPage
	lastPage = totalCount / rowPerPage;
	if(totalCount % rowPerPage != 0) {
		lastPage = lastPage + 1;
	}
	System.out.println(lastPage + " <- boardOne lastPage" + RESET);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>boardOne.jsp</title>
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
	<!-- boardMsg 발생시 출력 -->
	<div class="text-danger">
		<%
			if(request.getParameter("boardMsg") != null) {
		%>
				<%=request.getParameter("boardMsg")%>
		<%
			}
		%>
	</div>
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
	<%
		// 게시글을 작성한 본인만 수정/삭제에 접근 가능
		if(sessionId.equals(board.getMemberId())) {
	%>
			<div class="text-center">
				<a href="<%=request.getContextPath()%>/board/updateBoardForm.jsp?boardNo=<%=boardNo%>&memberId=<%=board.getMemberId()%>" class="btn btn-secondary">
					수정
				</a>
				<a href="<%=request.getContextPath()%>/board/deleteBoardAction.jsp?boardNo=<%=boardNo%>&memberId=<%=board.getMemberId()%>" class="btn btn-danger">
					삭제
				</a>
			</div>
	<%
		}
	%>
	<!--------------------------------------------------------- boardOne 끝 ------------------------------------------------------------------>
		
	<br>
	
	<!----------------------------------------------------- 댓글입력폼 (세션에 id값이 있을때만 출력) --------------------------------------------------->
	<div>
		<%
			// 로그인 사용자만 댓글 입력을 허용하기 위해 분기
			if(session.getAttribute("loginMemberId") != null) {
				// 현재 로그인 사용자의 아이디를 변수에 넣기
				String loginMemberId = (String)session.getAttribute("loginMemberId"); // 형변환해주기
		%>
				<h1>Comment</h1>
				<div class="text-danger">
					<%
						// commentMsg 발생시 출력
						if(request.getParameter("commentMsg") != null) {
					%>
							<%=request.getParameter("commentMsg") %>
					<%
						}
					%>
				</div>
				<form action="<%=request.getContextPath()%>/board/insertCommentAction.jsp" method="post">
					<!-- boardNo와 memberId는 입력값이 없기 때문에 hidden으로 넘김 -->
					<input type="hidden" name="boardNo" value="<%=board.getBoardNo()%>">
					<input type="hidden" name="memberId" value="<%=loginMemberId%>">
					<table>
						<tr>
							<td>내용</td>
							<td>
								<textarea rows="3" cols="80" name="commentContent"></textarea>
							</td>
						</tr>
					</table>
					<button type="submit" class="btn btn-secondary">입력</button>
				</form>
		<%
			}
		%>
	</div>
	<!----------------------------------------------------------- 댓글입력폼 끝 ----------------------------------------------------------------->

	<br>
	
	<!------------------------------------------------------- 댓글리스트 commentList모델 출력  ----------------------------------------------------->
	<table class="table table-hover">
		<thead>
			<tr>
				<th>댓글 내용</th>
				<th>작성자</th>
				<th>작성일자</th>
				<th>수정일자</th>
				<th>수정</th>
				<th>삭제</th>
			</tr>
		</thead>
		<tbody>			
			<%
				for(Comment c : commentList) {
			%>
					<tr>
						<td><%=c.getCommentContent()%></td>
						<td><%=c.getMemberId()%></td>
						<td><%=c.getCreatedate()%></td>
						<td><%=c.getUpdatedate()%></td>
						<td>
							<%
								// 댓글을 작성한 본인만 수정에 접근 가능
								if(sessionId.equals(c.getMemberId())) {
							%>
									<a href="<%=request.getContextPath()%>/board/updateCommentForm.jsp?boardNo=<%=boardNo%>&memberId=<%=c.getMemberId()%>&commentNo=<%=c.getCommentNo()%>" class="btn btn-outline-secondary btn-sm">
										수정
									</a>
							<%
								}
							%>
						</td>
						<td>
							<%
								// 댓글을 작성한 본인만 삭제에 접근 가능
								if(sessionId.equals(c.getMemberId())) {
							%>
									<a href="<%=request.getContextPath()%>/board/deleteCommentAction.jsp?boardNo=<%=boardNo%>&memberId=<%=c.getMemberId()%>&commentNo=<%=c.getCommentNo()%>" class="btn btn-outline-secondary btn-sm">
										삭제
									</a>
							<%
								}
							%>
						</td>
					</tr>
			<%
				}
			%>
		</tbody>
	</table>
	<%
		// 댓글이 없으면 출력
		if(totalCount == 0) {
	%>
			<h5 class="krFont">댓글이 없습니다 ㅠㅠ</h5>
	<%
		}
	%>
	
	<!------- 페이징 시작 ------->
	<div class="text-center">
		<%
			if(currentPage > 1) {
		%>
				<a href="<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=currentPage - 1 %>&rowPerPage=<%=rowPerPage%>&boardNo=<%=boardNo%>" class="btn btn-secondary btn-sm">
					이전
				</a>
		<%
			}
		%>
			<%=currentPage%>페이지
		<%
			if(lastPage > currentPage) {
		%>
			<a href="<%=request.getContextPath()%>/board/boardOne.jsp?currentPage=<%=currentPage + 1%>&rowPerPage=<%=rowPerPage%>&boardNo=<%=boardNo%>" class="btn btn-secondary btn-sm">
				다음
			</a>
		<%
			}
		%>
	</div>
	<!------- 페이징 끝 ------->
	<!--------------------------------------------------------------- commentList 끝 -------------------------------------------------------------->
</div>

	<br>
	
<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>

</body>
</html>