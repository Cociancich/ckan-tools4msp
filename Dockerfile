FROM registry.gitlab.com/gisdev.io/ckan/ckan:dev-v2-9-gisdevio

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qy crudini

ARG CKANEXT_SCHEMING_VERSION=release-3.0.0
RUN ckan-pip3 --no-cache install git+https://github.com/ckan/ckanext-scheming.git@${CKANEXT_SCHEMING_VERSION}

COPY ckanext/ckanext-branding /usr/lib/ckan/venv/src/ckanext/ckanext-branding
RUN ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-branding

COPY ckanext/ckanext-schemas /usr/lib/ckan/venv/src/ckanext/ckanext-schemas
RUN ckan-pip3 install -e /usr/lib/ckan/venv/src/ckanext/ckanext-schemas

RUN ckan-pip3 install gunicorn flask_debugtoolbar

COPY --chmod=+x entrypoint/custom-entrypoint.sh entrypoint/dev-entrypoint.sh /

ENV CKAN_INI=/etc/ckan/production.ini

USER ckan
RUN mkdir -p /var/lib/ckan/webassets/.webassets-cache
ENTRYPOINT ["/bin/bash", "/custom-entrypoint.sh"]
CMD ["gunicorn", "--chdir", "/usr/lib/ckan/venv/src/ckan", "wsgi:application", "-b", "0.0.0.0:5000"]
