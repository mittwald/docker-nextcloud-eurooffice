# Dünner Layer über dem offiziellen Image: nur die Entrypoint-Hooks reinbacken,
# damit die Euro-Office-App bei Erstinstallation automatisch aktiviert und
# konfiguriert wird (statt die Hooks als Bind-Mount reinzureichen).
# Hook-Mechanismus: https://github.com/nextcloud/docker#auto-configuration-via-hook-folders
# Default: stable-apache. stable folgt dem jeweils aktuellen stabilen Major –
# regelmäßig bauen/pullen, damit kein Major übersprungen wird (NC migriert nur
# major-weise). Variante (apache/fpm) und Version über --build-arg überschreibbar;
# die Hooks sind SAPI-unabhängig und funktionieren mit beiden Varianten.
ARG NEXTCLOUD_VERSION=stable
ARG NEXTCLOUD_VARIANT=apache
FROM nextcloud:${NEXTCLOUD_VERSION}-${NEXTCLOUD_VARIANT}

COPY hooks/ /docker-entrypoint-hooks.d/
RUN find /docker-entrypoint-hooks.d -name '*.sh' -exec chmod +x {} +
