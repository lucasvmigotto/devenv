# syntax=docker/dockerfile:1

ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"

FROM alpine/curl:8.17.0 AS flutter

ARG _VERSION="3.38.9"
ARG _FLUTTER_STORAGE="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux"

ENV _FLUTTER_TAR="flutter_linux_${_VERSION}-stable.tar.xz"
ENV _FLUTTER_ARTIFACT="${_FLUTTER_STORAGE}/${_FLUTTER_TAR}"

RUN curl -sfo "${_FLUTTER_TAR}" "${_FLUTTER_ARTIFACT}" \
    && mkdir /flutter \
    && tar -xf "${_FLUTTER_TAR}" -C /flutter

FROM ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}

ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _PUB_CACHE="${_HOME}/.pub-cache"

COPY --from=flutter /flutter/ /

ENV PUB_CACHE="${_PUB_CACHE}"

ENV PATH="${PATH}:/flutter/bin/"

RUN mkdir -p "${_PUB_CACHE}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_PUB_CACHE}"

USER "${_USERNAME}"

VOLUME [ "${_PUB_CACHE}" ]
