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
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("submit");
		if (action.equals("insert")) {
			int queries_num = Integer.parseInt(request.getParameter("queries_num"));
			Random rand = new Random();
			int random_num = rand.nextInt(30) + 1;
			if (queries_num < random_num) random_num = queries_num;
			Statement stmt = conn.createStatement();
			stmt.executeQuery("SELECT proc_insert_orders(" + queries_num + "," + random_num + ")");
			out.println("<script>alert('" + queries_num + " orders are inserted!');</script>");
		}
		else if (action.equals("refresh")) {
			//Need to implement.
		}
	}
	
%>
%>
<form action="orders.jsp" method="post">
	<div class="form-group">
		<label for="rows">Rows Dropdown Menu</label>
		<select name="rows" id="rows" class="form-control">
			<option value="user">Customers</option>
			<option value="state">States</option>
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
		<input class="btn btn-primary" type="submit" name="submit" value="Run Query"/>
	</div>
	
	<div class="form-group">
		<input class="btn btn-primary" type="submit" name="submit" value="Next 10 Rows"/>
		<input class="btn btn-primary" type="submit" name="submit" value="Next 10 Columns"/>
	</div>
</form>
<table class="table table-striped">
	<%
		/*if ("POST".equalsIgnoreCase(request.getMethod())) {
		out.print("<th></th>");
		
		for (int c = 0; c < numCols; ++c) {
			System.out.println(results.getString("product_name"));
			out.print("<th>" + results.getString("product_name") + "</th>");
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
		}*/
	%>
</table>
</body>
</html>
