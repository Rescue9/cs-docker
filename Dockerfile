FROM lscr.io/linuxserver/code-server:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# System dependencies
# =========================
RUN apt-get update && \
    apt-get install -y \
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
        runuser \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# =========================
# User setup
# =========================
RUN usermod -u 1000 abc && groupmod -g 1000 abc

# =========================
# Java (Temurin via apt)
# =========================
RUN apt-get update && \
    apt-get install -y openjdk-21-jdk && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# =========================
# Android SDK (cmdline tools)
# =========================
ENV ANDROID_HOME=/config/sdks/android
ENV ANDROID_SDK_ROOT=/config/sdks/android

RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/tools.zip && \
    unzip /tmp/tools.zip -d $ANDROID_HOME/cmdline-tools && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm /tmp/tools.zip

RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0"

# =========================
# Flutter SDK
# =========================
ENV FLUTTER_HOME=/config/sdks/flutter

RUN mkdir -p /config/sdks && \
    git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# =========================
# PATH
# =========================
ENV PATH=$PATH:/config/bin:$FLUTTER_HOME/bin:$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# =========================
# Defaults + entrypoint
# =========================
COPY ./files/ /defaults/

COPY ./init-config.sh /usr/local/bin/init-config.sh
RUN chmod +x /usr/local/bin/init-config.sh

ENTRYPOINT ["/usr/local/bin/init-config.sh"]
CMD ["/init"]