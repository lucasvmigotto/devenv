# syntax=docker/dockerfile:1

ARG _VERSION="10.0"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM mcr.microsoft.com/dotnet/sdk:${_VERSION} AS dotnet

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _NUGET_PACKAGES="${_HOME}/.nuget/packages"

COPY --from=dotnet /usr/share/dotnet /usr/share/dotnet

ENV DOTNET_ROOT="/usr/share/dotnet"
ENV PATH="${DOTNET_ROOT}:${PATH}"
ENV NUGET_PACKAGES="${_NUGET_PACKAGES}"
ENV DOTNET_CLI_HOME="${_HOME}/.dotnet"
ENV ASPNETCORE_HTTP_PORTS="8080"
ENV DOTNET_GENERATE_ASPNET_CERTIFICATE="false"
ENV DOTNET_NOLOGO="true"
ENV DOTNET_ROLL_FORWARD="Major"
ENV DOTNET_RUNNING_IN_CONTAINER="true"
ENV DOTNET_USE_POLLING_FILE_WATCHER="true"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install libicu-dev ;; \
       esac \
    && pkg_clean \
    && mkdir -p "${_NUGET_PACKAGES}" "${_HOME}/.dotnet" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_HOME}/.nuget" "${_HOME}/.dotnet"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_NUGET_PACKAGES}" ]
