# syntax=docker/dockerfile:1

ARG _VERSION="3.14"
ARG _DISTRO="trixie"

FROM ghcr.io/astral-sh/uv:python${_VERSION}-${_DISTRO} AS uv

FROM mcr.microsoft.com/devcontainers/base:${_DISTRO}

ARG _USERNAME="vscode"
ARG _HOME="/home/${_USERNAME}"

ARG _VIRTUAL_ENV="/${_HOME}/.venv"

COPY --from=uv /usr/local/bin/uv /usr/local/bin/uvx /bin/

RUN mkdir -p "${_VIRTUAL_ENV}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_VIRTUAL_ENV}"

ENV VIRTUAL_ENV="${_VIRTUAL_ENV}"

ENV UV_PROJECT_ENVIRONMENT="${VIRTUAL_ENV}"
ENV UV_LINK_MODE="copy"

USER "${_USERNAME}"

VOLUME [ "${_VIRTUAL_ENV}" ]
