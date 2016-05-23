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

session.setAttribute( "rowHeader", "state" );
session.setAttribute( "sortingOption", "alphabetical" );
session.setAttribute( "categoryFilter", "IS NOT NULL" );
session.setAttribute( "firstRowIndex", 1 );
session.setAttribute( "firstColIndex", 1 );

String rowRange = "LIMIT 20 OFFSET " + session.getAttribute( "firstRowIndex" ).toString();
String colRange = "LIMIT 10 OFFSET " + session.getAttribute( "firstColIndex" ).toString();

String queryString = null;

if (session.getAttribute("rowHeader").equals("user")) {
	if (session.getAttribute("sortingOption").equals("alphabetical")) {
		queryString = "SELECT u.name FROM users u WHERE u.role = 'c'"
                   + " ORDER BY u.name ASC " + rowRange + ";";
	}
	else if (session.getAttribute("sortingOption").equals("topK")) {
		queryString = "SELECT user.name FROM " +
			"(JOIN users u, (SELECT u_id, SUM(order_amt) AS total FROM " +
			"(SELECT order.user_id AS u_id, order.price * order.quantity AS order_amt FROM " +
			"(JOIN orders order, products product ON order.product_id = product.id " +
			"AND product.category_id " + session.getAttribute( "categoryFilter" ).toString() +
			" )) GROUP BY order.user_id ORDER BY order_amt DESC) ON u.id = u_id)" + rowRange + ";";
	}
}
else if (session.getAttribute("rowHeader").equals("state")) {
	if (session.getAttribute("sortingOption").equals("alphabetical")) {
		queryString = "SELECT DISTINCT u.state FROM users u " +
                	  "ORDER BY u.state ASC " + rowRange + ";"; 
	}
	else if (session.getAttribute("sortingOption").equals("topK")) {
		queryString = "SELECT DISTINCT state FROM " +
			"(SELECT u.state AS state, SUM(customer_total) AS state_total FROM " +
			"(JOIN users u, (SELECT u_id, SUM(order_amt) AS customer_total FROM " +
			"(SELECT order.user_id AS u_id, order.price * order.quantity AS order_amt FROM " +
			"(JOIN orders order, products product ON order.product_id = product.id " +
			"AND product.category_id " + session.getAttribute("categoryFilter").toString() +
			" )) GROUP BY order.user_id) ON u.id = u_id) " +
			"GROUP BY u.state ORDER BY state_total DESC) " + rowRange + ";";
	}
}
                                                             
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery(queryString);
%>
<table class="table table-striped">
	<th>Results</th>
	<% while (rs.next()) { %>
		<tr><td><%=rs.getString("state")%></td></tr>
	<% } %>
</table>
</body>
</html>