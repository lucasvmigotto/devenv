#!/usr/bin/env bash

set -Eeuo pipefail

# Creates (idempotently) a non-root group/user and grants passwordless
# escalation via either sudo or doas.
#
# Usage:
#   groupnuser.sh <GROUP_ID> <USER_ID> <GROUP_NAME> <USER_NAME> <SHELL> <PRIV_TOOL> [EXTRA_GROUPS]

_group_id=${1:?'group id required'}
_user_id=${2:?'user id required'}
_group_name=${3:?'group name required'}
_user_name=${4:?'user name required'}
_user_shell=${5:-/bin/zsh}
_priv_tool=${6:-sudo}
_extra_groups=${7:-}

# --- group (idempotent) ---
if ! getent group "${_group_name}" >/dev/null 2>&1; then
    if command -v groupadd >/dev/null 2>&1; then
        groupadd --gid "${_group_id}" "${_group_name}"
    else
        addgroup --gid "${_group_id}" "${_group_name}"
    fi
fi

# --- user (idempotent) ---
if ! getent passwd "${_user_name}" >/dev/null 2>&1; then
    if command -v useradd >/dev/null 2>&1; then
        useradd --uid "${_user_id}" --gid "${_group_id}" \
            --home "/home/${_user_name}" --create-home \
            --shell "${_user_shell}" "${_user_name}"
    else
        # Alpine busybox
        adduser -D -h "/home/${_user_name}" -s "${_user_shell}" \
            -u "${_user_id}" -G "${_group_name}" "${_user_name}"
    fi
fi

# --- supplementary groups ---
if [[ -n "${_extra_groups}" ]]; then
    if command -v usermod >/dev/null 2>&1; then
        usermod -aG "${_extra_groups}" "${_user_name}"
    else
        addgroup "${_user_name}" "${_extra_groups}" 2>/dev/null || true
    fi
fi

# --- passwordless escalation ---
case "${_priv_tool}" in
    sudo)
        if grep -qE '^[#@]includedir[[:space:]]+/etc/sudoers\.d' /etc/sudoers 2>/dev/null; then
            printf '%s ALL=(ALL) NOPASSWD: ALL\n' "${_user_name}" > "/etc/sudoers.d/${_user_name}"
            chmod 0440 "/etc/sudoers.d/${_user_name}"
        else
            grep -q "^${_user_name} ALL=(ALL) NOPASSWD: ALL$" /etc/sudoers 2>/dev/null \
                || printf '%s ALL=(ALL) NOPASSWD: ALL\n' "${_user_name}" >> /etc/sudoers
        fi
        ;;
    doas)
        touch /etc/doas.conf
        grep -q "^permit nopass ${_user_name}$" /etc/doas.conf 2>/dev/null \
            || printf 'permit nopass %s\n' "${_user_name}" >> /etc/doas.conf
        chmod 0640 /etc/doas.conf
        ;;
    *)
        echo "devenv: unknown _PRIV_TOOL '${_priv_tool}' (expected sudo|doas)" >&2
        exit 1
        ;;
esac
