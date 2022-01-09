#!/bin/bash
set -e

/ckan-entrypoint.sh

conf="/etc/ckan/production.ini"
alias conf_set="crudini --set $conf app:main"
alias conf_get="crudini --get $conf app:main"
alias conf_set_list="crudini --set --list --list-sep=' ' $conf app:main"

shopt -s expand_aliases

#ckan
conf_set ckan.site_title "catalogue-tools4msp"
#conf_set ckan.site_description ""
#conf_set ckan.site_logo ""
#conf_set ckan.site_intro_text ""
#conf_set ckan.site_about "
## About
#$(conf_get ckan.site_intro_text)
#"

#ckanext-branding
conf_set_list ckan.plugins "branding"

#ckanext-scheming
conf_set_list ckan.plugins "scheming_datasets schemas"
conf_set scheming.dataset_schemas "ckanext.schemas:custom_schema.yaml"

#ckanext-schemas
conf_set_list ckan.plugins "schemas"

exec "$@"
