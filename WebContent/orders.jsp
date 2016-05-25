<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*, org.postgresql.util.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
	<title>CSE135 Project</title>
</head>
<body style="padding-left:10px;">
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

session.setAttribute( "rowHeader", "user" );
session.setAttribute( "sortingOption", "topK" );
session.setAttribute( "categoryFilter", "IS NOT NULL" );
session.setAttribute( "firstRowIndex", 0 );
session.setAttribute( "firstColIndex", 0 );

String rowRange = "LIMIT 20 OFFSET " + session.getAttribute( "firstRowIndex" ).toString();
String colRange = "LIMIT 10 OFFSET " + session.getAttribute( "firstColIndex" ).toString();
String categoryFilter = session.getAttribute( "categoryFilter" ).toString();

String rowHeaders = null;
String colHeaders = null;

if (session.getAttribute("sortingOption").equals("alphabetical")) {
	colHeaders = "SELECT p.name FROM products p WHERE p.category_id " + categoryFilter + " " +
			     "ORDER BY p.name ASC " + colRange;
}
else if (session.getAttribute("sortingOption").equals("topK")) {
	colHeaders = "SELECT p.name, SUM(o.price) AS product_total FROM " +
				 "orders o JOIN products p ON o.product_id = p.id AND o.is_cart = false " +
	             "AND p.category_id " + categoryFilter + " " +
			     "GROUP BY p.name ORDER BY product_total DESC " + colRange;
}

if (session.getAttribute("rowHeader").equals("user")) {
	if (session.getAttribute("sortingOption").equals("alphabetical")) {
		rowHeaders = "SELECT u.name AS row_header, u.name AS total FROM users u WHERE u.role = 'c'"
                   + " ORDER BY u.name ASC " + rowRange;
	}
	else if (session.getAttribute("sortingOption").equals("topK")) {
		rowHeaders = "SELECT u.name AS row_header, customer_total AS total FROM " +
	  				 "users u JOIN (SELECT o.user_id, SUM(o.price) AS customer_total FROM " +
	  				 "orders o JOIN products p ON o.product_id = p.id AND o.is_cart = false " +
	  				 "AND p.category_id " + categoryFilter + " " + 
	  				 "GROUP BY o.user_id ORDER BY customer_total DESC) AS uncessecary_alias " +
	  				 "ON u.id = user_id " + rowRange;
	}
}
else if (session.getAttribute("rowHeader").equals("state")) {
	if (session.getAttribute("sortingOption").equals("alphabetical")) {
		rowHeaders = "SELECT DISTINCT u.state AS row_header, u.state AS total FROM users u " +
                	 "ORDER BY u.state ASC " + rowRange; 
	}
	else if (session.getAttribute("sortingOption").equals("topK")) {
		rowHeaders = "SELECT u.state AS row_header, SUM(r.customer_total) AS total FROM " +
					 "users u JOIN (SELECT o.user_id, SUM(o.price) AS customer_total FROM " +
					 "orders o JOIN products p ON o.product_id = p.id AND o.is_cart = false " +
					 "AND p.category_id " + categoryFilter + " " +
					 "GROUP BY o.user_id) AS r " +
					 "ON u.id = r.user_id GROUP BY u.state ORDER BY total DESC " + rowRange;
	}
}

Statement stmt = conn.createStatement();
ResultSet row_headers = stmt.executeQuery(rowHeaders + ";");

stmt = conn.createStatement();
ResultSet categories = stmt.executeQuery("SELECT * FROM categories;");


%>
<div class="form-group">
	<label for="rows">Rows Dropdown Menu</label>
	<select name="rows" id="rows" class="form-control">
		<option value="user">Customers</option>
		<option value="states">States</option>
	</select>
</div>
<div class="form-group">
	<label for="order">Order Dropdown Menu</label>
	<select name="order" id="order" class="form-control">
		<option value="alphabetical">Alphabetical</option>
		<option value="topK">TopK</option>
	</select>
</div>
<div class="form-group">
 	<label for="salesFilteringOption">Sales Filtering Option</label>
	<select name="salesFilteringOption" id="salesFilteringOption" class="form-control">
		<option value="all">All</option>
		<% while (categories.next()) { %>
			<option value="<%=categories.getString("id")%>"><%=categories.getString("name")%></option>
		<% } %>
	</select>
</div>
<div class="form-group">
	<input class="btn btn-primary" type="submit" name="submit" value="Run Query"/>
</div>

<div class="form-group">
	<input class="btn btn-primary" type="submit" name="submit" value="Next 10 Rows"/>
	<input class="btn btn-primary" type="submit" name="submit" value="Next 10 Columns"/>
</div>

<table class="table table-striped">
	<th>User/State</th><th>Total</th>
	<% while (row_headers.next()) { %>
		<tr><td><%=row_headers.getString("row_header")%></td><td><%=row_headers.getString("total")%></td></tr>
	<% } %>
</table>
</body>
</html>