# Base image for all Jon-Babylon containers
# Provides common system tools and developer user setup

FROM ubuntu:22.04

# Set environment for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Add Kitware repository for latest CMake
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget && \
    # Add Kitware GPG key
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | \
        gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    # Add Kitware repository
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main" | \
        tee /etc/apt/sources.list.d/kitware.list && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install system dependencies and development tools
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        # Base system tools
        curl \
        wget \
        sudo \
        locales \
        lsb-release \
        software-properties-common \
        # System utilities
        rsync \
        openssh-client \
        mosh \
        socat \
        git \
        nano \
        less \
        tree \
        tmux \
        htop \
        jq \
        bc \
        xxd \
        gawk \
        parallel \
        gdb \
        stow \
        # Compression tools
        unzip \
        zip \
        xz-utils \
        p7zip-full \
        # Build tools
        build-essential \
        make \
        pkg-config \
        autoconf \
        automake \
        libtool \
        libtool-bin \
        bison \
        flex \
        m4 \
        texinfo \
        ccache \
        patchelf \
        # CMake from Kitware
        cmake \
        cmake-curses-gui \
        cmake-extras \
        # Debugging tools
        valgrind \
        strace \
        sshpass \
        # Media tools
        ffmpeg \
        # Hardware interface tools
        can-utils \
        i2c-tools \
        minicom \
        # Database clients
        postgresql-client \
        redis-tools \
        # Development headers
        libssl-dev \
        libpq-dev \
        libczmq-dev \
        libnm-dev \
        uuid-dev \
        # Runtime libraries
        libssl3 \
        libpq5 \
        libczmq4 \
        libnm0 \
        libglib2.0-0 \
        libglib2.0-dev \
        libjson-glib-1.0-0 \
        libjson-glib-dev \
        libsoup-3.0-0 \
        libsoup-3.0-dev \
        libsoup2.4-1 \
        libsoup2.4-dev \
        libinotifytools0-dev \
        inotify-tools \
        gobject-introspection && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create developer user with sudo access
RUN useradd -m -s /bin/bash -u 1000 developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/developer/.local/bin && \
    chown -R developer:developer /home/developer

# Install Homebrew for developer user
USER developer
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/developer/.bashrc

# Add brew to PATH for subsequent RUN commands
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

USER root

# Create workspace directory with permissive permissions for any user
RUN mkdir -p /workspace && \
    chmod 777 /workspace && \
    mkdir -p /tmp/home && \
    chmod 777 /tmp/home

# Install development tools via Homebrew
USER developer
RUN brew install neovim zellij fzf bear ripgrep-all fzf-make && \
    brew cleanup

USER root

# Create vim symlink to nvim
RUN ln -sf /home/linuxbrew/.linuxbrew/bin/nvim /usr/bin/vim

# Install custom system tools from source/binaries
# These tools match the Jettison bootstrap script installations
# Split into individual RUN commands for better caching and easier debugging

# Navi - Interactive cheatsheet tool
COPY dockerfiles/base/tools/navi /tmp/tools/navi
RUN chmod +x /tmp/tools/navi/*.sh && \
    /tmp/tools/navi/install.sh && \
    rm -rf /tmp/tools/navi

# Hiredis - Redis C client library (built from source)
COPY dockerfiles/base/tools/hiredis /tmp/tools/hiredis
RUN chmod +x /tmp/tools/hiredis/*.sh && \
    /tmp/tools/hiredis/install.sh && \
    rm -rf /tmp/tools/hiredis

# Final cleanup
RUN rm -rf /tmp/tools

# Oh My Bash - Bash framework for root user
COPY dockerfiles/base/tools/oh-my-bash /tmp/tools/oh-my-bash
RUN chmod +x /tmp/tools/oh-my-bash/*.sh && \
    /tmp/tools/oh-my-bash/install.sh && \
    rm -rf /tmp/tools/oh-my-bash

# NvChad - Neovim configuration for root user
COPY dockerfiles/base/tools/nvchad /tmp/tools/nvchad
RUN chmod +x /tmp/tools/nvchad/*.sh && \
    /tmp/tools/nvchad/install.sh && \
    rm -rf /tmp/tools/nvchad

# Copy common scripts
COPY --chown=developer:developer dockerfiles/base/scripts/run_test_wrapper.sh /usr/local/bin/run_test_wrapper.sh
COPY --chown=developer:developer dockerfiles/base/scripts/check_versions.sh /usr/local/bin/check_versions.sh
RUN chmod +x /usr/local/bin/run_test_wrapper.sh /usr/local/bin/check_versions.sh

# Set up basic environment
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/developer/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
ENV USER=developer
ENV EDITOR=vim
ENV VISUAL=vim

# Switch to developer user
USER developer
WORKDIR /workspace

# Oh My Bash - Bash framework for developer user
COPY --chown=developer:developer dockerfiles/base/tools/oh-my-bash /home/developer/.install-tmp/oh-my-bash
RUN chmod +x /home/developer/.install-tmp/oh-my-bash/*.sh && \
    /home/developer/.install-tmp/oh-my-bash/install.sh && \
    rm -rf /home/developer/.install-tmp/oh-my-bash

# NvChad - Neovim configuration for developer user
COPY --chown=developer:developer dockerfiles/base/tools/nvchad /home/developer/.install-tmp/nvchad
RUN chmod +x /home/developer/.install-tmp/nvchad/*.sh && \
    /home/developer/.install-tmp/nvchad/install.sh && \
    rm -rf /home/developer/.install-tmp

# Verify all tools are installed and available
RUN /usr/local/bin/check_versions.sh

# Default command
CMD ["/bin/bash"]