FROM --platform=linux/amd64 ubuntu:20.04

RUN apt-get update && \
  apt-get install -y wget unzip curl python3.8 python3-pip git 

WORKDIR /app
COPY core/requirements.txt /app/requirements.txt

RUN pip3 install -r /app/requirements.txt

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /app/awscliv2.zip
RUN unzip /app/awscliv2.zip

COPY profiles.yml /app/profiles.yml
COPY dbt_project.yml /app/dbt_project.yml
COPY packages.yml /app/packages.yml

COPY selectors.yml /app/selectors.yml
COPY analysis /app/analysis
COPY macros /app/macros
COPY models /app/models
COPY seeds /app/seeds
COPY snapshots /app/snapshots
COPY tests /app/tests
# COPY tests/testutils/ /app/tests/testutils/

RUN /app/aws/install 
RUN dbt deps

COPY core/entrypoint.sh /app/entrypoint.sh
RUN chmod 755 /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]