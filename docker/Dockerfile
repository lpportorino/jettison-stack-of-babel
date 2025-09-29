# Jon-Babylon - Universal Polyglot Development Image
# Optimized multi-stage build with proper layer caching

# ============================================================================
# Stage 1: Base System
# ============================================================================
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# System updates and essential tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl wget git vim nano \
        ca-certificates gnupg lsb-release \
        software-properties-common \
        locales tzdata sudo \
        build-essential make cmake pkg-config && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /workspace

# ============================================================================
# Stage 2: Development Libraries
# ============================================================================
FROM base AS libraries

# Development libraries needed by multiple tools
RUN apt-get update && apt-get install -y --no-install-recommends \
        libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev \
        libncurses5-dev libncursesw5-dev xz-utils tk-dev libxml2-dev \
        libxmlsec1-dev liblzma-dev zlib1g-dev \
        zip unzip p7zip-full \
        net-tools iputils-ping \
        rlwrap patchelf ccache && \
    rm -rf /var/lib/apt/lists/*

# ============================================================================
# Stage 3: JVM Ecosystem (Java, Kotlin, Clojure)
# ============================================================================
FROM libraries AS jvm-languages

# Copy installation scripts
COPY tools/java/install/install.sh /tmp/install-java.sh
COPY tools/kotlin/install/install.sh /tmp/install-kotlin.sh
COPY tools/clojure/install/install.sh /tmp/install-clojure.sh

# Install Java
RUN chmod +x /tmp/install-java.sh && \
    /tmp/install-java.sh && \
    rm /tmp/install-java.sh

# Install Kotlin
RUN chmod +x /tmp/install-kotlin.sh && \
    /tmp/install-kotlin.sh && \
    rm /tmp/install-kotlin.sh

# Install Clojure
RUN chmod +x /tmp/install-clojure.sh && \
    /tmp/install-clojure.sh && \
    rm /tmp/install-clojure.sh

# ============================================================================
# Stage 4: System Languages (C/C++, Python)
# ============================================================================
FROM jvm-languages AS system-languages

# Copy installation scripts
COPY tools/clang/install/install.sh /tmp/install-clang.sh
COPY tools/python/install/install.sh /tmp/install-python.sh
COPY tools/python/install/nuitka.sh /tmp/install-nuitka.sh

# Install LLVM/Clang
RUN chmod +x /tmp/install-clang.sh && \
    /tmp/install-clang.sh && \
    rm /tmp/install-clang.sh

# Install Python and Nuitka
RUN chmod +x /tmp/install-python.sh && \
    /tmp/install-python.sh && \
    rm /tmp/install-python.sh

RUN chmod +x /tmp/install-nuitka.sh && \
    /tmp/install-nuitka.sh && \
    rm /tmp/install-nuitka.sh

# ============================================================================
# Stage 5: Modern Languages (Rust, Node.js)
# ============================================================================
FROM system-languages AS modern-languages

# Copy installation scripts
COPY tools/rust/install/install.sh /tmp/install-rust.sh
COPY tools/nodejs/install/install.sh /tmp/install-nodejs.sh

# Install Rust
RUN chmod +x /tmp/install-rust.sh && \
    /tmp/install-rust.sh && \
    rm /tmp/install-rust.sh

# Install Node.js
RUN chmod +x /tmp/install-nodejs.sh && \
    /tmp/install-nodejs.sh && \
    rm /tmp/install-nodejs.sh

# ============================================================================
# Stage 6: Build Tools
# ============================================================================
FROM modern-languages AS build-tools

# Copy installation scripts
COPY tools/build-tools/maven/install/install.sh /tmp/install-maven.sh
COPY tools/build-tools/gradle/install/install.sh /tmp/install-gradle.sh

# Install Maven
RUN chmod +x /tmp/install-maven.sh && \
    /tmp/install-maven.sh && \
    rm /tmp/install-maven.sh

# Install Gradle
RUN chmod +x /tmp/install-gradle.sh && \
    /tmp/install-gradle.sh && \
    rm /tmp/install-gradle.sh

# ============================================================================
# Stage 7: JavaScript/Web Tools
# ============================================================================
FROM build-tools AS web-tools

# Copy installation scripts
COPY tools/typescript/install/install.sh /tmp/install-typescript.sh
COPY tools/web-tools/install/install.sh /tmp/install-web-tools.sh
COPY tools/package-managers/install/install.sh /tmp/install-package-managers.sh

# Install TypeScript
RUN chmod +x /tmp/install-typescript.sh && \
    /tmp/install-typescript.sh && \
    rm /tmp/install-typescript.sh

# Install Web Tools
RUN chmod +x /tmp/install-web-tools.sh && \
    /tmp/install-web-tools.sh && \
    rm /tmp/install-web-tools.sh

# Install Package Managers
RUN chmod +x /tmp/install-package-managers.sh && \
    /tmp/install-package-managers.sh && \
    rm /tmp/install-package-managers.sh

# ============================================================================
# Stage 8: Testing & Validation
# ============================================================================
FROM web-tools AS testing

# Copy all test files
COPY tools/*/test /opt/tests/
COPY scripts/check_versions.sh /scripts/

# Make scripts executable
RUN chmod +x /scripts/check_versions.sh && \
    find /opt/tests -name "*.sh" -exec chmod +x {} \;

# Run version checks
RUN /scripts/check_versions.sh

# ============================================================================
# Stage 9: Final Image
# ============================================================================
FROM testing AS final

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /opt -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true && \
    find /opt -name "*.pyc" -delete 2>/dev/null || true

# Create non-root user
RUN useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up workspace
WORKDIR /workspace
RUN chown developer:developer /workspace

# Labels
LABEL maintainer="Jettison Team"
LABEL description="Jon-Babylon: Universal polyglot development environment"
LABEL version="2025.01"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD java -version && python3 --version && node --version && rustc --version

# Default user and command
USER developer
CMD ["/bin/bash"]