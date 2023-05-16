<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	// 1. 유효성 검사
	// 1-1. 세션
	if(session.getAttribute("loginMemberId") == null) {
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	String memberId = (String)session.getAttribute("loginMemberId");
	System.out.println(memberId + " <- memberOne session loginMemberId");
	// 1-2. 요청값
	String msg = null;
	if(request.getParameter("memberPw") == null
			|| request.getParameter("memberPw").equals("")) {
		msg = URLEncoder.encode("비밀번호가 입력되지 않았습니다", "utf-8");
	} else if(request.getParameter("memberBirth") == null
			|| request.getParameter("memberBirth").equals("")) {
		msg = URLEncoder.encode("생년월일이 선택되지 않았습니다", "utf-8");
	} else if(request.getParameter("memberGender") == null
			|| request.getParameter("memberGender").equals("")) {
		msg = URLEncoder.encode("성별이 선택되지 않았습니다", "utf-8");
	}
	if(msg != null) { // msg 발생시 (수정 실패시) form 페이지로
		response.sendRedirect(request.getContextPath() + "/member/updateMemberForm.jsp?msg=" + msg);
		return;
	}
	
	// 1-3. null이거나 공백이 아니면 값 불러오기
	String memberPw = request.getParameter("memberPw");
	String memberBirth = request.getParameter("memberBirth");
	String memberGender = request.getParameter("memberGender");
	System.out.println(memberPw + " <- updateMemberAction memberPw");
	System.out.println(memberBirth + " <- updateMemberAction memberBirth");
	System.out.println(memberGender + " <- updateMemberAction memberGender");
	
	// 1-4. 파라미터값 클래스에 저장
	Member paramMember = new Member();
	paramMember.setMemberId(memberId);
	paramMember.setMemberPw(memberPw);
	paramMember.setMemberBirth(memberBirth);
	paramMember.setMemberGender(memberGender);
	
	// 2. update
	// 2-1. 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 2.2 쿼리 작성
	// 쿼리 작성 시 패스워드 암호화 해주기!
	String sql = "UPDATE member SET member_birth = ?, member_gender = ?, updatedate = NOW() WHERE member_id = ? AND member_pw = PASSWORD(?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, paramMember.getMemberBirth());
	stmt.setString(2, paramMember.getMemberGender());
	stmt.setString(3, paramMember.getMemberId());
	stmt.setString(4, paramMember.getMemberPw());
	System.out.println(stmt + " <- updateMemberAction stmt");
	
	// 2-3. 쿼리가 잘 진행되었는지 확인
	int row = stmt.executeUpdate();
	if(row == 1) { // 성공시 memberOne으로
		System.out.println(row + " <- updateMemberAction 성공");
		msg = URLEncoder.encode("회원정보가 정상적으로 수정되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/memberOne.jsp?msg=" + msg);
		return;
	} else if(row == 0) { // 실패시 Form으로
		System.out.println(row + " <- updateMemberAction 실패");
		msg = URLEncoder.encode("비밀번호가 일치하지 않습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/updateMemberForm.jsp?msg=" + msg);
		return;
	} else { // 그 외 오류시
		System.out.println(row + " <- updateMemberAction 오류");
		msg = URLEncoder.encode("회원정보가 수정되지 않았습니다 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/updateMemberForm.jsp?msg=" + msg);
		return;
	}
%>