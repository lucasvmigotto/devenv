# devenv

A suite of reproducible, non-root [DevContainer](https://containers.dev) base
and language images, built on Debian, Ubuntu, Alpine, and Arch Linux.

Each image ships a `developer` user (UID 1000) with passwordless escalation
(`sudo` or `doas`), ZSH + [Spaceship](https://spaceship-prompt.sh/) prompt, and
a curated set of [Nerd Fonts](https://www.nerdfonts.com/)
(FiraCode, FiraMono, NerdFontsSymbolsOnly). Shell and font setup are driven by
the [dottod](https://github.com/lucasvmigotto/dottod) dotfiles (a git
submodule), so the images stay in sync with your workstation.

## Layout

```txt
.docker/           Dockerfiles (base + one per language)
bin/               build scripts (pkg.sh, groupnuser.sh, setup-base.sh, ...)
build/             CI matrix (manifest.json + gen-matrix.py)
dottod/            git submodule — shell/fonts source of truth
.github/workflows/ base.yml, languages.yml, build-image.yml, dockerhub-description.yml
dockerhub.README.md  Docker Hub description
```

## Tags

Base images (`ghcr.io/lucasvmigotto/devenv`):

| Distro    | Versions                    | Priv tool |
| --------- | --------------------------- | --------- |
| `debian`  | `trixie` `bookworm` `bullseye` | `sudo` (default), `-doas` suffix |
| `ubuntu`  | `noble` `jammy`             |           |
| `alpine`  | `3.23` `3.22` `3.21`        |           |
| `archlinux` | `base` `base-devel` `multilib-devel` | |

Examples: `debian-trixie`, `debian-trixie-doas`, `alpine-3.23`.

Language images: `{lang}-{version}-{distro}`, e.g. `rust-1.89-debian`,
`python-3.14-alpine`, `go-1.26-ubuntu`.

Flutter images bundle a JDK and the Android SDK for building and testing
Android apps. The default JDK is 25; a JDK 21 variant appends `-jdk21`:
`flutter-3.47.0-debian`, `flutter-3.47.0-jdk21-debian`.

Node images ship yarn (Berry) by default; `-npm` and `-pnpm` variants exist.

## Languages

java, go, rust, python (uv), dotnet, flutter, bun, zig, c, cpp, clojure, lua,
elixir, haskell, node (yarn/npm/pnpm), assembly, cobol, julia, scala,
delphi (free pascal), perl, php, r, ruby, smalltalk (pharo), basic (yabasic),
ada (gnat), lisp (sbcl). Every image
declares `VOLUME`s for its dependency caches
(owned by `developer`) so caches survive container rebuilds:

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

> **Substitutions:** `delphi` ships the Free Pascal Compiler in
> Delphi-compatibility mode (`{$mode delphi}`) — Embarcadero Delphi has no
> headless Linux distribution. `smalltalk` ships Pharo — GNU Smalltalk was
> dropped from Debian/Ubuntu and has no active upstream.

### Supported distros

Upstream glibc-linked toolchains restrict some images (`build/manifest.json`
is the source of truth):

| Distros | Languages |
| ------- | --------- |
| debian, ubuntu, alpine, archlinux | assembly, bun, c, cpp, go, lisp, lua, perl, python, r, rust, zig |
| debian, ubuntu, archlinux | clojure, delphi, java, julia, node, php, ruby, scala |
| debian, ubuntu, alpine | basic, cobol |
| debian, ubuntu | ada, dotnet, elixir, flutter, haskell, smalltalk |

## Building locally

Base image (single parametrized Dockerfile):

```bash
docker build -f .docker/base.Dockerfile \
    --build-arg _BASE_IMAGE=debian:trixie-slim \
    --build-arg _DISTRO=debian \
    --build-arg _PRIV_TOOL=sudo \
    -t devenv:debian-trixie .
```

Language image (base reference is overridable via `_BASE_IMAGE`):

```bash
docker build -f .docker/rust.Dockerfile \
    --build-arg _VERSION=1.89 \
    --build-arg _DISTRO_NAME=debian \
    --build-arg _DISTRO_VERSION=trixie \
    --build-arg _BASE_IMAGE=devenv:debian-trixie \
    -t devenv:rust .
```

## CI/CD

The build matrix is declared in [`build/manifest.json`](build/manifest.json) and
rendered to a GitHub Actions matrix by `build/gen-matrix.py`. `base.yml` builds
all base variants; `languages.yml` builds language images after the base
succeeds. Both delegate to the reusable `build-image.yml` (Buildx multi-arch,
`type=gha` layer cache, SLSA provenance, push to GHCR + Docker Hub).

To add a language or a new version, edit `manifest.json` — no workflow YAML
changes are required. Languages may declare an optional `jdk` list (used by
flutter: the first entry is the default tag, others get a `-jdk{N}` suffix)
or a `pm` list (used by node: the first entry is the default tag, others get
a `-{pm}` suffix, e.g. `-npm`, `-pnpm`).

## Privilege escalation

`_PRIV_TOOL=sudo|doas` is a base-image-only switch. Base images tagged
`{distro}-{version}` default to `sudo`; append `-doas` for `doas`.
