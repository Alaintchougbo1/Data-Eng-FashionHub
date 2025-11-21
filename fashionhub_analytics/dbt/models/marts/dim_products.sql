select
  id as product_key,
  name,
  category,
  brand,
  price,
  cost
from {{ ref('stg_products') }};
