#!/usr/bin/env bash

set -e

function _install-nerdfont() {

    local fontUrl=${1:?"Font URL must be informed"}
    local destinationFolder=${2:?"Font folder must be informed"}
    local tmpDestination=${3:-"/tmp/fonts"}

    local fontName=$(basename "${fontUrl}" | tr '[:upper:]' '[:lower:]')

    if ! curl -fsSLI "${fontUrl}" > /dev/null; then
        echo "URL ${fontUrl} is not available"
        exit 1
    fi

    local fontPath="${tmpDestination}/${fontName}"

    curl -sSLo "${fontPath}" "$fontUrl"

    [[ ! -f "${fontPath}" ]] && (
        echo "Download failed for ${fontName}" && exit 1
    )

    unzip -oqq "${fontPath}" "*.[ot]tf" -d "${destinationFolder}"

    fc-cache -f

    rm -rf "${fontPath}"

}

function _nerdfonts() {

    local fonts
    local nerdfontBase="https://github.com/ryanoasis/nerd-fonts/releases/download"
    local nerdfontVersion="v3.4.0"
    local tempDestination="/tmp/fonts"
    local globalInstall=0
    local userName=$(whoami)

    local OPTIND
    while getopts "f:b:x:t:g:u" opt; do
        case $opt in
            f) fonts+=("${OPTARG}") ;;
            b) nerdfontBase="${OPTARG}" ;;
            x) nerdfontVersion="${OPTARG}" ;;
            x) tempDestination="${OPTARG}" ;;
            g) globalInstall=1 ;;
            u) userName="${OPTARG}" ;;
            *) echo "Invalid ${opt} option provided" ;;
        esac
    done
    shift $((OPTIND-1))

    local fontFolder=$(
        [[ "${globalInstall}" -eq 0 && "${userName}" != "root" ]] \
            && (
                mkdir -p "/home/${userName}/.local/share/fonts" \
                && echo "/home/${userName}/.local/share/fonts"
            ) \
            || echo "/usr/local/share/fonts"
    )

    [[ ! -d "${tempDestination}" ]] \
        && mkdir -p "${tempDestination}"

    for font in ${fonts[@]}; do
        echo "Installing ${font}"
        if [[ $(fc-list | grep -i "${font}") ]]; then
            echo "${font} already installed, skipping..."
            continue
        fi
        _install-nerdfont \
            "${nerdfontBase}/${nerdfontVersion}/${font}.zip" \
            "${fontFolder}" \
            "${tempDestination}" \
            && echo "${font} installed" \
            || echo "${font} could not be installed"
    done

    rm -rf "${tempDestination}"

}

_nerdfonts $@

shred -u "$0" # suicide
