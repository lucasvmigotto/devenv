# syntax=docker/dockerfile:1

ARG _VERSION="3.38.9"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM alpine/curl:8.17.0 AS flutter

ARG _VERSION
ARG _FLUTTER_STORAGE="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux"

ENV _FLUTTER_TAR="flutter_linux_${_VERSION}-stable.tar.xz"

RUN curl -sfo "${_FLUTTER_TAR}" "${_FLUTTER_STORAGE}/${_FLUTTER_TAR}" \
    && mkdir /flutter \
    && tar -xf "${_FLUTTER_TAR}" -C /flutter

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _PUB_CACHE="${_HOME}/.pub-cache"

COPY --from=flutter /flutter/ /opt/flutter/

ENV FLUTTER_ROOT="/opt/flutter"
ENV PUB_CACHE="${_PUB_CACHE}"
ENV PATH="${FLUTTER_ROOT}/bin:${PATH}"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install git unzip xz-utils libglu1-mesa libstdc++6 ;; \
       esac \
    && pkg_clean \
    && mkdir -p "${_PUB_CACHE}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_PUB_CACHE}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_PUB_CACHE}" ]
