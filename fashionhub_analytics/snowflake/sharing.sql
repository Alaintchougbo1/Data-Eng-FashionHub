-- Secure data share to external account (replace with real account)
create or replace share FASHIONHUB_SHARE;
grant usage on database RAW_DATA to share FASHIONHUB_SHARE;
grant usage on schema RAW_DATA to share FASHIONHUB_SHARE;
grant select on table RAW_DATA.ORDERS to share FASHIONHUB_SHARE;
-- ALTER SHARE FASHIONHUB_SHARE ADD ACCOUNT = <CONSUMER_ACCOUNT>;
