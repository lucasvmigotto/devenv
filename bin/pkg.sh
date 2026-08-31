#!/bin/sh

# devenv package-manager abstraction (POSIX sh).
#
# Detects the target distro from _DISTRO (debian|ubuntu|alpine|archlinux) or
# from /etc/os-release. Exposes two families of functions that share the same
# logic:
#
#   _pkg_update / _pkg_install / _pkg_remove / _pkg_clean   (consumed by dottod)
#   pkg_update  / pkg_install  / pkg_remove  / pkg_clean    (consumed by Dockerfiles)
#
# All functions must be invoked as root (from a root RUN step).

set -eu

if [ -n "${_DISTRO:-}" ]; then
    _DEVENV_DISTRO="${_DISTRO}"
else
    _DEVENV_DISTRO="$(. /etc/os-release 2>/dev/null && echo "${ID:-}")"
fi

case "${_DEVENV_DISTRO}" in
    debian|ubuntu)  _DEVENV_PKG='apt' ;;
    alpine)         _DEVENV_PKG='apk' ;;
    arch|archlinux) _DEVENV_PKG='pacman' ;;
    *) echo "devenv: unsupported distro '${_DEVENV_DISTRO}'" >&2; exit 1 ;;
esac

_pkg_update() {
    case "${_DEVENV_PKG}" in
        apt)    apt-get update -qq ;;
        apk)    apk update --quiet ;;
        pacman) pacman -Sy --noconfirm ;;
    esac
}

_pkg_install() {
    case "${_DEVENV_PKG}" in
        apt)    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends -qq "$@" ;;
        apk)    apk add --no-cache --quiet "$@" ;;
        pacman) pacman -S --noconfirm --needed "$@" ;;
    esac
}

_pkg_remove() {
    case "${_DEVENV_PKG}" in
        apt)    apt-get remove --yes --purge -qq "$@" ;;
        apk)    apk del --quiet "$@" ;;
        pacman) pacman -Rns --noconfirm "$@" ;;
    esac
}

_pkg_clean() {
    case "${_DEVENV_PKG}" in
        apt)    rm -rf /var/lib/apt/lists/* ;;
        apk)    rm -rf /var/cache/apk/* ;;
        pacman) rm -rf /var/cache/pacman/pkg/* ;;
    esac
}

pkg_update()  { _pkg_update "$@"; }
pkg_install() { _pkg_install "$@"; }
pkg_remove()  { _pkg_remove "$@"; }
pkg_clean()   { _pkg_clean "$@"; }
