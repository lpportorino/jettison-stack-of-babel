# Clang/LLVM Container - C/C++ development tools
ARG BASE_IMAGE=ghcr.io/lpportorino/jon-babylon-base:latest
FROM ${BASE_IMAGE}

# Switch to root for installation
USER root

# Install LLVM/Clang and build tools
COPY dockerfiles/clang/tools /tmp/tools

RUN chmod +x /tmp/tools/**/*.sh && \
    /tmp/tools/clang/install.sh && \
    rm -rf /tmp/tools

# Install additional C/C++ development tools
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        cmake \
        ninja-build \
        ccache \
        valgrind \
        gdb \
        cppcheck && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install ARM64 cross-compilation dependencies
# Required for cross-compiling C projects like lighthouse to ARM64
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    dpkg --add-architecture arm64 && \
    # Configure apt to use ports.ubuntu.com for arm64 packages
    sed -i 's|^deb \([a-z]* \)\?http://archive.ubuntu.com/ubuntu|deb [arch=amd64] \1http://archive.ubuntu.com/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|^deb \([a-z]* \)\?http://security.ubuntu.com/ubuntu|deb [arch=amd64] \1http://security.ubuntu.com/ubuntu|g' /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports jammy main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports jammy-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        crossbuild-essential-arm64 \
        libc6-dev:arm64 \
        libglib2.0-dev:arm64 \
        libpq-dev:arm64 \
        pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build hiredis from source for ARM64 cross-compilation
# This gives us optimized ARM64 libraries with Cortex-A78AE tuning
COPY dockerfiles/clang/tools/hiredis /tmp/tools/hiredis
RUN chmod +x /tmp/tools/hiredis/*.sh && \
    /tmp/tools/hiredis/install.sh && \
    rm -rf /tmp/tools/hiredis

# Setup environment
ENV CC=clang
ENV CXX=clang++
ENV PATH="/usr/lib/llvm-21/bin:${PATH}"

# Configure pkg-config for ARM64 cross-compilation
# This allows pkg-config to find ARM64 libraries when cross-compiling
ENV PKG_CONFIG_PATH="/usr/lib/aarch64-linux-gnu/pkgconfig"
ENV PKG_CONFIG_LIBDIR="/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig"

# Create symlinks for common names
RUN ln -sf /usr/lib/llvm-21/bin/clang /usr/local/bin/clang && \
    ln -sf /usr/lib/llvm-21/bin/clang++ /usr/local/bin/clang++ && \
    ln -sf /usr/lib/llvm-21/bin/clang-format /usr/local/bin/clang-format && \
    ln -sf /usr/lib/llvm-21/bin/clang-tidy /usr/local/bin/clang-tidy && \
    ln -sf /usr/lib/llvm-21/bin/lld /usr/local/bin/lld

# Switch back to developer
USER developer
WORKDIR /workspace

# Verify installations
RUN clang --version && \
    clang++ --version && \
    clang-format --version && \
    clang-tidy --version && \
    cmake --version

CMD ["/bin/bash"]