# Clang/LLVM Container - C/C++ development tools
FROM ghcr.io/lpportorino/jon-babylon-base:latest

# Switch to root for installation
USER root

# Install LLVM/Clang and build tools
COPY tools/clang/install.sh /tmp/install-clang.sh

RUN chmod +x /tmp/install-clang.sh && \
    /tmp/install-clang.sh && \
    rm -f /tmp/install-clang.sh

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

# Setup environment
ENV CC=clang
ENV CXX=clang++
ENV PATH="/usr/lib/llvm-21/bin:${PATH}"

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