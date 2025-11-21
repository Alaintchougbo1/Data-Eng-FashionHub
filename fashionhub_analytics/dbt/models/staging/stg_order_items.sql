select
  order_id,
  product_id,
  quantity,
  unit_price,
  quantity * unit_price as line_amount
from RAW_DATA.ORDER_ITEMS;
