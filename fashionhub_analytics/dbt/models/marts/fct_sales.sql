with oi as (
  select * from {{ ref('stg_order_items') }}
),
o as (
  select * from {{ ref('stg_orders') }}
)
select
  o.id as order_id,
  o.customer_id as customer_key,
  oi.product_id as product_key,
  o.order_date,
  o.status,
  oi.quantity,
  oi.unit_price,
  oi.line_amount
from o
join oi on oi.order_id = o.id
where o.status <> 'CANCELLED';
