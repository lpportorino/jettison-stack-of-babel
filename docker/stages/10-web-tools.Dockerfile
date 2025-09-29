# Stage 10: Web Tools
ARG BASE_IMAGE=jon-babylon:09-build-tools
FROM ${BASE_IMAGE}

LABEL stage="10-web-tools"
LABEL description="TypeScript, ESLint, Prettier, esbuild, Bun, and web dev tools"

# Install TypeScript
COPY tools/typescript/install/install.sh /tmp/install-typescript.sh
RUN chmod +x /tmp/install-typescript.sh && \
    /tmp/install-typescript.sh && \
    rm /tmp/install-typescript.sh

# Install Web Tools (esbuild, prettier, eslint, etc.)
COPY tools/web-tools/install/install.sh /tmp/install-web-tools.sh
RUN chmod +x /tmp/install-web-tools.sh && \
    /tmp/install-web-tools.sh && \
    rm /tmp/install-web-tools.sh

# Install Package Managers (yarn, pnpm)
COPY tools/package-managers/install/install.sh /tmp/install-package-managers.sh
RUN chmod +x /tmp/install-package-managers.sh && \
    /tmp/install-package-managers.sh && \
    rm /tmp/install-package-managers.sh

# Test TypeScript
RUN echo 'const msg: string = "Hello from TypeScript!"; console.log(msg);' > /tmp/test.ts && \
    tsc /tmp/test.ts && \
    node /tmp/test.js && \
    rm /tmp/test.ts /tmp/test.js

# Test esbuild
RUN echo 'export const hello = () => console.log("Hello from esbuild!");' > /tmp/test.js && \
    esbuild /tmp/test.js --bundle --outfile=/tmp/out.js && \
    rm /tmp/test.js /tmp/out.js

# Test Bun
RUN bun --version

HEALTHCHECK --interval=30s --timeout=3s \
    CMD tsc --version && bun --version

CMD ["/bin/bash"]