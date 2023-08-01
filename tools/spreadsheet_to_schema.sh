#!/bin/bash
#
# Requirements:
# - https://duckdb.org/
# - https://jqlang.github.io/jq/

SPREADSHEET="Data cluster matrices_20230801.xlsx"
WORKSHEET="Struttura_catalogue"
SCHEMA="struttura.json"

set -euo pipefail

echo "# Conversion report"
echo "## Entries processed"

OGR_XLSX_HEADERS=FORCE duckdb << EOF | jq -s '{dataset_fields: del(.[][] | nulls)}' > "$SCHEMA"
install spatial;
load spatial;
load json;
create macro labelize(str) as trim(regexp_replace(lcase(str), '[^a-z0-9]+', '-', 'g'), '-');
copy (
select labelize(field_name) as field_name,
       field_name as label,
       case when field_type = 'multiple_checkbox'
            then 'multiple_checkbox'
       end as preset,
       case when field_type = 'multiple_checkbox' then
       json_group_array(
         json_object(
           'value', labelize(label),
           'label', label
         )
       )
       else null
       end as choices
  from st_read('$SPREADSHEET', layer='$WORKSHEET')
 where field_type in ('multiple_checkbox', 'text')
 group by field_name, field_type
) to '/dev/stdout' (format json);
EOF

echo -n "Entries processed: "

OGR_XLSX_HEADERS=FORCE duckdb << EOF 2>/dev/null
install spatial;
load spatial;
load json;
.headers off
.mode ascii
select count(*)
  from st_read('$SPREADSHEET', layer='$WORKSHEET')
 where field_type in ('multiple_checkbox', 'text')
EOF
echo

echo "## Entries not processed"
echo "### field_type not supported"

OGR_XLSX_HEADERS=FORCE duckdb << EOF
install spatial;
load spatial;
load json;
.mode markdown
select *
  from st_read('$SPREADSHEET', layer='$WORKSHEET')
 where field_type not in ('multiple_checkbox', 'text')
EOF
