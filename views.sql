
-- Reusable derived tables

-- 1) Order financials with extended price and margin
CREATE VIEW v_order_lines AS
SELECT
  oi.order_item_id,
  oi.order_id,
  o.order_date,
  o.store_id,
  o.customer_id,
  oi.product_id,
  p.product_name,
  p.category,
  oi.quantity,
  oi.unit_price,
  oi.discount,
  (oi.unit_price - oi.discount) * oi.quantity AS net_revenue,
  (p.unit_cost) * oi.quantity AS cost,
  ((oi.unit_price - oi.discount) - p.unit_cost) * oi.quantity AS margin
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id;

-- 2) Order-level KPI
CREATE VIEW v_orders AS
SELECT
  o.order_id, o.order_date, o.store_id, o.customer_id,
  SUM((oi.unit_price - oi.discount) * oi.quantity) AS order_revenue,
  SUM(((oi.unit_price - oi.discount) - p.unit_cost) * oi.quantity) AS order_margin,
  COUNT(DISTINCT oi.order_item_id) AS line_count
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
GROUP BY o.order_id;

-- 3) Customer first purchase date
CREATE VIEW v_customer_first_purchase AS
SELECT
  customer_id,
  MIN(order_date) AS first_purchase_date
FROM orders
GROUP BY customer_id;
