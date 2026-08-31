# syntax=docker/dockerfile:1

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

ARG _CCACHE_DIR="${_HOME}/.cache/ccache"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install build-essential g++ clang lldb gdb make cmake ninja-build ccache pkg-config ;; \
         alpine)        pkg_install build-base g++ clang lldb gdb make cmake ninja ccache pkgconf ;; \
         archlinux)     pkg_install base-devel clang lldb gdb make cmake ninja ccache pkgconf ;; \
       esac \
    && pkg_clean

ENV CC="clang"
ENV CXX="clang++"
ENV CCACHE_DIR="${_CCACHE_DIR}"

RUN mkdir -p "${_CCACHE_DIR}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_CCACHE_DIR}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_CCACHE_DIR}" ]
