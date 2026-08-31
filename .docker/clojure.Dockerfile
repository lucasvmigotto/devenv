# syntax=docker/dockerfile:1

ARG _VERSION="1.12.4"
ARG _JAVA_VERSION="21"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM eclipse-temurin:${_JAVA_VERSION}-jdk AS java

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _JAVA_HOME="/opt/java/openjdk"
ARG _MVN_REP="${_HOME}/.m2/repository"

COPY --from=java "${_JAVA_HOME}" "${_JAVA_HOME}"

ENV JAVA_HOME="${_JAVA_HOME}"
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV CLJ_TOOLS_VERSION="${_VERSION}"

RUN curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh \
    && bash linux-install.sh \
    && rm -f linux-install.sh \
    && mkdir -p "${_MVN_REP}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_HOME}/.m2"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_MVN_REP}" ]
