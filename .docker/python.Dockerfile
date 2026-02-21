# syntax=docker/dockerfile:1

ARG _VERSION="3.14"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _DISTRO_VARIANT="slim"

FROM ghcr.io/astral-sh/uv:python${_VERSION}-${_DISTRO_VERSION} AS uv

FROM ghcr.io/lucasvmigotto/devenv/${_DISTRO_NAME}:${_DISTRO_VERSION}

ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _VIRTUAL_ENV="/${_HOME}/.venv"

COPY --from=uv /usr/local/bin/uv /usr/local/bin/uvx /bin/

RUN mkdir -p "${_VIRTUAL_ENV}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_VIRTUAL_ENV}"

ENV UV_PROJECT_ENVIRONMENT="${_VIRTUAL_ENV}"
ENV UV_LINK_MODE="copy"

ENV VIRTUAL_ENV="${_VIRTUAL_ENV}"

USER "${_USERNAME}"

VOLUME [ "${_VIRTUAL_ENV}" ]
