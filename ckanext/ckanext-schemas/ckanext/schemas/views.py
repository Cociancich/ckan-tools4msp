from flask import Blueprint, jsonify
import ckan.plugins.toolkit as toolkit

scheming = Blueprint("scheming", __name__)

@scheming.route('/scheming/api/util/<field>/autocomplete')
def autocomplete(field):
    results = []
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
        for dataset in found['results']:
            results.append({'Name': dataset['name']})
    else:
        pass
    return jsonify({"ResultSet": {"Result": results}})
