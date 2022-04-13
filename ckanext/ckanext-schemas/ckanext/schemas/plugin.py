import ckan.plugins as plugins
import ckan.plugins.toolkit as toolkit


class SchemasPlugin(plugins.SingletonPlugin):
    plugins.implements(plugins.IConfigurer)
    plugins.implements(plugins.IFacets, inherit=True)

    # IConfigurer

    def update_config(self, config_):
        toolkit.add_template_directory(config_, 'templates')
        toolkit.add_public_directory(config_, 'public')
        toolkit.add_resource('fanstatic',
            'schemas')

    # IFacets

    def _facets(self, facets_dict):
        if 'groups' in facets_dict:
            del facets_dict['groups']
        facets_dict['category'] = toolkit._('Category')
        facets_dict['sub_category'] = toolkit._('Sub Category')
        facets_dict['owner'] = toolkit._('Owner')
        facets_dict['web_services'] = toolkit._('Web services')
        return facets_dict

    def dataset_facets(self, facets_dict, package_type):
        return self._facets(facets_dict)
