WITH SOURCE AS (
 select * from {{ source('dynamodb_lugus', 'lugus')}}
 WHERE  1=1 AND _type = 'Order'

 {{- incremental_fivetran_synced() -}}
 {{- limit_rows_date('_fivetran_synced', -1, 'week') -}}
 {{- not_fivetran_deleted() -}}

)

SELECT
-- unique ID
  CAST(order_id AS VARCHAR) AS order_id,
-- Other IDs
  CAST(facility_id AS VARCHAR) AS facility_id,
  CAST(client_id AS VARCHAR) AS client_id,
  CAST(consumer_id AS VARCHAR) AS consumer_id,
  CAST(external_id AS VARCHAR) AS external_id,
  CAST(submitted_by_id AS VARCHAR) AS submitted_by_id,
  CAST(address_id AS VARCHAR) AS address_id,
  CAST(legacy_consumer_id AS VARCHAR) AS legacy_consumer_id,
  CAST(legacy_facility_id AS VARCHAR) AS legacy_facility_id,

-- Dates and timestamps
  CAST(time_zone AS VARCHAR) AS time_zone,--::varchar,
  updated_at AT TIME ZONE 'UTC' AS updated_at,--::timestamptz,
  CAST(db_updated_at AS TIMESTAMP(6)) AS db_updated_at,--::timestamp,
  created_at AT TIME ZONE 'UTC' AS created_at,--::timestamptz,
  CAST(db_created_at AS TIMESTAMP(6)) AS db_created_at,--::timestamp,
  consumer_expected_service_date  AT TIME ZONE 'UTC' AS consumer_expected_service_date ,--::timestamptz,
  sla_service_date AT TIME ZONE 'UTC' AS sla_service_date,--::timestamptz,
  CAST(sla_delivery_date AS DATE) AS sla_delivery_date,--::date,


-- fivetran
  CAST(_fivetran_synced AS TIMESTAMP(6)) AS _fivetran_synced,--::timestamp,
  CAST(_fivetran_deleted AS BOOLEAN) AS _fivetran_deleted,--::boolean,

-- Other strings
  CAST(_type AS VARCHAR) AS _type,--::varchar,
  CAST(last_event AS VARCHAR) AS last_event,--::varchar,
  CAST(updated_by AS VARCHAR) AS updated_by,--::varchar,
  CAST(service_class AS VARCHAR) AS service_class,--::varchar,
  CAST(description AS VARCHAR) AS description,--::varchar as description,
  CAST(controller AS VARCHAR) AS controller,--::varchar,
  CAST(kind AS VARCHAR) AS kind,--::varchar,
  CAST(instructions AS VARCHAR) AS instructions,--::varchar,
  CAST(company AS VARCHAR) AS company,--::varchar,
  CAST(service_type AS VARCHAR) AS service_type,--::varchar,
  CAST(client_name AS VARCHAR) AS client_name,--::varchar,
  CAST(client_display_name AS VARCHAR) AS client_display_name,--::varchar,
  CAST(dynamic_link AS VARCHAR) AS dynamic_link --::varchar

FROM SOURCE
