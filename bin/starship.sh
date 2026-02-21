#!/usr/bin/env bash

set -e

function _starship() {

    local baseShell
    local userName="$(whoami)"
    local scriptUrl='https://starship.rs/install.sh'

    local OPTIND
    while getopts "s:u:x" opt; do
        case $opt in
            s) baseShell="${OPTARG}" ;;
            u) userName="${OPTARG}" ;;
            x) scriptUrl="${OPTARG}" ;;
            *) echo "Invalid ${opt} option provided" ;;
        esac
    done

    local home="/home/${userName}"
    local baseShellrc="${home}/.${baseShell}rc"
    local localBin="${home}/.local/bin"

    [[ ! -d "${localBin}" ]] && mkdir -p "${localBin}"

    curl -fsSL "${scriptUrl}" | sh -s -- \
        --bin-dir "${localBin}" \
        --force > /dev/null

    if [[ ! $(echo ":${PATH}:" | grep -i "${localBin}") ]]; then
        echo "export PATH=\"\${PATH}\":${localBin}" | tee -a "${baseShellrc}"
    fi

    echo "eval \"\$(starship init ${baseShell})\"" | tee -a "${baseShellrc}"

}

_starship $@

shred -u "$0" # suicide
