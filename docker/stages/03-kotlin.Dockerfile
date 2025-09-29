# Stage 03: Kotlin
ARG BASE_IMAGE=jon-babylon:02-java
FROM ${BASE_IMAGE}

LABEL stage="03-kotlin"
LABEL description="Kotlin language support via SDKMAN"

# Copy and run installation script
COPY tools/kotlin/install/install.sh /tmp/install-kotlin.sh
RUN chmod +x /tmp/install-kotlin.sh && \
    /tmp/install-kotlin.sh && \
    rm /tmp/install-kotlin.sh

# Test Kotlin installation
RUN echo 'fun main() { println("Hello from Kotlin!") }' > /tmp/test.kt && \
    kotlinc /tmp/test.kt -include-runtime -d /tmp/test.jar && \
    java -jar /tmp/test.jar && \
    rm /tmp/test.kt /tmp/test.jar

HEALTHCHECK --interval=30s --timeout=3s \
    CMD kotlin -version

CMD ["/bin/bash"]