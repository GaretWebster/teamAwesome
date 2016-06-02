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
	
	boolean precompute = false;
	
	if (precompute) {
		Statement stmt = conn.createStatement();
		
		String get_product_totals_by_state = 
				"SELECT p.id AS product_id, u.state_id, SUM(o.price) AS total FROM " +
				"products p JOIN users u JOIN orders o ON o.product.id = p.id AND " +
				"o.user_id = u.id GROUP BY p.id, u.state_id;";			
		ResultSet totals = stmt.executeQuery(get_product_totals_by_state);
		
		HashMap<String, Double> product_state_totals = new HashMap<String, Double>();
		while (totals.next()) {
			double total = totals.getDouble("total");
			
			int product_id = totals.getInt("product_id");
			int state_id = totals.getInt("state_id");
			String key = Integer.toString(product_id) + " " + Integer.toString(state_id);
			
			product_state_totals.put(key, total); 
		}
		
		String get_products = "SELECT p.id, p.category_id FROM products;";
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
			
			stmt.executeUpdate(insert_row);
		}
	
	}

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
	%>
</table>
</body>
</html>
