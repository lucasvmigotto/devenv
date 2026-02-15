# syntax=docker/dockerfile:1.7-labs

ARG _VERSION="27"
ARG _DISTRO="trixie"

FROM openjdk:${_VERSION}-ea-jdk AS java

FROM mcr.microsoft.com/devcontainers/base:${_DISTRO}

ARG _USERNAME="vscode"
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
