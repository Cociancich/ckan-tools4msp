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
conf_set ckan.site_description "This is the portal of the catalogue-tools4msp project."
#conf_set ckan.site_logo ""
#conf_set ckan.site_intro_text ""
conf_set ckan.site_about "
# About
#$(conf_get ckan.site_intro_text)

# Developers
Source code available at [gitlab.com/gisdev.io/catalogue-tools4msp](https://gitlab.com/gisdev.io/catalogue-tools4msp).

# Administrators
Harvesting operations can be monitored at [/harvest](/harvest).
"

#ckanext-branding
conf_set_list ckan.plugins "branding"

#ckanext-scheming
conf_set_list ckan.plugins "scheming_datasets schemas"
conf_set scheming.dataset_schemas "ckanext.schemas:custom_schema.yaml"

#ckanext-schemas
conf_set_list ckan.plugins "schemas"

#ckanext-harvest
conf_set_list ckan.plugins "harvest ckan_harvester"
conf_set ckan.harvest.mq.type "redis"
conf_set ckan.harvest.mq.hostname "redis"
#conf_set ckan.harvest.protect_fields "notes tags topics"

[ "$CKAN_EXTRA" = "true" ] && ckan --config=$CKAN_INI harvester initdb

exec "$@"
