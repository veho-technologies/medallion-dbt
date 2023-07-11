

from datetime import datetime
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.providers.amazon.aws.operators.ecs import EcsOperator


with DAG('dbt.stg_dynamodb_lugus__packages', description='DBT Task running - stg_dynamodb_lugus__packages Model',
          schedule_interval='0 0 * * *',
          start_date=datetime(2017, 3, 20), 
          max_active_runs=1,
          catchup=False,
          tags=["repo:medallion-dbt", "dbt", "staging","lugus"]):

    cluster_name = "medallion-dbt"
    task_definition_name = "dbt-run"

    dbt_ecs_operator = EcsOperator(
        task_id="ecs_run_stg_dynamodb_lugus__packages",
        cluster=cluster_name,
        task_definition=task_definition_name,
        launch_type="FARGATE",
        overrides={
            "containerOverrides": [
                {
                    "name": "dbt",
                    "command": [
                        "--select", "stg_dynamodb_lugus__packages"
                    ],
                },
            ],
        },
        network_configuration={
            "awsvpcConfiguration": {
                "subnets": ["subnet-0f56c0f0d3ef65fad", "subnet-07ea66eb5992d1026"],
                "securityGroups": ["sg-0191d202f900b6845"],
                "assignPublicIp": "DISABLED",
            },
        },
        reattach=True,
        awslogs_group="/ecs/medallion-dbt-run",
        awslogs_stream_prefix="ecs/medallion-dbt/"
    )

    dbt_ecs_operator