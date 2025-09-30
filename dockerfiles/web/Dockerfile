# Web Container - Node.js, TypeScript, Bun, and web development tools
ARG BASE_IMAGE=ghcr.io/lpportorino/jon-babylon-base:latest
FROM ${BASE_IMAGE}

# Switch to root for installation
USER root

# Install Node.js, Bun, and web tools
COPY dockerfiles/web/tools /tmp/tools

RUN chmod +x /tmp/tools/**/*.sh && \
    /tmp/tools/nodejs/install.sh && \
    /tmp/tools/bun/install.sh && \
    /tmp/tools/package-managers/install.sh && \
    /tmp/tools/web-tools/install.sh && \
    /tmp/tools/typescript/install.sh && \
    rm -rf /tmp/tools

# Setup environment
ENV BUN_INSTALL="/opt/bun"
ENV PATH="/opt/bun/bin:/usr/local/lib/node_modules/.bin:${PATH}"

# Create symlinks for Bun
RUN ln -sf /opt/bun/bin/bun /usr/local/bin/bun && \
    ln -sf /opt/bun/bin/bunx /usr/local/bin/bunx

# Install additional web development tools globally
RUN npm install -g \
    vite \
    @vitejs/plugin-react \
    @vitejs/plugin-vue \
    webpack \
    webpack-cli \
    parcel \
    rollup \
    turbo \
    nx \
    lerna \
    @angular/cli \
    @vue/cli \
    create-react-app \
    create-next-app \
    @nestjs/cli \
    express-generator \
    nodemon \
    pm2 \
    concurrently \
    serve \
    http-server

# Enable corepack for yarn and pnpm
RUN corepack enable && \
    corepack prepare yarn@stable --activate && \
    corepack prepare pnpm@latest --activate

# Fix permissions
RUN chown -R developer:developer /opt/bun 2>/dev/null || true && \
    chmod -R 755 /opt/bun 2>/dev/null || true

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache && \
    npm cache clean --force

# Switch back to developer
USER developer
WORKDIR /workspace

# Verify installations
RUN node --version && \
    npm --version && \
    yarn --version && \
    pnpm --version && \
    bun --version && \
    tsc --version && \
    esbuild --version && \
    prettier --version && \
    eslint --version

CMD ["/bin/bash"]