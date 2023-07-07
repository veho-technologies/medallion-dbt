WITH  SOURCE  AS (

  select * from {{ source('dynamodb', 'lugus')}}
  -- not filtering by kind creates duplicate data since every order is associated with
  -- 2 ordersensitive rows of kind original or current. We only care about the current address for modeling purposes.
  where _type = 'OrderSensitiveData' and kind = 'current'

  {{- incremental_fivetran_synced() -}}
  {{- limit_rows_date('_fivetran_synced', -1, 'week') -}}
  {{- not_fivetran_deleted() -}}

),

ADDR_DATA AS (
    SELECT
        CAST(order_id AS VARCHAR) AS order_id,
        CAST(address_id AS VARCHAR) AS address_id,
        CAST(_fivetran_synced AS TIMESTAMP(6)) AS _fivetran_synced,
        CAST(_fivetran_deleted AS BOOLEAN) AS _fivetran_deleted,
        CAST(_type AS VARCHAR) AS _type,
        CAST(recipient AS VARCHAR) AS recipient,
        CAST(kind AS VARCHAR) AS kind,
        updated_at AT TIME ZONE 'UTC' AS updated_at,
        CAST(db_updated_at AS TIMESTAMP(6)) AS db_updated_at,
        created_at AT TIME ZONE 'UTC' AS created_at,
        CAST(db_created_at AS TIMESTAMP(6)) AS db_created_at,

        -- address data
        CAST(json_extract_scalar(address, '$.street') AS VARCHAR) AS street,
        CAST(json_extract_scalar(address, '$.city') AS VARCHAR) AS city,
        CAST(json_extract_scalar(address, '$.state') AS VARCHAR) AS state,
        CAST(json_extract_scalar(address, '$.apartment') AS VARCHAR) AS apartment,
        CAST(json_extract_scalar(address, '$.country') AS VARCHAR) AS country,
        CAST(json_extract_scalar(address, '$.zipCode') AS VARCHAR) AS zip_code,
        CAST(json_extract_scalar(address, '$.location.source') AS VARCHAR) AS coordinates_source,
        CAST(json_extract_scalar(address, '$.location.lat') AS REAL) AS lat,
        CAST(json_extract_scalar(address, '$.location.lng') AS REAL) AS lng,
        CAST(phone AS VARCHAR) AS phone


    FROM SOURCE
)

SELECT * FROM ADDR_DATA
