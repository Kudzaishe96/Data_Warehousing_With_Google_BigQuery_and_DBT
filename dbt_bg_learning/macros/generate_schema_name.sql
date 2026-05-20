--Creating custom schemas using jinja functions
{% macro generate_schema_name(custom_schema_name, node) -%}

    {# If no custom schema is passed, use the target schema (dev/prod) #}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {# Otherwise, use the provided schema name after trimming whitespace #}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}