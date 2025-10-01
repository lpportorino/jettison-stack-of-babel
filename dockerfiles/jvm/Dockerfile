# JVM Container - Java, Kotlin, Clojure, and build tools
ARG BASE_IMAGE=ghcr.io/lpportorino/jon-babylon-base:latest
FROM ${BASE_IMAGE}

# Switch to root for installation
USER root

# Install SDKMAN and JVM tools
COPY dockerfiles/jvm/tools /tmp/tools

RUN chmod +x /tmp/tools/*.sh /tmp/tools/**/*.sh && \
    /tmp/tools/sdkman.sh && \
    /tmp/tools/clojure/install.sh && \
    rm -rf /tmp/tools

# Setup environment variables
ENV SDKMAN_DIR="/opt/sdkman"
ENV JAVA_HOME="/opt/sdkman/candidates/java/current"
ENV MAVEN_HOME="/opt/sdkman/candidates/maven/current"
ENV GRADLE_HOME="/opt/sdkman/candidates/gradle/current"
ENV PATH="/opt/sdkman/candidates/java/current/bin:/opt/sdkman/candidates/kotlin/current/bin:/opt/sdkman/candidates/maven/current/bin:/opt/sdkman/candidates/gradle/current/bin:/opt/sdkman/candidates/leiningen/current/bin:${PATH}"

# Create symlinks for system-wide access
RUN ln -sf /opt/sdkman/candidates/java/current/bin/java /usr/local/bin/java && \
    ln -sf /opt/sdkman/candidates/java/current/bin/javac /usr/local/bin/javac && \
    ln -sf /opt/sdkman/candidates/kotlin/current/bin/kotlin /usr/local/bin/kotlin && \
    ln -sf /opt/sdkman/candidates/kotlin/current/bin/kotlinc /usr/local/bin/kotlinc && \
    ln -sf /opt/sdkman/candidates/maven/current/bin/mvn /usr/local/bin/mvn && \
    ln -sf /opt/sdkman/candidates/gradle/current/bin/gradle /usr/local/bin/gradle && \
    ln -sf /opt/sdkman/candidates/leiningen/current/bin/lein /usr/local/bin/lein

# Install Kotlin tools (ktlint, detekt)
RUN mkdir -p /opt/kotlin-tools && \
    curl -sSLO https://github.com/pinterest/ktlint/releases/download/1.7.1/ktlint && \
    chmod +x ktlint && \
    mv ktlint /opt/kotlin-tools/ && \
    ln -sf /opt/kotlin-tools/ktlint /usr/local/bin/ktlint && \
    curl -sSL https://github.com/detekt/detekt/releases/download/v1.23.8/detekt-cli-1.23.8.zip -o detekt.zip && \
    unzip -q detekt.zip -d /opt/kotlin-tools/detekt && \
    rm detekt.zip && \
    ln -sf /opt/kotlin-tools/detekt/bin/detekt-cli /usr/local/bin/detekt && \
    chmod +x /opt/kotlin-tools/detekt/bin/detekt-cli

# Fix permissions for any user
RUN chmod -R 755 /opt/sdkman /opt/clojure /opt/kotlin-tools 2>/dev/null || true && \
    # Make SDKMAN directories writable for any user
    mkdir -p /opt/sdkman/tmp && chmod 777 /opt/sdkman/tmp && \
    mkdir -p /opt/sdkman/archives && chmod 777 /opt/sdkman/archives && \
    mkdir -p /opt/sdkman/candidates && chmod -R 755 /opt/sdkman/candidates

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache && \
    find /opt -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

# Copy version check script
COPY --chown=developer:developer dockerfiles/jvm/check_versions.sh /usr/local/bin/check_versions.sh
RUN chmod +x /usr/local/bin/check_versions.sh

# Switch back to developer
USER developer
WORKDIR /workspace

# Verify installations
RUN java --version && \
    kotlin -version && \
    clojure --version && \
    mvn --version && \
    gradle --version && \
    lein version && \
    ktlint --version && \
    detekt --version

CMD ["/bin/bash"]