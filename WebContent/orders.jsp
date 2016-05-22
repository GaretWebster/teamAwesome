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

/*session.rowHeader
session.sortingOption*/
session.setAttribute( "categoryFilter", 10 );
session.setAttribute( "firstRowIndex", 1 );
session.setAttribute( "firstColIndex", 1 );

String rowRange = "WHERE ROWNUM >= " + session.getAttribute( "firstRowIndex" ).toString() 
				+ "AND ROWNUM < " + Integer.toString(( Integer ) session.getAttribute( "firstRowIndex" ) + 20);

String colRange = "WHERE ROWNUM >= " + session.getAttribute( "firstColIndex" ).toString() 
				+ "AND ROWNUM < " + Integer.toString(( Integer ) session.getAttribute( "firstColIndex" ) + 10);

String customersAlphabetical = "SELECT u.name FROM users u WHERE u.role = 'customer'"
                               + " ORDER BY u.name ASC " + rowRange + ";";
              
String customersByTopK = "SELECT user.name FROM " +
	"(JOIN users user, (SELECT u_id, SUM(order_amt) FROM " +
	"(SELECT order.user_id AS u_id, order.price * order.quantity AS order_amt FROM " +
	"(JOIN orders order, products product ON order.product_id = product.id " +
	"AND product.category_id = " + session.getAttribute( "categoryFilter" ).toString() +
	")) GROUP BY order.user_id ORDER BY order_amt DESC) ON user.id = u_id)" + rowRange + ";";
	
String productsAlphabetical = "SELECT product.name FROM products product WHERE " +
	"product.category_id = " + session.getAttribute( "categoryFilter" ).toString() +
	" ORDER BY product.name ASC " + colRange + ";";
	
String productsByTopK = "SELECT product.name FROM " +
	"(SELECT product.id, product.name, SUM(order.price * order.quantity) AS order_amt FROM " +
	"(JOIN orders order, products product ON order.product_id = product.id " +
	"AND product.category_id = " + session.getAttribute( "categoryFilter" ).toString() +
	") GROUP BY product.id ORDER BY order_amt DESC) " + colRange + ";";
                                                             
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery("SELECT p.name as product_name, o.quantity, o.price " + 
	" FROM orders o, products p where o.is_cart = false and o.product_id = p.id and " +
	" o.user_id = " + session.getAttribute("user_id").toString() );
%>
</body>
</html>