FROM registry.gitlab.com/gisdev.io/ckan/ckan

USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -qq crudini

COPY entrypoint/custom-entrypoint.sh /
RUN chmod +x custom-entrypoint.sh

USER ckan
ENTRYPOINT ["/bin/bash", "/custom-entrypoint.sh"]
CMD ["ckan","-c","/etc/ckan/production.ini", "run", "--host", "0.0.0.0"]
