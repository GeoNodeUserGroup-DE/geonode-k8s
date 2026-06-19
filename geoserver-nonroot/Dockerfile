# Custom geonode/geoserver Docker image building for non-root environments
# Necessary until solving in upstream,
# see also https://github.com/GeoNode/geonode-docker/pull/59

ARG GEOSERVER_VERSION=2.27.4-latest

FROM geonode/geoserver:${GEOSERVER_VERSION}

ARG GEOSERVER_UID=1000
ARG GEOSERVER_GID=1000

USER root

# Create group and user with configurable UID/GID
RUN groupadd -g ${GEOSERVER_GID} geoserver && \
    useradd -u ${GEOSERVER_UID} -g ${GEOSERVER_GID} -m geoserver

# Fix writable directories
RUN mkdir -p /usr/local/tomcat/conf \
    && chown -R 1000:1000 /usr/local/tomcat \
    && chown -R 1000:1000 /opt \
    && chmod -R g=u /usr/local/tomcat \
    && chmod -R g=u /opt

# Replace hardcoded /root/ references with ${HOME} in entrypoint
# so the script works for any user, not just root or geoserver
RUN sed -i 's|/root/\(\.bashrc\)|${HOME}/\1|g' \
        /usr/local/tomcat/tmp/entrypoint.sh && \
    sed -i 's|/root/\(\.override_env\)|${HOME}/\1|g' \
        /usr/local/tomcat/tmp/entrypoint.sh

# Strip setuid bits, for enhanced security
RUN find / -xdev -perm -4000 -exec chmod u-s {} \; 2>/dev/null || true

USER ${GEOSERVER_UID}:${GEOSERVER_GID}
