<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	// 세션 유효성 검사
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>updatePwForm.jsp</title>
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
	<h1>Change Password</h1>
		<!-- 변경 실패시 에러메세지 출력 -->
		<div class="text-danger">
			<%
				if(request.getParameter("msg") != null) {
			%>
					<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div>
		<form action="<%=request.getContextPath()%>/member/updatePwAction.jsp" method="post">
			<table class="table container">
				<tr>
					<th class="table-secondary">기존 비밀번호</th>
					<td>
						<input type="password" name="memberPw" placeholder="기존 비밀번호" class="form-control">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">신규 비밀번호</th>
					<td>
						<input type="password" name="memberNewPw" placeholder="신규 비밀번호" class="form-control">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">신규 비밀번호 확인</th>
					<td>
						<input type="password" name="memberNewPw2" placeholder="신규 비밀번호 확인" class="form-control">
					</td>
				</tr>
			</table>
			<a href="<%=request.getContextPath()%>/member/memberOne.jsp" class="btn btn-secondary">
				뒤로가기
			</a>
			<button type="submit" class="btn btn-outline-secondary">변경</button>
		</form>
</div>

<br>

<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>

</body>
</html>