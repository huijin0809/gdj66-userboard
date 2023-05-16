<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.*" %>
<%@ page import="vo.*" %>
<%
	// 1. 유효성 검사
	// 1-1. 세션
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	String memberId = (String)session.getAttribute("loginMemberId");
	System.out.println(memberId + " <- updatePwAction session loginMemberId");
	// 1-2. 요청값
	String msg = null;
	if(request.getParameter("memberPw") == null
			|| request.getParameter("memberPw").equals("")) {
		msg = URLEncoder.encode("기존 비밀번호가 입력되지 않았습니다", "utf-8");
	} else if(request.getParameter("memberNewPw") == null
			|| request.getParameter("memberNewPw").equals("")) {
		msg = URLEncoder.encode("신규 비밀번호가 입력되지 않았습니다", "utf-8");
	} else if(request.getParameter("memberNewPw2") == null
			|| request.getParameter("memberNewPw2").equals("")) {
		msg = URLEncoder.encode("신규 비밀번호 확인이 입력되지 않았습니다", "utf-8");
	}
	if(msg != null) {
		response.sendRedirect(request.getContextPath() + "/member/updatePwForm.jsp?msg=" + msg);
		return;
	}
	String memberPw = request.getParameter("memberPw");
	String memberNewPw = request.getParameter("memberNewPw");
	String memberNewPw2 = request.getParameter("memberNewPw2");
	// 1-3. 신규 비밀번호 확인
	if(!memberNewPw.equals(memberNewPw2)) {
		msg = URLEncoder.encode("신규 비밀번호 확인이 일치하지 않습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/updatePwForm.jsp?msg=" + msg);
		return;
	}
	// 1-4. 디버깅
	System.out.println(memberPw + " <- updatePwAction 기존 비밀번호");
	System.out.println(memberNewPw + " <- updatePwAction 신규 비밀번호");
	System.out.println(memberNewPw + " <- updatePwAction 신규 비밀번호 확인");
	
	// 2. update
	// 2-1. 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2-2. 쿼리 작성
	// 패스워드 암호화 해주기!
	String sql = "UPDATE member SET member_pw = PASSWORD(?), updatedate = NOW() WHERE member_id = ? AND member_pw = PASSWORD(?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, memberNewPw);
	stmt.setString(2, memberId);
	stmt.setString(3, memberPw);
	System.out.println(stmt + " <- updatePwAction stmt");
	
	// 2-3. 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	if(row == 1) { // 성공시 memberOne으로
		System.out.println(row + " <- updatePwAction 성공");
		msg = URLEncoder.encode("비밀번호가 정상적으로 변경되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/memberOne.jsp?msg=" + msg);
		return;
	} else if(row == 0) { // 실패시 Form으로
		System.out.println(row + " <- updatePwAction 실패");
		msg = URLEncoder.encode("기존 비밀번호가 일치하지 않습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/updatePwForm.jsp?msg=" + msg);
		return;
	} else { // 그 외 오류시
		System.out.println(row + " <- updatePwAction 오류");
		msg = URLEncoder.encode("비밀번호가 변경되지 않았습니다 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/updatePwForm.jsp?msg=" + msg);
		return;
	}
%>