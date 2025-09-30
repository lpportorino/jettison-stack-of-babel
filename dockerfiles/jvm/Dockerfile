# JVM Container - Java, Kotlin, Clojure, and build tools
FROM ghcr.io/lpportorino/jon-babylon-base:latest

# Switch to root for installation
USER root

# Install SDKMAN and JVM tools
COPY tools/java/install.sh /tmp/install-java.sh
COPY tools/kotlin/install.sh /tmp/install-kotlin.sh
COPY tools/clojure/install.sh /tmp/install-clojure.sh

RUN chmod +x /tmp/install-*.sh && \
    /tmp/install-java.sh && \
    /tmp/install-kotlin.sh && \
    /tmp/install-clojure.sh && \
    rm -f /tmp/install-*.sh

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

# Fix permissions
RUN chown -R developer:developer /opt/sdkman 2>/dev/null || true && \
    chmod -R 755 /opt/sdkman 2>/dev/null || true

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache && \
    find /opt -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

# Switch back to developer
USER developer
WORKDIR /workspace

# Verify installations
RUN java --version && \
    kotlin -version && \
    clojure --version && \
    mvn --version && \
    gradle --version && \
    lein version

CMD ["/bin/bash"]