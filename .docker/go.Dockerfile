# syntax=docker/dockerfile:1

ARG _VERSION="1.26"
ARG _DISTRO="trixie"

FROM golang:${_VERSION}-${_DISTRO} AS go

FROM mcr.microsoft.com/devcontainers/base:${_DISTRO}

ARG _VERSION="1.26.0"
ARG _USERNAME="vscode"

ARG _HOME="/home/${_USERNAME}"

ARG _LOCAL_BIN="/usr/local/go"

ARG _GO_PATH="${_HOME}/go"
ARG _GO_BIN="${_GO_PATH}/bin"
ARG _GO_PKG="${_GO_PATH}/pkg"

COPY --from=go "${_LOCAL_BIN}" "${_LOCAL_BIN}"
COPY --from=go "/go" "${_GO_PATH}"

RUN chown -R "${_USERNAME}:${_USERNAME}" "${_GO_PATH}"

ENV GOPATH="${_GO_PATH}"
ENV GOLANG_VERSION="${_VERSION}"

ENV PATH="${PATH}:${_LOCAL_BIN}/bin"

USER "${_USERNAME}"

VOLUME [ "${_GO_BIN}", "${_GO_PKG}" ]
