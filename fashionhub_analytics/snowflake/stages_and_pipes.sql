-- Internal stage for temp files
create or replace stage STAGE_INTERNAL file_format = (type = csv field_delimiter=',' skip_header=1);

-- External stage for S3 bucket
create or replace stage STAGE_S3
  url='s3://fashionhub-data/orders/'
  storage_integration = MY_S3_INT
  file_format = (type = csv field_delimiter=',' skip_header=1);

-- Named JSON/Parquet formats
create or replace file format FF_JSON type = json;
create or replace file format FF_PARQUET type = parquet;

-- Snowpipe for automatic ingestion from S3 into RAW_DATA.ORDERS 
create or replace pipe RAW_DATA.PIPE_ORDERS auto_ingest = true as
copy into RAW_DATA.ORDERS
from @STAGE_S3/orders/
file_format = (type=csv field_delimiter=',' skip_header=1)
on_error = 'continue';
