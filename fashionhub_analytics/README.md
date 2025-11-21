# FashionHub Analytics — Snowflake + dbt

This repository is a starter scaffold for the **E‑commerce Analytics Platform** project.
It mirrors the deliverables and grading grid in your brief and includes runnable
skeletons for data generation, ingestion, transformation, security, and orchestration.

> Target stack: **Snowflake, dbt, Dagster**.


## Layout

```
fashionhub_analytics/
├─ data_generation/
│  ├─ sql_generators/         # Snowflake SQL to synthesize structured/semi-structured data
│  ├─ python_generators/      # Python scripts to emit JSON/CSV/Parquet fixtures
│  └─ setup_all_data.sql      # Master script to orchestrate generators
├─ snowflake/
│  ├─ warehouses.sql          # Multi-cluster WH + auto-suspend/resume
│  ├─ stages_and_pipes.sql    # Internal/external stages + Snowpipe
│  ├─ security.sql            # RBAC, masking, row access policies, tags
│  └─ sharing.sql             # Secure data sharing script
├─ dbt/                       # dbt project
│  ├─ dbt_project.yml
│  ├─ models/
│  │  ├─ staging/
│  │  └─ marts/
│  ├─ analyses/
│  └─ tests/
├─ dagster/
│  ├─ README.md
│  ├─ repository.py
│  └─ jobs.py
├─ docs/
│  ├─ checklist.md            
│  └─ query_profile_notes.md  
└─ Makefile                   
```

## Quickstart

1) Create Snowflake objects:
```sql
-- In Snowflake SQL worksheet
!source snowflake/warehouses.sql
!source snowflake/stages_and_pipes.sql
!source snowflake/security.sql
```

2) Generate demo data:
- Run `data_generation/setup_all_data.sql` in Snowflake (calls the SQL generators).
- Optionally run the Python generators locally to create files for Snowpipe ingestion.

3) Run dbt:
```bash
cd dbt
# configure your ~/.dbt/profiles.yml first
dbt deps
dbt seed --select tag:seed
dbt run
dbt test
dbt docs generate && dbt docs serve
```

4) Orchestrate with Dagster (local):
```bash
cd dagster
pip install -r requirements.txt
dagster dev
```
