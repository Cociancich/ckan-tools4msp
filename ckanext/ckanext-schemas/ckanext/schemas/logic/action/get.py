import ckan.plugins.toolkit as toolkit
from ckan.logic.action.get import package_search
from ckan.logic.action.get import package_show as ckan_package_show

# https://github.com/ckan/ckan/blob/5840e49052dc6c747316fedcc7821431f2ec50a0/ckan/logic/action/get.py#L1709-L1712
ROWS = 1000

@toolkit.chained_action
def package_show(original_action, context, data_dict):
    package = original_action(context, data_dict)
    name = package['name']
    # Derived
    results = package_search(context, {'q': f'derives_from:"{name}"', 'rows': ROWS})
    package['derived'] = ','.join(pkg['name'] for pkg in results['results'])
    # Children
    results = package_search(context, {'q': f'child_of:"{name}"', 'rows': ROWS})
    package['children'] = ','.join(pkg['name'] for pkg in results['results'])
    return package
