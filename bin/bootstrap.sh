#!/bin/sh

# POSIX-sh bootstrap: installs bash (absent on Alpine by default) using the
# native package manager, then hands off to the bash-based setup script.
# Invoked as `RUN sh /opt/devenv/bin/bootstrap.sh` from a root RUN step.

set -eu

_distro="${_DISTRO:-}"

case "${_distro}" in
    debian|ubuntu)
        apt-get update -qq
        DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends -qq bash ca-certificates
        ;;
    alpine)
        apk add --no-cache bash
        ;;
    archlinux)
        pacman -Sy --noconfirm bash
        ;;
    *)
        echo "devenv: unsupported distro '${_distro}'" >&2
        exit 1
        ;;
esac

exec bash /opt/devenv/bin/setup-base.sh
