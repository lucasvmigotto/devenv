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
.github/workflows/ base.yml, languages.yml, build-image.yml
.devcontainer/     devcontainer for developing this repo
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
