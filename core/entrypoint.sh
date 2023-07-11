#!/bin/bash

dbt run "$@"
dbt test "$@"
dbt run-operation _add_schemas_to_datashare
dbt run-operation _trigger_dbt_job
