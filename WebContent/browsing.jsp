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
		if (action.equals("cart")) {
			int product_id = Integer.parseInt(request.getParameter("id"));
			int user_id = (Integer) session.getAttribute("user_id");
			Float price = Float.parseFloat(request.getParameter("price"));
			int quantity = Integer.parseInt(request.getParameter("quantity"));
		    if (quantity > 0) {
		    	Statement stmt = conn.createStatement();
			    String sql = "INSERT INTO orders (user_id,product_id,quantity,price,is_cart) " +
			    	"VALUES ('"+user_id+"', '"+product_id+"', '"+quantity+"', '"+price*quantity+"', true)";
			    int result = stmt.executeUpdate(sql);
			    if (result == 1) out.println("<script>alert('insert into cart success');</script>");
			    else out.println("<script>alert('insert into cart fail');</script>");
		    }
		    else {out.println("<script>alert('? quantity = 0.');</script>");}
		}
		else if (action.equals("purchase")) {
			
			/* update product total */  
		    Statement stmt = conn.createStatement();
		    ResultSet user_info = stmt.executeQuery("SELECT u.state_id FROM users u " +
		    										"WHERE u.id = " + session.getAttribute("user_id").toString() + ";");
		    
		    user_info.next();
		    String state_column = "t" + user_info.getInt("state_id");
		    
		    stmt = conn.createStatement();
		    ResultSet orders = stmt.executeQuery("SELECT * from orders WHERE user_id = " + session.getAttribute("user_id") +
		    		                             " AND is_cart = true;"); 

		    while (orders.next()) {
		    	/* Update product totals */
			    stmt = conn.createStatement();
			    String get_product_info = "SELECT p." + state_column + ", p.total FROM product_totals p " +
			                              "WHERE p.product_id = " + Integer.toString(orders.getInt("product_id")) + ";";                  
			    ResultSet product_info = stmt.executeQuery(get_product_info);
		    	product_info.next();
		    	
		    	Double new_product_state_total = product_info.getDouble(state_column) + orders.getDouble("price");
		    	Double new_product_total = product_info.getDouble("total") + orders.getDouble("price");
		    	
		    	stmt = conn.createStatement();
		    	stmt.executeUpdate("UPDATE product_totals SET " + state_column + "=" + new_product_state_total.toString() +
		    			           ",total=" + new_product_total.toString() + " " +
		    	                   "WHERE product_id = " + Integer.toString(orders.getInt("product_id")) + ";");
		    	
		    	/* Update state totals */
		    	stmt = conn.createStatement();
		    	ResultSet product_category = stmt.executeQuery(
		    								"SELECT p.category_id FROM products p WHERE p.id = " + 
		    	                             orders.getInt("product_id") + ";");
		    	product_category.next();
		    	
		    	stmt = conn.createStatement();
		    	ResultSet total = stmt.executeQuery(
		    						"SELECT total FROM state_totals WHERE state_id = " + user_info.getInt("state_id") +
		    			          	" AND category_id = " + product_category.getInt("category_id") + ";");
		    	total.next();
		    			          
		    	Double new_total = total.getDouble("total") + orders.getDouble("price");
		    	stmt = conn.createStatement();
		    	stmt.executeUpdate("UPDATE state_totals SET total=" + new_total.toString() + " " +
		    	                   "WHERE state_id = " + user_info.getInt("state_id") + " " +
		    	                   "AND category_id = " + product_category.getInt("category_id") + ";");
		    	
		    }
		    
		    /* Update orders */
		    
		    stmt = conn.createStatement();
		    String sql = "UPDATE orders SET is_cart = false where user_id = " + session.getAttribute("user_id") +
		    		" and is_cart = true";
		    int result = stmt.executeUpdate(sql);
		    if (result == 1) out.println("<script>alert('purchase sucess!');</script>");
		    else out.println("<script>alert('purchase fail!');</script>");
		    
		}
	}
		
	Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery("SELECT p.id, p.name, p.sku, p.price, c.name as category_name" + 
		" FROM products p, categories c where is_delete = false and c.id = p.category_id");
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
	<th>Product Name</th>
	<th>Category Name</th>
	<th>SKU</th>
	<th>Price</th>
	<th>Quantity</th>
	<th>Cart</th>
<% while (rs.next()) { %>
	<tr>
		<td><input value="<%=rs.getString("name")%>" name="name" size="15"/>
		<td><input value="<%=rs.getString("category_name")%>" name="category_name" size="30"/></td>
		<td><input value="<%=rs.getString("sku")%>" name="sku" size="30"/></td>
	<form action="browsing.jsp" method="POST">
		<td><input value="<%=rs.getFloat("price")%>" name="price" size="30"/></td>
		<td><input value="0" name="quantity" size="30"/></td>
    	<input type="hidden" value="<%=rs.getInt("id")%>" name="id"/>
    	<td><input class="btn btn-primary" type="submit" name="submit" value="cart"/></td>
    </form>
	</tr>
<% } %>
</table>
</body>

</html>