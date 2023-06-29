WITH SOURCE AS (

  select
    order_id,
    package_id,
    event_type,
    user_id,
    user_display_name,
    log_id,
    "message",
    "timestamp",
    location,
    CAST(json_parse(meta) AS MAP<VARCHAR, VARCHAR>) AS meta, -- JSON is not supported in iceberg tables, use MAP(dictionary) instead.
    row_number() over (partition by package_id order by timestamp asc) as event_sequence_order,
    row_number() over (partition by package_id order by timestamp desc) as event_sequence_order_r,

    _fivetran_synced

  from {{ source('dynamodb', 'lugus') }}
  where 1=1
  and _type = 'PackageLog'
  {{- incremental_fivetran_synced() -}}
  {{- not_fivetran_deleted() -}}

)

SELECT
  CAST(package_id AS VARCHAR) AS id,
  CAST(order_id AS VARCHAR) AS order_id,
  CAST(event_type AS VARCHAR) AS event_type,
  CAST(user_id AS VARCHAR) AS user_id,
  CAST(user_display_name AS VARCHAR) AS user_display_name,
  CAST(log_id AS VARCHAR) AS log_id,
  CAST("message" AS VARCHAR) AS "message",
  CAST("timestamp" AS TIMESTAMP(6)) AS "timestamp",
  DATE("timestamp") AS "date",
  YEAR("timestamp") AS "year",
  CAST(event_sequence_order AS INTEGER) AS event_sequence_order,
  CASE
    WHEN event_sequence_order_r = 1 THEN 1 ELSE 0
    END AS most_recent,
  -- meta fields
  CAST(meta['routeId'] AS VARCHAR) AS route_id,
  CAST(meta['stopId'] AS VARCHAR) AS stop_id,
  CASE user_id WHEN 'DivertModule' THEN 32.99 ELSE CAST(json_extract_scalar(location, '$.lat') AS REAL) END as lat,
  CASE user_id WHEN 'DivertModule' THEN -97.05 ELSE CAST(json_extract_scalar(location, '$.lng') AS REAL) END as lng,
  CAST(meta['reason'] AS VARCHAR) AS service_date_change_reason,
  CAST(FROM_ISO8601_TIMESTAMP(meta['slaServiceDate']) AS TIMESTAMP(6)) AS sla_service_date,
  -- todo @jpmugizi figure out why some scheduledServiceDate are showing up in this format: "scheduledServiceDate":{"$date":1662868799999}
  -- CAST(FROM_ISO8601_TIMESTAMP(meta['scheduledServiceDate']) AS TIMESTAMP(6)) AS scheduled_service_date,
  meta['scheduledServiceDate']  AS scheduled_service_date,
  CASE WHEN event_type = 'attentionNeeded' then message else NULL END AS attention_needed_detail,
  CAST(meta['activityType'] AS VARCHAR) AS activity_type,
  CAST(meta['finalFacilityId'] AS VARCHAR) AS final_facility_id,
  CAST(meta['fromContainerBarCode'] AS VARCHAR) AS from_container_bar_code,
  CAST(meta['fromContainerId'] AS VARCHAR) AS from_container_id,
  CAST(meta['toContainerBarCode'] AS VARCHAR) AS to_container_bar_code,
  CAST(meta['toContainerId'] AS VARCHAR) AS to_container_id,
  CAST(meta['originalSource'] AS VARCHAR) AS original_source,
  CAST(FROM_ISO8601_TIMESTAMP(meta['previousScheduledServiceDate']) AS TIMESTAMP(6)) AS previous_scheduled_service_date,
  CAST(FROM_ISO8601_TIMESTAMP(meta['previousSlaServiceDate']) AS TIMESTAMP(6)) AS previous_sla_service_date,
  CAST(_fivetran_synced AS TIMESTAMP(6)) AS _fivetran_synced

FROM SOURCE