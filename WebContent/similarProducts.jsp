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
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("submit");
		if (action.equals("delete")) {
			int id = Integer.parseInt(request.getParameter("id"));
			Statement stmt = conn.createStatement();
			String sql = "UPDATE products SET is_delete = true where id = " + id;
			try {
				stmt.executeUpdate(sql);
			}
			catch(Exception e) {out.println("<script>alert('can not delete!');</script>");}
		}
		else if (action.equals("update")) {
			int id = Integer.parseInt(request.getParameter("id"));
			String name = request.getParameter("name");
			String sku = request.getParameter("sku");
			Float price = Float.parseFloat(request.getParameter("price"));
			Statement stmt = conn.createStatement();
			String sql = "UPDATE products SET name = '" + name +
					"', sku = '" + sku + "', price = " + price + " where id = " + id;
			int result = stmt.executeUpdate(sql);
			if (result == 1) out.println("<script>alert('update product sucess!');</script>");
		    else out.println("<script>alert('update product fail!');</script>");
		}
		else if (action.equals("insert")) {
			String name = request.getParameter("name");
			String category_name = request.getParameter("category_name");
			String sku = request.getParameter("sku");
			Float price = Float.parseFloat(request.getParameter("price"));
			Statement stmt1 = conn.createStatement();
			ResultSet rs1 = stmt1.executeQuery("SELECT id from categories where name = '" + category_name + "'");
			if (rs1.next()) {
				int category_id = rs1.getInt(1);
				Statement stmt2 = conn.createStatement();
				String sql = "INSERT into products(name, category_id, sku, price, is_delete) values('" + name +
						"', '" + category_id + "', '" + sku + "', '" + price + "', false)";
				int result = stmt2.executeUpdate(sql);
				if (result == 1) out.println("<script>alert('insert into product sucess!');</script>");
			    else out.println("<script>alert('insert into product fail!');</script>");
			}
			else {out.println("<script>alert('category does not exist!');</script>");}
		}
	}
	
	String queryString = "SELECT t1.p_id as p1_id, t2.p_id as p2_id, SUM(t1.total_spent * t2.total_spend)/(SUM(t1.total_spent)*sum(t2.total_spend)) AS cos FROM  (SELECT o.user_id, p.id as p_id, SUM(o.price) AS total_spent FROM products p JOIN orders o ON p.id = o.product_id GROUP BY o.user_id, p.id) as t1  JOIN  (SELECT o.user_id, p.id as p_id, SUM(o.price) as total_spend FROM products p JOIN orders o ON p.id = o.product_id GROUP BY o.user_id, p.id) as t2  ON t1.user_id = t2.user_id WHERE t1.p_id < t2.p_id GROUP BY t1.p_id, t2.p_id order by cos DESC LIMIT 100;";
	
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery(queryString);
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
	<th>Category 1 topK</th>
	<th>Category 2 topK</th>
	<tr>
	<form action="products.jsp" method="POST">
		<td><input name="name"/></td>
		<td><input name="category_name"/></td>
	</form>
	</tr>
<% while (rs.next()) { %>
	<tr>
	<form action="products.jsp" method="POST">
		<td><input value="<%=rs.getString("cos")%>" name="name" size="15"/>
		<td><%=rs.getString("cos")%></td>
	</form>
	</tr>
<% } %>
</table>

</body>
</html>