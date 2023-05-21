<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	// 한글 깨지지 않게 인코딩
	request.setCharacterEncoding("utf-8");

	// 1. 세션 유효성 검사
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	String memberId = (String)session.getAttribute("loginMemberId");
	System.out.println(memberId + " <- memberOne session loginMemberId");
	
	// 2. 모델값 구하기 // member모델
	// 2-1. 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2.2 쿼리 작성
	String membersql = "SELECT member_id memberId, createdate createdate, updatedate updatedate, member_birth memberBirth, member_gender memberGender FROM member WHERE member_id = ?";
	PreparedStatement memberStmt = null;
	ResultSet memberRs = null;
	memberStmt = conn.prepareStatement(membersql);
	memberStmt.setString(1, memberId);
	System.out.println(memberStmt + " <- memberOne memberStmt");
	
	// Vo타입으로 바꾸기
	memberRs = memberStmt.executeQuery();
	Member member = null;
	if(memberRs.next()) {
		member = new Member();
		member.setMemberId(memberRs.getString("memberId"));
		member.setCreatedate(memberRs.getString("createdate"));
		member.setUpdatedate(memberRs.getString("updatedate"));
		member.setMemberBirth(memberRs.getString("memberBirth"));
		member.setMemberGender(memberRs.getString("memberGender"));
	}
	
	// 디버깅
	System.out.println(member.getMemberId() + " <- memberOne memberId");
	System.out.println(member.getMemberBirth() + " <- memberOne memberBirth");
	System.out.println(member.getMemberGender() + " <- memberOne memberGender");
	System.out.println(member.getCreatedate() + " <- memberOne createdate");
	System.out.println(member.getUpdatedate() + " <- memberOne updatedate");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>memberOne.jsp</title>
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
	<!--------------------------- member 모델출력 시작 --------------------------->
	<h1><%=memberId%>'s Profile</h1>
		<!-- msg 발생시 메세지 출력 -->
		<div class="text-danger">
			<%
				if(request.getParameter("msg") != null) {
			%>
					<%=request.getParameter("msg")%>
			<%
				}
			%>
		</div>
		<table class="table container">
			<tr>
				<th class="table-dark">아이디</th>
				<td><%=member.getMemberId()%></td>
			</tr>
			<tr>
				<th class="table-dark">생년월일</th>
				<td><%=member.getMemberBirth()%></td>
			</tr>
			<tr>
				<th class="table-dark">성별</th>
				<td>
					<%
						if(member.getMemberGender().equals("M")) {
					%>
							남자
					<%
						} else {
					%>
							여자
					<% 
						}
					%>
				</td>
			</tr>
			<tr>
				<th class="table-dark">회원가입일</th>
				<td><%=member.getCreatedate()%></td>
			</tr>
			<tr>
				<th class="table-dark">최근수정일</th>
				<td><%=member.getUpdatedate()%></td>
			</tr>
		</table>
	<!---------------------------- member 모델출력 끝 ---------------------------->
	
	<!----------- 수정 / 탈퇴 ----------->
	<div class="text-center">
		<a href="<%=request.getContextPath()%>/member/updateMemberForm.jsp" class="btn btn-outline-secondary">회원정보 수정</a>
		<a href="<%=request.getContextPath()%>/member/updatePwForm.jsp" class="btn btn-outline-secondary">비밀번호 변경</a>
		<a href="<%=request.getContextPath()%>/member/deleteMemberForm.jsp" class="btn btn-danger">회원 탈퇴</a>
	</div>
	<!--------------- 끝 --------------->
</div>

<br>

<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>
</body>
</html>