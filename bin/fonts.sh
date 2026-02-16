#!/usr/bin/env bash

set -e

function _font_downloader() {

    local _NERDFONT_NAME=${1:?"Font name not informed"}
    local _NERDFONT_VERSION=${2:-"v3.4.0"}
    local _NERDFONT_BASE=${3:-"https://github.com/ryanoasis/nerd-fonts/releases/download/"}
    local _DESTINATION=${4:-"/tmp/fonts"}

    local _FONT_URL="${_NERDFONT_BASE}/${_NERDFONT_VERSION}/${_NERDFONT_NAME}.zip"
    local _FONT_NAME=$(basename $_FONT_URL | tr '[:upper:]' '[:lower:]' )

    if ! curl -sfIo /dev/null $_FONT_URL; then
        echo "Invalid font URL"
        exit 1
    fi

    mkdir -p "${_DESTINATION}"

    local _FONT_PATH="${_DESTINATION}/${_FONT_NAME}"

    curl -sSLo "${_FONT_PATH}" $_FONT_URL

    [[ -f "${_FONT_PATH}" ]] \
        && echo "${_FONT_PATH}" \
        || (echo "Download failed for ${_FONT_NAME}" && exit 1)

}

function _font_installer() {

    local _FONT_PATH=${1:?"Font path not informed"}
    local _NERDFONT_VERSION=${2:-"v3.4.0"}
    local _NERDFONT_BASE=${3:-"https://github.com/ryanoasis/nerd-fonts/releases/download/"}
    local _FONTS_FOLDER=${4:-"/usr/share/fonts"}
    local _FONTS_PATTERN=${5:-"*.[ot]tf"}

    if [[ ! -d "${_FONTS_FOLDER}" ]]; then
        mkdir -p "${_FONTS_FOLDER}"
    fi

    unzip -oqq \
        "${_FONT_PATH}" \
        "${_FONTS_PATTERN}" \
        -d "${_FONTS_FOLDER}"

    fc-cache

}

function main() {

    for font in $@; do
        _font_installer $(_font_downloader "${font}")
    done

}

main $@ # FiraCode FiraMono RobotoMono
