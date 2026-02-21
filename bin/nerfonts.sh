𝔏𝔲𝔠𝔞𝔰
lucasvmigotto
🫠𝓝𝓮𝓷𝓱𝓾𝓶𝓪 𝓫𝓸𝓪 𝓪𝓬ã𝓸 𝓯𝓲𝓬𝓪 𝓼𝓮𝓶 𝓹𝓾𝓷𝓲𝓬ã𝓸



𝔏𝔲𝔠𝔞𝔰

 — Yesterday at 1:56 PM
# syntax=docker/dockerfile:1

ARG _VERSION="noble"

FROM ubuntu:${_VERSION}

ARG _GROUP_NAME="developer"
ARG _GROUP_ID="1000"
ARG _USER_NAME="${_GROUP_NAME}"
ARG _USER_ID="${_GROUP_ID}"

COPY bin/nerdfonts.sh \
    bin/groupnuser.sh \
    bin/starship.sh \
    /tmp/

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
    && apt-get install --yes --no-install-recommends -qq \
        doas bash curl ca-certificates git fontconfig unzip > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
    && bash /tmp/groupnuser.sh \
        -y "${_GROUP_ID}" -i "${_USER_ID}" \
        -m "${_GROUP_NAME}" -n "${_USER_NAME}" \
        -s bash -x \
    && bash /tmp/nerdfonts.sh -g -f "FiraCode" -f "FiraMono" -f "RobotoMono" \
    && bash /tmp/starship.sh -u "${_USER_NAME}" -s bash \
    && chown -R "${_USER_NAME}:${_USER_NAME}" "/home/${_USER_NAME}" \
    && apt-get remove -qq --purge --yes unzip > /dev/null \
        && apt-get auto-remove -qq --yes > /dev/null \
    && rm -rf /tmp/*

USER "${_USER_NAME}"

WORKDIR "/home/${_USER_NAME}"

ENTRYPOINT [ "bash" ]

# syntax=docker/dockerfile:1

ARG _VERSION="trixie"

FROM debian:${_VERSION}-slim

ARG _GROUP_NAME="developer"
ARG _GROUP_ID="1000"
ARG _USER_NAME="${_GROUP_NAME}"
ARG _USER_ID="${_GROUP_ID}"

COPY bin/nerdfonts.sh \
    bin/groupnuser.sh \
    bin/starship.sh \
    /tmp/

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
    && apt-get install --yes --no-install-recommends -qq \
        doas bash curl ca-certificates git fontconfig unzip > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
    && bash /tmp/groupnuser.sh \
        -y "${_GROUP_ID}" -i "${_USER_ID}" \
        -m "${_GROUP_NAME}" -n "${_USER_NAME}" \
        -s bash -x \
    && bash /tmp/nerdfonts.sh -g -f "FiraCode" -f "FiraMono" -f "RobotoMono" \
    && bash /tmp/starship.sh -u "${_USER_NAME}" -s bash \
    && chown -R "${_USER_NAME}:${_USER_NAME}" "/home/${_USER_NAME}" \
    && apt-get remove -qq --purge --yes unzip > /dev/null \
        && apt-get auto-remove -qq --yes > /dev/null \
    && rm -rf /tmp/*

USER "${_USER_NAME}"

WORKDIR "/home/${_USER_NAME}"

ENTRYPOINT [ "bash" ]

# syntax=docker/dockerfile:1

ARG _VERSION="base"

FROM archlinux:${_VERSION}

ARG _GROUP_NAME="developer"
ARG _GROUP_ID="1000"
ARG _USER_NAME="${_GROUP_NAME}"
ARG _USER_ID="${_GROUP_ID}"

COPY bin/nerdfonts.sh \
    bin/groupnuser.sh \
    bin/starship.sh \
    /tmp/

RUN pacman -Syy > /dev/null \
    && pacman -Syy --noconfirm \
        doas which curl ca-certificates git fontconfig unzip > /dev/null \
        && rm -rf /var/cache/pacman/pkg/* \
    && bash /tmp/groupnuser.sh \
        -y "${_GROUP_ID}" -i "${_USER_ID}" \
        -m "${_GROUP_NAME}" -n "${_USER_NAME}" \
        -s bash -x \
    && bash /tmp/nerdfonts.sh -g -f "FiraCode" -f "FiraMono" -f "RobotoMono" \
    && bash /tmp/starship.sh -u "${_USER_NAME}" -s bash \
    && pacman -Rns --noconfirm unzip > /dev/null \
    && rm -rf /tmp/*

USER "${_USER_NAME}"

WORKDIR "/home/${_USER_NAME}"

ENTRYPOINT [ "bash" ]

# syntax=docker/dockerfile:1

ARG _VERSION="3.23"

FROM alpine:${_VERSION}

ARG _GROUP_NAME="developer"
ARG _GROUP_ID="1000"
ARG _USER_NAME="${_GROUP_NAME}"
ARG _USER_ID="${_GROUP_ID}"

COPY bin/nerdfonts.sh \
    bin/groupnuser.sh \
    bin/starship.sh \
    /tmp/

RUN apk update --quiet \
    && apk add --no-cache --quiet \
        doas bash shadow curl ca-certificates git fontconfig unzip \
        && rm -rf /var/cache/apk/* \
    && bash /tmp/groupnuser.sh \
        -y "${_GROUP_ID}" -i "${_USER_ID}" \
        -m "${_GROUP_NAME}" -n "${_USER_NAME}" \
        -s bash -x \
    && bash /tmp/nerdfonts.sh -g -f "FiraCode" -f "FiraMono" -f "RobotoMono" \
    && bash /tmp/starship.sh -u "${_USER_NAME}" -s bash \
    && apk del --quiet --purge shadow unzip \
    && rm -rf /tmp/*

USER "${_USER_NAME}"

WORKDIR "/home/${_USER_NAME}"

ENTRYPOINT [ "bash" ]

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

𝔏𝔲𝔠𝔞𝔰

 — Yesterday at 2:36 PM
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

𝔏𝔲𝔠𝔞𝔰

 — Yesterday at 5:03 PM
```sh
#!/usr/bin/env bash

set -e

function _install-nerdfont() {

message.txt
3 KB
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

﻿
```sh
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

```
message.txt
3 KB
