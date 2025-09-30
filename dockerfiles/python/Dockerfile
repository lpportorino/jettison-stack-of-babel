# Python Container - Python development with Nuitka
# Builds on Clang container for Nuitka compilation support
ARG CLANG_IMAGE=ghcr.io/lpportorino/jon-babylon-clang:latest
FROM ${CLANG_IMAGE}

# Switch to root for installation
USER root

# Install patchelf and newer binutils for Nuitka standalone builds
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        patchelf \
        binutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python via pyenv
COPY dockerfiles/python/tools /tmp/tools

RUN chmod +x /tmp/tools/**/*.sh && \
    /tmp/tools/python/install.sh && \
    rm -rf /tmp/tools

# Setup environment
ENV PYENV_ROOT="/opt/pyenv"
ENV PATH="/opt/pyenv/bin:/opt/pyenv/shims:${PATH}"
ENV NUITKA_CACHE_DIR="/opt/nuitka-cache"
# Add Python shared library to LD_LIBRARY_PATH for Nuitka
ENV LD_LIBRARY_PATH="/opt/pyenv/versions/3.13.7/lib:${LD_LIBRARY_PATH}"

# Create symlinks for system-wide access
RUN ln -sf /opt/pyenv/versions/3.13.7/bin/python3 /usr/local/bin/python3 && \
    ln -sf /opt/pyenv/versions/3.13.7/bin/python3 /usr/local/bin/python && \
    ln -sf /opt/pyenv/versions/3.13.7/bin/pip3 /usr/local/bin/pip3 && \
    ln -sf /opt/pyenv/versions/3.13.7/bin/pip3 /usr/local/bin/pip

# Install Python development tools
RUN pip install --no-cache-dir \
    nuitka==2.7.16 \
    black \
    flake8 \
    mypy \
    ruff \
    pytest \
    pytest-cov \
    pytest-xdist \
    ipython \
    jupyter \
    notebook \
    pandas \
    numpy \
    requests

# Fix permissions
RUN chown -R developer:developer /opt/pyenv 2>/dev/null || true && \
    chmod -R 755 /opt/pyenv 2>/dev/null || true && \
    mkdir -p /opt/nuitka-cache && \
    chown -R developer:developer /opt/nuitka-cache && \
    mkdir -p /opt/pyenv/shims && \
    chown -R developer:developer /opt/pyenv/shims && \
    chmod 755 /opt/pyenv/shims

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache && \
    find /opt/pyenv -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true && \
    find /opt/pyenv -type d -name test -exec rm -rf {} + 2>/dev/null || true && \
    find /opt/pyenv -type d -name tests -exec rm -rf {} + 2>/dev/null || true

# Switch back to developer
USER developer
WORKDIR /workspace

# Verify installations
RUN python --version && \
    pip --version && \
    python -m nuitka --version && \
    black --version && \
    flake8 --version && \
    mypy --version && \
    ruff --version

CMD ["/bin/bash"]