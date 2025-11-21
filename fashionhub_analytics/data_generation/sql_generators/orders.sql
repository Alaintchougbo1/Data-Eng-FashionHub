create or replace table RAW_DATA.ORDERS as
select
  seq4()::number as id,
  c.id as customer_id,
  dateadd('day', -uniform(1, 365, random()), current_date()) as order_date,
  iff(uniform(0,100,random()) < 6, 'CANCELLED', 'COMPLETED') as status,
  0.0::number(10,2) as amount
from RAW_DATA.CUSTOMERS c, table(generator(rowcount => 10000));
