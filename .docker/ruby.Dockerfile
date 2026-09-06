# syntax=docker/dockerfile:1

ARG _VERSION="3.4"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM ruby:${_VERSION}-slim AS ruby

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _GEM_HOME="${_HOME}/.gem"
ARG _BUNDLE_HOME="${_HOME}/.bundle"

COPY --from=ruby /usr/local/bin/ /usr/local/bin/
COPY --from=ruby /usr/local/lib/ruby /usr/local/lib/ruby
COPY --from=ruby /usr/local/include/ruby-* /usr/local/include/

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

# Runtime .so deps for the copied ruby binary (verify with `ldd` per base).
RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install libssl3 libyaml-0-2 zlib1g ;; \
         archlinux)     pkg_install openssl libyaml zlib ;; \
       esac \
    && pkg_clean \
    && mkdir -p "${_GEM_HOME}" "${_BUNDLE_HOME}" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_GEM_HOME}" "${_BUNDLE_HOME}"

ENV GEM_HOME="${_GEM_HOME}"
ENV BUNDLE_USER_HOME="${_BUNDLE_HOME}"
ENV PATH="${_GEM_HOME}/bin:${PATH}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_GEM_HOME}", "${_BUNDLE_HOME}" ]
