<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%
	// 유효성 검사
	// 1-1. 세션
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	String memberId = (String)session.getAttribute("loginMemberId");
	System.out.println(memberId + " <- deleteMemberAction session loginMemberId");
	
	// 1-2. 요청값
	String msg = null;
	if(request.getParameter("memberPw") == null
			|| request.getParameter("memberPw").equals("")) {
		msg = URLEncoder.encode("탈퇴하시려면 비밀번호를 입력해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/deleteMemberForm.jsp?msg=" + msg);
		return;
	}
	String memberPw = request.getParameter("memberPw");
	System.out.println(memberPw + " <- deleteMemberAction memberPw");
	
	// 2. delete
	// 2-1. 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-2. 쿼리 작성
	// 패스워드 암호화 해주기!
	String sql = "DELETE FROM member WHERE member_id = ? AND member_pw = PASSWORD(?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, memberId);
	stmt.setString(2, memberPw);
	System.out.println(stmt + " <- deleteMemberAction stmt");
	
	// 2-3. 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	if(row == 1) { // 성공시 세션초기화 후 home으로
		System.out.println(row + " <- deleteMemberAction 성공");
		msg = URLEncoder.encode("회원 탈퇴 되었습니다", "utf-8");
		session.invalidate();  // 세션초기화
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	} else if(row == 0) { // 실패시 Form으로
		System.out.println(row + " <- deleteMemberAction 실패");
		msg = URLEncoder.encode("비밀번호가 일치하지 않습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/deleteMemberForm.jsp?msg=" + msg);
		return;
	} else { // 그 외 오류시
		System.out.println(row + " <- deleteMemberAction 오류");
		msg = URLEncoder.encode("회원 탈퇴가 되지 않았습니다 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/deleteMemberForm.jsp?msg=" + msg);
		return;
	}
%>