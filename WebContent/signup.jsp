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
	<ul class="nav navbar-nav">
		<li><a href="login.jsp">LOGIN</a></li>
		<li><a href="signup.jsp">SIGN UP</a></li>
	</ul>
</div>
<div>
<form action="login.jsp" method="post">
  <div class="form-group">
  	<label for="name">Name</label>
  	<input type="text" class="form-control" id="name" name="name"/>
  </div>
  <div class="form-group">
  	<label for="role">Role</label>
  	<select name="role" id="role" class="form-control">
	    <option value="o">Owner</option>
	    <option value="c">Customer</option>
	</select>
  </div>
  <div class="form-group">
  	<label for="age">Age</label>
  	<input type="text" class="form-control" id="age" name="age">
  </div>
  <div class="form-group">
  	<label for="state">State</label>
  	<select name="state" id="state" class="form-control">
		<option value="1">Alabama</option>
		<option value="2">Alaska</option>
		<option value="3">Arizona</option>
		<option value="4">Arkansas</option>
		<option value="5">California</option>
		<option value="6">Colorado</option>
		<option value="7">Connecticut</option>
		<option value="8">Delaware</option>
		<option value="9">Florida</option>
		<option value="10">Georgia</option>
		<option value="11">Hawaii</option>
		<option value="12">Idaho</option>
		<option value="13">Illinois</option>
		<option value="14">Indiana</option>
		<option value="15">Iowa</option>
		<option value="16">Kansas</option>
		<option value="17">Kentucky</option>
		<option value="18">Louisiana</option>
		<option value="19">Maine</option>
		<option value="20">Maryland</option>
		<option value="21">Massachusetts</option>
		<option value="22">Michigan</option>
		<option value="23">Minnesota</option>
		<option value="24">Mississippi</option>
		<option value="25">Missouri</option>
		<option value="26">Montana</option>
		<option value="27">Nebraska</option>
		<option value="28">Nevada</option>
		<option value="29">New Hampshire</option>
		<option value="30">New Jersey</option>
		<option value="31">New Mexico</option>
		<option value="32">New York</option>
		<option value="33">North Carolina</option>
		<option value="34">North Dakota</option>
		<option value="35">Ohio</option>
		<option value="36">Oklahoma</option>
		<option value="37">Oregon</option>
		<option value="38">Pennsylvania</option>
		<option value="39">Rhode Island</option>
		<option value="40">South Carolina</option>
		<option value="41">South Dakota</option>
		<option value="42">Tennessee</option>
		<option value="43">Texas</option>
		<option value="44">Utah</option>
		<option value="45">Vermont</option>
		<option value="46">Virginia</option>
		<option value="47">Washington</option>
		<option value="48">West Virginia</option>
		<option value="49">Wisconsin</option>
		<option value="50">Wyoming</option>
	</select>
  </div>
  <div class="form-group">
  	<input class="btn btn-primary" type="submit" value="Join">
  </div>
 </form>
 </div>
</body>
</html>
