# syntax=docker/dockerfile:1

ARG _VERSION="1.12"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM julia:${_VERSION}-trixie AS julia

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _JULIA_HOME="/opt/julia"
ARG _JULIA_DEPOT="${_HOME}/.julia"

COPY --from=julia /usr/local/julia "${_JULIA_HOME}"

ENV JULIA_DEPOT_PATH="${_JULIA_DEPOT}"
ENV PATH="${_JULIA_HOME}/bin:${PATH}"

RUN mkdir -p "${_JULIA_DEPOT}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_JULIA_DEPOT}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_JULIA_DEPOT}" ]
