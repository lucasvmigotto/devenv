# devenv

Reproducible, non-root [DevContainer](https://containers.dev) images for Debian,
Ubuntu, Alpine, and Arch Linux.

![Docker Pulls](https://img.shields.io/docker/pulls/lucasvmigotto/devenv.svg)
![GitHub stars](https://img.shields.io/github/stars/lucasvmigotto/devenv.svg)

## Features

- **Non-root by default** — a `developer` user (UID 1000) with passwordless
  `sudo` or `doas`.
- **ZSH + Spaceship prompt** and Nerd Fonts (FiraCode, FiraMono,
  NerdFontsSymbolsOnly), driven by the
  [dottod](https://github.com/lucasvmigotto/dottod) dotfiles.
- **Persistent caches** — every language image declares `VOLUME`s for its
  dependency caches, mapped under `/home/developer`, so caches survive
  container rebuilds.
- **14 languages across 4 distros**, built and pushed with multi-arch Buildx,
  `type=gha` layer caching, and SLSA provenance.

## Tags

### Base images

| Tag                 | Distro     | Notes                     |
| ------------------- | ---------- | ------------------------- |
| `latest`            | Debian 13  | alias for `debian-trixie` |
| `debian-trixie`     | Debian 13  | `sudo` by default         |
| `debian-trixie-doas`| Debian 13  | `doas` escalation         |
| `ubuntu-noble`      | Ubuntu 24.04 | `sudo`                  |
| `alpine-3.23`       | Alpine 3.23 | `sudo`                  |
| `archlinux-base`    | Arch Linux | `sudo`                    |

Base versions: `debian` (`trixie` `bookworm` `bullseye`), `ubuntu` (`noble`
`jammy`), `alpine` (`3.23` `3.22` `3.21`), `archlinux` (`base` `base-devel`
`multilib-devel`). Append `-doas` to any tag for `doas` instead of `sudo`.

### Language images

Tag pattern: `{lang}-{version}-{distro}`.

```text
java-25-debian        go-1.26-alpine        rust-1.89-debian
python-3.14-alpine    dotnet-10.0-debian    flutter-3.38.9-debian
bun-1.3.9-alpine      zig-0.15.2-debian     c-latest-debian
cpp-latest-debian     clojure-1.12.4-debian lua-5.4-alpine
elixir-1.19-debian    haskell-9.12-debian
```

Not every language supports every distro (dotnet, elixir, and haskell are
glibc-only — Debian/Ubuntu). See the
[manifest](https://github.com/lucasvmigotto/devenv/blob/main/build/manifest.json)
for the full matrix.

## Quick start

```bash
# base image (interactive zsh)
docker run -it --rm lucasvmigotto/devenv:latest

# a language image
docker run -it --rm lucasvmigotto/devenv:go-1.26-debian
```

### Persistent caches

Declared `VOLUME`s are anonymous by default; use named volumes to persist them
across runs:

```bash
docker run -it --rm \
  -v rust-cargo:/home/developer/.cargo \
  lucasvmigotto/devenv:rust-1.89-debian
```

## DevContainer usage

`.devcontainer/devcontainer.json`:

```json
{
  "image": "lucasvmigotto/devenv:go-1.26-debian",
  "remoteUser": "developer"
}
```

`docker-compose.yml`:

```yaml
services:
  dev:
    image: lucasvmigotto/devenv:rust-1.89-debian
    user: developer
    volumes:
      - rust-cargo:/home/developer/.cargo
      - ./:/workspace
    working_dir: /workspace

volumes:
  rust-cargo:
```

## Languages & cache volumes

Every language image declares `VOLUME`s (owned by `developer`, under `$HOME`)
for its dependency caches:

| Language | Cache volumes (under `$HOME`) |
| -------- | ----------------------------- |
| java     | `.gradle`, `.m2/repository` |
| go       | `go/pkg`, `go/bin` |
| rust     | `.cargo/registry`, `.cargo/git`, `.cargo/bin` |
| python   | `.venv`, `.cache/uv`, `.local/share/uv/python` |
| dotnet   | `.nuget/packages` |
| flutter  | `.pub-cache` |
| bun      | `.bun` |
| zig      | `.cache/zig` |
| c / cpp  | `.cache/ccache` |
| clojure  | `.m2/repository` |
| lua      | `.luarocks` |
| elixir   | `.mix`, `.hex` |
| haskell  | `.ghcup`, `.stack`, `.cabal` |

## Privilege escalation

The non-root `developer` user has passwordless escalation. Base images default
to `sudo`; append `-doas` to the tag for `doas`:

```bash
docker run -it --rm lucasvmigotto/devenv:debian-trixie-doas
```

## Build from source

The base image is a single parametrized Dockerfile:

```bash
docker build -f .docker/base.Dockerfile \
    --build-arg _BASE_IMAGE=debian:trixie-slim \
    --build-arg _DISTRO=debian \
    --build-arg _PRIV_TOOL=sudo \
    -t devenv:debian-trixie .
```

Source and build matrix: <https://github.com/lucasvmigotto/devenv>.
