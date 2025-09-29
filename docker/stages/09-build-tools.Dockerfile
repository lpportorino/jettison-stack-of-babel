# Stage 09: Build Tools (Maven, Gradle)
ARG BASE_IMAGE=jon-babylon:08-nodejs
FROM ${BASE_IMAGE}

LABEL stage="09-build-tools"
LABEL description="Maven and Gradle build tools"

# Install Maven
COPY tools/build-tools/maven/install/install.sh /tmp/install-maven.sh
RUN chmod +x /tmp/install-maven.sh && \
    /tmp/install-maven.sh && \
    rm /tmp/install-maven.sh

# Install Gradle
COPY tools/build-tools/gradle/install/install.sh /tmp/install-gradle.sh
RUN chmod +x /tmp/install-gradle.sh && \
    /tmp/install-gradle.sh && \
    rm /tmp/install-gradle.sh

# Test Maven
RUN mvn --version

# Test Gradle
RUN gradle --version

HEALTHCHECK --interval=30s --timeout=3s \
    CMD mvn --version && gradle --version

CMD ["/bin/bash"]