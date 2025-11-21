-- Daily sales, AOV, cancellation rate
with sales as (
  select order_date, sum(line_amount) as revenue, count(distinct order_id) as orders
  from {{ ref('fct_sales') }}
  group by 1
),
aov as (
  select s.order_date, revenue / nullif(orders,0) as avg_order_value
  from sales s
)
select s.order_date, s.revenue, s.orders, a.avg_order_value
from sales s join aov a using(order_date)
order by s.order_date;
