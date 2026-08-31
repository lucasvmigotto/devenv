# syntax=docker/dockerfile:1

ARG _VERSION="0.15.2"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM alpine/curl:8.17.0 AS zig

ARG _VERSION
ARG _ZIG_BASE="https://ziglang.org/download"

ENV _ZIG_TAR="zig-x86_64-linux-${_VERSION}.tar.xz"

RUN curl -fsSLo "${_ZIG_TAR}" "${_ZIG_BASE}/${_VERSION}/${_ZIG_TAR}" \
    && mkdir -p /zig \
    && tar -xf "${_ZIG_TAR}" -C /zig --strip-components=1

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _ZIG_HOME="/opt/zig"
ARG _ZIG_CACHE="${_HOME}/.cache/zig"

COPY --from=zig /zig "${_ZIG_HOME}"

ENV ZIG_HOME="${_ZIG_HOME}"
ENV ZIG_GLOBAL_CACHE_DIR="${_ZIG_CACHE}"
ENV PATH="${_ZIG_HOME}:${PATH}"

RUN mkdir -p "${_ZIG_CACHE}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_ZIG_CACHE}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_ZIG_CACHE}" ]
