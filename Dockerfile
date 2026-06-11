ARG NEXTCLOUD_VERSION=stable
ARG NEXTCLOUD_VARIANT=apache
FROM nextcloud:${NEXTCLOUD_VERSION}-${NEXTCLOUD_VARIANT}

COPY hooks/ /docker-entrypoint-hooks.d/
RUN find /docker-entrypoint-hooks.d -name '*.sh' -exec chmod +x {} +
