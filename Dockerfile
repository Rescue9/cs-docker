FROM lscr.io/linuxserver/code-server:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# BUILD VERSION (change this to force rebuild)
# =========================
RUN echo "BUILD VERSION 4 - $(date)" > /BUILD_VERSION

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
        openjdk-21-jdk \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Java
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Copy defaults
COPY ./files/ /defaults/

# Entrypoint
COPY ./init-config.sh /usr/local/bin/init-config.sh
RUN chmod +x /usr/local/bin/init-config.sh

ENTRYPOINT ["/usr/local/bin/init-config.sh"]
CMD ["/init"]