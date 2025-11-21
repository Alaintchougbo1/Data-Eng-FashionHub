-- ============================================================
-- MODULE 4 : DBT SETUP (STAGING + MARTS)
-- FashionHub Analytics
-- ============================================================

-- ================================================
-- 1. STAGING MODELS (dans models/staging/)
-- ================================================

-- stg_orders.sql
SELECT
  id           AS order_id,
  customer_id,
  order_date,
  status,
  amount
FROM RAW_DATA.ORDERS_RAW;

-- stg_products.sql
SELECT
  id AS product_id,
  name,
  category,
  price
FROM RAW_DATA.PRODUCTS;

-- stg_customers.sql
SELECT
  id AS customer_id,
  name,
  email,
  country
FROM RAW_DATA.CUSTOMERS;

-- ================================================
-- 2. FACT TABLE (dans models/marts/)
-- ================================================

-- fct_sales.sql
SELECT
  o.order_id,
  o.customer_id,
  c.country AS customer_country,
  oi.product_id,
  p.category AS product_category,
  oi.quantity,
  oi.unit_price,
  (oi.quantity * oi.unit_price) AS revenue
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('stg_order_items') }} oi
  ON oi.order_id = o.order_id
JOIN {{ ref('stg_products') }} p
  ON p.product_id = oi.product_id
JOIN {{ ref('stg_customers') }} c
  ON c.customer_id = o.customer_id;

-- ================================================
-- 3. DIMENSIONS (dans models/marts/)
-- ================================================

-- dim_customers.sql
SELECT 
  customer_id,
  name,
  email,
  country
FROM {{ ref('stg_customers') }};

-- dim_products.sql
SELECT
  product_id,
  name,
  category,
  price
FROM {{ ref('stg_products') }};

-- END MODULE 4
