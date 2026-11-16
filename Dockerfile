FROM lscr.io/linuxserver/code-server:latest

USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_VERSION=1.1.0

# Build identification
RUN printf 'BUILD VERSION %s\nBUILD DATE %s\n' \
    "${BUILD_VERSION}" "$(date -u '+%Y-%m-%d %H:%M:%S UTC')" \
    > /BUILD_VERSION

# Essential development dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unzip \
        wget \
        zip \
        lsof \
        xz-utils \
        pkg-config \
        build-essential \
        clang \
        lld \
        cmake \
        ninja-build \
        libgtk-3-dev \
        mesa-utils \
        git \
        ca-certificates \
        rsync \
        jq \
        parallel \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Persistent SDK locations
ENV SDK_ROOT=/config/sdks

ENV ANDROID_HOME=/config/sdks/android
ENV ANDROID_SDK_ROOT=/config/sdks/android

ENV FLUTTER_HOME=/config/sdks/flutter

ENV JAVA_HOME=/config/sdks/java/current

# Persistent development caches
ENV GRADLE_USER_HOME=/config/.gradle
ENV PUB_CACHE=/config/.pub-cache
ENV ANDROID_USER_HOME=/config/.android

# Persistent extension cache
ENV EXT_CACHE=/config/.extension-cache

# Development PATH
ENV PATH="${PATH}:/config/sdks/flutter/bin:/config/sdks/android/platform-tools:/config/sdks/android/cmdline-tools/latest/bin:/config/sdks/java/current/bin"

# Inherit LinuxServer's native ENTRYPOINT and CMD.
# No custom initialization scripts.