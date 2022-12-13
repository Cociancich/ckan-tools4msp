FROM registry.gitlab.com/gisdev.io/ckan/ckan:dev-v2-9-gisdevio

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qy crudini

ARG CKANEXT_SCHEMING_VERSION=1307aedec8ae8b1c4c86d33ede654a3d9afe7fa3
RUN ckan-pip3 --no-cache install git+https://github.com/ckan/ckanext-scheming.git@${CKANEXT_SCHEMING_VERSION}

ARG CKANEXT_OAUTH2_VERSION=01da0474c4f3f07edd5fba1a324168864ba4d86c
RUN wget -q https://raw.githubusercontent.com/frafra/ckanext-oauth2/${CKANEXT_OAUTH2_VERSION}/requirements.txt -O requirements-ckanext-oauth2.txt && \
    ckan-pip3 --no-cache install -r requirements-ckanext-oauth2.txt && \
    ckan-pip3 --no-cache install git+https://github.com/frafra/ckanext-oauth2.git@${CKANEXT_OAUTH2_VERSION}

COPY ckanext/ckanext-branding /usr/lib/ckan/venv/src/ckanext/ckanext-branding
RUN ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-branding

COPY ckanext/ckanext-schemas /usr/lib/ckan/venv/src/ckanext/ckanext-schemas
RUN ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-schemas

RUN ckan-pip3 install flask_debugtoolbar

COPY --chmod=+x entrypoint/custom-entrypoint.sh entrypoint/dev-entrypoint.sh /

USER ckan
ENTRYPOINT ["/bin/bash", "/custom-entrypoint.sh"]
CMD ["ckan","-c","/etc/ckan/production.ini", "run", "--host", "0.0.0.0"]
