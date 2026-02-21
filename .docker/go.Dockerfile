# syntax=docker/dockerfile:1

ARG _VERSION="1.26"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _DISTRO_VARIANT="slim"

FROM golang:${_VERSION}-${_DISTRO_VERSION} AS go

RUN go install golang.org/x/tools/gopls@latest

FROM ghcr.io/lucasvmigotto/devenv/${_DISTRO_NAME}:${_DISTRO_VERSION}

ARG _VERSION="1.26.0"
ARG _USERNAME="developer"

ARG _HOME="/home/${_USERNAME}"

ARG _LOCAL_BIN="/usr/local/go"

ARG _GO_PATH="${_HOME}/go"
ARG _GO_BIN="${_GO_PATH}/bin"
ARG _GO_PKG="${_GO_PATH}/pkg"

COPY --from=go "${_LOCAL_BIN}" "${_LOCAL_BIN}"
COPY --from=go "/go" "${_GO_PATH}"

RUN sudo chown -R "${_USERNAME}:${_USERNAME}" "${_GO_PATH}"

ENV GOPATH="${_GO_PATH}"
ENV GOLANG_VERSION="${_VERSION}"

ENV PATH="${PATH}:${_LOCAL_BIN}/bin"

USER "${_USERNAME}"

VOLUME [ "${_GO_BIN}", "${_GO_PKG}" ]
