import yaml
from jinja2 import Environment, FileSystemLoader

environment = Environment(loader=FileSystemLoader("core/dag_generation/templates"))
template = environment.get_template("dag_template.py")

with open("core/dag_generation/models.yml", "r") as stream:
    try:
        models = yaml.safe_load(stream)
        for model in models:
            model_name = model['dbt_job_name']
            file_name = f"dags/{model_name}.py"
            content = template.render(
                model
            )
            with open(file_name, mode="w+", encoding="utf-8") as message:
                message.write(content)
                print(f"... wrote {file_name}")

    except yaml.YAMLError as exc:
        print(exc)