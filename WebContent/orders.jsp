<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
session.rowHeader
session.sortingOption
session.categoryFilter
session.firstRowIndex
session.firstColIndex

Connection conn = null;
try {
	Class.forName("org.postgresql.Driver");
String url = "jdbc:postgresql:cse135";
String admin = "moojin";
String password = "pwd";
conn = DriverManager.getConnection(url, admin, password);
}
catch (Exception e) {}

String rowRange = "WHERE ROWNUM >= " + Integer.toString(session.firstRowIndex) 
				+ "AND ROWNUM < " + Integer.toString(session.firstRowIndex + 20);

String colRange = "WHERE ROWNUM >= " + Integer.toString(session.firstColIndex) 
				+ "AND ROWNUM < " + Integer.toString(session.firstColIndex + 10);

String customersAlphabetical = "SELECT u.name FROM users u WHERE u.role = 'customer'"
                               + " ORDER BY u.name ASC " + rowRange + ";";
              
String customersByTopK = "SELECT user.name FROM " +
	"(JOIN users user, (SELECT u_id, SUM(order_amt) FROM " +
	"(SELECT order.user_id AS u_id, order.price * order.quantity AS order_amt FROM " +
	"(JOIN orders order, products product ON order.product_id = product.id " +
	"AND product.category_id = " + Integer.toString(session.categoryFilter) +
	")) GROUP BY order.user_id ORDER BY order_amt DESC) ON user.id = u_id)" + rowRange + ";";
	
String productsAlphabetical = "SELECT product.name FROM products product WHERE " +
	"product.category_id = " + Integer.toString(session.categoryFilter) +
	" ORDER BY product.name ASC " + colRange + ";";
	
String productsByTopK = "SELECT product.name FROM " +
	"(SELECT product.id, product.name, SUM(order.price * order.quantity) AS order_amt FROM " +
	"(JOIN orders order, products product ON order.product_id = product.id " +
	"AND product.category_id = " + Integer.toString(session.categoryFilter) +
	") GROUP BY product.id ORDER BY order_amt DESC) " + colRange + ";";
                             
                                  
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery("SELECT p.name as product_name, o.quantity, o.price " + 
	" FROM orders o, products p where o.is_cart = false and o.product_id = p.id and " +
	" o.user_id = " + session.getAttribute("user_id"));
%>
</body>
</html>