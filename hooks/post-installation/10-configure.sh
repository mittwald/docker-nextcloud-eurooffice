#!/bin/sh
set -eu

occ() { php /var/www/html/occ "$@"; }

with_slash() { case "$1" in */) printf '%s' "$1" ;; *) printf '%s/' "$1" ;; esac; }

occ config:system:set default_phone_region --value="DE"
occ config:system:set maintenance_window_start --type=integer --value=1
occ maintenance:repair --include-expensive || true

occ app:install eurooffice || true
occ app:enable eurooffice || true

if [ -n "${EUROOFFICE_DOMAIN:-}" ]; then
	case "$EUROOFFICE_DOMAIN" in
		*://*) eurooffice_url="$EUROOFFICE_DOMAIN" ;;
		*) eurooffice_url="https://${EUROOFFICE_DOMAIN}" ;;
	esac
	occ config:app:set eurooffice DocumentServerUrl --value="$(with_slash "$eurooffice_url")"
fi
if [ -n "${EUROOFFICE_JWT_SECRET:-}" ]; then
	occ config:app:set eurooffice jwt_secret --value="${EUROOFFICE_JWT_SECRET}"
fi
if [ -n "${EUROOFFICE_INTERNAL_URL:-}" ]; then
	occ config:app:set eurooffice DocumentServerInternalUrl --value="$(with_slash "${EUROOFFICE_INTERNAL_URL}")"
fi
if [ -n "${NEXTCLOUD_INTERNAL_URL:-}" ]; then
	occ config:app:set eurooffice StorageUrl --value="$(with_slash "${NEXTCLOUD_INTERNAL_URL}")"
fi
