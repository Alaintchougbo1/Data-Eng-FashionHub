.PHONY: help dbt-run dbt-test dbt-docs dagster

help:
	@echo "Common targets:"
	@echo "  dbt-run     -> run all dbt models"
	@echo "  dbt-test    -> run dbt tests"
	@echo "  dbt-docs    -> build dbt docs"
	@echo "  dagster     -> start Dagster dev server"

dbt-run:
	cd dbt && dbt run

dbt-test:
	cd dbt && dbt test

dbt-docs:
	cd dbt && dbt docs generate

dagster:
	cd dagster && dagster dev
