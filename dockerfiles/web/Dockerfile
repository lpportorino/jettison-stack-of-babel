# Web Container - Node.js, TypeScript, Bun, and web development tools
FROM ghcr.io/lpportorino/jon-babylon-base:latest

# Switch to root for installation
USER root

# Install Node.js, Bun, and web tools
COPY tools/nodejs/install.sh /tmp/install-nodejs.sh
COPY tools/bun/install.sh /tmp/install-bun.sh
COPY tools/package-managers/install.sh /tmp/install-package-managers.sh
COPY tools/web-tools/install.sh /tmp/install-web-tools.sh
COPY tools/typescript/install.sh /tmp/install-typescript.sh

RUN chmod +x /tmp/install-*.sh && \
    /tmp/install-nodejs.sh && \
    /tmp/install-bun.sh && \
    /tmp/install-package-managers.sh && \
    /tmp/install-web-tools.sh && \
    /tmp/install-typescript.sh && \
    rm -f /tmp/install-*.sh

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