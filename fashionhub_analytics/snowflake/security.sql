-- Roles
create role if not exists ANALYST;
create role if not exists DATA_ENGINEER;
create role if not exists DATA_SCIENTIST;
create role if not exists ADMIN;

-- Grant hierarchy (example)
grant role ANALYST to role DATA_SCIENTIST;
grant role DATA_SCIENTIST to role DATA_ENGINEER;
grant role DATA_ENGINEER to role ADMIN;

-- Least privilege example grants
grant usage on database RAW_DATA to role ANALYST;
grant usage on schema RAW_DATA to role ANALYST;
grant select on all tables in schema RAW_DATA to role ANALYST;
grant select on future tables in schema RAW_DATA to role ANALYST;

-- Masking policy (email/phone) - conditional by role
create or replace masking policy MASK_PII as (val string) returns string ->
  case
    when current_role() in ('ADMIN','DATA_ENGINEER') then val
    else regexp_replace(val, '(?s).', '*')
  end;

alter table RAW_DATA.CUSTOMERS modify column email set masking policy MASK_PII;
alter table RAW_DATA.CUSTOMERS modify column telephone set masking policy MASK_PII;

-- Row access policy restricting by country
create or replace row access policy RAP_COUNTRY as (country string) returns boolean ->
  case
    when current_role() in ('ADMIN','DATA_ENGINEER') then true
    when current_role() = 'ANALYST' then country in ('FR','DE','GB')
    else false
  end;

alter table RAW_DATA.CUSTOMERS add row access policy RAP_COUNTRY on (country);

-- Tags & tag-based masking (example)
create or replace tag CLASSIFICATION allowed_values 'PII','FINANCIAL','PUBLIC','CONFIDENTIAL';
alter table RAW_DATA.CUSTOMERS modify column email set tag CLASSIFICATION = 'PII';
