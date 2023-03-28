#!/bin/bash
set -e

/ckan-entrypoint.sh

conf="/etc/ckan/production.ini"
function conf_set() { crudini --set "$conf" app:main "$@"; }
function conf_get() { crudini --get "$conf" app:main "$@"; }
function conf_set_list() {
    param="$1"
    shift
    for var in "$@"; do
        crudini --set --list --list-sep=' ' "$conf" app:main "$param" "$var"
    done
}

#ckan
conf_set ckan.site_title "Tools4MSP"
conf_set ckan.site_description "This is the portal of the catalogue-tools4msp project."
conf_set ckan.site_logo "/logo.png"
conf_set ckan.favicon "favicon.png"
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
conf_set_list ckan.plugins branding

#ckanext-schemas
conf_set_list ckan.plugins schemas
conf_set scheming.dataset_schemas "ckanext.schemas:custom_schema.yaml ckanext.schemas:msp_data.json ckanext.schemas:msp_portal.json ckanext.schemas:msp_tool.json"
#conf_set ckan.default.package_type "msp-data" # CKAN > 2.9
conf_set ckan.domainareas_url "$DOMAINAREAS_URL"

#ckanext-scheming
conf_set_list ckan.plugins scheming_datasets
conf_set ckan.search.show_all_types true

#ckanext-oauth2
conf_set_list ckan.plugins oauth2
conf_set ckan.oauth2.authorization_endpoint https://accounts.google.com/o/oauth2/auth
conf_set ckan.oauth2.token_endpoint https://accounts.google.com/o/oauth2/token
conf_set ckan.oauth2.profile_api_url https://www.googleapis.com/oauth2/v1/userinfo
conf_set ckan.oauth2.client_id "$OAUTH2_CLIENT_ID"
conf_set ckan.oauth2.client_secret "$OAUTH2_CLIENT_SECRET"
conf_set ckan.oauth2.scope "https://www.googleapis.com/auth/userinfo.profile openid https://www.googleapis.com/auth/userinfo.email"
conf_set ckan.oauth2.profile_api_user_field email
conf_set ckan.oauth2.profile_api_fullname_field name
conf_set ckan.oauth2.profile_api_mail_field email
conf_set ckan.oauth2.authorization_header Authorization

exec "$@"
