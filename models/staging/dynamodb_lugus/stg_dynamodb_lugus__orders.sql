SELECT
-- unique ID
  order_id,
  updated_at
/*
-- other IDs
  facility_id::varchar,
  client_id::varchar,
  consumer_id::varchar,
  external_id::varchar,
  submitted_by_id::varchar,
  address_id::varchar,
  legacy_consumer_id::varchar,
  legacy_facility_id::varchar,

-- Dates and timestamps
  updated_at::timestamptz,
  db_updated_at::timestamp,
  created_at::timestamptz,
  db_created_at::timestamp,
  consumer_expected_service_date::timestamptz,
  sla_service_date::timestamptz,
  sla_delivery_date::date,
  time_zone::varchar,

-- fivetran
  _fivetran_synced::timestamp,
  _fivetran_deleted::boolean,

-- Other strings
  _type::varchar,
  last_event::varchar,
  updated_by::varchar,
  service_class::varchar,
  "description"::varchar as description,
  controller::varchar,
  kind::varchar,
  instructions::varchar,
  company::varchar,
  service_type::varchar,
  client_name::varchar,
  client_display_name::varchar,
  dynamic_link::varchar
  */

from {{ source('dynamodb', 'lugus')}}
WHERE   _type = 'Order' and  _fivetran_deleted = false LIMIT 1000