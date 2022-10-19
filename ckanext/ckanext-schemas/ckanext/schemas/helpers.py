import json
import os.path
import urllib.request

domainareas_url = "https://api.tools4msp.eu/api/domainareas/?format=json"

file_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'presets')

with open(os.path.join(file_dir, 'categories.json')) as categories_file:
    categories = json.load(categories_file)

def scheming_categories_choices(field):
    return categories

with urllib.request.urlopen(domainareas_url) as f:
    domainareas = json.load(f)

def scheming_domainareas_choices(field):
    for domainarea in domainareas:
        yield {
            'value': domainarea['label'].lower().replace(' ', '_').replace('&', '_'),
            'label': domainarea['label'],
        }

