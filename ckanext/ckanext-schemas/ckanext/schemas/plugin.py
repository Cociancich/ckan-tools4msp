import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit
from ckanext.schemas.views import scheming
import ckanext.schemas.helpers as helpers
import ckanext.schemas.logic.action.get

import json


class SchemasPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IBlueprint)
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.IFacets, inherit=True)
    plugins.implements(plugins.IPackageController, inherit=True)
    plugins.implements(plugins.ITemplateHelpers)
    plugins.implements(plugins.IActions)

    # IBlueprint
    def get_blueprint(self):
        return [scheming]

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic',
            'schemas')

    # IFacets

    def dataset_facets(self, facets_dict, package_type):
        for facet in ('organization', 'groups', 'tags', 'res_format', 'license_id'):
            if facet in facets_dict:
                del facets_dict[facet]
        facets_dict['vocab_category'] = toolkit._('Category')
        facets_dict['sub_category'] = toolkit._('Sub Category')
        facets_dict['owner'] = toolkit._('Owner')
        facets_dict['vocab_web_services'] = toolkit._('Web services')
        facets_dict['vocab_domain_area'] = toolkit._('Domain area')
        return facets_dict

    def group_facets(self, facets_dict, group_type, package_type):
        return self.dataset_facets(facets_dict, package_type)

    def organization_facets(self, facets_dict, organization_type, package_type):
        return self.dataset_facets(facets_dict, package_type)

    # IPackageController

    def before_index(self, pkg_dict):
        for field in ('derives_from', 'child_of'):
            data = pkg_dict.get(field+'_string')
            if data:
                data = data.split(',')
            else:
                data = []
            pkg_dict[field] = data
        for field in ('category', 'web_services', 'domain_area'):
            data = pkg_dict.get(field)
            if data:
                try:
                    data = json.loads(data)
                except ValueError:
                    data = data.split(',')
            else:
                data = []
            pkg_dict["vocab_"+field] = data
        return pkg_dict

    # ITemplateHelpers

    def get_helpers(self):
        return { name:getattr(helpers, name) for name in dir(helpers) }

    # IActions

    def get_actions(self):
        return {
           'ckan_package_show':
               ckanext.schemas.logic.action.get.ckan_package_show,
           'package_show':
               ckanext.schemas.logic.action.get.package_show,
        }
