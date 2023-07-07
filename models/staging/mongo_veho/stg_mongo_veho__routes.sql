with

source as (

  select * from {{ source('mongo_veho', 'routes')}}

  where 1=1

  {{ incremental_fivetran_synced() }}
  {{ limit_rows_date('_fivetran_synced', 'week', -1) }}

)

select
    --ids
    CAST(_id AS VARCHAR) as route_id,
    CAST(driver_id AS VARCHAR) as driver_id,
    CAST(pickup_location_id AS VARCHAR) as pickup_location_id,
    CAST(drop_off_location_id AS VARCHAR) as drop_off_location_id,
    CAST(updated_by AS VARCHAR) as updated_by,
    CAST(created_by AS VARCHAR) as created_by,

    --strings
    CAST(last_event AS VARCHAR) as last_event,
    CAST("name" AS VARCHAR) as "name",
    CAST(notes AS VARCHAR) as notes,

    -- JSON fields
    -- todo @jpmugizi: appropriately parse this with MAP or JSON_EXTRACT_SCALAR
    CAST(event_log AS VARCHAR) as event_log,
    CAST(computed_fields AS VARCHAR) as computed_fields,

    --bool
    CAST(pickup_process_enabled AS BOOLEAN) as pickup_process_enabled,
    CAST(consumer_messages_sent AS BOOLEAN) as consumer_messages_sent,
    CAST(published AS BOOLEAN) as published,

    --numeric/float
    CAST(estimated_distance AS REAL) as estimated_distance,
    CAST(estimated_duration AS REAL) as estimated_duration,
    CAST(estimated_payout AS REAL) as estimated_payout,

    --timestamp
    CAST(created_at AS TIMESTAMP(6)) AS created_at,
    CAST(start_time AS TIMESTAMP(6)) AS start_time,
    CAST(updated_at_orig AS TIMESTAMP(6)) AS updated_at_orig,
    CAST(updated_at AS TIMESTAMP(6)) AS updated_at,

    --fivetran
    CAST(_fivetran_deleted AS BOOLEAN) _fivetran_deleted,
    CAST(_fivetran_synced AS TIMESTAMP(6)) _fivetran_synced

FROM source