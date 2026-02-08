# syntax=docker/dockerfile:1.7-labs

ARG _VERSION="2025"
ARG _DISTRO="trixie"

FROM adobecoldfusion/coldfusion:latest-${_VERSION} AS codefusion

FROM mcr.microsoft.com/devcontainers/base:${_DISTRO}

ARG _USERNAME="vscode"

ARG _CODEFUSION_HOME="/codefusion/"
ARG _CFUSERNAME="cfuser"
ARG _CFUSER_UID=1001
ARG _CFUSER_GID=1001
ARG _CFUSER_PASSWORD="admin"

COPY --from=codefusion /opt/coldfusion "${_CODEFUSION_HOME}"

RUN groupadd --gid $_CFUSER_GID $_CFUSERNAME \
    && useradd \
        --uid $_CFUSER_UID \
        --gid $_CFUSER_GID \
        -m $_CFUSERNAME \
        -p $(openssl passwd -6 "${_CFUSER_PASSWORD}") \
    && chown -R "${_USERNAME}:${_CFUSERNAME}" "${_CODEFUSION_HOME}" \
    && usermod -aG "${_CFUSERNAME}" "${_USERNAME}"

ENV JAVA_HOME="${_CODEFUSION_HOME}jre"

ENV acceptEULA="YES"

ENV PATH="${PATH}:${_CODEFUSION_HOME}/cfusion/bin:${_CODEFUSION_HOME}/jre/bin"

USER "${_USERNAME}"

VOLUME [ "/app" ]
