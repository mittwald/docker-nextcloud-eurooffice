# docker-nextcloud-eurooffice

Dünner Layer über dem offiziellen [`nextcloud`](https://hub.docker.com/_/nextcloud)
-Image (`*-apache`), der nur die Entrypoint-Hooks einbäckt, damit die
[Euro-Office](https://github.com/Euro-Office/eurooffice-nextcloud)-Integration
beim ersten Container-Start automatisch installiert, aktiviert und konfiguriert
wird.

Es wird **nichts am Nextcloud-Image selbst verändert** – nur ein Skript unter
`/docker-entrypoint-hooks.d/post-installation/` ergänzt
([Hook-Mechanismus](https://github.com/nextcloud/docker#auto-configuration-via-hook-folders)).

## Automatische Builds

Der Workflow `.github/workflows/build.yml` baut das Image und published es nach
GHCR:

- **`schedule`** (alle 12 h): prüft via
  [`lucacome/docker-image-update-checker`](https://github.com/lucacome/docker-image-update-checker),
  ob sich das Basis-Image hinter `nextcloud:stable-apache` geändert hat, und baut
  nur dann – so werden neue Nextcloud-Releases automatisch übernommen, ohne
  unnötige Builds.
- **`push`** auf `main` und **`workflow_dispatch`** (manuell): bauen immer.

Tags: `ghcr.io/mittwald/nextcloud-eurooffice:stable-apache` und `:latest`
(`latest` = Default-Variante apache). Eine fpm-Variante würde zusätzlich
`stable-fpm` liefern.

`stable` folgt dem jeweils aktuellen stabilen Major. Da Nextcloud nur major-weise
migriert, regelmäßig laufen lassen / pullen, damit kein Major übersprungen wird.

## Verwendung

Schnell ausprobieren mit dem mitgelieferten Demo-Stack (`docker-compose.yaml`):

```bash
docker compose up -d   # -> http://localhost:8080
```

Oder das Image direkt einbinden:

```yaml
services:
  app:
    image: ghcr.io/mittwald/nextcloud-eurooffice:stable-apache
    # ... restliche Nextcloud-Konfiguration
```

### Konfiguration per Env-Variablen

Der Hook wertet diese Variablen aus (jeweils nur gesetzt, wenn gefüllt):

| Variable | Wirkung (`occ config:app:set eurooffice …`) |
|---|---|
| `EUROOFFICE_DOMAIN` | `DocumentServerUrl` = `https://$EUROOFFICE_DOMAIN` (Browser → Office) |
| `EUROOFFICE_JWT_SECRET` | `jwt_secret` |
| `EUROOFFICE_INTERNAL_URL` | `DocumentServerInternalUrl` (Nextcloud → Office, intern) |
| `NEXTCLOUD_INTERNAL_URL` | `StorageUrl` (Office → Nextcloud, intern) |

Config-Keys laut <https://github.com/Euro-Office/eurooffice-nextcloud>.

Zusätzlich: `NEXTCLOUD_BACKGROUND_CRON=true` schaltet die Background-Jobs auf
`cron`-Modus (`occ background:cron`) – sinnvoll, wenn ein cron-Container läuft.

> Die Euro-Office-App ist erst ab Nextcloud 34 im App Store. Auf 33 toleriert der
> Hook das fehlende Paket (`|| true`), der Start bricht nicht ab.

## Lokal bauen

```bash
docker build -t nextcloud-eurooffice:stable-apache .
# oder Version/Variante pinnen:
docker build --build-arg NEXTCLOUD_VERSION=33 --build-arg NEXTCLOUD_VARIANT=fpm \
  -t nextcloud-eurooffice:33-fpm .
```
