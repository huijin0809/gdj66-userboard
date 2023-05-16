<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="text-center">
	<h1 style="font-size:100px;">Userboard</h1>
	<p class="krFont">
		Eclipse(2022-12), JDK(17.0.6), Mariadb(10.5.19), Apache Tomcat(10.1.7), HeidiSQL<br>java, sql, html, css, bootstrap5
	</p>
</div>
<nav class="navbar navbar-expand-lg navbar-light bg-light">
	<div class="container-fluid">
	    <div class="collapse navbar-collapse" style="font-size:20px;" id="navbarColor03">
			<ul class="navbar-nav me-auto">
				<li class="nav-item"><a href="<%=request.getContextPath()%>/home.jsp" class="nav-link">Home</a></li>
				<!-- 로그인전: 홈으로 / 회원가입
					 로그인후: 홈으로 / 회원정보 / 로그아웃
					 로그인정보: 세션 loginMemberId -->
				<%
					if(session.getAttribute("loginMemberId") == null) { // 로그인 전
				%>
						<li class="nav-item"><a href="<%=request.getContextPath()%>/member/insertMemberForm.jsp" class="nav-link">Sign up</a></li>
				<%
					} else { // 로그인 후
				%>
						<li class="nav-item"><a href="<%=request.getContextPath()%>/member/memberOne.jsp" class="nav-link">Profile</a></li>
						<li class="nav-item"><a href="<%=request.getContextPath()%>/member/logoutAction.jsp" class="nav-link">Logout</a></li>
				<%
					}
				%>
			</ul>
		</div>
	</div>
</nav>