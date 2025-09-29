# Stage 08: Node.js
ARG BASE_IMAGE=jon-babylon:07-rust
FROM ${BASE_IMAGE}

LABEL stage="08-nodejs"
LABEL description="Node.js 22 LTS and npm"

# Copy and run installation script
COPY tools/nodejs/install/install.sh /tmp/install-nodejs.sh
RUN chmod +x /tmp/install-nodejs.sh && \
    /tmp/install-nodejs.sh && \
    rm /tmp/install-nodejs.sh

# Test Node.js
RUN echo 'console.log("Hello from Node.js!");' > /tmp/test.js && \
    node /tmp/test.js && \
    rm /tmp/test.js

# Test npm
RUN npm --version && \
    npm init -y --prefix /tmp/test && \
    rm -rf /tmp/test

HEALTHCHECK --interval=30s --timeout=3s \
    CMD node --version && npm --version

CMD ["/bin/bash"]