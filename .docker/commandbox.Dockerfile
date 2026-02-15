# syntax=docker/dockerfile:1.7-labs

ARG _VERSION="2025"
ARG _DISTRO="trixie"

FROM ortussolutions/commandbox:adobe${_VERSION} AS commandbox

FROM mcr.microsoft.com/devcontainers/base:${_DISTRO}

ARG _USERNAME="vscode"

ARG _HTTP_PORT=8080
ARG _HTTPS_PORT=8443

ARG _JAVA_HOME="/opt/java/openjdk"
ARG _CLASSPATH="${_JAVA_HOME}/classes"
ARG _APP_DIR="/app"
ARG _LIB_DIR="/usr/local/lib"
ARG _BIN_DIR="/usr/local/bin"
ARG _BUILD_DIR="${_LIB_DIR}/build"
ARG _COMMANDBOX_HOME="${_LIB_DIR}/CommandBox"


COPY --from=commandbox "${_LIB_DIR}" "${_LIB_DIR}"
COPY --from=commandbox "${_BIN_DIR}" "${_BIN_DIR}"
COPY --from=commandbox "${_JAVA_HOME}" "${_JAVA_HOME}"

RUN mkdir -p "${_APP_DIR}" \
    && chown \
        -R "${_USERNAME}:${_USERNAME}" \
        "${_COMMANDBOX_HOME}" \
        "${_BUILD_DIR}" \
        "${_APP_DIR}"

ENV PATH="${PATH}:${_JAVA_HOME}/bin"
ENV JAVA_HOME="${_JAVA_HOME}"

ENV APP_DIR="${_APP_DIR}"
ENV LIB_DIR="${_LIB_DIR}"
ENV BIN_DIR="${_BIN_DIR}"
ENV BUILD_DIR="${_BUILD_DIR}"
ENV COMMANDBOX_HOME="${_COMMANDBOX_HOME}"

ENV PORT=${_HTTP_PORT}
ENV SSL_PORT=${_HTTPS_PORT}

USER "${_USERNAME}"

VOLUME [ "${_APP_DIR}" ]

EXPOSE ${_HTTP_PORT}
EXPOSE ${_HTTPS_PORT}
