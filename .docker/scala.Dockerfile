# syntax=docker/dockerfile:1

ARG _VERSION="3.7"
ARG _JAVA_VERSION="21"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM eclipse-temurin:${_JAVA_VERSION}-jdk AS java

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _JAVA_VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _JAVA_HOME="/opt/java/openjdk"
ARG _COURSIER_CACHE="${_HOME}/.cache/coursier"
ARG _SBT_HOME="${_HOME}/.sbt"
ARG _IVY_HOME="${_HOME}/.ivy2"
ARG _CS_BIN_DIR="${_HOME}/.local/share/coursier/bin"

COPY --from=java "${_JAVA_HOME}" "${_JAVA_HOME}"

ENV JAVA_HOME="${_JAVA_HOME}"
ENV PATH="${JAVA_HOME}/bin:${_CS_BIN_DIR}:${PATH}"
ENV COURSIER_CACHE="${_COURSIER_CACHE}"
ENV DEVENV_SCALA_VERSION="${_VERSION}"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install gzip ;; \
         archlinux)     pkg_install gzip ;; \
       esac \
    && pkg_clean \
    && curl -fLo /tmp/cs.gz https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz \
    && gzip -d /tmp/cs.gz \
    && install -m 0755 /tmp/cs /usr/local/bin/cs \
    && rm -f /tmp/cs \
    && su "${_USERNAME}" -s /bin/zsh -c \
        "HOME=${_HOME} cs setup --yes --apps scala,scalac,sbt,scalafmt" \
    && mkdir -p "${_SBT_HOME}" "${_IVY_HOME}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_HOME}/.cache" "${_HOME}/.local" "${_SBT_HOME}" "${_IVY_HOME}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_COURSIER_CACHE}", "${_SBT_HOME}", "${_IVY_HOME}" ]
