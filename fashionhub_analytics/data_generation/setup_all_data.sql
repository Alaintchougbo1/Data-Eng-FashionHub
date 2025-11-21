-- Run all generators in order
!source data_generation/sql_generators/customers.sql;
!source data_generation/sql_generators/products.sql;
!source data_generation/sql_generators/orders.sql;
!source data_generation/sql_generators/order_items.sql;
!source data_generation/sql_generators/clickstream.sql;
!source data_generation/sql_generators/reviews.sql;
!source data_generation/sql_generators/api_logs.sql;
