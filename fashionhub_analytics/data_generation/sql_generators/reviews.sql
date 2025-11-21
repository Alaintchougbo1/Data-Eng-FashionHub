create or replace table RAW_DATA.PRODUCT_REVIEWS (review variant);

insert into RAW_DATA.PRODUCT_REVIEWS
select object_construct(
  'review_id', uuid_string(),
  'product_id', p.id,
  'rating', uniform(1,5,random()),
  'title', 'Good product',
  'body', 'Lorem ipsum',
  'meta', object_construct('region', c.country, 'lang', iff(c.country in ('FR','CA'),'fr','en'))
)::variant
from RAW_DATA.PRODUCTS p
join RAW_DATA.CUSTOMERS c on c.id % 11 = p.id % 11
sample (20);
