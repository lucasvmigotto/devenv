# syntax=docker/dockerfile:1

ARG _VERSION="8.4"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

FROM php:${_VERSION}-cli AS php
FROM composer:2 AS composer

FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _COMPOSER_HOME="${_HOME}/.composer"

COPY --from=php /usr/local/bin/php /usr/local/bin/php
COPY --from=php /usr/local/lib/php /usr/local/lib/php
COPY --from=php /usr/local/etc/php /usr/local/etc/php
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

# Runtime .so deps for the copied php binary (verify with `ldd` per base;
# upstream php:cli builds are bookworm-based, adjust if trixie sonames drift).
RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && case "${_DISTRO_NAME}" in \
         debian|ubuntu) pkg_install libzip4 libonig5 libxml2 libsqlite3-0 libcurl4 ;; \
         archlinux)     pkg_install libzip oniguruma libxml2 sqlite curl ;; \
       esac \
    && pkg_clean \
    && mkdir -p "${_COMPOSER_HOME}/cache" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_COMPOSER_HOME}"

ENV COMPOSER_HOME="${_COMPOSER_HOME}"
ENV PATH="${PATH}:${_COMPOSER_HOME}/vendor/bin"
ENV DEVENV_PHP_VERSION="${_VERSION}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_COMPOSER_HOME}" ]
