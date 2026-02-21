# syntax=docker/dockerfile:1

ARG _VERSION="trixie"

FROM debian:${_VERSION}-slim

ARG _GROUP_NAME="developer"
ARG _GROUP_ID="1000"
ARG _USER_NAME="${_GROUP_NAME}"
ARG _USER_ID="${_GROUP_ID}"

COPY bin/nerdfonts.sh \
    bin/groupnuser.sh \
    bin/starship.sh \
    /tmp/

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
    && apt-get install --yes --no-install-recommends -qq \
        doas bash curl ca-certificates git fontconfig unzip > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
    && bash /tmp/groupnuser.sh \
        -y "${_GROUP_ID}" -i "${_USER_ID}" \
        -m "${_GROUP_NAME}" -n "${_USER_NAME}" \
        -s bash -x \
    && bash /tmp/nerdfonts.sh -g -f "FiraCode" -f "FiraMono" -f "RobotoMono" \
    && bash /tmp/starship.sh -u "${_USER_NAME}" -s bash \
    && chown -R "${_USER_NAME}:${_USER_NAME}" "/home/${_USER_NAME}" \
    && apt-get remove -qq --purge --yes unzip > /dev/null \
        && apt-get auto-remove -qq --yes > /dev/null \
    && rm -rf /tmp/*

USER "${_USER_NAME}"

WORKDIR "/home/${_USER_NAME}"

ENTRYPOINT [ "bash" ]
