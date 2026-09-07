# syntax=docker/dockerfile:1

ARG _VERSION="130"
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

ARG _PHARO_HOME="/opt/pharo"
ARG _PHARO_CACHE="${_HOME}/.cache/pharo"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && pkg_install libcairo2 libgl1 libssl3 unzip \
    && pkg_clean \
    && mkdir -p "${_PHARO_HOME}" "${_PHARO_CACHE}" \
    && cd "${_PHARO_HOME}" \
    && curl -fsSL "https://get.pharo.org/64/${_VERSION}+vm" | bash \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_PHARO_HOME}" "${_PHARO_CACHE}"

ENV PHARO_HOME="${_PHARO_HOME}"
ENV PATH="${_PHARO_HOME}:${PATH}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_PHARO_CACHE}" ]
