{% macro incremental_fivetran_synced() %}

  {% if is_incremental() %}
    and _fivetran_synced::timestamp > dateadd('hours', -1, (select max(_fivetran_synced::timestamp) from {{ this }}))
  {% endif %}

{% endmacro %}