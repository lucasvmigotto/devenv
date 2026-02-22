# syntax=docker/dockerfile:1

ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"

FROM alpine/curl:8.17.0 AS node

ARG _VERSION="25.6.1"

WORKDIR /app/

ARG _URL=https://nodejs.org/dist/v${_VERSION}/node-v${_VERSION}-linux-x64.tar.xz

RUN curl -fsSo node.tar.xz "${_URL}" \
    && mkdir -p /app/node \
    && tar -xf node.tar.xz -C /app/node/ --strip-components=1

FROM ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}

ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"
ARG _LOCAL_LIB="/usr/local/lib/"

COPY --from=node /app/node/ /node/

ENV PATH="${PATH}:/node/bin/"

RUN doas apt-get update -qq \
    && doas apt-get install --yes --no-install-recommends -qq \
        libatomic1 > /dev/null \
        && doas rm -rf /var/lib/apt/lists/* \
    && npm install --global yarn

USER "${_USERNAME}"
