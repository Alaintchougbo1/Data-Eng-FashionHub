-- ============================================================
-- MODULE 5 : SECURITY, RBAC & DATA GOVERNANCE
-- FashionHub Analytics
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE FASHIONHUB;
USE SCHEMA RAW_DATA;

---------------------------------------------------------------
-- 1. CREATION DES ROLES
---------------------------------------------------------------

CREATE ROLE IF NOT EXISTS DATA_ENGINEER;
CREATE ROLE IF NOT EXISTS DATA_ANALYST;
CREATE ROLE IF NOT EXISTS DATA_SCIENTIST;

-- Attribution (à toi par exemple)
GRANT ROLE DATA_ENGINEER   TO USER ALAIN;
GRANT ROLE DATA_ANALYST    TO USER ALAIN;
GRANT ROLE DATA_SCIENTIST  TO USER ALAIN;

---------------------------------------------------------------
-- 2. GRANTS PAR ROLE
---------------------------------------------------------------

-- DATA ENGINEER = can create structures, stages, pipes, tables
GRANT USAGE ON DATABASE FASHIONHUB TO ROLE DATA_ENGINEER;
GRANT USAGE ON SCHEMA RAW_DATA    TO ROLE DATA_ENGINEER;
GRANT CREATE TABLE  ON SCHEMA RAW_DATA TO ROLE DATA_ENGINEER;
GRANT CREATE VIEW   ON SCHEMA RAW_DATA TO ROLE DATA_ENGINEER;
GRANT CREATE PIPE   ON SCHEMA RAW_DATA TO ROLE DATA_ENGINEER;
GRANT USAGE, MONITOR ON WAREHOUSE WH_S TO ROLE DATA_ENGINEER;

-- DATA ANALYST = read-only on analytics
GRANT USAGE        ON DATABASE FASHIONHUB TO ROLE DATA_ANALYST;
GRANT USAGE        ON SCHEMA RAW_DATA TO ROLE DATA_ANALYST;
GRANT SELECT       ON ALL TABLES IN SCHEMA RAW_DATA TO ROLE DATA_ANALYST;
GRANT SELECT       ON FUTURE TABLES IN SCHEMA RAW_DATA TO ROLE DATA_ANALYST;
GRANT USAGE        ON WAREHOUSE WH_S TO ROLE DATA_ANALYST;

-- DATA SCIENTIST = read + compute intensive
GRANT USAGE ON DATABASE FASHIONHUB TO ROLE DATA_SCIENTIST;
GRANT USAGE ON SCHEMA RAW_DATA     TO ROLE DATA_SCIENTIST;
GRANT SELECT ON ALL TABLES IN SCHEMA RAW_DATA TO ROLE DATA_SCIENTIST;
GRANT USAGE ON WAREHOUSE WH_M      TO ROLE DATA_SCIENTIST;

---------------------------------------------------------------
-- 3. MASKING POLICY (Ex: masquer les emails)
---------------------------------------------------------------

CREATE OR REPLACE MASKING POLICY mask_email AS (val STRING) 
RETURNS STRING ->
  CASE 
    WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'DATA_ENGINEER') 
      THEN val
    ELSE CONCAT('***', SUBSTR(val, POSITION('@' IN val)))
  END;

-- Application sur la colonne email
ALTER TABLE RAW_DATA.CUSTOMERS 
  MODIFY COLUMN email 
  SET MASKING POLICY mask_email;

---------------------------------------------------------------
-- 4. ROW ACCESS POLICY (Ex: restriction par pays)
---------------------------------------------------------------

CREATE OR REPLACE ROW ACCESS POLICY region_filter
AS (country STRING) 
RETURNS BOOLEAN ->
  CASE 
    WHEN CURRENT_ROLE() = 'DATA_ANALYST' 
      THEN country = 'FR'
    ELSE TRUE
  END;

-- Application (exemple)
ALTER TABLE RAW_DATA.ORDERS 
  MODIFY ROW ACCESS POLICY region_filter ON (country);

---------------------------------------------------------------
-- 5. SECURE DATA SHARING (READER ACCOUNT)
---------------------------------------------------------------

-- 1) Create share
CREATE OR REPLACE SHARE fashionhub_share;

-- 2) Grant objects
GRANT USAGE ON DATABASE FASHIONHUB TO SHARE fashionhub_share;
GRANT USAGE ON SCHEMA RAW_DATA     TO SHARE fashionhub_share;
GRANT SELECT ON VIEW RAW_DATA.VW_CLICKSTREAM_ACTIONS TO SHARE fashionhub_share;

-- 3) Provide to external consumer
-- (consumer provides AWS account or Snowflake account locator)
-- ALTER SHARE fashionhub_share ADD ACCOUNT = <external_account>;

-- End Module 5
