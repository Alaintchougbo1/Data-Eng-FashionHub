create or replace table RAW_DATA.API_LOGS (log variant);

insert into RAW_DATA.API_LOGS
select object_construct(
  'request_id', uuid_string(),
  'path', '/orders',
  'status', iff(uniform(0,100,random())<5,500,200),
  'latency_ms', uniform(20, 1200, random()),
  'payload', object_construct('page', uniform(1,9,random()), 'size', 50)
)::variant
from table(generator(rowcount => 1000));
