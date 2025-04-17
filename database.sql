-- DROP DATABASE IF EXISTS tester;
-- CREATE DATABASE tester;

USE tester;
DROP TABLE IF EXISTS Cart_items;
DROP TABLE IF EXISTS Cart;
DROP TABLE IF EXISTS Search_history;
DROP TABLE IF EXISTS Event_log;
DROP TABLE IF EXISTS Order_items;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Delivery;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Customer;

-- comments --
-- create some example tables to test functions and triggers with

-- customers table
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    cName VARCHAR(255) NOT NULL,
    cCorpName VARCHAR(255) DEFAULT NULL,
    cEmail VARCHAR(255) UNIQUE NOT NULL,
    cPhone VARCHAR(15) DEFAULT NULL,
    cAddress VARCHAR(255) DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- category table
CREATE TABLE Category (
    category_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    catName VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL
);

-- products table
CREATE TABLE Products (
    products_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    category_id INT NOT NULL,
    pName VARCHAR(255) NOT NULL,
    price DECIMAL(7,2) NOT NULL DEFAULT 0.00,
    stock INT DEFAULT 0,
    description TEXT NULL,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- cart table
CREATE TABLE Cart (
    cart_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    date_added DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);


-- cart items table
CREATE TABLE Cart_items (
    c_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    cart_id INT NOT NULL,
    customer_id INT NOT NULL,
    products_id INT NOT NULL,
    quantity INT DEFAULT 1 NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES Cart(cart_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (products_id) REFERENCES Products(products_id)
);

-- order table
CREATE TABLE Orders (
    orders_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_sum DECIMAL(8,2) NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- orders item table
CREATE TABLE Order_items (
    orderItems_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    orders_id INT NOT NULL,
    products_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(7,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (orders_id) REFERENCES Orders(orders_id),
    FOREIGN KEY (products_id) REFERENCES Products(products_id)
);

-- payment table
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    orders_id INT NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    payment_method ENUM('Credit Card', 'Bank Transfer', 'Klarna') NOT NULL,
    payment_status ENUM('Successful', 'Pending', 'Failed') NOT NULL,
    FOREIGN KEY (orders_id) REFERENCES Orders(orders_id)
);

-- delivery table
create table Delivery(
	delivery_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    orders_id INT NOT NULL,
    delivery_date DATE NOT NULL,
    delivery_status ENUM('Pending', 'Shipped', 'Delivered', 'Delayed', 'Cancelled') DEFAULT 'Pending' NOT NULL,
    FOREIGN KEY (orders_id) REFERENCES Orders(orders_id)
);

-- event log table
CREATE TABLE Event_log (
    event_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- search history table
CREATE TABLE Search_history (
    search_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,
    search_term VARCHAR(255) NOT NULL,
    search_time DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

INSERT INTO Customer(customer_id, cName, cCorpName, cEmail, cPhone, cAddress) 
VALUES (100, 'Tester1', 'Tester School', 'tester@testmail.com', '+46712345678', 'Testergatan 123, 456 78, Teststad');

INSERT INTO Category(category_id, catName) VALUES (1, 'Tablets');
INSERT INTO Category(category_id, catName) VALUES (2, 'Laptop');
INSERT INTO Category(category_id, catName) VALUES (3, 'Phones');
INSERT INTO Category(category_id, catName) VALUES (4, 'Projectors');
INSERT INTO Category(category_id, catName) VALUES (5, 'Smartboard');
INSERT INTO Category(category_id, catName) VALUES (6, 'Accessories');

INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1000, 1, 'iPad', 10000.00, 28);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1001, 1, 'iPad Air', 9000.00, 88);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1002, 1, 'Huawei Matepad', 7000.00, 12);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1003, 2, 'Asus Vivobook s14', 12000.00, 8);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1004, 2, 'Huawei Matebook 13', 15000.00, 2);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1005, 2, 'HP Pavillion', 20000.00, 50);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1006, 2, 'Lenovo Yoga 9', 14000.00, 33);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1007, 3, 'Huawei P70 pro', 23000.00, 1);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1008, 3, 'iPhone 16 PRO MAX', 19000.00, 28);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1009, 3, 'Samsung S23+', 11000.00, 78);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1010, 4, 'Projector 1', 33000.00, 18);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1011, 4, 'Philips Neopicks 100', 1500.00, 66);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1012, 4, 'Samsung Freestyle 2', 7000.00, 4);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1013, 4, 'Plexgear Full HD/LCD projektor', 2700.00, 22);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1014, 6, 'Apple Pencil Gen 2', 2000.00, 228);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1015, 6, 'Laptopbad (Logga)', 700.00, 228);
INSERT INTO Products(products_id, category_id, pName, price, stock) VALUES (1016, 6, 'Logitech Keyboard', 999.00, 128);


