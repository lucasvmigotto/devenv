# syntax=docker/dockerfile:1

ARG _DISTRO="debian"
ARG _VERSION="trixie"
ARG _VARIANT="slim"

FROM ${_DISTRO}:${_VERSION}-${_VARIANT}

ARG _GROUP_NAME="developer"
ARG _GROUP_ID="1000"
ARG _USER_NAME="${_GROUP_NAME}"
ARG _USER_ID="${_GROUP_ID}"
ARG _HOME="/home/${_USER_NAME}"

COPY ./bin/apt.sh \
    ./bin/fonts.sh \
    ./bin/group-user.sh \
    ./bin/zsh.sh \
    /tmp/

RUN bash /tmp/apt.sh \
        sudo curl fontconfig unzip \
        git zsh ca-certificates \
        && rm /tmp/apt.sh \
    && bash /tmp/fonts.sh -f "FiraCode" -f "FiraMono" -f "RobotoMono" \
        && rm /tmp/fonts.sh \
    && bash /tmp/group-user.sh \
        -y "${_GROUP_ID}" -i "${_USER_ID}" \
        -m "${_GROUP_NAME}" -n "${_USER_NAME}" \
        -s "zsh" -x \
        && rm /tmp/group-user.sh \
    && su "${_USER_NAME}" bash -c "$(curl -fsSL 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh') '' --unattended" > /dev/null \
    && bash /tmp/zsh.sh "${_HOME}" zsh-autosuggestions zsh-syntax-highlighting \
        && rm /tmp/zsh.sh \
    && chown -R "${_USER_NAME}:${_USER_NAME}" "${_HOME}"

USER "${_USER_NAME}"

WORKDIR "${_HOME}"

ENTRYPOINT [ "zsh" ]
