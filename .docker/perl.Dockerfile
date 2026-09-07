# syntax=docker/dockerfile:1

ARG _VERSION="5.40"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _PERL5_HOME="${_HOME}/perl5"
ARG _CPAN_HOME="${_HOME}/.cpan"
ARG _CPANM_HOME="${_HOME}/.cpanm"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install perl make gcc ;; \
         alpine)        pkg_install perl make gcc musl-dev wget ;; \
         archlinux)     pkg_install perl make gcc ;; \
       esac \
    && pkg_clean \
    && curl -fsSL https://cpanmin.us | perl - App::cpanminus \
    && mkdir -p "${_PERL5_HOME}" "${_CPAN_HOME}" "${_CPANM_HOME}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_PERL5_HOME}" "${_CPAN_HOME}" "${_CPANM_HOME}"

ENV PERL5LIB="${_PERL5_HOME}/lib/perl5"
ENV PERL_LOCAL_LIB_ROOT="${_PERL5_HOME}"
ENV PERL_MB_OPT="--install_base ${_PERL5_HOME}"
ENV PERL_MM_OPT="INSTALL_BASE=${_PERL5_HOME}"
ENV PATH="${_PERL5_HOME}/bin:${PATH}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_PERL5_HOME}", "${_CPAN_HOME}", "${_CPANM_HOME}" ]
