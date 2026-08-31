# syntax=docker/dockerfile:1

ARG _BASE_IMAGE=debian:trixie-slim
FROM ${_BASE_IMAGE}

ARG _DISTRO=debian
ARG _PRIV_TOOL=sudo
ARG _GROUP_NAME=developer
ARG _GROUP_ID=1000
ARG _USER_NAME=developer
ARG _USER_ID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV DEVENV_USER=${_USER_NAME}
ENV DEVENV_PRIV_TOOL=${_PRIV_TOOL}

COPY bin/ /opt/devenv/bin/
COPY dottod/ /opt/dottod/

RUN sh /opt/devenv/bin/bootstrap.sh

ENV SHELL=/bin/zsh
ENV HOME=/home/${_USER_NAME}
ENV ZSH=/home/${_USER_NAME}/.oh-my-zsh

USER ${_USER_NAME}
WORKDIR /home/${_USER_NAME}

ENTRYPOINT ["zsh", "-l"]
