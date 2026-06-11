#!/bin/sh
# Läuft einmalig nach der Nextcloud-Erstinstallation (Entrypoint-Hook):
# https://github.com/nextcloud/docker#auto-configuration-via-hook-folders
set -eu

occ() { php /var/www/html/occ "$@"; }

# Pflicht-Setting, sonst dauerhafte Admin-Warnung (Region für Telefonnummern):
# https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/config_sample_php_parameters.html
occ config:system:set default_phone_region --value="DE"

# Wartungsfenster für schwere Background-Jobs (UTC-Stunde 1 = nachts):
# entfernt die "maintenance window"-Warnung im Admin-Overview
occ config:system:set maintenance_window_start --type=integer --value=1

# Euro-Office-Integrations-App aus dem App Store installieren & aktivieren (NC 34+).
# Schlägt auf NC 33 fehl -> Fehler wird toleriert, damit der Start nicht bricht.
occ app:install eurooffice || true
occ app:enable eurooffice || true

# App-Settings setzen (config:app:set schreibt direkt in appconfig, unabhängig
# davon ob die App schon aktiv ist). Keys laut Euro-Office-Doku:
# https://github.com/Euro-Office/eurooffice-nextcloud
# Jeder Wert wird nur gesetzt, wenn die zugehörige Env-Variable gefüllt ist.
if [ -n "${EUROOFFICE_DOMAIN:-}" ]; then
	occ config:app:set eurooffice DocumentServerUrl --value="https://${EUROOFFICE_DOMAIN}"
fi
if [ -n "${EUROOFFICE_JWT_SECRET:-}" ]; then
	occ config:app:set eurooffice jwt_secret --value="${EUROOFFICE_JWT_SECRET}"
fi
