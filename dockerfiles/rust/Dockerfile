# Rust Container - Rust development tools
FROM ghcr.io/lpportorino/jon-babylon-base:latest

# Switch to root for installation
USER root

# Install Rust via rustup
COPY tools/rust/install.sh /tmp/install-rust.sh

RUN chmod +x /tmp/install-rust.sh && \
    /tmp/install-rust.sh && \
    rm -f /tmp/install-rust.sh

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

# Install additional Rust tools
RUN export CARGO_HOME=/opt/cargo && \
    export RUSTUP_HOME=/opt/rustup && \
    /opt/cargo/bin/rustup default stable && \
    /opt/cargo/bin/cargo install cargo-audit && \
    /opt/cargo/bin/cargo install cargo-outdated && \
    /opt/cargo/bin/cargo install cargo-edit && \
    /opt/cargo/bin/cargo install cargo-watch

# Fix permissions
RUN chown -R developer:developer /opt/cargo /opt/rustup 2>/dev/null || true && \
    chmod -R 755 /opt/cargo /opt/rustup 2>/dev/null || true

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache && \
    rm -rf /opt/cargo/registry/cache && \
    rm -rf /opt/cargo/git/checkouts

# Switch back to developer
USER developer
WORKDIR /workspace

# Verify installations
RUN rustc --version && \
    cargo --version && \
    rustfmt --version && \
    cargo clippy --version

CMD ["/bin/bash"]