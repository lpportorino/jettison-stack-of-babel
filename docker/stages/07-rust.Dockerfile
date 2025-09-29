# Stage 07: Rust
ARG BASE_IMAGE=jon-babylon:06-clang
FROM ${BASE_IMAGE}

LABEL stage="07-rust"
LABEL description="Rust via rustup"

# Copy and run installation script
COPY tools/rust/install/install.sh /tmp/install-rust.sh
RUN chmod +x /tmp/install-rust.sh && \
    /tmp/install-rust.sh && \
    rm /tmp/install-rust.sh

# Test Rust compilation
RUN echo 'fn main() { println!("Hello from Rust!"); }' > /tmp/test.rs && \
    rustc /tmp/test.rs -o /tmp/test && \
    /tmp/test && \
    rm /tmp/test.rs /tmp/test

# Test Cargo
RUN cargo new /tmp/test_project && \
    cd /tmp/test_project && \
    cargo build --release && \
    ./target/release/test_project && \
    cd / && \
    rm -rf /tmp/test_project

HEALTHCHECK --interval=30s --timeout=3s \
    CMD rustc --version && cargo --version

CMD ["/bin/bash"]