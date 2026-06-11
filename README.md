# nextcloud-eurooffice-image

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

- **`schedule`** (täglich): zieht per `pull: true` das aktuelle
  `nextcloud:stable-apache` und übernimmt so neue Nextcloud-Releases
  automatisch.
- **`push`** auf `main` und **`workflow_dispatch`** (manuell).

Tags: `ghcr.io/<owner>/<repo>:stable` und `:latest`.

`stable` folgt dem jeweils aktuellen stabilen Major. Da Nextcloud nur major-weise
migriert, regelmäßig laufen lassen / pullen, damit kein Major übersprungen wird.

## Verwendung

```yaml
services:
  app:
    image: ghcr.io/<owner>/nextcloud-eurooffice-image:stable
    # ... restliche Nextcloud-Konfiguration
```

### Konfiguration per Env-Variablen

Der Hook wertet diese Variablen aus (jeweils nur gesetzt, wenn gefüllt):

| Variable | Wirkung (`occ config:app:set eurooffice …`) |
|---|---|
| `EUROOFFICE_DOMAIN` | `DocumentServerUrl` = `https://$EUROOFFICE_DOMAIN` |
| `EUROOFFICE_JWT_SECRET` | `jwt_secret` |

Config-Keys laut <https://github.com/Euro-Office/eurooffice-nextcloud>.

> Die Euro-Office-App ist erst ab Nextcloud 34 im App Store. Auf 33 toleriert der
> Hook das fehlende Paket (`|| true`), der Start bricht nicht ab.

## Lokal bauen

```bash
docker build -t nextcloud-eurooffice:stable .
# oder eine bestimmte Version pinnen:
docker build --build-arg NEXTCLOUD_VERSION=33 -t nextcloud-eurooffice:33 .
```
