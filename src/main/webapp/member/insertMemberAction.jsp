<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.URLEncoder"%> <!-- msg 한글 메세지가 깨지지 않도록 -->
<%@ page import = "vo.*" %>
<%
	// method가 post방식이므로 인코딩
	request.setCharacterEncoding("utf-8");

	//세션 유효성 검사 // 로그인되어있는 상태면 이 페이지에 올 수 없음
	if(session.getAttribute("loginMemberId") != null) { 
		response.sendRedirect(request.getContextPath() + "/home.jsp");
		return;
	}
	// 요청값 유효성 검사 및 msg 발생
	String msg = null;
	if(request.getParameter("memberId") == null
			|| request.getParameter("memberId").equals("")) {
		msg = URLEncoder.encode("아이디가 입력되지 않았습니다", "utf-8");
	} else if(request.getParameter("memberPw") == null
			|| request.getParameter("memberPw").equals("")) {
		msg = URLEncoder.encode("비밀번호가 입력되지 않았습니다", "utf-8");
	} else if(request.getParameter("memberBirth") == null) { // 공백검사시 에러발생
		msg = URLEncoder.encode("생년월일이 선택되지 않았습니다", "utf-8");
	} else if(request.getParameter("memberGender") == null
			|| request.getParameter("memberGender").equals("")) {
		msg = URLEncoder.encode("성별이 선택되지 않았습니다", "utf-8");
	}
	if(msg != null) { // msg 발생시 (회원가입 실패시) form 페이지로
		response.sendRedirect(request.getContextPath() + "/member/insertMemberForm.jsp?msg=" + msg);
		return;
	}
	
	// null이거나 공백이 아니면 값 불러오기
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	String memberBirth = request.getParameter("memberBirth");
	String memberGender = request.getParameter("memberGender");
	System.out.println(memberId + " <- insertMemberAction memberId");
	System.out.println(memberPw + " <- insertMemberAction memberPw");
	System.out.println(memberBirth + " <- insertMemberAction memberBirth");
	System.out.println(memberGender + " <- insertMemberAction memberGender");
	
	// 파라미터값 클래스에 저장
	Member paramMember = new Member();
	paramMember.setMemberId(memberId);
	paramMember.setMemberPw(memberPw);
	paramMember.setMemberBirth(memberBirth);
	paramMember.setMemberGender(memberGender);
	
	// 드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	PreparedStatement stmt1 = null;
	PreparedStatement stmt2 = null;
	ResultSet rs = null;
	
	// id 중복검사
	// 해당 id가 데이터에 존재하는지(where) count 해본다
	String sql1 = "SELECT count(*) FROM member WHERE member_id = ?";
	stmt1 = conn.prepareStatement(sql1);
	stmt1.setString(1, paramMember.getMemberId());
	System.out.println(stmt1 + " <- insertMemberAction select count sql");
	rs = stmt1.executeQuery();
	
	// 중복된 id 갯수 확인
	int cnt = 0;
	if(rs.next()) {
		cnt = rs.getInt("count(*)");
		// 해당 id의 갯수를 cnt 변수에 저장
		// 0일 경우 중복 없음 
	}
	
	// 0보다 클 경우 중복 있음 // form으로 리다이렉션
	if(cnt > 0) {
		System.out.println(cnt + " <- insertMemberAction 중복된 아이디 갯수");
		msg = URLEncoder.encode("중복된 아이디입니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/insertMemberForm.jsp?msg=" + msg);
		return;
	} else {
		System.out.println("insertMemberAction 중복된 아이디 없음");
	}
	
	// 회원가입 정보 insert // 패스워드 암호화해서 작성
	String sql2 = "INSERT INTO member(member_id, member_pw, createdate, updatedate, member_birth, member_gender) VALUES(?, PASSWORD(?), NOW(), NOW(), ?, ?)";
	stmt2 = conn.prepareStatement(sql2);
	stmt2.setString(1, paramMember.getMemberId());
	stmt2.setString(2, paramMember.getMemberPw());
	stmt2.setString(3, paramMember.getMemberBirth());
	stmt2.setString(4, paramMember.getMemberGender());
	System.out.println(stmt2 + " <- insertMemberAction insert sql");
	
	// 쿼리가 잘 실행되었는지 확인
	int row = stmt2.executeUpdate(); // 1이면 1행 성공, 0이면 실패
	System.out.println(row + " <- insertMemberAction row");
	
	// row값에 따라 msg발생 및 리다이렉션
	if(row == 1) { // 회원가입 성공시 home으로
		System.out.println("insertMemberAction 회원가입 성공");
		msg = URLEncoder.encode("회원가입이 완료되었습니다", "utf-8");
		response.sendRedirect(request.getContextPath() + "/home.jsp?msg=" + msg);
		return;
	} else { // 회원가입 실패시 form으로
		System.out.println("insertMemberAction 회원가입 실패");
		msg = URLEncoder.encode("회원가입을 다시 시도해주세요", "utf-8");
		response.sendRedirect(request.getContextPath() + "/member/insertMemberForm.jsp?msg=" + msg);
		return;
	}
%>