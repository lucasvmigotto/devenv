# syntax=docker/dockerfile:1

ARG _DISTRO="debian"
ARG _VERSION="trixie"
ARG _VARIANT="-slim"

FROM ${_DISTRO}:${_VERSION}${_VARIANT} AS base

ARG _GROUP_NAME="developer"
ARG _GROUP_ID="1000"
ARG _USER_NAME="${_GROUP_NAME}"
ARG _USER_ID="${_GROUP_ID}"
ARG _HOME="/home/${_USER_NAME}"

COPY ./bin/fonts.sh ./bin/zsh-plugins.sh /tmp/

RUN apt-get update -qq > /dev/null \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install --yes --no-install-recommends -qq \
        sudo curl fontconfig unzip git zsh ca-certificates > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
    && bash /tmp/fonts.sh "FiraCode" "FiraMono" "RobotoMono" && rm /tmp/fonts.sh \
    && groupadd --gid "${_GROUP_ID}" "${_GROUP_NAME}" \
        && useradd \
            --uid "${_USER_ID}" \
            --gid "${_GROUP_ID}" \
            --create-home "${_USER_NAME}" \
            --shell $(which zsh) \
            && touch "${_HOME}/.zshrc" \
            && usermod -aG sudo "${_USER_NAME}" \
        && echo "${_USER_NAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${_USER_NAME}" \
        && chmod 0440 "/etc/sudoers.d/${_USER_NAME}" \
    && su "${_USER_NAME}" \
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) '' --unattended" > /dev/null \
    && bash /tmp/zsh-plugins.sh "${_HOME}" "zsh-autosuggestions" "zsh-syntax-highlighting" && rm /tmp/zsh-plugins.sh \
    # && curl -sS https://starship.rs/install.sh | sh -s -- --force \
    #     && echo 'eval $(starship init zsh)' >> "${_HOME}/.zshrc" \
    && chown -R "${_USER_NAME}:${_USER_NAME}" "${_HOME}"

USER "${_USER_NAME}"

WORKDIR "${_HOME}"

ENTRYPOINT [ "zsh" ]
