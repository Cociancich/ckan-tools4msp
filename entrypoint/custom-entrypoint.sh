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
crudini --set "$conf" DEFAULT debug "false"
conf_set ckan.site_title "ITINERIS Catalogue"
conf_set ckan.site_description "This is the portal of the catalogue of WP5 Itineris project."
conf_set ckan.site_url "$CKAN_SITE_URL"
conf_set ckan.root_path "$CKAN_ROOT_PATH"
# add root path to login urls
sed -i -E  "s@= (/[user|login])@= $CKAN_ROOT_PATH\1@" /etc/ckan/who.ini

conf_set ckan.site_logo "/logo.png"
conf_set ckan.favicon "favicon.png"
conf_set ckan.site_intro_text "Welcome to Itineris WP5 Marine data catalog (work in progress)"
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
conf_set scheming.dataset_schemas "ckanext.schemas:custom_schema.yaml ckanext.schemas:msp_data.json ckanext.schemas:itoos_data.json  ckanext.schemas:msp_portal.json ckanext.schemas:msp_tool.json"
#conf_set ckan.default.package_type "msp-data" # CKAN > 2.9
DOMAINAREAS_PATH="/usr/lib/ckan/domainareas.json"
wget -nv "$DOMAINAREAS_URL" -O "$DOMAINAREAS_PATH"
conf_set ckan.domainareas_path "$DOMAINAREAS_PATH"
EDMOLIST_PATH="/usr/lib/ckan/edmolist.json"
wget -nv "$EDMOLIST_URL" -O "$EDMOLIST_PATH"
conf_set ckan.edmolist_path "$EDMOLIST_PATH"



#ckanext-scheming
conf_set_list ckan.plugins scheming_datasets
conf_set ckan.search.show_all_types true

#ckanext-spatial
conf_set_list ckan.plugins spatial_metadata spatial_query
conf_set ckanext.spatial.search_backend solr-bbox
conf_set ckan.solr_url "$CKAN_SOLR_URL"
conf_set ckanext.spatial.common_map.type "custom"
conf_set ckanext.spatial.common_map.custom.url "https://tiles.emodnet-bathymetry.eu/2020/baselayer/web_mercator/{z}/{x}/{y}.png"
conf_set ckanext.spatial.common_map.attribution "Tiles from  <a href=\"https://emodnet.ec.europa.eu/en/bathymetry\">Emodnet bathymetry</a>"



#datapusher
conf_set_list ckan.plugins datastore datapusher
conf_set ckan.datapusher.callback_url_base "$CKAN_SITE_URL_INTERNAL"
ckan datastore set-permissions | psql "$CKAN_SQLALCHEMY_URL"
(sleep 1m && ckan datapusher submit -y) &

exec "$@"
