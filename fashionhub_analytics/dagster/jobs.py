from dagster import job, op
import subprocess, os

@op
def dbt_run():
    subprocess.check_call(["dbt", "run"], cwd=os.path.join(os.path.dirname(__file__), "..", "dbt"))

@op
def dbt_test():
    subprocess.check_call(["dbt", "test"], cwd=os.path.join(os.path.dirname(__file__), "..", "dbt"))

@job
def nightly_build():
    dbt_run()
    dbt_test()
