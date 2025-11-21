select
  id as customer_key,
  name,
  email,
  country,
  date_inscription
from {{ ref('stg_customers') }};
