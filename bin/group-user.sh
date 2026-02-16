#!/usr/bin/env bash

set -e

function main() {

    local groupId
    local groupName
    local userName
    local userId
    local groupId
    local userShell
    local isSudo

    while getopts "y:i:m:n:s:x" opt; do
        case $opt in
            y) groupId="${OPTARG}" ;;
            i) userId="${OPTARG}" ;;
            m) groupName="${OPTARG}" ;;
            n) userName="${OPTARG}" ;;
            s) userShell="${OPTARG}" ;;
            x) isSudo=1 ;;
            ?) echo "Invalid ${opt} option provided" ;;
        esac
    done

    groupadd --gid "${groupId}" "${groupName}"

    useradd \
        --uid "${userId}" \
        --gid "${groupId}" \
        --create-home "${userName}" \
        --shell $(which "${userShell}")

    if [[ ! -f "/home/${userName}/.${userShell}rc" ]]; then
        touch "/home/${userName}/.${userShell}rc"
    fi

    if [[ ${isSudo} ]]; then
        usermod -aG sudo "${userName}"
        echo "${userName} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${userName}"
        chmod 0440 "/etc/sudoers.d/${userName}"
    fi

}

main $@
