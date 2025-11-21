from dagster import Definitions
from .jobs import nightly_build

defs = Definitions(jobs=[nightly_build])
