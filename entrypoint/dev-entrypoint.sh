#!/bin/bash
set -e

/custom-entrypoint.sh

conf="/etc/ckan/production.ini"
function conf_set() { crudini --set "$conf" app:main "$@"; }

crudini --set "$conf" DEFAULT debug "true"

ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-branding
ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-schemas

exec "$@"
