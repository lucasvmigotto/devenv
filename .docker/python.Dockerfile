# syntax=docker/dockerfile:1

ARG _VERSION="3.14"
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

ARG _VIRTUAL_ENV="${_HOME}/.venv"
ARG _UV_CACHE_DIR="${_HOME}/.cache/uv"
ARG _UV_PYTHON_DIR="${_HOME}/.local/share/uv/python"

ENV UV_INSTALL_DIR="/usr/local/bin"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV UV_PROJECT_ENVIRONMENT="${_VIRTUAL_ENV}"
ENV UV_LINK_MODE="copy"
ENV UV_CACHE_DIR="${_UV_CACHE_DIR}"
ENV UV_PYTHON_INSTALL_DIR="${_UV_PYTHON_DIR}"
ENV DEVENV_PYTHON_VERSION="${_VERSION}"

RUN mkdir -p "${_VIRTUAL_ENV}" "${_UV_CACHE_DIR}" "${_UV_PYTHON_DIR}" \
    && chown -R "${_USERNAME}:${_USERNAME}" \
        "${_VIRTUAL_ENV}" "${_HOME}/.cache" "${_HOME}/.local/share/uv"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_VIRTUAL_ENV}", "${_UV_CACHE_DIR}", "${_UV_PYTHON_DIR}" ]
