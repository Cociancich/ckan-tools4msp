import json
import urllib.request

domainareas_url = "https://api.tools4msp.eu/api/domainareas/?format=json"

with urllib.request.urlopen(domainareas_url) as f:
    domainareas = json.load(f)

def scheming_domainareas_choices(field):
    for domainarea in domainareas:
        yield {
            'value': domainarea['label'].lower().replace(' ', '_'),
            'label': domainarea['label'],
        }

