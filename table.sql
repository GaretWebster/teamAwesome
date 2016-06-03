DROP TABLE IF EXISTS states CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product_totals CASCADE;
DROP TABLE IF EXISTS state_totals CASCADE;

CREATE TABLE states (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE
);

CREATE TABLE users (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE,
    role  char(1) NOT NULL,
    age   INTEGER NOT NULL,
    state_id INTEGER REFERENCES states (id) NOT NULL
);

CREATE TABLE categories (
    id  SERIAL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE,
    description  TEXT NOT NULL
);


CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    sku CHAR(10) NOT NULL UNIQUE,
    category_id INTEGER REFERENCES categories (id) NOT NULL,
    price FLOAT NOT NULL CHECK (price >= 0),
    is_delete BOOLEAN NOT NULL
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users (id) NOT NULL,
    product_id INTEGER REFERENCES products (id) NOT NULL,
    quantity INTEGER NOT NULL,
    price FLOAT NOT NULL CHECK (price >= 0),
    is_cart BOOLEAN NOT NULL
);

CREATE TABLE state_totals (
	state_id INTEGER REFERENCES states(id) NOT NULL,
	category_id INTEGER REFERENCES categories (id) NOT NULL,
	total FLOAT NOT NULL
);

CREATE TABLE product_totals (
	product_id INTEGER REFERENCES products(id) NOT NULL,
	category_id INTEGER REFERENCES categories(id) NOT NULL,
	t1 FLOAT,
	t2 FLOAT,
	t3 FLOAT,
	t4 FLOAT,
	t5 FLOAT,
	t6 FLOAT,
	t7 FLOAT,
	t8 FLOAT,
	t9 FLOAT,
	t10 FLOAT,
	t11 FLOAT,
	t12 FLOAT,
	t13 FLOAT,
	t14 FLOAT,
	t15 FLOAT,
	t16 FLOAT,
	t17 FLOAT,
	t18 FLOAT,
	t19 FLOAT,
	t20 FLOAT,
	t21 FLOAT,
	t22 FLOAT,
	t23 FLOAT,
	t24 FLOAT,
	t25 FLOAT,
	t26 FLOAT,
	t27 FLOAT,
	t28 FLOAT,
	t29 FLOAT,
	t30 FLOAT,
	t31 FLOAT,
	t32 FLOAT,
	t33 FLOAT,
	t34 FLOAT,
	t35 FLOAT,
	t36 FLOAT,
	t37 FLOAT,
	t38 FLOAT,
	t39 FLOAT,
	t40 FLOAT,
	t41 FLOAT,
	t42 FLOAT,
	t43 FLOAT,
	t44 FLOAT,
	t45 FLOAT,
	t46 FLOAT,
	t47 FLOAT,
	t48 FLOAT,
	t49 FLOAT,
	t50 FLOAT,
	total FLOAT
);
