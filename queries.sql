
.headers on
.mode column

-- ============ 1) Monthly revenue, AOV, and orders ============
WITH monthly AS (
  SELECT strftime('%Y-%m', order_date) AS ym,
         COUNT(*) AS orders,
         SUM(order_revenue) AS revenue
  FROM v_orders
  GROUP BY ym
)
SELECT
  ym AS month,
  orders,
  ROUND(revenue,2) AS revenue,
  ROUND(revenue * 1.0 / NULLIF(orders,0), 2) AS aov
FROM monthly
ORDER BY month;

-- ============ 2) Top products by revenue & margin ============
SELECT
  product_name,
  SUM(net_revenue) AS revenue,
  SUM(margin) AS margin,
  COUNT(*) AS lines
FROM v_order_lines
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 10;

-- ============ 3) RFM segmentation ============
WITH last_date AS (SELECT MAX(order_date) AS max_d FROM orders),
cust_rev AS (
  SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    MAX(o.order_date) AS last_order,
    COUNT(DISTINCT o.order_id) AS frequency,
    SUM(v.order_revenue) AS monetary
  FROM customers c
  LEFT JOIN orders o ON o.customer_id = c.customer_id
  LEFT JOIN v_orders v ON v.order_id = o.order_id
  GROUP BY c.customer_id
),
scores AS (
  SELECT
    cr.*,
    (julianday((SELECT max_d FROM last_date)) - julianday(cr.last_order)) AS recency_days,
    NTILE(3) OVER (ORDER BY (julianday((SELECT max_d FROM last_date)) - julianday(cr.last_order)) ASC) AS r_score,
    NTILE(3) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(3) OVER (ORDER BY monetary DESC) AS m_score
  FROM cust_rev cr
)
SELECT customer_id, customer_name,
       ROUND(recency_days,1) AS recency_days,
       frequency, ROUND(monetary,2) AS monetary,
       r_score, f_score, m_score,
       (r_score || f_score || m_score) AS rfm_code
FROM scores
ORDER BY r_score DESC, f_score DESC, m_score DESC;

-- ============ 4) New vs Returning customers by month ============
WITH firsts AS (
  SELECT customer_id, MIN(order_date) AS first_date FROM orders GROUP BY customer_id
),
labelled AS (
  SELECT
    o.order_id,
    strftime('%Y-%m', o.order_date) AS ym,
    CASE WHEN o.order_date = (SELECT first_date FROM firsts f WHERE f.customer_id=o.customer_id)
         THEN 'New' ELSE 'Returning' END AS cust_type
  FROM orders o
)
SELECT ym, cust_type, COUNT(*) AS orders
FROM labelled
GROUP BY ym, cust_type
ORDER BY ym, cust_type;

-- ============ 5) Store leaderboard with YoY growth ============
WITH by_month AS (
  SELECT store_id, strftime('%Y-%m', order_date) AS ym, SUM(order_revenue) AS rev
  FROM v_orders GROUP BY store_id, ym
),
yoy AS (
  SELECT b1.store_id, b1.ym, b1.rev,
         LAG(b1.rev, 12) OVER (PARTITION BY b1.store_id ORDER BY b1.ym) AS rev_last_year
  FROM by_month b1
)
SELECT s.store_name, ym,
       ROUND(rev,2) AS revenue,
       ROUND(((rev - rev_last_year) * 100.0) / NULLIF(rev_last_year,0), 2) AS yoy_pct
FROM yoy
JOIN stores s ON s.store_id = yoy.store_id
ORDER BY ym, store_name;

-- ============ 6) Cohort-like table: first month vs activity month ============
WITH first_month AS (
  SELECT customer_id, strftime('%Y-%m', MIN(order_date)) AS cohort FROM orders GROUP BY customer_id
),
activity AS (
  SELECT o.customer_id, strftime('%Y-%m', o.order_date) AS act_month
  FROM orders o
)
SELECT fm.cohort, a.act_month, COUNT(DISTINCT a.customer_id) AS active_customers
FROM first_month fm
JOIN activity a ON a.customer_id = fm.customer_id
GROUP BY fm.cohort, a.act_month
ORDER BY fm.cohort, a.act_month;

-- ============ 7) Inventory coverage (toy calc) ============
-- Average daily sales in the last 90 days vs on_hand
WITH last_90 AS (
  SELECT date(MAX(order_date), '-90 day') AS start_d, MAX(order_date) AS end_d FROM orders
),
sales AS (
  SELECT
    ol.store_id, ol.product_id, SUM(ol.quantity) AS qty,
    (julianday((SELECT end_d FROM last_90)) - julianday((SELECT start_d FROM last_90))) AS days
  FROM v_order_lines ol
  JOIN orders o ON o.order_id = ol.order_id
  WHERE o.order_date >= (SELECT start_d FROM last_90)
  GROUP BY ol.store_id, ol.product_id
)
SELECT s.store_id, p.product_name, i.on_hand,
       ROUND(qty / NULLIF(days,0), 2) AS avg_daily_sales,
       ROUND(i.on_hand / NULLIF((qty / NULLIF(days,0)),0), 1) AS days_of_cover
FROM sales s
JOIN inventory i ON i.store_id = s.store_id AND i.product_id = s.product_id
JOIN products p  ON p.product_id = s.product_id
ORDER BY days_of_cover;

-- ============ 8) Contribution margin by product category ============
SELECT category,
       ROUND(SUM(margin),2) AS total_margin,
       ROUND(SUM(net_revenue),2) AS total_revenue,
       ROUND( (SUM(margin) * 100.0) / NULLIF(SUM(net_revenue),0), 2) AS margin_pct
FROM v_order_lines
GROUP BY category
ORDER BY total_margin DESC;
