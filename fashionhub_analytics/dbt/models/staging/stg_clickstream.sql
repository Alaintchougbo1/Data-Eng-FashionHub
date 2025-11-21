-- Flatten nested JSON from VARIANT
with src as (
  select event
  from RAW_DATA.CLICKSTREAM_EVENTS
),
actions as (
  select
    event:event_id::string as event_id,
    event:ts::timestamp as ts,
    event:user:id::number as user_id,
    event:user:country::string as country,
    event:session:id::string as session_id,
    f.value:type::string as action_type,
    f.value:product_id::number as product_id,
    f.value:qty::number as qty
  from src, lateral flatten(input => src.event:actions) f
)
select * from actions;
