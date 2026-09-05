# syntax=docker/dockerfile:1

ARG _VERSION="1.19"
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

ARG _MIX_HOME="${_HOME}/.mix"
ARG _HEX_HOME="${_HOME}/.hex"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && pkg_install elixir \
    && pkg_clean \
    && mkdir -p "${_MIX_HOME}" "${_HEX_HOME}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_MIX_HOME}" "${_HEX_HOME}"

ENV MIX_HOME="${_MIX_HOME}"
ENV HEX_HOME="${_HEX_HOME}"
ENV DEVENV_ELIXIR_VERSION="${_VERSION}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_MIX_HOME}", "${_HEX_HOME}" ]
