# syntax=docker/dockerfile:1

ARG _VERSION="4.4"
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

ARG _R_LIBS_USER="${_HOME}/.R/library"
ARG _R_CACHE="${_HOME}/.cache/R"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install r-base r-base-dev ;; \
         alpine)        pkg_install R R-dev ;; \
         archlinux)     pkg_install r ;; \
       esac \
    && pkg_clean \
    && mkdir -p "${_R_LIBS_USER}" "${_R_CACHE}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_HOME}/.R" "${_HOME}/.cache"

ENV R_LIBS_USER="${_R_LIBS_USER}"
ENV DEVENV_R_VERSION="${_VERSION}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_R_LIBS_USER}", "${_R_CACHE}" ]
