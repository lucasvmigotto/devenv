#!/usr/bin/env bash

set -e

function _font-installer() {

    local fontUrl=${1:?"Font URL must be informed"}
    local folder=${2:?"Font folder must be informed"}
    local tmpDestination=${3:-"/tmp/fonts"}

    local fontName=$(basename "$fontUrl" | tr '[:upper:]' '[:lower:]' )

    if ! curl -sfIo /dev/null "$fontUrl"; then
        echo "Invalid font URL"
        exit 1
    fi

    mkdir -p "${tmpDestination}"

    local fontPath="${tmpDestination}/${fontName}"

    curl -sSLo "${fontPath}" "$fontUrl"

    [[ ! -f "${fontPath}" ]] \
        && (echo "Download failed for ${fontName}" && exit 1)

    unzip -oqq \
        "${fontPath}" \
        "*.[ot]tf" \
        -d "${folder}"

    fc-cache

    rm -rf "${fontPath}"

}

function main() {

    local fonts
    local nerdfontBase="https://github.com/ryanoasis/nerd-fonts/releases/download/"
    local nerdfontVersion="v3.4.0"
    local fontFolder="/usr/share/fonts"
    local OPTIND

    while getopts "f:b:v:h" opt; do
        case $opt in
            f) fonts+=("${OPTARG}") ;;
            b) nerdfontBase="${OPTARG}" ;;
            v) nerdfontVersion="${OPTARG}" ;;
            h) fontFolder="${OPTARG}" ;;
            ?) echo "Invalid ${opt} option provided" ;;
        esac
    done
    shift $((OPTIND-1))

    for font in ${fonts[@]}; do
        local url=
        _font-installer \
            "${nerdfontBase}/${nerdfontVersion}/${font}.zip" \
            "${fontFolder}"
    done

}

main $@
