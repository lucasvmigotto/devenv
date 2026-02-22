# syntax=docker/dockerfile:1

ARG _VERSION="3.23"

FROM alpine:${_VERSION}

ARG _GROUP_NAME="developer"
ARG _GROUP_ID="1000"
ARG _USER_NAME="${_GROUP_NAME}"
ARG _USER_ID="${_GROUP_ID}"

COPY ./bin/nerdfonts.sh \
    ./bin/groupnuser.sh \
    ./bin/starship.sh \
    /tmp/

RUN apk update --quiet \
    && apk add --no-cache --quiet \
        doas bash shadow curl ca-certificates git fontconfig unzip \
        && rm -rf /var/cache/apk/* \
    && bash /tmp/groupnuser.sh \
        -y "${_GROUP_ID}" -i "${_USER_ID}" \
        -m "${_GROUP_NAME}" -n "${_USER_NAME}" \
        -s bash -x \
    && bash /tmp/nerdfonts.sh -g -f "FiraCode" -f "FiraMono" -f "RobotoMono" \
    && bash /tmp/starship.sh -u "${_USER_NAME}" -s bash \
    && apk del --quiet --purge shadow unzip \
    && rm -rf /tmp/*

USER "${_USER_NAME}"

WORKDIR "/home/${_USER_NAME}"

ENTRYPOINT [ "bash" ]
