<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>
</head>

<%
	Connection conn = null;
	try {
		Class.forName("org.postgresql.Driver");
    	String url = "jdbc:postgresql:cse135";
    	String admin = "moojin";
    	String password = "pwd";
    	conn = DriverManager.getConnection(url, admin, password);
	}
	catch (Exception e) {}
	
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT t1.p_id as p1_id, t2.p_id as p2_id, SUM(t1.total_spent * t2.total_spend)/(SUM(t1.total_spent)*sum(t2.total_spend)) AS cos FROM (SELECT o.user_id, p.id as p_id, SUM(o.price) AS total_spent FROM products p JOIN orders o ON p.id = o.product_id GROUP BY o.user_id, p.id) as t1 JOIN (SELECT o.user_id, p.id as p_id, SUM(o.price) as total_spend FROM products p JOIN orders o ON p.id = o.product_id GROUP BY o.user_id, p.id) as t2 ON t1.user_id = t2.user_id WHERE t1.p_id < t2.p_id GROUP BY t1.p_id, t2.p_id order by cos DESC LIMIT 100;");
	
	//ResultSet rs = stmt.executeQuery("WITH productTotals AS (SELECT p.id AS prodId, SUM(o.price) AS total FROM products p, orders o WHERE o.product_id=p.id GROUP BY p.id), dotProducts AS (SELECT p1.name AS product1, p2.name AS product2, p1.id AS pid1, p2.id AS pid2, SUM(o1.price*o2.price) AS numerator FROM products p1, products p2, users u1, users u2, orders o1, orders o2 WHERE o1.user_id=u1.id AND o1.product_id=p1.id AND o2.user_id=u2.id AND o2.product_id=p2.id AND u1.id=u2.id AND p1.id != p2.id AND p1.id > p2.id GROUP BY p1.id, p2.id) SELECT dotProducts.pid1 AS pid1, dotProducts.product1 AS product1, dotProducts.pid2 AS pid2, dotProducts.product2 AS product2, (dotProducts.numerator/(pTotals1.total*pTotals2.total)) AS similarity FROM dotProducts, productTotals pTotals1, productTotals pTotals2 WHERE pTotals1.prodId=dotProducts.pid1 AND pTotals2.prodId=dotProducts.pid2 ORDER BY similarity DESC LIMIT 100;");

	%>
<body>
<div class="collapse navbar-collapse">
<%  if (session.getAttribute("user_role").equals("o")) { %>
	<ul class="nav navbar-nav">
		<li><a href="index.jsp">Home</a></li>
		<li><a href="categories.jsp">Categories</a></li>
		<li><a href="products.jsp">Products</a></li>
		<li><a href="browsing.jsp">Product Browsing</a></li>
		<li><a href="carts.jsp">Carts</a></li>
		<li><a href="purchases.jsp">Purchases</a></li>
		<li><a href="orders.jsp">Orders</a></li>
		<li><a href="similarProducts.jsp">Similar Products</a></li>
		<li><a href="login.jsp">Logout</a></li>
	</ul>
 <% } else { %>
 	<ul class="nav navbar-nav">
		<li><a href="index.jsp">Home</a></li>
		<li><a href="browsing.jsp">Product Browsing</a></li>
		<li><a href="carts.jsp">Carts</a></li>
		<li><a href="purchases.jsp">Purchases</a></li>
		<li><a href="login.jsp">Logout</a></li>
	</ul>
 <% } %>
</div>
<table class="table table-striped">
	<th>Cosine</th>
	<th>Product 1 Number</th>
	<th>Product 2 Number</th>
<% while (rs.next()) { %>
	<tr>
	<form>
		<td><%=rs.getString("cos")%></td>
		<td><%=rs.getString("t1.p_id")%></td>
		<td><%=rs.getString("t2.p_id")%></td>
	</form>
	</tr>
<% } %>
</table>

</body>
</html>
