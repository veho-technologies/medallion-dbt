{% macro limit_rows_date(column_name, datepart, interval) %}

  -- this filter will only be applied on non-production run
  {% if target.name != 'prod' %}
    and ({{ column_name }}) >= dateadd({{ datepart }}, {{ interval }}, trunc(getDate()))
  {% endif %}

{% endmacro %}