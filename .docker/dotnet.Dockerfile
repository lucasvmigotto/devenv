# syntax=docker/dockerfile:1

ARG _VERSION="10.0"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _DISTRO_VARIANT="slim"

FROM mcr.microsoft.com/dotnet/sdk:${_VERSION} AS dotnet

FROM ghcr.io/lucasvmigotto/devenv/${_DISTRO_NAME}:${_DISTRO_VERSION}

ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _NUGET_PACKAGES="${_HOME}/.nuget/packages"
ARG _ASPNETCORE_HTTP_PORTS="8080"
ARG _DOTNET_GENERATE_ASPNET_CERTIFICATE="false"
ARG _DOTNET_NOLOGO="true"
ARG _DOTNET_ROLL_FORWARD="Major"
ARG _DOTNET_RUNNING_IN_CONTAINER="true"
ARG _DOTNET_USE_POLLING_FILE_WATCHER="true"

COPY --from=dotnet /usr/share/dotnet /dotnet/

ENV PATH="${PATH}:/dotnet"

RUN export DEBIAN_FRONTEND="noninteractive" \
    && sudo apt-get update -qq > /dev/null \
    && sudo apt-get install \
        --yes --no-install-recommends -qq \
        libicu-dev > /dev/null \
    && sudo rm -rf /var/lib/apt/lists/* \
    && echo "export DOTNET_SDK_VERSION=$(dotnet --version)" | sudo tee --append "${_HOME}/.zshrc"

ENV NUGET_PACKAGES="${_NUGET_PACKAGES}"
ENV ASPNETCORE_HTTP_PORTS="${_ASPNETCORE_HTTP_PORTS}"
ENV DOTNET_GENERATE_ASPNET_CERTIFICATE="${_DOTNET_GENERATE_ASPNET_CERTIFICATE}"
ENV DOTNET_NOLOGO="${_DOTNET_NOLOGO}"
ENV DOTNET_ROLL_FORWARD="${_DOTNET_ROLL_FORWARD}"
ENV DOTNET_RUNNING_IN_CONTAINER="${_DOTNET_RUNNING_IN_CONTAINER}"
ENV DOTNET_USE_POLLING_FILE_WATCHER="${_DOTNET_USE_POLLING_FILE_WATCHER}"

USER "${_USERNAME}"

VOLUME [ "${_NUGET_PACKAGES}" ]
