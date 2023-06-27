WITH SOURCE AS (

  select

    order_id,
    event_type,
    user_id,
    user_display_name,
    log_id,
    "message",
    "timestamp",
    CAST(json_parse(meta) AS MAP<VARCHAR, VARCHAR>) AS meta, -- JSON is not supported in iceberg tables, use MAP(dictionary) instead.
    row_number() over (partition by order_id order by timestamp asc) as event_sequence_order,
    row_number() over (partition by order_id order by timestamp desc) as event_sequence_order_r,

    _fivetran_synced

  from {{ source('dynamodb', 'lugus') }}
  where 1=1
  and _type = 'OrderLog'
  {{- incremental_fivetran_synced() -}}
  {{- not_fivetran_deleted() -}}

)

SELECT
  CAST(order_id AS VARCHAR) AS id,
  CAST(event_type AS VARCHAR) AS event_type,
  CAST(user_id AS VARCHAR) AS user_id,
  CAST(user_display_name AS VARCHAR) AS user_display_name,
  CAST(log_id AS VARCHAR) AS log_id,
  CAST("message" AS VARCHAR) AS "message",
  CAST("timestamp" AS TIMESTAMP(6)) AS "timestamp",
  DATE("timestamp") AS "date",
  CAST(event_sequence_order AS INTEGER) AS event_sequence_order,
  CASE
    WHEN event_sequence_order_r = 1 THEN 1 ELSE 0
    END AS most_recent,
  CAST(meta['reason'] AS VARCHAR) AS service_date_change_reason,
  CAST(meta['slaDeliveryDate'] AS VARCHAR) AS sla_delivery_date,
  CAST(meta['originalSource'] AS VARCHAR) AS original_source,
  CAST(_fivetran_synced AS TIMESTAMP(6)) AS _fivetran_synced

  FROM SOURCE