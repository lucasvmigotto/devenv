# syntax=docker/dockerfile:1

ARG _VERSION="3.10-sdk"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _DISTRO_VARIANT="slim"

FROM dart:${_VERSION} AS dart

FROM ghcr.io/lucasvmigotto/devenv/${_DISTRO_NAME}:${_DISTRO_VERSION}

ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _PUB_CACHE="/${_HOME}/.pub-cache"

COPY --from=dart /usr/lib/dart/ /dart

ENV PUB_CACHE="${_PUB_CACHE}"

ENV PATH="${PATH}:/dart/bin/"

RUN mkdir -p "${_PUB_CACHE}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_PUB_CACHE}"

USER "${_USERNAME}"

VOLUME [ "${_PUB_CACHE}" ]
