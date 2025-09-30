# Base image for all Jon-Babylon containers
# Provides common system tools and developer user setup

FROM ubuntu:22.04

# Set environment for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install common system dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        wget \
        sudo \
        locales \
        git \
        unzip \
        xz-utils \
        build-essential \
        pkg-config \
        libssl-dev \
        vim \
        nano \
        less \
        tree \
        htop && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create developer user with sudo access
RUN useradd -m -s /bin/bash -u 1000 developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/developer/.local/bin && \
    chown -R developer:developer /home/developer

# Create workspace directory
RUN mkdir -p /workspace && \
    chown -R developer:developer /workspace && \
    chmod 755 /workspace

# Copy common scripts
COPY --chown=developer:developer scripts/run_test_wrapper.sh /usr/local/bin/run_test_wrapper.sh
RUN chmod +x /usr/local/bin/run_test_wrapper.sh

# Set up basic environment
ENV PATH="/home/developer/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
ENV USER=developer

# Switch to developer user
USER developer
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]