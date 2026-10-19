# docker-nextcloud-eurooffice

Thin layer on top of the official [`nextcloud`](https://hub.docker.com/_/nextcloud)
image (`*-apache`) that only bakes in the entrypoint hooks, so the
[Euro-Office](https://github.com/Euro-Office/eurooffice-nextcloud) integration is
automatically installed, enabled and configured on first container start.

**Nothing in the Nextcloud image itself is changed** – only a script under
`/docker-entrypoint-hooks.d/post-installation/` is added
([hook mechanism](https://github.com/nextcloud/docker#auto-configuration-via-hook-folders)).

## Automated builds

The workflow `.github/workflows/build.yml` builds the image and publishes it to
GHCR:

- **`schedule`** (every 12 h): checks via
  [`lucacome/docker-image-update-checker`](https://github.com/lucacome/docker-image-update-checker)
  whether the base image behind `nextcloud:<NEXTCLOUD_VERSION>-apache` changed,
  and only builds then – so new Nextcloud patch/minor releases of the pinned
  major are picked up automatically without unnecessary builds. A `keepalive`
  job re-enables the workflow on every scheduled run, because GitHub disables
  scheduled workflows after 60 days without repository activity.
- **`push`** to `main` and **`workflow_dispatch`** (manual): always build.

Tags: `ghcr.io/mittwald/nextcloud-eurooffice:stable-apache`, `:latest` and the
concrete major (e.g. `:34-apache`) for pinning/rollback.

Tags built from this workflow are multi-platform manifests for
**`linux/amd64`** and **`linux/arm64`**, so the image also runs on Apple Silicon
and arm64 servers. Tags published before this change stay amd64-only until they
are rebuilt. Since the Dockerfile only copies files onto the multi-arch base
image, no emulation is involved in the build.

The built Nextcloud major is pinned via `NEXTCLOUD_VERSION` in the workflow and
the `Dockerfile`. Since Nextcloud only migrates one major at a time, bump it one
major at a time so none is skipped.

## Dependency updates

[Renovate](https://docs.renovatebot.com/) (`renovate.json`) opens PRs for the
GitHub Actions and for new Nextcloud majors (`NEXTCLOUD_VERSION`). New releases
wait 3 days before a PR is opened, nothing is automerged. Renovate proposes the
newest major – if more than one major is behind, bump manually one at a time.

## Usage

Quick try with the bundled demo stack (`docker-compose.yaml`):

```bash
docker compose up -d   # -> http://localhost:8080
```

Or use the image directly:

```yaml
services:
  nextcloud-app:
    image: ghcr.io/mittwald/nextcloud-eurooffice:stable-apache
    # ... rest of the Nextcloud configuration
```

### Production

`docker-compose.prod.yaml` for running behind a TLS-terminating reverse proxy
(e.g. Mittwald container hosting). Secrets/domains come from a `.env` (see the
file header):

```bash
docker compose -f docker-compose.prod.yaml up -d
```

Since the proxy speaks plain HTTP internally, the prod compose sets
`OVERWRITEPROTOCOL`, `OVERWRITECLIURL` and `TRUSTED_PROXIES` (otherwise URLs are
generated as `http://` → mixed content). These are applied directly by the
`nextcloud` image into `config.php`.

### Environment variables

The hook evaluates these variables (each only applied when set):

| Variable | Effect (`occ config:app:set eurooffice …`) |
|---|---|
| `EUROOFFICE_DOMAIN` | `DocumentServerUrl` (browser → Office); `https://` is prepended unless a scheme is already given |
| `EUROOFFICE_JWT_SECRET` | `jwt_secret` (min. 32 characters) |
| `EUROOFFICE_INTERNAL_URL` | `DocumentServerInternalUrl` (Nextcloud → Office, internal) |
| `NEXTCLOUD_INTERNAL_URL` | `StorageUrl` (Office → Nextcloud, internal) |

Config keys per <https://github.com/Euro-Office/eurooffice-nextcloud>.

> The Euro-Office app is only in the app store from Nextcloud 34 on. On 33 the
> hook tolerates the missing package (`|| true`), so the start does not abort.

## Build locally

```bash
docker build -t nextcloud-eurooffice:34-apache .
# or pin another version:
docker build --build-arg NEXTCLOUD_VERSION=33 -t nextcloud-eurooffice:33 .
```

For both platforms at once (result stays in the build cache unless you add
`--push` or `--load`):

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t nextcloud-eurooffice:34-apache .
```
