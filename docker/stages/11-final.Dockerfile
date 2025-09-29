# Stage 11: Final Assembly
ARG BASE_IMAGE=jon-babylon:10-web-tools
FROM ${BASE_IMAGE}

LABEL stage="11-final"
LABEL description="Final jon-babylon image with all tools"
LABEL maintainer="Jettison Team"
LABEL version="2025.01"

# Copy all test projects
COPY tests /opt/tests
COPY scripts/check_versions.sh /scripts/

# Make scripts executable
RUN chmod +x /scripts/check_versions.sh && \
    find /opt/tests -name "*.sh" -exec chmod +x {} \;

# Run comprehensive version check
RUN /scripts/check_versions.sh

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /opt -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true && \
    find /opt -name "*.pyc" -delete 2>/dev/null || true

# Set up workspace permissions
RUN chown -R developer:developer /workspace

# Switch to non-root user
USER developer
WORKDIR /workspace

# Final health check - verify all major tools
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD java -version && \
        python3 --version && \
        node --version && \
        rustc --version && \
        clang --version

# Default command
CMD ["/bin/bash"]