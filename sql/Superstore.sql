DROP DATABASE IF EXISTS Superstore_project;
CREATE DATABASE Superstore_project CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE Superstore_project;

CREATE TABLE Geography (
    geo_id INT AUTO_INCREMENT PRIMARY KEY,
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(50),
    postal_code VARCHAR(20)
);

CREATE TABLE Customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(150),
    segment VARCHAR(50)
);

CREATE TABLE Products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    sub_category VARCHAR(100)
);

DROP TABLE IF EXISTS Orders;

CREATE TABLE Orders (
    row_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    order_date VARCHAR(50),
    ship_date VARCHAR(50),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    geo_id INT,
    sales VARCHAR(50),
    quantity VARCHAR(50),
    discount VARCHAR(50),
    profit VARCHAR(50),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES Products(product_id),
    CONSTRAINT fk_geo FOREIGN KEY (geo_id) REFERENCES Geography(geo_id)
);

CREATE TABLE temp_superstore (
    Row_ID TEXT,
    Order_ID TEXT,
    Order_Date TEXT,
    Ship_Date TEXT,
    Ship_Mode TEXT,
    Customer_ID TEXT,
    Customer_Name TEXT,
    Segment TEXT,
    Country TEXT,
    City TEXT,
    State TEXT,
    Postal_Code TEXT,
    Region TEXT,
    Product_ID TEXT,
    Category TEXT,
    Sub_Category TEXT,
    Product_Name TEXT,
    Sales TEXT,
    Quantity TEXT,
    Discount TEXT,
    Profit TEXT
);

INSERT INTO Geography (country, city, state, region, postal_code)
SELECT DISTINCT Country, City, State, Region, Postal_Code
FROM temp_superstore;

INSERT INTO Customers (customer_id, customer_name, segment)
SELECT DISTINCT Customer_ID, Customer_Name, Segment
FROM temp_superstore;

INSERT INTO Products (product_id, product_name, category, sub_category)
SELECT Product_ID, MAX(Product_Name), Category, Sub_Category
FROM temp_superstore
GROUP BY Product_ID, Category, Sub_Category;

INSERT INTO Orders (row_id, order_id, order_date, ship_date, ship_mode, customer_id, product_id, geo_id, sales, quantity, discount, profit)
SELECT 
    t.Row_ID, t.Order_ID, t.Order_Date, t.Ship_Date, t.Ship_Mode, 
    t.Customer_ID, t.Product_ID, g.geo_id, t.Sales, t.Quantity, t.Discount, t.Profit
FROM temp_superstore t
JOIN Geography g ON t.Postal_Code = g.postal_code 
                AND t.City = g.city 
                AND t.State = g.state;
                
SELECT COUNT(*) FROM Orders;

DROP TABLE temp_superstore;

CREATE OR REPLACE VIEW orders_ab_test AS
SELECT *,
    CASE 
        WHEN `row_id` % 2 = 0 THEN 'Control (A)' 
        ELSE 'Test (B)' 
    END AS ab_group,
    CASE 
        WHEN `row_id` % 2 <> 0 THEN Sales * 1.15 
        ELSE Sales 
    END AS test_sales
FROM orders;