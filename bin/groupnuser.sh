#!/usr/bin/env bash

set -e

function _groupnuser() {

    local groupId
    local groupName
    local userName
    local userId
    local groupId
    local userShell
    local hasGreatPowers=0

    local OPTIND
    while getopts "y:i:m:n:s:x" opt; do
        case $opt in
            y) groupId="${OPTARG}" ;;
            i) userId="${OPTARG}" ;;
            m) groupName="${OPTARG}" ;;
            n) userName="${OPTARG}" ;;
            s) userShell="${OPTARG}" ;;
            x) hasGreatPowers=1 ;;
            *) echo "Invalid ${opt} option provided" ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ $(cat /etc/group | grep "${groupId}") ]]; then
        groupmod --new-name \
            "${groupName}" \
            "$(cat /etc/group | grep "${groupId}" | cut -d ":" -f 1)"
    else
        groupadd --gid "${groupId}" "${groupName}"
    fi

    if [[ $(cat /etc/passwd | grep "${userId}") ]]; then
        usermod \
            --move-home --home "/home/${userName}" \
            --login \
                "${userName}" \
                "$(cat /etc/passwd | grep "${userId}" | cut -d ":" -f 1)" \
            --shell $(which "${userShell}")
    else
        useradd \
            --uid "${userId}" \
            --gid "${groupId}" \
            --create-home "${userName}" \
            --shell $(which "${userShell}")
    fi

    if [[ "${hasGreatPowers}" == 1 ]]; then
        echo "permit nopass :${groupName}" \
            >> '/etc/doas.conf'
    fi

}

_groupnuser $@

shred -u "$0" # suicide
