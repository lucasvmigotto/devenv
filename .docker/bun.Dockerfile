# syntax=docker/dockerfile:1

ARG _VERSION="1.3.9"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _BUN_INSTALL="${_HOME}/.bun"

ENV BUN_INSTALL="${_BUN_INSTALL}"
ENV PATH="${BUN_INSTALL}/bin:${PATH}"

RUN curl -fsSL https://bun.com/install | bash -s -- "bun-v${_VERSION}" \
    && mkdir -p "${_BUN_INSTALL}/install/cache" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_BUN_INSTALL}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_BUN_INSTALL}" ]
