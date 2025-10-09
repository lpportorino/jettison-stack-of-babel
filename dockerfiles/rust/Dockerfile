# Rust Container - Rust development tools
# Builds on Clang container for C/C++ FFI support
ARG CLANG_IMAGE=ghcr.io/lpportorino/jon-babylon-clang:latest
FROM ${CLANG_IMAGE}

# Switch to root for installation
USER root

# Install Rust via rustup
COPY dockerfiles/rust/tools /tmp/tools

RUN chmod +x /tmp/tools/**/*.sh && \
    /tmp/tools/rust/install.sh && \
    rm -rf /tmp/tools

# Setup environment
ENV CARGO_HOME="/opt/cargo"
ENV RUSTUP_HOME="/opt/rustup"
ENV PATH="/opt/cargo/bin:${PATH}"

# Create symlinks for system-wide access
RUN ln -sf /opt/cargo/bin/rustc /usr/local/bin/rustc && \
    ln -sf /opt/cargo/bin/cargo /usr/local/bin/cargo && \
    ln -sf /opt/cargo/bin/rustup /usr/local/bin/rustup && \
    ln -sf /opt/cargo/bin/rustfmt /usr/local/bin/rustfmt && \
    ln -sf /opt/cargo/bin/cargo-clippy /usr/local/bin/cargo-clippy

# Install additional Rust tools and clean up after each to save space
RUN export CARGO_HOME=/opt/cargo && \
    export RUSTUP_HOME=/opt/rustup && \
    /opt/cargo/bin/rustup default stable && \
    # Install cargo-audit
    /opt/cargo/bin/cargo install cargo-audit && \
    rm -rf /opt/cargo/registry/cache/* /opt/cargo/registry/src/* && \
    # Install cargo-outdated
    /opt/cargo/bin/cargo install cargo-outdated && \
    rm -rf /opt/cargo/registry/cache/* /opt/cargo/registry/src/* && \
    # Install cargo-edit
    /opt/cargo/bin/cargo install cargo-edit && \
    rm -rf /opt/cargo/registry/cache/* /opt/cargo/registry/src/* && \
    # Install cargo-watch
    /opt/cargo/bin/cargo install cargo-watch && \
    rm -rf /opt/cargo/registry/cache/* /opt/cargo/registry/src/*

# Aggressive cleanup and fix permissions
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache && \
    rm -rf /opt/cargo/registry/cache && \
    rm -rf /opt/cargo/registry/src && \
    rm -rf /opt/cargo/git/checkouts && \
    rm -rf /opt/cargo/git/db && \
    # Remove rustup docs and other unnecessary files
    rm -rf /opt/rustup/toolchains/*/share/doc && \
    rm -rf /opt/rustup/toolchains/*/share/man && \
    # Recreate necessary directories
    mkdir -p /opt/cargo/registry/cache /opt/cargo/git/checkouts && \
    # Fix permissions for all users
    chown -R developer:developer /opt/cargo /opt/rustup 2>/dev/null || true && \
    chmod -R 777 /opt/cargo /opt/rustup 2>/dev/null || true

# Switch back to developer
USER developer
WORKDIR /workspace

# Verify installations
RUN rustc --version && \
    cargo --version && \
    rustfmt --version && \
    cargo clippy --version

CMD ["/bin/bash"]