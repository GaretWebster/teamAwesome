<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.DecimalFormat, java.util.HashMap, javax.sql.*, javax.naming.*, org.postgresql.util.*"%>
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
	
	Statement stmt;
	
	/* Precomputation */
	
	if (application.getAttribute("precomputation_done") == null) {
		
		stmt = conn.createStatement();
		stmt.executeUpdate("DELETE FROM product_totals;");
		
		stmt = conn.createStatement();
		stmt.executeUpdate("DELETE FROM state_totals;");
		
		/* compute product totals */
		
		String get_product_totals_by_state = 
				"SELECT p.id AS product_id, u.state_id, SUM(o.price) AS total " +
				"FROM orders o " +
				"JOIN products p " +
				"ON o.product_id = p.id " +
				"JOIN users u " +
				"ON o.user_id = u.id " +
				"GROUP BY p.id, u.state_id;";
				
		stmt = conn.createStatement();
		ResultSet totals = stmt.executeQuery(get_product_totals_by_state);
		
		HashMap<String, Double> product_state_totals = new HashMap<String, Double>();
		while (totals.next()) {
			double total = totals.getDouble("total");
			
			int product_id = totals.getInt("product_id");
			int state_id = totals.getInt("state_id");
			String key = Integer.toString(product_id) + " " + Integer.toString(state_id);
			
			product_state_totals.put(key, total); 
		}
		
		stmt = conn.createStatement();
		String get_products = "SELECT p.id, p.category_id FROM products p;";
		ResultSet products = stmt.executeQuery(get_products);
		
		while (products.next()) {
			int product_id = products.getInt("id");
			int category_id = products.getInt("category_id");
			Double product_total = new Double(0);
			
			String insert_row = "INSERT INTO product_totals VALUES " +
				"(" + Integer.toString(product_id) + ", " + Integer.toString(category_id);
								
			for (int s = 1; s <= 50; ++s) {
				insert_row += ", ";
				
				String key = Integer.toString(product_id) + " " + Integer.toString(s);
				Double state_total = product_state_totals.get(key);
				if (state_total == null) {
					state_total = new Double(0);
				}
				
				product_total += state_total;
				insert_row +=  state_total.toString(); 
			}
			
			insert_row += ", " + product_total.toString() + ");";
			
			stmt = conn.createStatement();
			stmt.executeUpdate(insert_row);
		}
		
		/* compute state totals */
		
		String get_state_totals = 
			"SELECT s.id AS state_id, p.category_id, SUM(o.price) AS total " +
			"FROM orders o " +
			"JOIN products p " +
			"ON o.product_id = p.id " +
			"JOIN users u " +
			"ON o.user_id = u.id " +
			"JOIN states s " +
			"ON u.state_id = s.id " +
			"GROUP BY s.id, p.category_id;";
		stmt = conn.createStatement();
		ResultSet state_totals_rs = stmt.executeQuery(get_state_totals);
		
		HashMap<String, Double> state_totals = new HashMap<String, Double>();
		while (state_totals_rs.next()) {
			Double state_total = state_totals_rs.getDouble("total");
			
			int state_id = state_totals_rs.getInt("state_id");
			int category_id = state_totals_rs.getInt("category_id");
			String key = Integer.toString(state_id) + " " + Integer.toString(category_id);
			
			state_totals.put(key, state_total);
		}
		
		stmt = conn.createStatement();
		ResultSet categories = stmt.executeQuery("SELECT * FROM categories;");
			
		while (categories.next()) {
			int category_id = categories.getInt("id");
			
			for (int s = 1; s <= 50; ++s) {
				String key = Integer.toString(s) + " " + Integer.toString(category_id);
				
				Double state_category_total = state_totals.get(key);
				if (state_category_total == null) {
					state_category_total = new Double(0);
				}
				
				stmt = conn.createStatement();
				stmt.executeUpdate("INSERT INTO state_totals VALUES (" +
								   Integer.toString(s) + ", " + Integer.toString(category_id) +
								   ", " + state_category_total.toString() + ");");
			}
		}
			
		application.setAttribute("precomputation_done", true);
	}
	
	/* Perform initial page load */
	
	String category_filter = "IS NOT NULL";
	if (request.getParameter("salesFilteringOption") != null) {
		category_filter = "= " + request.getParameter("salesFilteringOption");
	}
	
	String get_top_products = "SELECT * FROM product_totals WHERE category_id " + category_filter +
							  " ORDER BY total DESC LIMIT 50;";
	stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, 
			   					ResultSet.CONCUR_READ_ONLY);
	ResultSet top_products = stmt.executeQuery(get_top_products);
								 
	String get_top_states = "SELECT state_id, SUM(total) AS state_total FROM state_totals WHERE category_id " + category_filter +
							" GROUP BY state_id ORDER BY state_total DESC LIMIT 50";
	stmt = conn.createStatement();
	ResultSet top_states = stmt.executeQuery(get_top_states);
	
	stmt = conn.createStatement();
	ResultSet categories = stmt.executeQuery("SELECT * FROM categories;");
%>
<form action="orders.jsp" method="post">
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
</form>
<table class="table table-striped">
	<%
		top_products.beforeFirst();
		while (top_products.next()) {
			out.println("<th>" + top_products.getInt("product_id") + "</th>");
		}
		
		while (top_states.next()) {
			out.println("<tr class='" + top_states.getInt("state_id") + "'>");
			out.println("<td>" + top_states.getInt("state_id") + "</td>");
			
			top_products.beforeFirst();
			while (top_products.next()) {
				out.println("<td class='" + top_products.getInt("product_id") + "'>" + 
							 top_products.getDouble("t" + top_states.getInt("state_id")) + "</td>");
			}
			
			out.println("<tr>");
		}
	%>
</table>
</body>
</html>
