-- Multi-warehouse setup with auto-suspend/resume
create or replace warehouse WH_XS auto_suspend = 60 auto_resume = true initially_suspended = true warehouse_size = 'XSMALL';
create or replace warehouse WH_S  auto_suspend = 60 auto_resume = true initially_suspended = true warehouse_size = 'SMALL';
create or replace warehouse WH_M  auto_suspend = 120 auto_resume = true initially_suspended = true warehouse_size = 'MEDIUM';
create or replace warehouse WH_L  auto_suspend = 300 auto_resume = true initially_suspended = true warehouse_size = 'LARGE';

-- Example policies:
-- ETL/batch -> WH_M or WH_L; BI/adhoc -> WH_S; tiny builds/tests -> WH_XS.
