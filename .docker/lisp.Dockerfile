# syntax=docker/dockerfile:1

ARG _VERSION="2.4"
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

ARG _QUICKLISP_HOME="${_HOME}/quicklisp"
ARG _ASDF_CACHE="${_HOME}/.cache/common-lisp"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && pkg_install sbcl curl \
    && pkg_clean \
    && curl -fsSLo /tmp/quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp \
    && su "${_USERNAME}" -s /bin/zsh -c \
        "HOME=${_HOME} sbcl --non-interactive \
            --load /tmp/quicklisp.lisp \
            --eval '(quicklisp-quickstart:install :path \"${_QUICKLISP_HOME}/\")'" \
    && rm -f /tmp/quicklisp.lisp \
    && mkdir -p "${_ASDF_CACHE}" \
    && printf '%s\n' \
        '#-quicklisp' \
        '(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))' \
        '  (when (probe-file quicklisp-init)' \
        '    (load quicklisp-init)))' \
        > "${_HOME}/.sbclrc" \
    && chown -R "${_USERNAME}:${_USERNAME}" "${_QUICKLISP_HOME}" "${_ASDF_CACHE}" "${_HOME}/.sbclrc"

ENV DEVENV_SBCL_VERSION="${_VERSION}"
ENV ASDF_OUTPUT_TRANSLATIONS="/:${_ASDF_CACHE}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

VOLUME [ "${_QUICKLISP_HOME}", "${_ASDF_CACHE}" ]
