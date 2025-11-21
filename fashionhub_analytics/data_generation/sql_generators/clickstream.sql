-- VARIANT column with nested arrays/objects and LATERAL FLATTEN friendly shapes
create or replace table RAW_DATA.CLICKSTREAM_EVENTS (event variant);

insert into RAW_DATA.CLICKSTREAM_EVENTS
select
  object_construct(
    'event_id', uuid_string(),
    'ts', dateadd('second', -uniform(1, 3600*24*90, random()), current_timestamp()),
    'user', object_construct('id', c.id, 'country', c.country),
    'session', object_construct('id', uuid_string(), 'ref', iff(uniform(0,100,random())<50,'ads','organic')),
    'actions', array_construct(
        object_construct('type','view','product_id', p1.id),
        object_construct('type','add_to_cart','product_id', p2.id, 'qty', uniform(1,3,random()))
    ),
    'device', object_construct('ua','Mozilla/5.0','os', iff(uniform(0,1,random())=0,'ios','android'))
  )::variant
from RAW_DATA.CUSTOMERS c
join RAW_DATA.PRODUCTS p1 on p1.id % 5 = c.id % 5
join RAW_DATA.PRODUCTS p2 on p2.id % 7 = c.id % 7
sample (5);
