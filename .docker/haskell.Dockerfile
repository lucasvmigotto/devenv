# syntax=docker/dockerfile:1

ARG _VERSION="9.12"
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

ARG _GHCUP_DIR="${_HOME}/.ghcup"
ARG _STACK_ROOT="${_HOME}/.stack"
ARG _CABAL_DIR="${_HOME}/.cabal"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" \
    && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && pkg_install build-essential libgmp-dev libffi-dev libncurses-dev curl \
    && pkg_clean \
    && su "${_USERNAME}" -s /bin/zsh -c \
        "curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org \
         | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_MINIMAL=1 BOOTSTRAP_HASKELL_GHC_VERSION=${_VERSION} sh" \
    && mkdir -p "${_STACK_ROOT}" "${_CABAL_DIR}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_STACK_ROOT}" "${_CABAL_DIR}"

ENV PATH="${_GHCUP_DIR}/bin:${PATH}"
ENV STACK_ROOT="${_STACK_ROOT}"
ENV CABAL_DIR="${_CABAL_DIR}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_GHCUP_DIR}", "${_STACK_ROOT}", "${_CABAL_DIR}" ]
