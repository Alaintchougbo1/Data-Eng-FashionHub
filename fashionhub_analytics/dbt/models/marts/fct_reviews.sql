select
  product_id as product_key,
  count(*) as review_count,
  avg(rating) as avg_rating
from {{ ref('stg_reviews') }}
group by 1;
