-- ============================================================
-- MODULE 1 : ARCHITECTURE & PERFORMANCE TESTS
-- FashionHub Analytics
-- ============================================================

USE ROLE SYSADMIN;
USE DATABASE FASHIONHUB;
USE SCHEMA RAW_DATA;

-- ------------------------------------------------------------
-- 1. CREATE TEST WAREHOUSES
-- ------------------------------------------------------------

CREATE WAREHOUSE IF NOT EXISTS WH_XS
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

CREATE WAREHOUSE IF NOT EXISTS WH_S
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

CREATE WAREHOUSE IF NOT EXISTS WH_M
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- ------------------------------------------------------------
-- 2. PERFORMANCE TESTS : SCAN & AGGREGATION
-- ------------------------------------------------------------

-- Test 1 : Count(*) = SCAN test
USE WAREHOUSE WH_XS;
SELECT COUNT(*) FROM RAW_DATA.ORDERS_RAW;

USE WAREHOUSE WH_S;
SELECT COUNT(*) FROM RAW_DATA.ORDERS_RAW;

USE WAREHOUSE WH_M;
SELECT COUNT(*) FROM RAW_DATA.ORDERS_RAW;

-- ------------------------------------------------------------

-- Test 2 : Aggregation
USE WAREHOUSE WH_XS;
SELECT status, COUNT(*), SUM(amount)
FROM RAW_DATA.ORDERS_RAW
GROUP BY status;

USE WAREHOUSE WH_S;
SELECT status, COUNT(*), SUM(amount)
FROM RAW_DATA.ORDERS_RAW
GROUP BY status;

USE WAREHOUSE WH_M;
SELECT status, COUNT(*), SUM(amount)
FROM RAW_DATA.ORDERS_RAW
GROUP BY status;

-- ------------------------------------------------------------
-- 3. COMPLEX QUERY TEST (multi-table join + aggregation)
-- ------------------------------------------------------------

USE WAREHOUSE WH_XS;
SELECT 
    p.category,
    COUNT(*) AS items_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM RAW_DATA.ORDER_ITEMS oi
JOIN RAW_DATA.PRODUCTS p ON p.id = oi.product_id
JOIN RAW_DATA.ORDERS o   ON o.id = oi.order_id
GROUP BY p.category
ORDER BY revenue DESC;

USE WAREHOUSE WH_M;
SELECT 
    p.category,
    COUNT(*) AS items_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM RAW_DATA.ORDER_ITEMS oi
JOIN RAW_DATA.PRODUCTS p ON p.id = oi.product_id
JOIN RAW_DATA.ORDERS o   ON o.id = oi.order_id
GROUP BY p.category
ORDER BY revenue DESC;

-- ------------------------------------------------------------
-- 4. MICRO-PARTITIONS ANALYSIS
-- ------------------------------------------------------------

SELECT *
FROM TABLE(
  INFORMATION_SCHEMA.TABLE_STORAGE_METRICS(
    TABLE_NAME => 'ORDERS_RAW',
    SCHEMA_NAME => 'RAW_DATA'
  )
);

-- ------------------------------------------------------------
-- 5. CLUSTERING & WAREHOUSE SETTINGS
-- ------------------------------------------------------------

SHOW WAREHOUSES;

SELECT 
  TABLE_CATALOG,
  TABLE_SCHEMA,
  TABLE_NAME,
  CLUSTERING_KEY,
  AUTOMATIC_CLUSTERING_HISTORY
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE TABLE_NAME = 'ORDERS_RAW';

-- END MODULE 1
