# syntax=docker/dockerfile:1

ARG _VERSION="1.89"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM rust:${_VERSION} AS rust

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _CARGO_HOME="${_HOME}/.cargo"
ARG _RUSTUP_HOME="${_HOME}/.rustup"

COPY --from=rust /usr/local/cargo "${_CARGO_HOME}"
COPY --from=rust /usr/local/rustup "${_RUSTUP_HOME}"

ENV CARGO_HOME="${_CARGO_HOME}"
ENV RUSTUP_HOME="${_RUSTUP_HOME}"
ENV PATH="${_CARGO_HOME}/bin:${PATH}"

RUN mkdir -p "${_CARGO_HOME}/registry" "${_CARGO_HOME}/git" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_CARGO_HOME}" "${_RUSTUP_HOME}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_CARGO_HOME}/registry", "${_CARGO_HOME}/git", "${_CARGO_HOME}/bin" ]
