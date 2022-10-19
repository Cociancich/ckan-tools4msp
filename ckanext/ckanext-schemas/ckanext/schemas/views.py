from flask import Blueprint, jsonify
import ckan.plugins.toolkit as toolkit
from . import helpers

scheming = Blueprint("scheming", __name__)

@scheming.route('/scheming/api/util/<field>/autocomplete')
def autocomplete(field):
    value = toolkit.request.params.get('incomplete')
    if field == "dataset":
        context = {
            "user": toolkit.g.user,
            "userobj": toolkit.g.userobj,
        }
        query = {
            "q": f"name:*{value}*",
            "include_private": True,
        }
        found = toolkit.get_action('package_search')(context,  query)
        tags = [dataset['name'] for dataset in found['results']]
    elif field == "category":
        tags = [tag['value'] for tag in helpers.scheming_categories_choices(field)]
    elif field == "domain_area":
        tags = [tag['value'] for tag in helpers.scheming_domainareas_choices(field)]
    else:
        pass
    results = []
    for tag in tags:
        if value.lower() in tag.lower():
            results.append({'Name': tag})
    return jsonify({"ResultSet": {"Result": results}})
