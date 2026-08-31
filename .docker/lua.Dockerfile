# syntax=docker/dockerfile:1

ARG _VERSION="5.4"
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

ARG _LUAROCKS_HOME="${_HOME}/.luarocks"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install "lua${_VERSION}" luarocks ;; \
         alpine)        pkg_install "lua${_VERSION}" luarocks ;; \
         archlinux)     pkg_install lua luarocks ;; \
       esac \
    && pkg_clean

RUN mkdir -p "${_LUAROCKS_HOME}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_LUAROCKS_HOME}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_LUAROCKS_HOME}" ]
