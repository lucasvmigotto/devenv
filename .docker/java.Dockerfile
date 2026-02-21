# syntax=docker/dockerfile:1

ARG _VERSION="27"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _DISTRO_VARIANT="slim"

FROM openjdk:${_VERSION}-ea-jdk AS java

FROM ghcr.io/lucasvmigotto/devenv/${_DISTRO_NAME}:${_DISTRO_VERSION}

ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _VERSION="27"
ARG _JAVA_HOME="/java/"

COPY --from=java "/usr/java/openjdk-${_VERSION}/" "${_JAVA_HOME}"

ENV JAVA_HOME="${_JAVA_HOME}"
ENV PATH="${PATH}:${JAVA_HOME}bin"

ENV _MVN_REP_DIR="${_HOME}/.m2/repository/"

RUN mkdir -p "${_MVN_REP_DIR}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_MVN_REP_DIR}"

USER "${_USERNAME}"

VOLUME [ "${_MVN_REP_DIR}" ]
