<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="vo.*" %>
<%
	// 세션 유효성 검사
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	String memberId = (String)session.getAttribute("loginMemberId");
	System.out.println(memberId + " <- localList session loginMemberId");
	
	// 모델값 구하기 - localList 모델
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// select 쿼리 작성 // 가장 최근에 생성한 카테고리가 상단으로 가도록 정렬
	String sql = "SELECT l.local_name localName, l.createdate createdate, COUNT(b.local_name) cnt FROM local l LEFT JOIN board b on l.local_name=b.local_name GROUP BY localName ORDER BY createdate DESC";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs = stmt.executeQuery();
	System.out.println(stmt + " <- localList stmt");
	
	// HashMap을 ArrayList에 넣기
	/* 
	ArrayList<HashMap<String, Object>> localList = new ArrayList<HashMap<String, Object>>();
	while(rs.next()) {
		HashMap<String, Object> l = new HashMap<String, Object>();
		l.put("localName", rs.getString("localName"));
		l.put("createdate", rs.getString("createdate"));
		l.put("cnt", rs.getInt("cnt"));
		localList.add(l);
	}
	*/
	
	// Vo타입의 ArrayList와 Map 사용
	ArrayList<Local> localList = new ArrayList<Local>();
	Map<String,Integer> cnt = new HashMap<>();
	while(rs.next()) {
		Local l = new Local();
		l.setLocalName(rs.getString("localName"));
		l.setCreatedate(rs.getString("createdate"));
		cnt.put(l.getLocalName(), rs.getInt("cnt"));
		// cnt.put(rs.getString("localName"), rs.getInt("cnt"));
		localList.add(l);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>localList.jsp</title>
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
<!------------------------------------------- localList 모델셋 시작 ------------------------------------------->
	<h1>Category List</h1>
	<h6 class="krFont">현재 사용 중인 카테고리는 수정/삭제를 할 수 없습니다</h6>
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
	<br>
	<table class="table table-hover">
		<thead>
			<tr class="table-dark">	
				<th>카테고리</th>
				<th>생성일자</th>
				<th>현재 게시글 수</th>
				<th>수정</th>
				<th>삭제</th>
			</tr>
		</thead>
		<tbody>
			<%
				for(Local l : localList) {
			%>
					<tr class="table-active">
						<td><%=l.getLocalName()%></td>
						<td><%=l.getCreatedate()%></td>
						<td><%=cnt.get(l.getLocalName())%>개</td>
						<td>
							<%
								if(cnt.get(l.getLocalName()) == 0) {
							%>
									<a href="<%=request.getContextPath()%>/local/updateLocalForm.jsp?localName=<%=l.getLocalName()%>" class="btn">
										&#x270F;
									</a>
							<%
								}
							%>
						</td>
						<td>
							<%
								if(cnt.get(l.getLocalName()) == 0) {
							%>
									<a href="<%=request.getContextPath()%>/local/deleteLocalForm.jsp?localName=<%=l.getLocalName()%>" class="btn">
										&#x1F5D1;
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
<!-------------------------------------------- localList 모델셋 끝 ------------------------------------------->
	<div class="text-center">
		<a href="<%=request.getContextPath()%>/local/insertLocalForm.jsp" class="btn btn-secondary">
			&#x1F4C3; 새로운 카테고리 생성
		</a>
	</div>
</div>

	<br>
	
<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>

</body>
</html>