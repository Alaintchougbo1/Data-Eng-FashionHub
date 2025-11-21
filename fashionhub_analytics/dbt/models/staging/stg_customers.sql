with base as (
  select
    id,
    initcap(name) as name,
    lower(email) as email,
    telephone,
    country,
    date_inscription
  from RAW_DATA.CUSTOMERS
)
select * from base;
