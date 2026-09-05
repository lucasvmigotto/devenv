# syntax=docker/dockerfile:1

ARG _VERSION="3.47.0"
ARG _JAVA_VERSION="25"
ARG _DISTRO_NAME="debian"
ARG _DISTRO_VERSION="trixie"
ARG _BASE_IMAGE="ghcr.io/lucasvmigotto/devenv:${_DISTRO_NAME}-${_DISTRO_VERSION}"

# --- Flutter SDK (tarball) ---
FROM alpine/curl:8.17.0 AS flutter

ARG _VERSION
ARG _FLUTTER_STORAGE="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux"

ENV _FLUTTER_TAR="flutter_linux_${_VERSION}-stable.tar.xz"

RUN curl -sfo "${_FLUTTER_TAR}" "${_FLUTTER_STORAGE}/${_FLUTTER_TAR}" \
    && mkdir /flutter \
    && tar -xf "${_FLUTTER_TAR}" -C /flutter

# --- JDK ---
FROM eclipse-temurin:${_JAVA_VERSION}-jdk AS jdk

# --- Android commandline-tools (sdkmanager) ---
FROM alpine/curl:8.17.0 AS android-sdk

ARG _ANDROID_SDK_TOOLS_VERSION="11076708"
ARG _ANDROID_SDK_ROOT="/opt/android-sdk"

RUN apk add --no-cache unzip \
    && mkdir -p "${_ANDROID_SDK_ROOT}/cmdline-tools" \
    && curl -fsSLo /tmp/cmdline-tools.zip \
        "https://dl.google.com/android/repository/commandlinetools-linux-${_ANDROID_SDK_TOOLS_VERSION}_latest.zip" \
    && unzip -q /tmp/cmdline-tools.zip -d "${_ANDROID_SDK_ROOT}/cmdline-tools" \
    && mv "${_ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" "${_ANDROID_SDK_ROOT}/cmdline-tools/latest" \
    && rm -f /tmp/cmdline-tools.zip

# --- final (dottod base) ---
FROM ${_BASE_IMAGE}

USER root

ARG _VERSION
ARG _JAVA_VERSION
ARG _DISTRO_NAME
ARG _DISTRO_VERSION
ARG _USERNAME="developer"
ARG _HOME="/home/${_USERNAME}"

ARG _JAVA_HOME="/opt/java/openjdk"
ARG _FLUTTER_HOME="/opt/flutter"
ARG _ANDROID_SDK_ROOT="/opt/android-sdk"
ARG _ANDROID_PLATFORM="36"
ARG _ANDROID_BUILD_TOOLS="${_ANDROID_PLATFORM}"
ARG _NDK_VERSION=""

ARG _PUB_CACHE="${_HOME}/.pub-cache"
ARG _GRADLE_HOME="${_HOME}/.gradle"
ARG _ANDROID_HOME="${_HOME}/.android"

COPY --from=jdk "${_JAVA_HOME}" "${_JAVA_HOME}"
ENV JAVA_HOME="${_JAVA_HOME}"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

COPY --from=flutter /flutter/ "${_FLUTTER_HOME}"
ENV FLUTTER_ROOT="${_FLUTTER_HOME}"
ENV PATH="${FLUTTER_ROOT}/bin:${PATH}"

COPY --from=android-sdk "${_ANDROID_SDK_ROOT}" "${_ANDROID_SDK_ROOT}"
ENV ANDROID_SDK_ROOT="${_ANDROID_SDK_ROOT}"
ENV ANDROID_HOME="${_ANDROID_SDK_ROOT}"
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

COPY bin/pkg.sh /opt/devenv/bin/pkg.sh

RUN export _DISTRO="${_DISTRO_NAME}" && . /opt/devenv/bin/pkg.sh \
    && pkg_update \
    && pkg_install git unzip xz-utils libglu1-mesa libstdc++6 \
    && pkg_clean \
    && yes | sdkmanager --licenses > /dev/null \
    && sdkmanager "platform-tools" \
        ${_NDK_VERSION:+"ndk;${_NDK_VERSION}"} \
        $(for _p in $(echo "${_ANDROID_PLATFORM}" | tr ";" "\n"); do echo "platforms;android-${_p}"; done) \
        $(for _v in $(echo "${_ANDROID_BUILD_TOOLS}" | tr ";" "\n"); do echo "build-tools;${_v}.0.0"; done) > /dev/null \
    && flutter precache --android > /dev/null \
    && mkdir -p "${_PUB_CACHE}" "${_GRADLE_HOME}" "${_ANDROID_HOME}" \
    && chown -R "${_USERNAME}:${_USERNAME}" \
        "${_PUB_CACHE}" "${_GRADLE_HOME}" "${_ANDROID_HOME}" \
        "${_FLUTTER_HOME}" "${_ANDROID_SDK_ROOT}"

USER "${_USERNAME}"
WORKDIR "${_HOME}"

RUN flutter config --no-analytics > /dev/null

VOLUME [ "${_PUB_CACHE}", "${_GRADLE_HOME}", "${_ANDROID_HOME}" ]
