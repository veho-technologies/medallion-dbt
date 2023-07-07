{#
  a macro to convert dynamodb ms or seconds to timestamp
  however sometimes we get bad data so we have to do some case whens against iso8601 strings, and big ints
#}

{%- macro dynamodb_timestamp_to_timestamp(value) -%}
  case
    when {{ value }} is null or {{ value }} = '' then null
    when {{ value }} like '%-%-%T%' then cast(from_iso8601_timestamp({{ value }}) as timestamp(6)) -- very simple iso8601 check
    when length(cast({{ value }} as varchar)) = 10 then date_add('second', cast({{ value }} as bigint), cast('1970-01-01 00:00:00' as timestamp(6))) -- for dynamodb seconds -- 10 digits until the 24th century
    else date_add('second', cast({{ value }} as bigint)/1000, cast('1970-01-01 00:00:00' as timestamp(6))) -- for dynamodb milliseconds
  end
{%- endmacro -%}