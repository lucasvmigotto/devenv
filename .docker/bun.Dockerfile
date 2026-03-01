# syntax=docker/dockerfile:1

ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"

FROM ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}

ARG _VERSION="1.3.9"
ARG _URL="https://bun.com/install"

ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

RUN doas apt-get update -qq > /dev/null \
    && doas apt-get install --yes --no-install-recommends -qq \
        unzip > /dev/null \
        && doas rm -rf /var/lib/apt/lists/* \
    && curl -fsSL "${_URL}" | bash -s -- "bun-v${_VERSION}" > /dev/null \
    && doas apt-get remove -qq --purge --yes unzip > /dev/null \
        && doas apt-get auto-remove -qq --yes > /dev/null

ENV BUN_INSTALL="${_HOME}/.bun"
ENV PATH="${PATH}:${BUN_INSTALL}/bin"
