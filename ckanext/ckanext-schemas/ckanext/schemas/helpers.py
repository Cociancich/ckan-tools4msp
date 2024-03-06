from ckan.common import config

import json
import os.path

domainareas_path = config.get('ckan.domainareas_path')

file_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'presets')

with open(os.path.join(file_dir, 'categories.json')) as categories_file:
    categories = json.load(categories_file)

def scheming_categories_choices(field):
    return categories

with open(domainareas_path) as f:
    domainareas = json.load(f)

def scheming_domainareas_choices(field):
    for domainarea in domainareas:
        yield {
            'value': domainarea['label'].lower().replace(' ', '_').replace('&', '_'),
            'label': domainarea['label'],
        }

