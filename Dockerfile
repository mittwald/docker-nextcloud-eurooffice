ARG NEXTCLOUD_VERSION=34
ARG NEXTCLOUD_VARIANT=apache
FROM nextcloud:${NEXTCLOUD_VERSION}-${NEXTCLOUD_VARIANT}

# Das Execute-Bit der Hooks steht im Git-Index (100755) und wird von COPY
# uebernommen. Ohne nachgelagertes RUN laeuft im Build kein Befehl in der
# Zielarchitektur, deshalb kommen die Multi-Plattform-Builds ohne Emulation aus.
# Neue Hooks entsprechend mit `git update-index --chmod=+x` ablegen.
COPY hooks/ /docker-entrypoint-hooks.d/
