# syntax=docker/dockerfile:1

ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _DISTRO_VARIANT="slim"

FROM ghcr.io/lucasvmigotto/devenv/${_DISTRO_NAME}:${_DISTRO_VERSION}

ARG _VERSION="1.3.9"
ARG _URL="https://bun.com/install"

ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

RUN curl -fsSL "${_URL}" | bash -s "bun-v${_VERSION}" \
    && sudo mv "${_HOME}/.bun" /bun/

ENV PATH="${PATH}:/bun/bin"

USER "${_USERNAME}"
