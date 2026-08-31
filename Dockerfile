FROM lscr.io/linuxserver/code-server:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# BUILD VERSION (change this to force rebuild)
# =========================
RUN echo "BUILD VERSION 2.0. - AI Enhanced - $(date)" > /BUILD_VERSION

RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://mirrors.krnk.org/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|https://archive.ubuntu.com/ubuntu|https://mirrors.krnk.org/ubuntu|g' /etc/apt/sources.list
RUN echo "Updated /etc/apt/sources.list to use a static KRNK mirror."

# Added pipx, python3, and python3-venv for AI CLIs like Aider
RUN apt-get update && \
    apt-get install -y \
        unzip wget zip lsof xz-utils pkg-config \
        build-essential clang lld cmake ninja-build \
        libgtk-3-dev mesa-utils git ca-certificates \
        rsync openjdk-21-jdk jq parallel curl \
        python3 python3-pip python3-venv pipx \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Install Aider (CLI AI coding assistant) globally via pipx
ENV PIPX_HOME=/usr/local/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN pipx install aider-chat

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