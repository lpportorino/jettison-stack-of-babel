# Stage 01: Build Essentials
# Development libraries and build tools
ARG BASE_IMAGE=jon-babylon:00-base
FROM ${BASE_IMAGE}

LABEL stage="01-build-essentials"
LABEL description="Build essentials and development libraries"

# Install build essentials and development libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        make \
        cmake \
        pkg-config \
        automake \
        autoconf \
        libtool \
        m4 \
        gcc \
        g++ \
        gdb \
        vim \
        nano \
        && \
    apt-get install -y --no-install-recommends \
        libssl-dev \
        libffi-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        liblzma-dev \
        zlib1g-dev \
        libgdbm-dev \
        libnss3-dev \
        && \
    apt-get install -y --no-install-recommends \
        zip \
        unzip \
        p7zip-full \
        net-tools \
        iputils-ping \
        rlwrap \
        patchelf \
        ccache \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Verify installation
RUN gcc --version && \
    g++ --version && \
    make --version

HEALTHCHECK --interval=30s --timeout=3s \
    CMD gcc --version && make --version

CMD ["/bin/bash"]