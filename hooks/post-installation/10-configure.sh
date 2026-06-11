#!/bin/sh
set -eu

occ() { php /var/www/html/occ "$@"; }

occ config:system:set default_phone_region --value="DE"

occ app:install eurooffice || true
occ app:enable eurooffice || true

if [ -n "${EUROOFFICE_DOMAIN:-}" ]; then
	occ config:app:set eurooffice DocumentServerUrl --value="https://${EUROOFFICE_DOMAIN}"
fi
if [ -n "${EUROOFFICE_JWT_SECRET:-}" ]; then
	occ config:app:set eurooffice jwt_secret --value="${EUROOFFICE_JWT_SECRET}"
fi
