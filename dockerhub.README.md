# devenv - v1.1.0

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
- **28 languages across 4 distros**, built and pushed with multi-arch Buildx,
  `type=gha` layer caching, and SLSA provenance.
- **Flutter with Android SDK** — Flutter images bundle a JDK and the Android
  SDK (commandline-tools, platforms, build-tools), pre-cached engine
  artifacts, and `VOLUME`s for `.pub-cache`, `.gradle`, and `.android`.

## Tags

### Base images

Tag pattern: `{distro}-{version}` (`sudo` by default; append `-doas`).
`latest` is an alias for `debian-trixie`.

| Distro    | Tags                                        |
| --------- | ------------------------------------------- |
| `debian`  | `trixie`, `bookworm`, `bullseye`            |
| `ubuntu`  | `noble`, `jammy`                            |
| `alpine`  | `3.23`, `3.22`, `3.21`                      |
| `archlinux` | `base`, `base-devel`, `multilib-devel`    |

Examples: `debian-trixie`, `debian-trixie-doas`, `ubuntu-noble`, `alpine-3.23`, `archlinux-base`.

### Language images

Tag pattern: `{lang}-{version}-{distro}` (e.g. `go-1.26-debian`,
`python-3.14-alpine`).

| Image     | Versions              | Distros                    | Notes                              |
| --------- | --------------------- | -------------------------- | ---------------------------------- |
| assembly  | `latest`              | debian, ubuntu, alpine, archlinux | stateless toolchain, no cache |
| bun       | `1.3.9`               | debian, ubuntu, alpine, archlinux |                               |
| c         | `latest`              | debian, ubuntu, alpine, archlinux |                               |
| clojure   | `1.12.4`              | debian, ubuntu, archlinux   |                                    |
| cobol     | `3.2`                 | debian, ubuntu, alpine      |                                    |
| cpp       | `latest`              | debian, ubuntu, alpine, archlinux |                               |
| delphi    | `3.2.2`               | debian, ubuntu, archlinux   | Free Pascal, Delphi mode           |
| dotnet    | `10.0`, `9.0`         | debian, ubuntu              | glibc-only                         |
| elixir    | `1.19`                | debian, ubuntu              | glibc-only                         |
| flutter   | `3.47.0`              | debian, ubuntu              | Android SDK; JDK 25 default, `-jdk21` variant |
| go        | `1.26`, `1.25`        | debian, ubuntu, alpine, archlinux |                               |
| haskell   | `9.12`                | debian, ubuntu              | glibc-only                         |
| java      | `25`, `21`            | debian, ubuntu, archlinux   |                                    |
| julia     | `1.12`, `1.10`        | debian, ubuntu, archlinux   |                                    |
| lua       | `5.4`                 | debian, ubuntu, alpine, archlinux |                               |
| node      | `24.20.0`, `22.23.2`  | debian, ubuntu, archlinux   | yarn (Berry) default, `-npm` / `-pnpm` variants |
| perl      | `5.40`                | debian, ubuntu, alpine, archlinux |                               |
| php       | `8.4`, `8.3`          | debian, ubuntu, archlinux   |                                    |
| python    | `3.14`, `3.13`, `3.12` | debian, ubuntu, alpine, archlinux | uv-managed                     |
| r         | `4.4`                 | debian, ubuntu, alpine, archlinux |                               |
| ruby      | `3.4`, `3.3`          | debian, ubuntu, archlinux   |                                    |
| rust      | `1.89`                | debian, ubuntu, alpine, archlinux |                               |
| scala     | `3.7.4`, `2.13.18`    | debian, ubuntu, archlinux   | JDK 21, via Coursier               |
| smalltalk | `130`, `120`          | debian, ubuntu              | Pharo; glibc-only                  |
| zig       | `0.15.2`              | debian, ubuntu, alpine, archlinux |                               |
| basic     | `2.90`                | debian, ubuntu, alpine      | Yabasic interpreter                |
| ada       | `latest`              | debian, ubuntu              | GNAT (distro default version)      |
| lisp      | `2.4`                 | debian, ubuntu, alpine, archlinux | SBCL + Quicklisp                 |

Example variant tags: `node-24.20.0-npm-debian`, `flutter-3.47.0-jdk21-ubuntu`.

Upstream glibc-linked toolchains are why some images skip Alpine (musl);
see the
[manifest](https://github.com/lucasvmigotto/devenv/blob/main/build/manifest.json)
as the single source of truth for the full tag matrix.

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
| flutter  | `.pub-cache`, `.gradle`, `.android` |
| bun      | `.bun` |
| zig      | `.cache/zig` |
| c / cpp  | `.cache/ccache` |
| clojure  | `.m2/repository` |
| lua      | `.luarocks` |
| elixir   | `.mix`, `.hex` |
| haskell  | `.ghcup`, `.stack`, `.cabal` |
| node     | `.npm`, `.yarn`, `.local/share/pnpm` |
| assembly | *(none — stateless toolchain)* |
| cobol    | *(none — stateless toolchain)* |
| julia    | `.julia` |
| scala    | `.cache/coursier`, `.sbt`, `.ivy2` |
| delphi (fpc) | `.fppkg` |
| perl     | `perl5`, `.cpan` |
| php      | `.composer` |
| r        | `.R/library`, `.cache/R` |
| ruby     | `.gem`, `.bundle` |
| smalltalk (pharo) | `.cache/pharo` |
| basic (yabasic) | *(none — stateless interpreter)* |
| ada (gnat) | `.cache/ccache` |
| lisp (sbcl) | `quicklisp`, `.cache/common-lisp` |

> **Substitutions:** `delphi` is Free Pascal in Delphi-compatibility mode
> (Embarcadero Delphi has no headless Linux distribution); `smalltalk` is
> Pharo (GNU Smalltalk is unmaintained and absent from Debian/Ubuntu).

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
