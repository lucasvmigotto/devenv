#!/usr/bin/env bash

set -Eeuo pipefail

# Build-time setup for the devenv base image. Inherits the following as
# environment variables (declared as Docker ARGs):
#   _DISTRO      debian | ubuntu | alpine | archlinux
#   _PRIV_TOOL   sudo | doas
#   _GROUP_NAME  _GROUP_ID  _USER_NAME  _USER_ID

export _DISTRO="${_DISTRO:-debian}"
source /opt/devenv/bin/pkg.sh

_group_id="${_GROUP_ID:-1000}"
_user_id="${_USER_ID:-1000}"
_group_name="${_GROUP_NAME:-developer}"
_user_name="${_USER_NAME:-developer}"
_priv_tool="${_PRIV_TOOL:-sudo}"

# 1. install runtime packages (distro-specific)
_pkg_update
case "${_DISTRO}" in
    debian|ubuntu)
        _pkg_install git bash curl ca-certificates fontconfig unzip sudo doas locales
        ;;
    alpine)
        _pkg_install git bash curl ca-certificates fontconfig unzip sudo doas shadow
        ;;
    archlinux)
        _pkg_install git bash curl ca-certificates fontconfig unzip sudo doas which
        ;;
esac

# 2. locale (debian/ubuntu) so the dottod bashrc `LANG=en_US.UTF-8` resolves
case "${_DISTRO}" in
    debian|ubuntu)
        echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
        locale-gen >/dev/null 2>&1 || true
        ;;
esac

# 3. non-root user + passwordless escalation (bash login shell)
_bash_bin="$(command -v bash)"
bash /opt/devenv/bin/groupnuser.sh \
    "${_group_id}" "${_user_id}" "${_group_name}" "${_user_name}" \
    "${_bash_bin}" "${_priv_tool}"

# 4. shell (plain bash + dottod bashrc) as the developer user
su "${_user_name}" -s "${_bash_bin}" -c \
    "HOME=/home/${_user_name} _DOT_NO_PACKAGES=1 _DOT_TARGET_USER=${_user_name} bash /opt/dottod/bin/shell.sh"

# 5. fonts (global) — FiraCode, FiraMono, NerdFontsSymbolsOnly
export _DOT_NO_PACKAGES=1
export _DOT_NERDFONT_GLOBAL_INSTALL=1
export _DOT_NERDFONT_VERSION='v3.4.0'
bash /opt/dottod/bin/fonts.sh FiraCode FiraMono NerdFontsSymbolsOnly

# 6. cleanup
_pkg_clean
rm -rf /tmp/*
