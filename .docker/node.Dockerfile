# syntax=docker/dockerfile:1

ARG _VERSION="24.20.0"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM alpine/curl:8.17.0 AS node

ARG _VERSION

WORKDIR /app/

ARG _URL=https://nodejs.org/dist/v${_VERSION}/node-v${_VERSION}-linux-x64.tar.xz

RUN curl -fsSo node.tar.xz "${_URL}" \
    && mkdir -p /app/node \
    && tar -xf node.tar.xz -C /app/node/ --strip-components=1

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _PKG_MANAGER="yarn"
ARG _NODE_HOME="/opt/node"

COPY --from=node /app/node/ "${_NODE_HOME}/"

ENV PATH="${_NODE_HOME}/bin:${PATH}"
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install libatomic1 ;; \
         archlinux) : ;; \
       esac \
    && pkg_clean \
    && "${_NODE_HOME}/bin/corepack" enable \
    && if [ "${_PKG_MANAGER}" = "yarn" ]; then \
           su "${_USERNAME}" -s /bin/sh -c "PATH=${_NODE_HOME}/bin:\$PATH ${_NODE_HOME}/bin/corepack prepare yarn@stable --activate"; \
       elif [ "${_PKG_MANAGER}" = "pnpm" ]; then \
           su "${_USERNAME}" -s /bin/sh -c "PATH=${_NODE_HOME}/bin:\$PATH ${_NODE_HOME}/bin/corepack prepare pnpm@latest --activate" \
           && su "${_USERNAME}" -s /bin/sh -c "PATH=${_NODE_HOME}/bin:\$PATH ${_NODE_HOME}/bin/pnpm --version > /dev/null"; \
       fi \
    && mkdir -p "${_HOME}/.cache" "${_HOME}/.local/share/pnpm" "${_HOME}/.yarn" "${_HOME}/.npm" \
    && chown -R "${_USERNAME}:${_USERNAME}" \
        "${_HOME}/.cache" "${_HOME}/.local" "${_HOME}/.yarn" "${_HOME}/.npm"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_HOME}/.npm", "${_HOME}/.yarn", "${_HOME}/.local/share/pnpm" ]
