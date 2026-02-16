#!/usr/bin/env bash

set -e

function main() {

    local home=${1:?"Must inform the home dir"}
    local plugins=${@:2}

    for plugin in ${plugins[@]}; do
        git clone --quiet \
            "https://github.com/zsh-users/${plugin}" \
            "${home}/.oh-my-zsh/custom/plugins/${plugin}"
    done

    [[ ${#plugins[@]} > 0 ]] && \
        sed -i \
            "s/^plugins=(git)/plugins=(git ${plugins[@]})/" \
            "${home}/.zshrc"

}

main $@
