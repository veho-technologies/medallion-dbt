{% macro incremental_fivetran_synced() %}

  {%- if is_incremental() -%}
    and _fivetran_synced > (
      select date_add('hour', -1, max(_fivetran_synced)) from {{ this }}
    )
  {%- endif -%}

{% endmacro %}