-- Creates RAW_DATA.CUSTOMERS with synthetic data
create schema if not exists RAW_DATA;

create or replace table RAW_DATA.CUSTOMERS as
select
  seq4()::number as id,
  initcap(fake_first_name) || ' ' || initcap(fake_last_name) as name,
  lower(replace(initcap(fake_first_name)||'.'||initcap(fake_last_name)||'@example.com',' ','')) as email,
  '+1' || lpad(uniform(1000000000, 1999999999, random()), 10, '0') as telephone,
  country,
  dateadd('day', -uniform(1, 365*3, random()), current_date()) as date_inscription
from table(generator(rowcount => 5000)),
lateral (
  select
    any_value(value:countries[uniform(0, array_size(value:countries)-1, random())]::string) as country,
    any_value(value:first_names[uniform(0, array_size(value:first_names)-1, random())]::string) as fake_first_name,
    any_value(value:last_names[uniform(0, array_size(value:last_names)-1, random())]::string) as fake_last_name
  from (select parse_json('{
    "countries": ["US","FR","DE","GB","ES","IT","CA","BR","AU","JP","IN"],
    "first_names": ["alex","sam","jordan","morgan","taylor","jamie","chris","casey","owen","nina","ravi","li","noa"],
    "last_names": ["smith","dupont","muller","brown","garcia","rossi","martin","santos","nguyen","suzuki","khan","zhou"]
  }') as value)
);
