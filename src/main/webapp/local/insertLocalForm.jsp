<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 세션 유효성 검사
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	String memberId = (String)session.getAttribute("loginMemberId");
	System.out.println(memberId + " <- insertLocalForm session loginMemberId");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>insertLocalForm.jsp</title>
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
	<!---------------------- 카테고리 insert form 시작 ---------------------->
	<h1>Create Category</h1>
	<h6 class="krFont">중복되지 않는 이름을 입력해주세요</h6>
		<!-- 생성 실패시 에러메세지 출력 -->
		<div class="text-danger">
			<%
				if(request.getParameter("msg") != null) {
			%>
					<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div>
		<form action="<%=request.getContextPath()%>/local/insertLocalAction.jsp" method="post">
			<table class="table container">
				<tr>
					<th class="table-secondary">카테고리 이름</th>
					<td>
						<input type="text" name="localName" class="form-control">
					</td>
				</tr>
			</table>
			<a href="<%=request.getContextPath()%>/local/localList.jsp" class="btn btn-secondary">
				뒤로가기
			</a>
			<button type="submit" class="btn btn-outline-secondary">생성</button>
		</form>
	<!---------------------- 카테고리 insert form 끝 ---------------------->
</div>

<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>
</body>
</html>