FROM registry.gitlab.com/gisdev.io/ckan/ckan

USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -qq crudini

ARG CKANEXT_SCHEMING_VERSION=cee49eea5e69c800403432785ec4086a0611641c
RUN ckan-pip3 --no-cache install git+https://github.com/ckan/ckanext-scheming.git@${CKANEXT_SCHEMING_VERSION}

COPY ckanext/ckanext-branding /usr/lib/ckan/venv/src/ckanext/ckanext-branding
RUN ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-branding

COPY ckanext/ckanext-schemas /usr/lib/ckan/venv/src/ckanext/ckanext-schemas
RUN ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-schemas

COPY entrypoint/custom-entrypoint.sh /
RUN chmod +x custom-entrypoint.sh

USER ckan
ENTRYPOINT ["/bin/bash", "/custom-entrypoint.sh"]
CMD ["ckan","-c","/etc/ckan/production.ini", "run", "--host", "0.0.0.0"]
