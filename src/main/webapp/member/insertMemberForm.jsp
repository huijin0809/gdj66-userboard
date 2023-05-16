<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	//세션 유효성 검사 // 로그인되어있는 상태면 이 페이지에 올 수 없음
	if(session.getAttribute("loginMemberId") != null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>﻿insertMemberForm.jsp</title>
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
	<!-- 회원가입 폼 -->
	<h1>Sign up</h1>
		<!-- 회원가입 실패시 에러메세지 출력 -->
		<div class="text-danger">
			<%
				if(request.getParameter("msg") != null) {
			%>
					<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div>
		<form action="<%=request.getContextPath()%>/member/insertMemberAction.jsp" method="post">
			<table class="table container">
				<tr>
					<th class="table-secondary">아이디</th>
					<td>
						<input type="text" name="memberId" placeholder="아이디를 입력해주세요" class="form-control">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">비밀번호</th>
					<td>
						<input type="password" name="memberPw" placeholder="비밀번호를 입력해주세요" class="form-control">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">생년월일</th>
					<td>
						<input type="date" name="memberBirth" class="form-control">
					</td>
				</tr>
				<tr>
					<th class="table-secondary">성별</th>
					<td>
					 <div class="form-check">
				        <input class="form-check-input" type="radio" name="memberGender" id="optionsRadios1" value="M">
				        <label class="form-check-label" for="optionsRadios1">
				        	남자
				        </label>
				      </div>
				      <div class="form-check">
				        <input class="form-check-input" type="radio" name="memberGender" id="optionsRadios2" value="F">
				        <label class="form-check-label" for="optionsRadios2">
				         	여자
				        </label>
				      </div>
					</td>
				</tr>
			</table>
			<button type="submit" class="btn btn-outline-secondary">회원가입</button>
		</form>
</div>

<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>
</body>
</html>