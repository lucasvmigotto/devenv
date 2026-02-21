#!/usr/bin/env bash

set -e

function _zshomz() {

    local plugins
    local userName="$(whoami)"
    local scriptUrl='https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh'

    local OPTIND
    while getopts "p:s:u" opt; do
        case $opt in
            p) plugins+=("${OPTARG}") ;;
            s) scriptUrl="${OPTARG}" ;;
            u) userName="${OPTARG}" ;;
            *) echo "Invalid ${opt} option provided" ;;
        esac
    done
    shift $((OPTIND-1))

    local omzInstallCommand="$(curl -fsSL ${scriptUrl}) '' --unattended > /dev/null"
    if [[ ! -z "${userName}" && "$(whoami)" == "root" ]]; then
        su "${userName}" sh -c "${omzInstallCommand}" > /dev/null
    else
        sh -c "${omzInstallCommand}" > /dev/null
    fi

    local home="/home/${userName}"
    local zshFile="${home}/.zshrc"

    [[ ! -f "${zshFile}" ]] && (
        echo "${zshFile} not found after omz installation" >&2 \
        && exit 1
    )

    for plugin in ${plugins[@]}; do
        git clone --quiet \
            "https://github.com/zsh-users/${plugin}" \
            "${home}/.oh-my-zsh/custom/plugins/${plugin}"
    done

    if [[ ${#plugins[@]} > 0 ]]; then
        local replace="s/^plugins=(git)/plugins=(git ${plugins[@]})/"
        sed -i "${replace}" "${zshFile}"
    fi

}

_zshomz $@

shred -u "$0" # suicide
