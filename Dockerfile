# Dünner Layer über dem offiziellen Image: nur die Entrypoint-Hooks reinbacken,
# damit die Euro-Office-App bei Erstinstallation automatisch aktiviert und
# konfiguriert wird (statt die Hooks als Bind-Mount reinzureichen).
# Hook-Mechanismus: https://github.com/nextcloud/docker#auto-configuration-via-hook-folders
# Default: stable-apache. stable folgt dem jeweils aktuellen stabilen Major –
# regelmäßig bauen/pullen, damit kein Major übersprungen wird (NC migriert nur
# major-weise). Über --build-arg überschreibbar.
ARG NEXTCLOUD_VERSION=stable
FROM nextcloud:${NEXTCLOUD_VERSION}-apache

COPY hooks/ /docker-entrypoint-hooks.d/
RUN find /docker-entrypoint-hooks.d -name '*.sh' -exec chmod +x {} +
