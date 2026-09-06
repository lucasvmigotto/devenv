# syntax=docker/dockerfile:1

ARG _VERSION="3.2"
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

ARG _COB_CONFIG_DIR="${_HOME}/.config/gnucobol"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && pkg_install gnucobol \
    && pkg_clean \
    && mkdir -p "${_COB_CONFIG_DIR}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_HOME}/.config"

ENV COB_CONFIG_DIR="${_COB_CONFIG_DIR}"
ENV DEVENV_COBOL_VERSION="${_VERSION}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_COB_CONFIG_DIR}" ]
