## Medallion DBT

DBT transforms and models for [Project Medallion](https://docs.google.com/document/d/1DaPqowJZwfL17teuwu2bsGxCVNFZ1JktX3pt7g-nEBQ/edit)

### Local Development Setup

**Prerequisite**
Ensure You have access to:

1. AWS
2. The `DataAnalyticsAdminAccess` role for the `data` AWS Account

Then,

Just copy this command in your terminal `.  core/bin/up.sh`  in the root directory and you should be good to go. This command installs all
the necessarily dependencies, create a DBT schema, and auths to AWS for you  to get you up and running quickly.

### Migrating DBT Models from Redshift to Athena
Refer to [this guide](./docs/migrating_to_athena.md)