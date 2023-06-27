WITH SOURCE AS (
 select * from {{ source('dynamodb', 'lugus')}}
 WHERE  1=1 AND _type = 'Package'

 {{- incremental_fivetran_synced() -}}
 {{- not_fivetran_deleted() -}}

)

SELECT
-- unique ID
  CAST(package_id AS VARCHAR) AS package_id,
-- Other IDs
  CAST(order_id AS VARCHAR) AS order_id,
  CAST(client_id AS VARCHAR) AS client_id,
  CAST(route_id AS VARCHAR) AS route_id,
  CAST(stop_id AS VARCHAR) AS stop_id,
  CAST(consumer_id AS VARCHAR) AS consumer_id,
  CAST(tracking_id AS VARCHAR) AS tracking_id,
  CAST(external_id AS VARCHAR) AS external_id,
  CAST(submitted_by_id AS VARCHAR) AS submitted_by_id,
  CAST(address_id AS VARCHAR) AS address_id,

-- Dates and timestamps
  updated_at AT TIME ZONE 'UTC' AS updated_at,
  CAST(db_updated_at AS TIMESTAMP(6)) AS db_updated_at,
  created_at AT TIME ZONE 'UTC' AS created_at,
  sla_service_date AT TIME ZONE 'UTC' AS sla_service_date,
  scheduled_service_date AT TIME ZONE 'UTC' AS scheduled_service_date,
  actual_service_date AT TIME ZONE 'UTC' AS actual_service_date,
  CAST(time_zone AS VARCHAR) AS time_zone,
  consumer_expected_service_date  AT TIME ZONE 'UTC' AS consumer_expected_service_date ,
  json_extract_scalar(arrival_time_window, '$.startsAt')  AS arrival_time_window_starts_at, -- todo @jpmugizi: figure out why cast to timestamp doesnt work, create as varchar for now.
  json_extract_scalar(arrival_time_window, '$.endsAt')  AS arrival_time_window_ends_at,


-- fivetran
  CAST(_fivetran_synced AS TIMESTAMP(6)) AS _fivetran_synced,
  CAST(_fivetran_deleted AS BOOLEAN) AS _fivetran_deleted,

-- Other strings
  CAST(_type AS VARCHAR) AS _type,
  CAST(last_event AS VARCHAR) AS last_event,
  CAST(updated_by AS VARCHAR) AS updated_by,
  CAST(service_class AS VARCHAR) AS service_class,
  CAST("description" AS VARCHAR) AS "description",
  CAST(bar_code AS VARCHAR) AS bar_code,
  CAST(controller AS VARCHAR) AS controller,
  CAST(kind AS VARCHAR) AS kind,
  CAST(instructions AS VARCHAR) AS instructions,
  CAST(company AS VARCHAR) AS company,
  CAST(external_carrier AS VARCHAR) AS external_carrier,
  CAST(external_carrier_tracking_id AS VARCHAR) AS external_carrier_tracking_id,
  CAST(recipient AS VARCHAR) AS recipient,
  CAST(external_shipping_label_link AS VARCHAR) AS external_shipping_label_link,

-- booleans
  CAST(signature_required AS BOOLEAN) as signature_required,

-- floats
  CAST("weight" AS DOUBLE) AS weight,
  CAST(height_dimension AS DOUBLE) AS height_dimension,
  CAST(width_dimension AS DOUBLE) AS width_dimension,
  CAST(length_dimension AS DOUBLE) AS length_dimension,
  CAST(declared_value AS DOUBLE) AS declared_value

FROM SOURCE