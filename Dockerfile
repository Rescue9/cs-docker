FROM lscr.io/linuxserver/code-server:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
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
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN usermod -u 1000 abc && groupmod -g 1000 abc

# Store repo-managed defaults here (safe from volume overrides)
#COPY ./files/ /defaults/

# Add init script
#COPY ./init-config.sh /usr/local/bin/init-config.sh
#RUN chmod +x /usr/local/bin/init-config.sh

# Hook into container startup
#ENTRYPOINT ["/usr/local/bin/init-config.sh"]

# Fall back to original entrypoint behavior
#CMD ["/init"]

USER abc