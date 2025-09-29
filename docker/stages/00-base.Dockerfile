# Stage 00: Base System
# Foundation layer with Ubuntu 22.04 and essential system tools
FROM ubuntu:22.04

LABEL stage="00-base"
LABEL description="Base Ubuntu system with essential tools"
LABEL version="2025.01"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# System updates and absolute essentials
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        git \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
        apt-transport-https \
        locales \
        tzdata \
        sudo \
        && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create workspace
WORKDIR /workspace

# Create non-root user (will be used in final stage)
RUN useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD echo "Base system ready"

CMD ["/bin/bash"]