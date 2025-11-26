-- Create the database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- Create MySQL user and grant privileges
CREATE USER IF NOT EXISTS 'sanket'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'sanket'@'localhost';
FLUSH PRIVILEGES;

-- Users table for login/signup
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- Products available in the store
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(100),
    image_url VARCHAR(500)
);

-- Cart items linked to users with quantity control
CREATE TABLE cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Orders placed by users
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    payment_mode VARCHAR(50) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Items within each order
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Contact messages from users
CREATE TABLE contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    message TEXT NOT NULL
);

-- Sample users for login
INSERT INTO users (username, email, password) VALUES
('om', 'om@example.com', 'om@2025'),
('nikhil', 'nikhil@example.com', 'Nikhil@2025');

-- Product catalog
INSERT INTO products (name, price, category, image_url) VALUES
('Boat Earbuds', 1999.00, 'Audio', '/static/images/Bluetooth Earbuds.jpg'),
('Samsung Speaker', 2569.00, 'Audio', '/static/images/Bluetooth Speaker.jpg'),
('External HDD 1TB', 5100.00, 'Accessories', '/static/images/External HDD 1TB.jpg'),
('Fitness Band', 3100.00, 'Accessories', '/static/images/Fitness Band.jpg'),
('Gaming Monitor', 11450.00, 'Laptops', '/static/images/Gaming Monitor 24.jpg'),
('Laptop 14-inch', 43999.00, 'Audio', '/static/images/Laptop 14-inch.jpg'),
('HP Laser Printer', 8759.00, 'Audio', '/static/images/Laser Printer.jpg'),
('Mechanical Keyboard', 1300.00, 'Audio', '/static/images/Mechanical Keyboard.jpg'),
('Soundbar 2.1', 9999.00, 'Audio', '/static/images/Soundbar 2.1.jpg'),
('USB-C Cable', 999.00, 'Audio', '/static/images/USB-C Cable.jpg'),
('Samsung Webcam HD', 4599.00, 'Audio', '/static/images/Webcam HD.jpg'),
('Wireless Mouse', 2699.00, 'Audio', '/static/images/Wireless Mouse.jpg'),
('Smartphone X1', 23999.00, 'Accessories', '/static/images/Smartphone X1.jpg'),
('Samsung Speaker', 8999.00, 'Audio', '/static/images/Smart TV 43.jpg'),
('Router Dual Band', 3726.00, 'Accessories', '/static/images/Router Dual Band.jpg'),
('Power Bank 20,000mAh', 1999.00, 'Accessories', '/static/images/Power Bank 20,000mAh.jpg'),
('Soundbar 2.1', 1999.00, 'Audio', '/static/images/Soundbar 2.1.jpg'),
('Smartwatch Pro', 1999.00, 'Accessories', '/static/images/Smartwatch Pro.jpg'),
('Smartphone X1', 1999.00, 'Accessories', '/static/images/Smartphone X1.jpg');
