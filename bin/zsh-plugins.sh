#!/usr/bin/env bash

set -e

function _zsh-plugin-install() {

    local _HOME=${1:?"Please set the HOME with .oh-my-zsh dir"}
    local _PLUGINS=${@:2}

    if [[ ${#_PLUGINS[@]} < 1 ]]; then
        echo "Plugins list must have, at least, one item"
        exit 1
    fi

    for plugin in ${_PLUGINS[@]}; do

        git clone --quiet \
            "https://github.com/zsh-users/${plugin}" \
            "${_HOME}/.oh-my-zsh/custom/plugins/${plugin}"

    done

    sed -i \
        "s/^plugins=(git)/plugins=(git ${_PLUGINS[@]})/" \
        "${_HOME}/.zshrc"

}

_zsh-plugin-install $@ # zsh-autosuggestions zsh-syntax-highlighting
