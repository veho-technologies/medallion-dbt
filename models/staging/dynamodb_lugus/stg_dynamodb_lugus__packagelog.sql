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
    {# CAST(json_parse(meta) AS MAP<VARCHAR, VARCHAR>) AS meta, -- JSON is not supported in iceberg tables, use MAP(dictionary) instead. #}
    json_parse(meta) as meta,

    _fivetran_synced

  from {{ source('dynamodb', 'lugus') }}
  where 1=1
  and _type = 'PackageLog'
  {{- incremental_fivetran_synced() -}}
  {{- limit_rows_date('_fivetran_synced', -1, 'week') -}}
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
  -- meta fields
  CAST(json_extract_scalar(meta, '$.routeId') AS VARCHAR) AS route_id,
  CAST(json_extract_scalar(meta, '$.stopId') AS VARCHAR) AS stop_id,
  CASE user_id WHEN 'DivertModule' THEN 32.99 ELSE CAST(json_extract_scalar(location, '$.lat') AS REAL) END as lat,
  CASE user_id WHEN 'DivertModule' THEN -97.05 ELSE CAST(json_extract_scalar(location, '$.lng') AS REAL) END as lng,
  CAST(json_extract_scalar(meta, '$.reason') AS VARCHAR) AS service_date_change_reason,
  case
    when json_extract(meta, '$.slaServiceDate["$date"]') is not null then 
      {{ dynamodb_timestamp_to_timestamp("json_extract_scalar(meta, '$.slaServiceDate[\"$date\"]')") }}
    else
      {{ dynamodb_timestamp_to_timestamp("json_extract_scalar(meta, '$.slaServiceDate')") }}
  end as slaServiceDate,
  case
    when json_extract(meta, '$.scheduledServiceDate["$date"]') is not null then 
      {{ dynamodb_timestamp_to_timestamp("json_extract_scalar(meta, '$.scheduledServiceDate[\"$date\"]')") }}
    else
      {{ dynamodb_timestamp_to_timestamp("json_extract_scalar(meta, '$.scheduledServiceDate')") }}
  end as scheduledServiceDate,
  CASE WHEN event_type = 'attentionNeeded' then message else NULL END AS attention_needed_detail,
  CAST(json_extract_scalar(meta, '$.activityType') AS VARCHAR) AS activity_type,
  CAST(json_extract_scalar(meta, '$.finalFacilityId') AS VARCHAR) AS final_facility_id,
  CAST(json_extract_scalar(meta, '$.fromContainerBarCode') AS VARCHAR) AS from_container_bar_code,
  CAST(json_extract_scalar(meta, '$.fromContainerId') AS VARCHAR) AS from_container_id,
  CAST(json_extract_scalar(meta, '$.toContainerBarCode') AS VARCHAR) AS to_container_bar_code,
  CAST(json_extract_scalar(meta, '$.toContainerId') AS VARCHAR) AS to_container_id,
  CAST(json_extract_scalar(meta, '$.originalSource') AS VARCHAR) AS original_source,
  CAST(from_iso8601_timestamp(json_extract_scalar(meta, '$.previousScheduledServiceDate')) AS TIMESTAMP(6)) AS previous_scheduled_service_date,
  CAST(from_iso8601_timestamp(json_extract_scalar(meta, '$.previousSlaServiceDate')) AS TIMESTAMP(6)) AS previous_sla_service_date,
  CAST(_fivetran_synced AS TIMESTAMP(6)) AS _fivetran_synced

FROM SOURCE