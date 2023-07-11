{# templates/dag_template.py #}

from datetime import datetime
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.providers.amazon.aws.operators.ecs import EcsOperator


with DAG('dbt.{{dbt_job_name}}', description='DBT Task running - {{dbt_job_name}} Model',
          schedule_interval='{{schedule}}',
          start_date=datetime(2017, 3, 20), 
          max_active_runs=1,
          catchup=False,
          tags=["repo:medallion-dbt", "dbt", "{{ tags|join('\",\"')}}"]):

    cluster_name = "medallion-dbt"
    task_definition_name = "medallion-dbt-run"

    dbt_ecs_operator = EcsOperator(
        task_id="ecs_run_{{dbt_job_name}}",
        cluster=cluster_name,
        task_definition=task_definition_name,
        launch_type="FARGATE",
        overrides={
            "containerOverrides": [
                {
                    "name": "dbt",
                    "command": [
                        "--select", "{{dbt_job_name}}"
                    ],
                },
            ],
        },
        network_configuration={
            "awsvpcConfiguration": {
                "subnets": ["subnet-0f13024214fe8248a", "subnet-07942ea20b0cea893"],
                "securityGroups": ["sg-02e07527d3854470b"],
                "assignPublicIp": "DISABLED",
            },
        },
        reattach=True,
        awslogs_group="/ecs/medallion-dbt-run",
        awslogs_stream_prefix="ecs/medallion-dbt"
    )

    dbt_ecs_operator