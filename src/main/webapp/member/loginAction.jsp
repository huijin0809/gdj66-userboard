<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %> <!-- ??? -->
<%@ page import = "vo.*" %>
<%
	// 한글 깨지지 않게 인코딩
	request.setCharacterEncoding("utf-8");

	// 세션 유효성 검사 
	if(session.getAttribute("loginMemberId") != null) { // 로그인되어있는 상태면 이 페이지에 올 수 없다
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}

	//요청값 유효성 검사 및 msg 발생
	String msg = null;
	if(request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")) {
		msg = URLEncoder.encode("아이디가 입력되지 않았습니다", "utf-8");
	} else if(request.getParameter("memberPw") == null
			|| request.getParameter("memberPw").equals("")) {
		msg = URLEncoder.encode("비밀번호가 입력되지 않았습니다", "utf-8");
	}
	if(msg != null) { // msg 발생시 (로그인 실패시) home 페이지로
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	}
	
	// null이거나 공백이 아니면 값 불러오기
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	System.out.println(memberId + " <- loginAction memberId");
	System.out.println(memberPw + " <- loginAction memberPw");
	
	// 객체에 값을 넣으면 객체지향적인 코드가 되기 때문에..?
	Member paramMember = new Member();
	paramMember.setMemberId(memberId);
	paramMember.setMemberPw(memberPw); 
	
	// db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 동적쿼리 작성
	String sql = "SELECT member_id memberId FROM member WHERE member_id = ? AND member_pw = PASSWORD(?)"; // 패스워드 암호화 해주기
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, paramMember.getMemberId());
	stmt.setString(2, paramMember.getMemberPw());
	// 디버깅
	System.out.println(stmt + " <- loginAction sql");
	
	rs = stmt.executeQuery();
	if(rs.next()) { // 일치하는 값이 있으면 (true) 로그인 성공
		// 세션에 로그인 정보(memberid)를 저장
		session.setAttribute("loginMemberId", rs.getString("memberId"));
		System.out.println("로그인 성공! 세션정보 : " + session.getAttribute("loginMemberId"));
	} else { // 로그인 실패
		System.out.println("로그인 실패!");
	}
	
	// 홈으로 리다이렉션
	response.sendRedirect(request.getContextPath() + "/home.jsp");
%>