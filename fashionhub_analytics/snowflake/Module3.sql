-- ============================================================
-- MODULE 3 : JSON VIEWS & ANALYTICS
-- Project : FashionHub Analytics
-- ============================================================

USE ROLE SYSADMIN;
USE WAREHOUSE WH_S;
USE DATABASE FASHIONHUB;
USE SCHEMA RAW_DATA;

---------------------------------------------------------------
-- 1. CLICKSTREAM VIEW
---------------------------------------------------------------

CREATE OR REPLACE VIEW RAW_DATA.VW_CLICKSTREAM_ACTIONS AS
SELECT
  c.EVENT:event_id::string        AS event_id,
  c.EVENT:ts::timestamp           AS event_ts,
  c.EVENT:user:id::number         AS user_id,
  c.EVENT:user:country::string    AS user_country,
  c.EVENT:session:id::string      AS session_id,
  c.EVENT:session:ref::string     AS session_ref,
  a.value:product_id::number      AS product_id,
  a.value:type::string            AS action_type,
  a.value:qty::number             AS quantity
FROM RAW_DATA.CLICKSTREAM_EVENTS c,
LATERAL FLATTEN(input => c.EVENT:actions) a;

---------------------------------------------------------------
-- 2. PRODUCT REVIEWS VIEW
---------------------------------------------------------------

CREATE OR REPLACE VIEW RAW_DATA.VW_PRODUCT_REVIEWS AS
SELECT
  r.REVIEW:review_id::string      AS review_id,
  r.REVIEW:product_id::number     AS product_id,
  r.REVIEW:rating::number         AS rating,
  r.REVIEW:comment::string        AS comment,
  r.REVIEW:ts::timestamp          AS review_ts,
  r.REVIEW:user:id::number        AS user_id,
  r.REVIEW:user:country::string   AS user_country
FROM RAW_DATA.PRODUCT_REVIEWS r;

---------------------------------------------------------------
-- 3. API LOGS VIEW
---------------------------------------------------------------

CREATE OR REPLACE VIEW RAW_DATA.VW_API_LOGS AS
SELECT
  l.LOG:ts::timestamp                 AS log_ts,
  l.LOG:level::string                 AS level,
  l.LOG:message::string               AS message,
  l.LOG:request:method::string        AS req_method,
  l.LOG:request:path::string          AS req_path,
  l.LOG:response:status::number       AS resp_status,
  l.LOG:response:time_ms::number      AS resp_time_ms
FROM RAW_DATA.API_LOGS l;

---------------------------------------------------------------
-- 4. ANALYTICAL QUERIES
---------------------------------------------------------------

-- A. Top products added to cart
SELECT
  a.product_id,
  p.name,
  p.category,
  COUNT(*) AS add_to_cart_count
FROM RAW_DATA.VW_CLICKSTREAM_ACTIONS a
JOIN RAW_DATA.PRODUCTS p
  ON p.id = a.product_id
WHERE a.action_type = 'add_to_cart'
GROUP BY a.product_id, p.name, p.category
ORDER BY add_to_cart_count DESC
LIMIT 10;

---------------------------------------------------------------

-- B. Funnel view -> add_to_cart
SELECT
  product_id,
  SUM(CASE WHEN action_type = 'view' THEN 1 ELSE 0 END) AS views,
  SUM(CASE WHEN action_type = 'add_to_cart' THEN 1 ELSE 0 END) AS adds,
  ROUND(
    NVL(SUM(CASE WHEN action_type = 'add_to_cart' THEN 1 ELSE 0 END) /
        NULLIF(SUM(CASE WHEN action_type = 'view' THEN 1 ELSE 0 END), 0), 0), 4
  ) AS view_to_cart_rate
FROM RAW_DATA.VW_CLICKSTREAM_ACTIONS
GROUP BY product_id
HAVING views > 50
ORDER BY view_to_cart_rate DESC
LIMIT 20;

---------------------------------------------------------------

-- C. Average rating per product
SELECT
  r.product_id,
  p.name,
  AVG(r.rating) AS avg_rating,
  COUNT(*)      AS nb_reviews
FROM RAW_DATA.VW_PRODUCT_REVIEWS r
JOIN RAW_DATA.PRODUCTS p
  ON p.id = r.product_id
GROUP BY r.product_id, p.name
HAVING nb_reviews >= 5
ORDER BY avg_rating DESC;

---------------------------------------------------------------

-- D. Frequent API errors
SELECT
  resp_status,
  req_path,
  COUNT(*) AS error_count,
  AVG(resp_time_ms) AS avg_resp_time_ms
FROM RAW_DATA.VW_API_LOGS
WHERE level = 'ERROR'
GROUP BY resp_status, req_path
ORDER BY error_count DESC
LIMIT 20;

---------------------------------------------------------------
-- END OF MODULE 3
---------------------------------------------------------------
