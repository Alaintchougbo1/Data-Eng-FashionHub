with src as (
  select review
  from RAW_DATA.PRODUCT_REVIEWS
)
select
  review:review_id::string as review_id,
  review:product_id::number as product_id,
  review:rating::number as rating,
  review:meta:region::string as region,
  review:meta:lang::string as lang
from src;
