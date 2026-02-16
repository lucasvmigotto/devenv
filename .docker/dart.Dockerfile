# syntax=docker/dockerfile:1

ARG _VERSION="3.10-sdk"
ARG _DISTRO="trixie"

FROM dart:${_VERSION} AS dart

FROM mcr.microsoft.com/devcontainers/base:${_DISTRO}

ARG _USERNAME="vscode"
ARG _HOME="/home/${_USERNAME}"

ARG _PUB_CACHE="/${_HOME}/.pub-cache"

COPY --from=dart /usr/lib/dart/ /dart

ENV PUB_CACHE="${_PUB_CACHE}"

ENV PATH="${PATH}:/dart/bin/"

RUN mkdir -p "${_PUB_CACHE}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_PUB_CACHE}"

USER "${_USERNAME}"

VOLUME [ "${_PUB_CACHE}" ]
