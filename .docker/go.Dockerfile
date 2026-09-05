# syntax=docker/dockerfile:1

ARG _VERSION="1.26"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM golang:${_VERSION} AS go

ARG _VERSION

RUN go_minor="$(printf '%s' "${_VERSION}" | cut -d. -f2)" \
    && if [ "${go_minor}" -ge 26 ]; then \
           go install golang.org/x/tools/gopls@latest; \
       else \
           go install golang.org/x/tools/gopls@v0.21.1; \
       fi

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _GOROOT="/usr/local/go"
ARG _GOPATH="${_HOME}/go"

COPY --from=go "${_GOROOT}" "${_GOROOT}"
COPY --from=go /go "${_GOPATH}"

ENV GOPATH="${_GOPATH}"
ENV PATH="${_GOROOT}/bin:${_GOPATH}/bin:${PATH}"

RUN mkdir -p "${_GOPATH}/pkg" "${_GOPATH}/bin" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_GOPATH}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_GOPATH}/pkg", "${_GOPATH}/bin" ]
