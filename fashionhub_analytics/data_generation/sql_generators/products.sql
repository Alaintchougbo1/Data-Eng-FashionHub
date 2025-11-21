create or replace table RAW_DATA.PRODUCTS as
select
  seq4()::number as id,
  initcap(name) as name,
  category,
  initcap(brand) as brand,
  round(uniform(10, 600, random()), 2) as price,
  round(price * uniform(0.3, 0.8, random()), 2) as cost
from (
  select
    any_value(v:value::string) as name,
    any_value(cat.value::string) as category,
    any_value(br.value::string) as brand
  from table(generator(rowcount => 300))
  , lateral flatten(input => parse_json('["t-shirt","sneakers","jacket","pants","dress","hoodie","cap","socks","bag","watch"]')) v
  , lateral flatten(input => parse_json('["men","women","kids","accessories"]')) cat
  , lateral flatten(input => parse_json('["fashionhub","urban fox","swift","nordic","pacific"]')) br
);
