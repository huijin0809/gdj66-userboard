<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %> <!-- HashMap 사용 -->
<%@ page import = "vo.*" %>
<%
	// 콘솔창 출력 색상 지정
	final String RED = "\u001B[31m";
	final String BG_RED = "\u001B[41m";
	final String GREEN = "\u001B[32m";
	final String BG_GREEN = "\u001B[42m";
	final String RESET = "\u001B[0m";

	// 1) 요청값 유효성 검사 (리다이렉션)
	// 세션값이 있는지 또는 페이징 시 rowPerPage나 currentPage 등..
	// 1-1) session JSP 내장(기본)객체
	// 1-2) request / response JSP 내장(기본)객체
	// currentPage, rowPerPage, localName
	System.out.println(RED + request.getParameter("currentPage") + " <- home param currentPage");
	System.out.println(request.getParameter("rowPerPage") + " <- home param rowPerPage");
	System.out.println(request.getParameter("localName") + " <- home param localName" + RESET);
	
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10;
	if(request.getParameter("rowPerPage") != null) {
		rowPerPage = Integer.parseInt(request.getParameter("rowPerPage"));
	}
	String localName = "전체";
	if(request.getParameter("localName") != null) {
		localName = request.getParameter("localName");
	}
	
	System.out.println(GREEN + currentPage + " <- home currentPage");
	System.out.println(rowPerPage + " <- home rowPerPage");
	System.out.println(localName + " <- home localName" + RESET);
	
	// 2) 모델(=결과셋) 계층 (꼭 db에서만 가져오는 것은 아니다)
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-1) 서브메뉴를 출력하기 위한 쿼리 작성 (서브메뉴 결과셋)
	// 전체와 각 localName의 count를 조회하기 위해 쿼리를 합침(UNION ALL 사용)
	/*
		SELECT '전체' localName, COUNT(local_name) cnt FROM board
		UNION ALL 
		SELECT local_name, COUNT(local_name) FROM board GROUP BY local_name
	*/
	String subMenuSql = "SELECT '전체' localName, COUNT(local_name) cnt FROM board UNION ALL SELECT local_name, COUNT(local_name) FROM board GROUP BY local_name UNION ALL SELECT local_name, 0 cnt FROM local WHERE local_name NOT IN (SELECT local_name FROM board)";
	PreparedStatement subMenuStmt = conn.prepareStatement(subMenuSql);
	ResultSet subMenuRs = subMenuStmt.executeQuery();
	System.out.println(BG_GREEN + subMenuStmt + " <- home subMenuStmt");
	
	// HashMap을 ArrayList에 넣기
	ArrayList<HashMap<String, Object>> subMenuList = new ArrayList<HashMap<String, Object>>();
	while(subMenuRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("localName", subMenuRs.getString("localName"));
		m.put("cnt", subMenuRs.getInt("cnt"));
		subMenuList.add(m);
	}
	
	// 2-2) 카테고리 별 게시글 10개씩 출력 (게시판 목록 결과셋)
	// 모델값을 구하기 위한 변수 추가
	int startRow = (currentPage - 1) * rowPerPage;
	
	// 쿼리 작성
	PreparedStatement boardStmt = null;
	ResultSet boardRs = null;
	// 기본 쿼리
	String boardSql = "SELECT board_no boardNo, board_title boardTitle, local_name localName, createdate createdate FROM board";
	// localName 선택 시 중간에 추가되는 쿼리
	String localNameSql = " WHERE local_name = ?";
	// 마지막에 들어가는 쿼리 // 작성일자 순으로 내림차순 정렬
	String lastSql = " ORDER BY createdate DESC LIMIT ?, ?";
	
	if(localName.equals("전체") || localName.equals("")) {
		boardSql = boardSql + lastSql;
		boardStmt = conn.prepareStatement(boardSql);
		boardStmt.setInt(1, startRow);
		boardStmt.setInt(2, rowPerPage);
	} else {
		boardSql = boardSql + localNameSql + lastSql;
		boardStmt = conn.prepareStatement(boardSql);
		boardStmt.setString(1, localName);
		boardStmt.setInt(2, startRow);
		boardStmt.setInt(3, rowPerPage);
	}
	System.out.println(boardStmt + " <- home boardStmt" + RESET);
	boardRs = boardStmt.executeQuery(); // DB쿼리 결과셋 모델
	
	// 일반적인 자료구조로 변경 ArrayList
	ArrayList<Board> boardList = new ArrayList<Board>(); // 애플리케이션에서 사용할 모델 (사이즈 0)
	// boardRs -> boardList
	while(boardRs.next()) {
		Board b = new Board(); 
		b.setBoardNo(boardRs.getInt("boardNo"));
		b.setLocalName(boardRs.getString("localName"));
		b.setBoardTitle(boardRs.getString("boardTitle"));
		b.setCreatedate(boardRs.getString("createdate"));
		boardList.add(b); 
	}
	// 디버깅
	System.out.println(BG_RED + boardList + " <- home boardList");
	System.out.println(boardList.size() + " <- home boardList.size" + RESET);
	
	// 2-3) 페이징을 위한 모델값 구하기
	
	// 10단위 페이징을 위해 변수 추가
	int pageLength = 10; // 지정값 // 페이지 한 묶음을 몇 개로 할지
	int currentBlock = currentPage / pageLength;
	if(currentPage % pageLength != 0) {
		currentBlock = currentBlock + 1;
	}
	
	int startPage = (currentBlock - 1) * pageLength + 1; // 페이지 블록의 첫 페이지
 	int endPage = startPage + pageLength - 1 ; // 페이지 블록의 마지막 페이지
		
	// 쿼리 작성
	PreparedStatement pageStmt = null;
	ResultSet pageRs = null;
	// 기본 쿼리
	String pageSql = "SELECT count(*) FROM board";
	// localName에 따라 where절 추가
	if(localName.equals("전체") || localName.equals("")) {
		pageStmt = conn.prepareStatement(pageSql);
	} else {
		pageSql = pageSql + localNameSql;
		pageStmt = conn.prepareStatement(pageSql);
		pageStmt.setString(1, localName);
	}
	System.out.println(BG_GREEN + pageStmt + " <- home pageStmt" + RESET);
	
	// totalCount // 쿼리 실행 결과값을 변수에 저장
	pageRs = pageStmt.executeQuery();
	int totalCount = 0;
	if(pageRs.next()) {
		totalCount = pageRs.getInt("count(*)");
	}
	System.out.println(GREEN + totalCount + " <- home totalCount");
	
	// totalPage
	int totalPage = totalCount / rowPerPage;
	if(totalCount % rowPerPage != 0) {
		totalPage = totalPage + 1;
	}
	System.out.println(totalPage + " <- home totalPage" + RESET);
	
	// endPage
	if(endPage > totalPage) {
		endPage = totalPage;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>home.jsp</title>
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
	<div class="row">
		<div class="col-sm-4">
			<div class="text-danger">
				<%	// msg 발생시 출력
					if(request.getParameter("msg") != null) {
				%>
						<%=request.getParameter("msg")%>
				<%
					}
				%>
			</div>
			
			<!----------------------------------------------------- 로그인폼 (세션에 id값이 null일때만 출력) ---------------------------------------------------->
			<div>
				<%
					if(session.getAttribute("loginMemberId") == null) {
				%>
						<h1>Login</h1>
						<form action="<%=request.getContextPath()%>/member/loginAction.jsp" method="post">
							<table>
								<tr>
									<td>ID</td>
									<td>
										<input type="text" name="memberId">
									</td>
								</tr>
								<tr>
									<td>PW</td>
									<td>
										<input type="password" name="memberPw">
									</td>
								</tr>
							</table>
							<button type="submit" class="btn btn-secondary">로그인</button>
						</form>
				<%
					} else if(session.getAttribute("loginMemberId") != null) {
				%>
						<div class="card border-secondary mb-3" style="max-width: 20rem;">
						  <div class="card-header">online</div>
						  <div class="card-body">
						    <h4 class="card-title">welcome!</h4>
						    <p class="card-text"><%=session.getAttribute("loginMemberId")%>님 어서오세요 :)</p>
						  </div>
						</div>
				<%
					}
				%>
			</div>
			<!----------------------------------------------------------- 로그인폼 끝 ------------------------------------------------------------------>
		</div>
		<div class="col-sm-8">
				<div class="card border-secondary mb-3">
				  <div class="card-header">
				  	<h5 class="krFont">카테고리별 회원전용 게시판 프로젝트 </h5>
				  	<h7>기간 : 2023.05.02 ~ 05.15</h7>
				  </div>
				  <div class="card-body">
				    <p class="card-text">
				    	<ul>
				    		<li>카테고리별 게시판 구현, 카테고리별 게시글 수 출력</li>
				    		<li>게시글, 댓글, 카테고리 추가/수정/삭제 구현</li>
				    		<li>세션을 이용한 로그인/로그아웃 구현</li>
				    		<li>회원가입 및 회원정보 수정/탈퇴 구현</li>
				    		<li>10페이지 단위의 페이징 구현</li>
				    	</ul>
				    </p>
				  </div>
				</div>
			</div>
		</div>
	
	<br>
	
	<div class="row">
	<!------------------------------------------------ 서브메뉴(세로) subMenuList모델 출력 --------------------------------------------------------->
		<div class="col-sm-4">
			<h3 class="mt-4" style="font-size:50px;">Category</h3>
			<ul class="nav nav-pills flex-column">
				<%
					for(HashMap<String, Object> m : subMenuList) {
				%>
						<li class="nav-item">
							<a href="<%=request.getContextPath()%>/home.jsp?localName=<%=(String)m.get("localName")%>" class="nav-link">
								<%=(String)m.get("localName")%>(<%=(Integer)m.get("cnt")%>)
								<!-- 값타입이 Object타입이므로 형변환 -->
							</a>
						</li>
				<%		
					}
				%>
			</ul>
			<br>	
			<%
				// 로그인한 회원만 카테고리 관리에 접근 가능
				if(session.getAttribute("loginMemberId") != null) {
			%>
					<a href="<%=request.getContextPath()%>/local/localList.jsp" class="btn btn-secondary">
						&#x2699; 카테고리 관리
					</a>
			<%
				}
			%>
		</div>
	<!--------------------------------------------------------- subMenuList 끝 ----------------------------------------------------------------->
	
	<!-------------------------------------------------- 카테고리별 게시글 10개씩 boardList모델 출력------------------------------------------------------>
		<div class="col-sm-8">
			<div class="row">
				<div class="col-lg-6 col-sm-12 text-lg-start text-center">
					<h2 class="mt-4" style="font-size:50px;">Board</h2>
				</div>
				<%
					// 로그인한 회원만 게시글 작성에 접근 가능
					if(session.getAttribute("loginMemberId") != null) {
				%>
						<div class="col-lg-6 col-sm-12 text-lg-end text-center">
							<a href="<%=request.getContextPath()%>/board/insertBoardForm.jsp" class="btn btn-secondary">글쓰기</a>
						</div>
				<%
					}
				%>
			</div>
			<table class="table table-hover">
				<thead>
					<tr class="table-dark">	
						<th>Category</th>
						<th>Title</th>
						<th>Createdate</th>
					</tr>
				</thead>
				<tbody>
					<%
						for(Board b : boardList) {
					%>
							<tr class="table-active">
								<td><%=b.getLocalName()%></td>
								<td>
									<a href="<%=request.getContextPath()%>/board/boardOne.jsp?boardNo=<%=b.getBoardNo()%>">
										<%=b.getBoardTitle()%>
									</a>
								</td>
								<td><%=b.getCreatedate().substring(0, 10)%></td>
							</tr>
					<%
						}
					%>
				</tbody>
			</table>
			<!------- 페이징 시작 ------->
			<div>
			  <ul class="pagination" style="justify-content : center;">
			    <%
					if(startPage == 1) {
				%>
					    <li class="page-item disabled">
					      <a class="page-link" href="#">&laquo;</a>
					    </li>
				<%
					} else {
				%>
						<li class="page-item">
					      <a class="page-link" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=startPage - 1%>&rowPerPage=<%=rowPerPage%>&localName=<%=localName%>">&laquo;</a>
					    </li>
				<%
					}
				%>
			    <%
			    	for(int i = startPage; i <= endPage; i++) {
			    %>
					    <li class="page-item <%if(i == currentPage){%> active <%}%>">
					      <a class="page-link" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=i%>&rowPerPage=<%=rowPerPage%>&localName=<%=localName%>">
					      	<%=i%>
					      </a>
					    </li>
				<%
			    	}
				%>
				<%
					if(totalPage == endPage) {
				%>
					    <li class="page-item disabled">
					      <a class="page-link" href="#">&raquo;</a>
					    </li>
				<%
					} else {
				%>
						<li class="page-item">
					      <a class="page-link" href="<%=request.getContextPath()%>/home.jsp?currentPage=<%=endPage + 1%>&rowPerPage=<%=rowPerPage%>&localName=<%=localName%>">&raquo;</a>
					    </li>
				<%
					}
				%>
			  </ul>
			</div>
			<!------- 페이징 끝 ------->
	<!--------------------------------------------------------- boardList 끝 ------------------------------------------------------------------>
		</div>
	</div>
</div>

	<br>
	
<div> <!-- copyright include -->
	<jsp:include page="/inc/copyright.jsp"></jsp:include>
</div>
	
</body>
</html>