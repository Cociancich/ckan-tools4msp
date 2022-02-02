#!/bin/bash
set -e

/custom-entrypoint.sh

conf="/etc/ckan/production.ini"
alias conf_set="crudini --set $conf app:main"
shopt -s expand_aliases

# conf_set debug "true"

source /usr/lib/ckan/venv/bin/activate
ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-branding

patch /usr/lib/ckan/venv/src/ckan/ckan/cli/server.py /patches/passthrough_errors.patch

exec "$@"
