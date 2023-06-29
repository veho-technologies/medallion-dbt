# Migrating Existing DBT Models From Redshift To Athena

## Release Notes

### June 29, 2023

* As of June 29, 2023 This migration guide is for Athena Query Engine 3 and V 1.5 of  [DBT Athena Community Adapter](https://dbt-athena.github.io/)  . Both of these are in active development and subject to change frequently, please check the #data-platform-feed for newer versions and features and update this guide accordingly 

## Motivation

The Data Platform team is rebuilding the Analytics platform stack through [Project Medallion](https://docs.google.com/document/d/1DaPqowJZwfL17teuwu2bsGxCVNFZ1JktX3pt7g-nEBQ/edit) to improve its performance, reliability, and scalability. As part of Mediallion,  raw data (data coming from upstream sources through [Fivetran](https://fivetran.com/dashboard/connectors)) and staging data(a more cleaned up version of raw data) will start being stored in AWS S3 blob storage instead of Redshift, our data warehouse. 

Data stored in AWS S3 as part of Medallion will be queryable via the Athena Query Engine 3, which is an AWS managed version of  open-source query engine [Trino](https://trino.io/) .  S3 Blobs ("Tables") are stored in Parquet and Apache Iceberg format for fast and efficient querying. Since there are multiple moving parts of this setup, the migration guide will focus solely on converting Redshift SQL to Athena. 



## Known Limitations of the Athena SQL dialect

To reiterate, as of June 29 2023 this is relevant to Athena Engine 3 and DBT adapter v 1.5.2 . Check #data-platform-feed on Slack, to see if this has changed.

#### No Support for ISO Format Timestamp:

You only have access to the `TIMESTAMP(6)` datatype, if you have an ISO 8601 format use The [FROM_ISO8601_TIMESTAMP]([Date and time functions and operators &#8212; Trino 420 Documentation](https://trino.io/docs/current/functions/datetime.html#from_iso8601_timestamp)) function.

#### JSON is not supported with Apache Iceberg Tables

* **For flat JSON data** (for .e.g `{'key1': 'value'}` ) use the  `MAP<data_type, data_type> `  type .
  
  e.g:
  
  ```sql
  WITH SOURCE AS (
      CAST(json_parse(meta) AS MAP<VARCHAR, VARCHAR>) AS meta
  )
  
  SELECT 
   CAST(meta['reason'] AS VARCHAR) AS service_date_change_reason,
   CAST(meta['slaDeliveryDate'] AS VARCHAR) AS sla_delivery_date,
   CAST(meta['originalSource'] AS VARCHAR) AS original_source,
  FROM SOURCE
  ```
  
  `MAP` requires to explicitly known and set the key and value types ahead of time. So for instance, `MAP<VARCHAR, ANY>` is not valid. What we recommend is using `MAP<VARCHAR, VARCHAR>` then, `CAST` ing the values directly as you flattens them like in the above example

* **For nested JSON data** (for e.g `{'key1': {'key2':'value'}`)
  
  Use `the json_extract_scalar` function. For example, use
  
  ```sql
  CAST(json_extract_scalar(address, '$.location.source') AS VARCHAR) AS coordinates_source,
  CAST(json_extract_scalar(address, '$.location.lat') AS REAL) AS lat,
  CAST(json_extract_scalar(address, '$.location.lng') AS REAL) AS lng,
  
  
  ```

    to extract data from `"address": {"location": {"lat": -1, "lng": -0.203, "source": "mapquest" }}`

Although you can use json_extract with flat json data as well, `MAP` is more efficient than `json_extract_scalar` , so prefer using that data type whenever you have flat JSON data. 



### There is no syntax sugar for casting data types with ::

Unfortunately, with the dbt adapter, adding a type that you want to cast to at the end with `::` (e.g `SELECT order_id::varchar` in Redshift) is not supported.

You need to use the `CAST(my_column as <ATHENA_DATA_TYPE>`) as shown in the examples above.



## Redshift SQL vs Athena SQL Data Types Conversion

| REDSHIFT              | ATHENA ENGINE 3 | NOTES                                                                          |
| --------------------- |:--------------- | ------------------------------------------------------------------------------ |
| TIMESTAMP, TIMESTAMPZ | TIMESTAMP(6) ** | use `FROM_ISO8601_TIMESTAMP` function for  ISO timestamps                      |
| VARCHAR               | VARCHAR         |                                                                                |
| FLOAT                 | REAL            | float is used by Athena in DDL  and `real` in DML (select statements for e.g.) |
| FLAT JSON             | MAP             |                                                                                |
| NESTED JSON           | no equivalent   | use `json_extract_scalar` function                                             |
| Big int, int          | Big Int, int    |                                                                                |
| Boolean               | Boolean         |                                                                                |

** TIMESTAMP(3) is not supported with Iceberg Tables



### Troubleshooting

* **botocore.errorfactory.InvalidRequestException: An error occurred (InvalidRequestException) when calling the StartQueryExecution operation: line 16:25: mismatched input ':'**
  
  This seems to happen sporadically because of incremental syncs - Use full refresh and it should be back to working normally
  
   `dbt run --full-refresh --select my_model`
  
  

## Useful Documentation

* **Project Medallion RFC** : https://docs.google.com/document/d/1DaPqowJZwfL17teuwu2bsGxCVNFZ1JktX3pt7g-nEBQ

* **AWS Athena Data Types** :  https://docs.aws.amazon.com/athena/latest/ug/data-types.html

* **Trino Query Engine SQL Functions Reference** : https://trino.io/docs/current/functions/list-by-topic.html

* **DBT Athena Adapter** https://dbt-athena.github.io/ 