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

OGR_XLSX_HEADERS=FORCE duckdb << EOF | jq -s '{dataset_fields: .}' > "$SCHEMA"
install spatial;
load spatial;
load json;
copy (
select regexp_replace(lcase(field_name), '[^a-z0-9]+', '-', 'g') as field_name,
       field_name as label,
       'multiple_checkbox' as preset,
       json_group_array(
         json_object(
           'value', trim(regexp_replace(lcase(label), '[^a-z0-9]+', '-', 'g'), '-'),
           'label', label
         )
       ) as choices
  from st_read('$SPREADSHEET', layer='$WORKSHEET')
 where field_type = 'multiple_checkbox'
 group by field_name
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
 where field_type = 'multiple_checkbox'
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
 where field_type <> 'multiple_checkbox'
EOF
