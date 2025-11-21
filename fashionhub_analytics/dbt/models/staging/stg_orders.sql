with base as (
  select
    id,
    customer_id,
    to_date(order_date) as order_date,
    upper(status) as status,
    amount
  from RAW_DATA.ORDERS
)
select * from base;
