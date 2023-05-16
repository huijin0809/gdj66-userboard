<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
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
	System.out.println(memberId + " <- deleteLocalForm session loginMemberId");
	System.out.println(localName + " <- deleteLocalForm localName");
	
	// 2. 모델값 구하기
	// localCnt 모델
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 해당 localName의 게시글 수(board의 갯수)를 조회하는 쿼리 작성
	String sql = "SELECT count(*) FROM board WHERE local_name = ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, localName);
	// 변수에 값 저장
	ResultSet rs = stmt.executeQuery();
	System.out.println(stmt + " <- deleteLocalForm stmt");
	int localCnt = 0;
	if(rs.next()) {
		localCnt = rs.getInt("count(*)");
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
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
<!-------------------------------------------- deleteLocalForm 시작 ------------------------------------------->
	<!-- localCnt가 0일 경우에만 form 태그 출력 -->
	<%
		if(localCnt == 0) {
	%>
			<h1>Delete Category</h1>
			<h5 class="krFont">정말 삭제하시겠습니까?</h5>
			<form action="<%=request.getContextPath()%>/local/deleteLocalAction.jsp" method="post">
				<table class="table container">
					<tr>
						<th class="table-secondary">카테고리 이름</th>
						<td>
							<input type="text" name="localName" value="<%=localName%>" class="form-control" readonly>
						</td>
					</tr>
				</table>
				<a href="<%=request.getContextPath()%>/local/localList.jsp" class="btn btn-secondary">
				뒤로가기
				</a>
				<button type="submit" class="btn btn-danger">삭제</button>
			</form>
	<!-- localCnt가 0이 아닐 경우 메세지 출력 -->
	<%
		} else {
	%>
			<h5 class="krFont"> 현재 게시글이 존재하는 카테고리입니다. 삭제할 수 없습니다 &#x1F614; </h5>
			<h5 class="text-danger krFont"> <%=localName%> 카테고리의 현재 게시글 수는 <%=localCnt%>개 입니다.</h5>
			<br>
			<a href="<%=request.getContextPath()%>/local/localList.jsp" class="btn btn-secondary">
				뒤로가기
			</a>
	<%
		}
	%>
<!-------------------------------------------- deleteLocalForm 끝 ------------------------------------------->
</div>

	<br>
	
<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>

</body>
</html>