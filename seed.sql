
-- Minimal but meaningful seed data
DELETE FROM payments;
DELETE FROM order_items;
DELETE FROM orders;
DELETE FROM inventory;
DELETE FROM products;
DELETE FROM stores;
DELETE FROM customers;

-- Customers
INSERT INTO customers (customer_id, first_name, last_name, email, created_at) VALUES
(1,'Ava','Khan','ava.khan@example.com','2024-01-05'),
(2,'Ben','Lopez','ben.lopez@example.com','2024-02-10'),
(3,'Chloe','Zhang','chloe.zhang@example.com','2024-03-12'),
(4,'Drew','Nguyen','drew.nguyen@example.com','2024-05-01'),
(5,'Eli','Patel','eli.patel@example.com','2024-07-20'),
(6,'Faye','Kim','faye.kim@example.com','2025-01-08');

-- Stores
INSERT INTO stores (store_id, store_name, city, state, opened_at) VALUES
(1,'Downtown','Des Moines','IA','2023-08-01'),
(2,'Uptown','Chicago','IL','2023-11-15');

-- Products
INSERT INTO products (product_id, product_name, category, unit_cost, unit_price, active) VALUES
(1,'Cotton Tee','Apparel',8.00,15.00,1),
(2,'Denim Jeans','Apparel',25.00,49.00,1),
(3,'Sneakers','Footwear',35.00,79.00,1),
(4,'Water Bottle','Accessories',4.00,12.00,1),
(5,'Backpack','Accessories',18.00,45.00,1),
(6,'Hoodie','Apparel',20.00,39.00,1);

-- Inventory
INSERT INTO inventory (store_id, product_id, on_hand, last_updated) VALUES
(1,1,100,'2025-07-01'),
(1,2,60,'2025-07-01'),
(1,3,50,'2025-07-01'),
(1,4,200,'2025-07-01'),
(1,5,40,'2025-07-01'),
(1,6,70,'2025-07-01'),
(2,1,120,'2025-07-01'),
(2,2,55,'2025-07-01'),
(2,3,35,'2025-07-01'),
(2,4,180,'2025-07-01'),
(2,5,30,'2025-07-01'),
(2,6,80,'2025-07-01');

-- Orders (2024-2025 spread)
INSERT INTO orders (order_id, customer_id, store_id, order_date, status) VALUES
(101,1,1,'2024-07-15','paid'),
(102,2,1,'2024-08-03','paid'),
(103,3,2,'2024-10-20','paid'),
(104,1,2,'2025-01-10','paid'),
(105,4,1,'2025-02-14','paid'),
(106,5,1,'2025-03-05','paid'),
(107,6,2,'2025-04-22','paid'),
(108,2,2,'2025-06-11','paid'),
(109,3,1,'2025-07-04','paid'),
(110,1,1,'2025-08-19','paid'),
(111,6,1,'2025-09-10','paid');

-- Order Items (unit_price snapshots & discounts)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, discount) VALUES
(1,101,1,2,15.00,0.00),
(2,101,4,1,12.00,2.00),
(3,102,2,1,49.00,5.00),
(4,103,3,1,79.00,0.00),
(5,103,5,1,45.00,0.00),
(6,104,6,1,39.00,0.00),
(7,104,1,1,15.00,0.00),
(8,105,2,2,49.00,4.00),
(9,106,4,3,12.00,1.00),
(10,106,1,1,15.00,0.00),
(11,107,3,1,79.00,10.00),
(12,107,5,1,45.00,5.00),
(13,108,6,2,39.00,0.00),
(14,109,2,1,49.00,0.00),
(15,109,4,1,12.00,0.00),
(16,110,1,3,15.00,0.00),
(17,110,6,1,39.00,0.00),
(18,111,3,1,79.00,0.00);

-- Payments (summing to gross less discounts)
INSERT INTO payments (payment_id, order_id, paid_at, method, amount) VALUES
(1001,101,'2024-07-15','card', 15*2 + (12-2)*1),
(1002,102,'2024-08-03','card', (49-5)*1),
(1003,103,'2024-10-20','transfer', 79 + 45),
(1004,104,'2025-01-10','card', 39 + 15),
(1005,105,'2025-02-14','cash', (49-4)*2),
(1006,106,'2025-03-05','card', (12-1)*3 + 15),
(1007,107,'2025-04-22','card', (79-10) + (45-5)),
(1008,108,'2025-06-11','transfer', 39*2),
(1009,109,'2025-07-04','giftcard', 49 + 12),
(1010,110,'2025-08-19','card', 15*3 + 39),
(1011,111,'2025-09-10','card', 79);
