create or replace table RAW_DATA.ORDER_ITEMS as
select
  o.id as order_id,
  p.id as product_id,
  uniform(1, 4, random()) as quantity,
  p.price as unit_price
from RAW_DATA.ORDERS o
join RAW_DATA.PRODUCTS p
  on uniform(0,1,random())=0  -- random-ish join to spread items
qualify row_number() over (partition by o.id order by random()) <= uniform(1,4,random());
-- Recompute ORDERS.amount
update RAW_DATA.ORDERS o
set amount = (select sum(quantity*unit_price) from RAW_DATA.ORDER_ITEMS i where i.order_id = o.id);
