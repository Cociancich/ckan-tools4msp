FROM registry.gitlab.com/gisdev.io/ckan/ckan

USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -qq crudini

ARG CKANEXT_SCHEMING_VERSION=1307aedec8ae8b1c4c86d33ede654a3d9afe7fa3
RUN ckan-pip3 --no-cache install git+https://github.com/ckan/ckanext-scheming.git@${CKANEXT_SCHEMING_VERSION}

ARG CKANEXT_HARVEST_VERSION=b17eb5e714a28c26de8be6150de4d1ed4c815c13
RUN wget -q https://raw.githubusercontent.com/ckan/ckanext-harvest/${CKANEXT_HARVEST_VERSION}/pip-requirements.txt -O requirements-ckanext-harvest.txt && \
    ckan-pip3 --no-cache install -r requirements-ckanext-harvest.txt && \
    ckan-pip3 --no-cache install git+https://github.com/ckan/ckanext-harvest.git@${CKANEXT_HARVEST_VERSION}

COPY ckanext/ckanext-branding /usr/lib/ckan/venv/src/ckanext/ckanext-branding
RUN ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-branding

COPY ckanext/ckanext-schemas /usr/lib/ckan/venv/src/ckanext/ckanext-schemas
RUN ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-schemas

COPY entrypoint/custom-entrypoint.sh entrypoint/ckan-entrypoint.sh /
RUN chmod +x custom-entrypoint.sh ckan-entrypoint.sh

USER ckan
ENTRYPOINT ["/bin/bash", "/custom-entrypoint.sh"]
CMD ["ckan","-c","/etc/ckan/production.ini", "run", "--host", "0.0.0.0"]
