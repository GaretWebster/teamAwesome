<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.DecimalFormat, javax.sql.*, javax.naming.*, org.postgresql.util.*"%>
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

int numRows = 20;
int numCols = 10;

session.setAttribute( "rowHeader", "user" );
session.setAttribute( "sortingOption", "topK" );
session.setAttribute( "categoryFilter", "IS NOT NULL" );
session.setAttribute( "firstRowIndex", 0 );
session.setAttribute( "firstColIndex", 0 );

String rowRange = "LIMIT " + Integer.toString(numRows) + " OFFSET " + session.getAttribute( "firstRowIndex" ).toString();
String colRange = "LIMIT " + Integer.toString(numCols) + " OFFSET " + session.getAttribute( "firstColIndex" ).toString();
String categoryFilter = session.getAttribute( "categoryFilter" ).toString();

String product_set = null;
String query = null;

if (session.getAttribute("sortingOption").equals("alphabetical")) {
	product_set = "SELECT p.id, p.name FROM products p WHERE p.category_id " + categoryFilter + " " +
			   "ORDER BY p.name ASC " + colRange;
}
else if (session.getAttribute("sortingOption").equals("topK")) {
	product_set = "SELECT p.id, p.name, SUM(o.price) AS product_total FROM " +
			   "orders o JOIN products p ON o.product_id = p.id AND o.is_cart = false " +
	           "AND p.category_id " + categoryFilter + " " +
			   "GROUP BY p.id ORDER BY product_total DESC " + colRange;
}

if (session.getAttribute("rowHeader").equals("user")) {
	String user_set;
	
	if (session.getAttribute("sortingOption").equals("alphabetical")) {
		user_set = "SELECT u.id, u.name FROM users u WHERE u.role = 'c'"
              + " ORDER BY u.name ASC " + rowRange; 
					
		query = "SELECT u.name AS row_name, p.name AS product_name, SUM(o.price) AS total FROM " +
			   "(" + user_set + ") AS u JOIN ((" + product_set + ") AS p JOIN orders o ON p.id = o.product_id) " +
			   "ON o.user_id = u.id GROUP BY u.name, p.name ORDER BY u.name ASC, p.name ASC";
	}
	else if (session.getAttribute("sortingOption").equals("topK")) {
		user_set = "SELECT u.id, u.name, customer_total FROM " +
				"users u JOIN (SELECT o.user_id, SUM(o.price) AS customer_total FROM " +
				"orders o JOIN products p ON o.product_id = p.id AND o.is_cart = false " +
				"AND p.category_id " + categoryFilter + " " + 
				"GROUP BY o.user_id ORDER BY customer_total DESC) AS uncessecary_alias " +
				"ON u.id = user_id " + rowRange;
		
		query = "SELECT u.name AS row_name, p.name AS product_name, " + 
		       "u.customer_total, p.product_total, SUM(o.price) AS total FROM " +
			   "(" + user_set + ") AS u JOIN ((" + product_set + ") AS p JOIN orders o ON p.id = o.product_id) " +
			   "ON o.user_id = u.id GROUP BY u.name, p.name, u.customer_total, p.product_total " +
			   "ORDER BY u.customer_total DESC, p.product_total DESC";
	}
}
else if (session.getAttribute("rowHeader").equals("state")) {
	String state_set;
	
	if (session.getAttribute("sortingOption").equals("alphabetical")) {
		state_set = "SELECT DISTINCT u.state FROM users u " +
                	 "ORDER BY u.state ASC " + rowRange;
		
		
		query = "SELECT s.state AS row_name, p.name AS product_name, SUM(o.price) AS total FROM " +
				"(" + state_set + ") AS s JOIN ((" + product_set + ") AS p JOIN orders o ON p.id = o.product_id) " +
				"ON o.user_id = u.id GROUP BY u.name, p.name ORDER BY u.name ASC, p.name ASC"; 
	}
	else if (session.getAttribute("sortingOption").equals("topK")) {
		state_set = "SELECT u.state, SUM(r.customer_total) AS state_total FROM " +
					 "users u JOIN (SELECT o.user_id, SUM(o.price) AS customer_total FROM " +
					 "orders o JOIN products p ON o.product_id = p.id AND o.is_cart = false " +
					 "AND p.category_id " + categoryFilter + " " +
					 "GROUP BY o.user_id) AS r " +
					 "ON u.id = r.user_id GROUP BY u.state ORDER BY state_total DESC " + rowRange;
	}
}

Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
ResultSet results = stmt.executeQuery(query + ";");

stmt = conn.createStatement();
ResultSet categories = stmt.executeQuery("SELECT * FROM categories;");


%>
<div class="form-group">
	<label for="rows">Rows Dropdown Menu</label>
	<select name="rows" id="rows" class="form-control">
		<option value="customers">Customers</option>
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
	<%
		results.next();
	
		out.print("<th></th>");
		
		for (int c = 0; c < numCols; ++c) {
			out.print("<th>" + results.getString("product_name") + "</th>");
			results.next();
		}
		
		results.first();
		
		outerloop:
		for (int r = 0; r < numRows; ++r) {
			out.print("<tr><td>" + results.getString("row_name") + "</td>");
			
			for (int c = 0; c < numCols; ++c) {
				out.println("<td>" + new DecimalFormat("0.00##").format(results.getInt("total")) + "</td>");
				if (!results.next()) {
					break outerloop;
				}
			}
			
			out.print("</tr>");
		}
	%>
</table>
</body>
</html>