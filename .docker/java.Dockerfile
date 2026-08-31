# syntax=docker/dockerfile:1

ARG _VERSION="27"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM eclipse-temurin:${_VERSION}-jdk AS java

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _JAVA_HOME="/opt/java/openjdk"
ARG _GRADLE_HOME="${_HOME}/.gradle"
ARG _MVN_REP="${_HOME}/.m2/repository"

COPY --from=java "${_JAVA_HOME}" "${_JAVA_HOME}"

ENV JAVA_HOME="${_JAVA_HOME}"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN mkdir -p "${_GRADLE_HOME}" "${_MVN_REP}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_GRADLE_HOME}" "${_HOME}/.m2"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_GRADLE_HOME}", "${_MVN_REP}" ]
