# Stage 02: Java (OpenJDK 21 LTS)
ARG BASE_IMAGE=jon-babylon:01-build-essentials
FROM ${BASE_IMAGE}

LABEL stage="02-java"
LABEL description="OpenJDK 21 LTS (Eclipse Temurin)"

# Copy and run installation script
COPY tools/java/install/install.sh /tmp/install-java.sh
RUN chmod +x /tmp/install-java.sh && \
    /tmp/install-java.sh && \
    rm /tmp/install-java.sh

# Copy test files
COPY tools/java/test /opt/tests/java

# Run validation
COPY tools/java/install/verify.sh /tmp/verify-java.sh
RUN chmod +x /tmp/verify-java.sh && \
    /tmp/verify-java.sh && \
    rm /tmp/verify-java.sh

# Test compilation
RUN cd /opt/tests/java && \
    javac HelloWorld.java && \
    java HelloWorld && \
    rm HelloWorld.class

HEALTHCHECK --interval=30s --timeout=3s \
    CMD java -version

CMD ["/bin/bash"]