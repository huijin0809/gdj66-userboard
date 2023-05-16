<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %> <!-- Hashmap 위치 -->
<%
	//드라이버 로딩 및 db 접속
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/userboard";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	// 1) 한 행만 출력 (limit 사용)
	// SELECT local_name localName, '대한민국' conuntry, '김희진' worker FROM local LIMIT 0,1
	String sql = "SELECT local_name localName, '대한민국' conuntry, '김희진' worker FROM local LIMIT 0,1";
	stmt = conn.prepareStatement(sql);
	rs = stmt.executeQuery();
	
	// Vo대신 HachMap타입을 사용
	HashMap<String, Object> map = null;
	if(rs.next()) { // 데이터가 있다면(true) map에 저장될 것
		// 디버깅
		/*	System.out.println(rs.getString("localName"));
			System.out.println(rs.getString("conuntry"));
			System.out.println(rs.getString("worker")); */
		map = new HashMap<String, Object>();
		map.put("localName", rs.getString("localName"));
		map.put("conuntry", rs.getString("conuntry"));
		map.put("worker", rs.getString("worker"));
	}
	// 디버깅
	System.out.println((String)map.get("localName")); // Object타입으로 지정했으므로 출력시 String타입으로 형변환
	System.out.println((String)map.get("conuntry"));
	System.out.println((String)map.get("worker"));
	
	// 2) 여러행을 출력 (limit 사용x)
	PreparedStatement stmt2 = null;
	ResultSet rs2 = null;
	String sql2 = "SELECT local_name localName, '대한민국' conuntry, '김희진' worker FROM local";
	stmt2 = conn.prepareStatement(sql2);
	rs2 = stmt2.executeQuery();
	
	// HashMap이 여러개 필요하므로 ArrayList를 사용한다
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	// ArrayList를 반복문(while)을 이용하여 HashMap에 값 넣기
	while(rs2.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("localName", rs2.getString("localName"));
		m.put("conuntry", rs2.getString("conuntry"));
		m.put("worker", rs2.getString("worker"));
		list.add(m);
	}
	
	// 3) 카테고리(local) 중복되는 데이터 수 표시하기
	// SELECT local_name localName, COUNT(local_name) cnt FROM board GROUP by local_name
	PreparedStatement stmt3 = null;
	ResultSet rs3 = null;
	String sql3 = "SELECT local_name localName, COUNT(local_name) cnt FROM board GROUP by local_name";
	stmt3 = conn.prepareStatement(sql3);
	rs3 = stmt3.executeQuery();
	
	// HashMap이 여러개 필요하므로 ArrayList를 사용한다
	ArrayList<HashMap<String, Object>> list3 = new ArrayList<HashMap<String, Object>>();
	// ArrayList를 반복문(while)을 이용하여 HashMap에 값 넣기
	while(rs3.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("localName", rs3.getString("localName"));
		m.put("cnt", rs3.getInt("cnt"));
		list3.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>localListByMap.jsp</title>
</head>
<body>
	<div>
		<h2>rs1 결과셋</h2>
		<%=map.get("localName")%>
		<%=map.get("conuntry")%>
		<%=map.get("worker")%>
	</div>

	<br>
	<h2>rs2 결과셋</h2>
	<table>
		<tr>
			<th>localName</th>
			<th>conuntry</th>
			<th>worker</th>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
				<tr>
					<td><%=m.get("localName")%></td>
					<td><%=m.get("conuntry")%></td>
					<td><%=m.get("worker")%></td>
				</tr>
		<%		
			}
		%>
	</table>
	
	<br>
	<h2>rs3 결과셋</h2>
	<ul>
		<li>
			<a href="">전체</a>
		</li>
		<%
			for(HashMap<String, Object> m : list3) {
		%>
				<li>
					<a href="">
						<%=(String)m.get("localName")%>(<%=(Integer)m.get("cnt")%>)
					</a>
				</li>
		<%		
			}
		%>
	</ul>
</body>
</html>