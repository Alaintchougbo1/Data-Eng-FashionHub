-- ============================================================
-- MODULE 2 : INGESTION PIPELINE (S3 → STAGE → SNOWPIPE)
-- FashionHub Analytics
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE FASHIONHUB;
USE SCHEMA RAW_DATA;

-- ------------------------------------------------------------
-- 1. STORAGE INTEGRATION
-- ------------------------------------------------------------

CREATE OR REPLACE STORAGE INTEGRATION S3_FASHIONHUB_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::111122223333:role/snowflake_s3_access'
  STORAGE_ALLOWED_LOCATIONS = ('s3://fashionhub-data/orders/')

DESC INTEGRATION S3_FASHIONHUB_INT;

-- ------------------------------------------------------------
-- 2. CREATE STAGE
-- ------------------------------------------------------------

CREATE OR REPLACE STAGE RAW_DATA.STAGE_S3_ORDERS
  URL='s3://fashionhub-data/orders/'
  STORAGE_INTEGRATION=S3_FASHIONHUB_INT
  FILE_FORMAT=(TYPE=CSV FIELD_DELIMITER=',' SKIP_HEADER=1);

LIST @RAW_DATA.STAGE_S3_ORDERS;

-- ------------------------------------------------------------
-- 3. TABLE FOR RAW ORDERS
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE RAW_DATA.ORDERS_RAW (
  id NUMBER,
  customer_id NUMBER,
  order_date DATE,
  status STRING,
  amount FLOAT
);

-- ------------------------------------------------------------
-- 4. SNOWPIPE
-- ------------------------------------------------------------

CREATE OR REPLACE PIPE RAW_DATA.PIPE_ORDERS_AUTO
  AUTO_INGEST = TRUE
  AS
  COPY INTO RAW_DATA.ORDERS_RAW
  FROM @RAW_DATA.STAGE_S3_ORDERS
  FILE_FORMAT=(TYPE=CSV FIELD_DELIMITER=',' SKIP_HEADER=1)
  ON_ERROR='CONTINUE';

DESC PIPE RAW_DATA.PIPE_ORDERS_AUTO;

-- ------------------------------------------------------------
-- 5. PIPE TEST
-- ------------------------------------------------------------

SELECT SYSTEM$PIPE_STATUS('RAW_DATA.PIPE_ORDERS_AUTO');

SELECT *
FROM TABLE(
  INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'RAW_DATA.ORDERS_RAW',
    START_TIME => DATEADD('hour', -24, CURRENT_TIMESTAMP())
  )
);

-- END MODULE 2
