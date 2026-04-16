FROM lscr.io/linuxserver/code-server:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# BUILD VERSION (change this to force rebuild)
# =========================
RUN echo "BUILD VERSION 1.0.2 - $(date)" > /BUILD_VERSION

RUN apt-get update && \
    apt-get install -y \
        unzip wget zip lsof xz-utils pkg-config \
        build-essential clang lld cmake ninja-build \
        libgtk-3-dev mesa-utils git ca-certificates \
        rsync openjdk-21-jdk jq parallel curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Extension cache directory (offline reuse)
ENV EXT_CACHE=/config/.extension-cache
RUN mkdir -p /config/.extension-cache

RUN rm -rf /defaults/*
COPY ./files/ /defaults/
COPY ./init-config.sh /usr/local/bin/init-config.sh
RUN chmod +x /usr/local/bin/init-config.sh

RUN echo "===== SEARCHING FOR extensions.txt - $(date) =====" | tee /EXTENSIONS_INFO && \
    find / -name "extensions.txt" 2>&1 | tee -a /EXTENSIONS_INFO || true

ENTRYPOINT ["/usr/local/bin/init-config.sh"]
CMD ["/init"]