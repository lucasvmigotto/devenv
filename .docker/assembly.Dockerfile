# syntax=docker/dockerfile:1

ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM ${_BASE_IMAGE}

USER root

ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && pkg_install nasm binutils gdb make \
    && pkg_clean

USER "${_USERNAME}"
WORKDIR "${_HOME}"
