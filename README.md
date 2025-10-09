# Jettison Stack of Babel 🗼

A collection of specialized polyglot Docker containers for the Jettison project.

## 🎯 Architecture

**Split Container Design**: Instead of one monolithic image, we provide 7 specialized containers that can be used independently or together:

| Container | Purpose | Base |
|-----------|---------|------|
| `jon-babylon-base` | Common tools & user setup | Ubuntu 22.04 |
| `jon-babylon-jvm` | Java, Kotlin, Clojure | base |
| `jon-babylon-clang` | C/C++ development | base |
| `jon-babylon-python` | Python with Nuitka | clang |
| `jon-babylon-rust` | Rust with C/C++ FFI | clang |
| `jon-babylon-go` | Go development | base |
| `jon-babylon-web` | Node.js, TypeScript, Bun | base |

## 🎯 Benefits

- **Smaller Images**: Each container only includes what it needs
- **Faster Builds**: Containers build in parallel
- **Better Caching**: Changes to one toolchain don't invalidate others
- **Flexibility**: Use only the containers you need
- **Multi-arch**: All containers support both AMD64 and ARM64

## 🚀 Quick Start

### Using Individual Containers

```bash
# Java/Kotlin/Clojure Development
docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace \
  ghcr.io/lpportorino/jon-babylon-jvm:latest

# Python Development with Nuitka
docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace \
  ghcr.io/lpportorino/jon-babylon-python:latest

# Rust Development
docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace \
  ghcr.io/lpportorino/jon-babylon-rust:latest

# Web Development (Node.js, TypeScript, Bun)
docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace \
  ghcr.io/lpportorino/jon-babylon-web:latest

# C/C++ Development
docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace \
  ghcr.io/lpportorino/jon-babylon-clang:latest

# Go Development
docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace \
  ghcr.io/lpportorino/jon-babylon-go:latest
```

**Note**: The `-u $(id -u):$(id -g)` flag runs the container with your host user ID, ensuring files created in the container have proper ownership on your host system.

### Running Containers Interactively

```bash
# Run locally built images
docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace \
  jon-babylon-jvm:latest

docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace \
  jon-babylon-python:latest

docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace \
  jon-babylon-rust:latest
```

## 📦 Container Details

### Base Container (`jon-babylon-base`)
Foundation for all other containers with comprehensive development tooling:

**System Foundation:**
- Ubuntu 22.04 LTS
- Developer user (UID 1000)
- Workspace at `/workspace`
- Environment: `EDITOR=vim`, `VISUAL=vim` (neovim with vim symlink)

**System Utilities:**
- curl, wget, rsync, openssh-client, mosh, socat
- git, nano, tmux, htop, tree, less
- jq, bc, xxd, gawk
- GNU parallel, gdb, stow

**Compression Tools:**
- zip, unzip, p7zip-full, xz-utils

**Build Tools:**
- build-essential (gcc, g++, make)
- pkg-config, autoconf, automake, libtool
- bison, flex, m4, texinfo
- ccache, patchelf

**CMake (from Kitware):**
- cmake, cmake-curses-gui, cmake-extras

**Debugging Tools:**
- valgrind, strace, sshpass

**Media Tools:**
- ffmpeg

**Hardware Interface Tools:**
- can-utils (CAN bus), i2c-tools (I2C), minicom (serial)

**Database Clients:**
- postgresql-client (psql), redis-tools (redis-cli)

**Development Headers:**
- libssl-dev, libpq-dev, libczmq-dev
- libnm-dev, uuid-dev, libglib2.0-dev
- gobject-introspection, libjson-glib-dev
- libsoup-3.0-dev, libsoup2.4-dev, libinotifytools0-dev

**Runtime Libraries:**
- libssl3, libpq5, libczmq4, libnm0
- libglib2.0-0, libjson-glib-1.0-0
- libsoup-3.0-0, libsoup2.4-1, inotify-tools

**Homebrew Package Manager:**
- **Homebrew** - Package manager for the developer user, used to install development tools

**Tools Installed via Homebrew:**
- **Neovim** (latest) - Modern extensible text editor
- **Zellij** - Modern terminal multiplexer
- **FZF** - Fuzzy finder for command line
- **Bear** - Compilation database generator for C/C++
- **Ripgrep-all (rga)** - Recursive search with support for PDFs, archives, and more
- **fzf-make** - Interactive Make target selector

**Custom Built Tools:**
- **Navi 2.24.0** - Interactive cheatsheet tool
- **Hiredis 1.3.0** - Redis C client library (built from source with ARM64 Cortex-A78 optimizations)

**Shell and Editor Configurations:**
- **Oh My Bash** - Bash framework with all plugins enabled (installed for root and developer users)
  - Plugins: ansible, asdf, aws, bash-preexec, bashmarks, battery, brew, cargo, colored-man-pages, chezmoi, dotnet, fasd, fzf, gcloud, git, goenv, golang, jump, kubectl, npm, nvm, pyenv, rbenv, sdkman, sudo, tmux-autoattach, vagrant, virtualenvwrapper, xterm, zellij-autoattach, zoxide
- **NvChad** - Neovim configuration with modern IDE features (installed for root and developer users)
  - Pre-configured with Lazy.nvim plugin manager
  - Mason for LSP/DAP/linter/formatter management

### JVM Container (`jon-babylon-jvm`)
Complete JVM ecosystem:
- **Java 25 LTS** (Temurin) via SDKMAN
- **Kotlin 2.2.20** via SDKMAN
- **Clojure 1.12.3** with CLI tools
- **Maven 3.9.11** - Project management
- **Gradle 9.1.0** - Build automation
- **Leiningen 2.12.0** - Clojure builds
- **ktlint 1.7.1** - Kotlin linter
- **detekt 1.23.8** - Kotlin static analysis
- **clj-kondo** - Clojure linter

### Clang Container (`jon-babylon-clang`)
Modern C/C++ development:
- **LLVM/Clang 21** - Latest compiler
- **clang-format** - Code formatting
- **clang-tidy** - Static analysis
- **CMake** - Build system
- **Ninja** - Fast builds
- **ccache** - Compilation cache
- **valgrind** - Memory debugging
- **gdb** - Debugger

### Python Container (`jon-babylon-python`)
Python with compilation support:
- **Python 3.13.7** - Latest stable
- **Python 3.12.8** - Previous stable
- **pyenv** - Version management
- **Nuitka 2.7.16** - Python compiler
- **black** - Code formatter
- **flake8** - Style checker
- **mypy** - Type checker
- **ruff** - Fast linter
- **pytest** - Testing framework
- **jupyter** - Interactive notebooks

### Rust Container (`jon-babylon-rust`)
Complete Rust toolchain:
- **Rust stable** - Latest via rustup
- **Cargo** - Package manager
- **rustfmt** - Code formatter
- **clippy** - Linter
- **cargo-audit** - Security audits
- **cargo-outdated** - Dependency updates
- **cargo-edit** - Cargo.toml management
- **cargo-watch** - Auto-rebuild

### Go Container (`jon-babylon-go`)
Go development environment:
- **Go 1.25.1** - Latest version
- **golangci-lint** - Meta linter
- **go-task** - Task runner
- **air** - Live reload
- **gopls** - Language server
- **goimports** - Import management
- **delve** - Debugger

### Web Container (`jon-babylon-web`)
Modern web development:
- **Node.js 22.20.0** - LTS version
- **Bun 1.1.45** - Fast runtime
- **TypeScript 5.9.2** - Type safety
- **npm/yarn/pnpm** - Package managers
- **esbuild** - Fast bundler
- **Vite** - Modern build tool
- **Prettier** - Code formatter
- **ESLint** - JavaScript linter
- **tsx** - TypeScript executor
- **webpack/parcel/rollup** - Bundlers

## 🏗️ Building from Source

### Build All Containers (Recommended)
```bash
# Use the build script to build all containers in the correct order
./build-local.sh
```

This script builds containers in dependency order:
1. `base` - Foundation for all containers
2. `clang` - C/C++ tools (depends on base)
3. `jvm`, `go`, `web` - Language containers (depend on base)
4. `python`, `rust` - Python with Nuitka and Rust with C/C++ FFI (depend on clang)

### Build Individual Containers

```bash
# Build base first (required by all)
docker build -t jon-babylon-base:latest -f dockerfiles/base/Dockerfile .

# Build clang (required by python)
docker build -t jon-babylon-clang:latest \
  --build-arg BASE_IMAGE=jon-babylon-base:latest \
  -f dockerfiles/clang/Dockerfile .

# Build other containers (each requires base)
docker build -t jon-babylon-jvm:latest \
  --build-arg BASE_IMAGE=jon-babylon-base:latest \
  -f dockerfiles/jvm/Dockerfile .

docker build -t jon-babylon-go:latest \
  --build-arg BASE_IMAGE=jon-babylon-base:latest \
  -f dockerfiles/go/Dockerfile .

docker build -t jon-babylon-web:latest \
  --build-arg BASE_IMAGE=jon-babylon-base:latest \
  -f dockerfiles/web/Dockerfile .

# Build python and rust (require clang for C/C++ integration)
docker build -t jon-babylon-python:latest \
  --build-arg CLANG_IMAGE=jon-babylon-clang:latest \
  -f dockerfiles/python/Dockerfile .

docker build -t jon-babylon-rust:latest \
  --build-arg CLANG_IMAGE=jon-babylon-clang:latest \
  -f dockerfiles/rust/Dockerfile .
```

## 🧪 Testing

Each container includes comprehensive test suites and a version check script:

```bash
# Check all tools in a container
docker run --rm ghcr.io/lpportorino/jon-babylon-base:latest check_versions.sh
docker run --rm ghcr.io/lpportorino/jon-babylon-jvm:latest check_versions.sh
docker run --rm ghcr.io/lpportorino/jon-babylon-python:latest check_versions.sh
docker run --rm ghcr.io/lpportorino/jon-babylon-rust:latest check_versions.sh
```

The base container's `check_versions.sh` verifies **60+ tools** including:
- All system utilities and compression tools
- Complete build toolchain (gcc, make, cmake, autoconf, etc.)
- Debugging tools (valgrind, strace, gdb)
- Hardware interface tools (can-utils, i2c-tools)
- Database clients (psql, redis-cli)
- Homebrew-managed tools (neovim, zellij, fzf, bear, ripgrep-all, fzf-make)
- Custom built tools (navi, hiredis)
- Development libraries (hiredis, libssl)
- Shell and editor configurations (Oh My Bash, NvChad)
- Environment variables (EDITOR, VISUAL)

### Local Testing

Run the comprehensive test suite locally:

```bash
# Run all container tests
./test-local.sh

# Tests include:
# - Java/Maven/Gradle compilation
# - Kotlin/Clojure projects
# - C/C++ compilation with Clang
# - Python/Nuitka compilation
# - Rust cargo builds
# - Go module tests
# - Node.js/TypeScript/Bun tests
```

Tests are automatically run in CI/CD before pushing images to the registry, ensuring all tools are properly installed and functioning.

## 📊 Multi-Architecture Support

All containers are built natively for both AMD64 and ARM64 architectures using GitHub's native runners (no QEMU emulation), ensuring:
- Native performance on all platforms
- Full compatibility with Apple Silicon Macs
- Optimized for AWS Graviton instances
- Perfect for traditional x86_64 systems

## 🔄 CI/CD

GitHub Actions automatically:
1. Builds all containers in parallel on native runners (AMD64 and ARM64)
2. Runs comprehensive test suites for each container
3. Only pushes to GitHub Container Registry if all tests pass
4. Creates multi-arch manifests for seamless platform support

Build status: ![Build Status](https://github.com/lpportorino/jettison-stack-of-babel/actions/workflows/build-split.yml/badge.svg)

## 📁 Project Structure

```
jettison-stack-of-babel/
├── dockerfiles/           # Container definitions
│   ├── base/             # Base container with common tools
│   │   ├── tools/        # Custom tool installation scripts
│   │   │   ├── navi/     # Navi installer
│   │   │   ├── hiredis/  # Hiredis build script
│   │   │   ├── oh-my-bash/ # Oh My Bash installer
│   │   │   └── nvchad/   # NvChad installer
│   │   ├── scripts/      # Utility scripts
│   │   └── tests/        # Base container tests
│   ├── jvm/              # Java/Kotlin/Clojure
│   │   └── tests/        # JVM language tests
│   ├── clang/            # C/C++ tools
│   │   └── tests/        # C/C++ compilation tests
│   ├── python/           # Python with Nuitka
│   │   └── tests/        # Python/Nuitka tests
│   ├── rust/             # Rust toolchain
│   │   └── tests/        # Rust cargo tests
│   ├── go/               # Go development
│   │   └── tests/        # Go module tests
│   └── web/              # Node.js/Web tools
│       └── tests/        # Web/TypeScript tests
├── build-local.sh        # Local build script (recommended)
├── test-local.sh         # Local test runner
└── .github/workflows/    # CI/CD pipelines
```

## 🔧 Configuration

### Environment Variables

All containers respect these variables:
- `WORKSPACE`: Default `/workspace`
- `USER`: Default `developer`
- `EDITOR`: Default `vim` (neovim)
- `VISUAL`: Default `vim` (neovim)

Tool-specific environment variables:
- **JVM**: `JAVA_HOME=/opt/sdkman/candidates/java/current`, `SDKMAN_DIR=/opt/sdkman`
- **Go**: `GOROOT=/usr/local/go`, `GOPATH=/opt/go`
- **Rust**: `CARGO_HOME=/opt/cargo`, `RUSTUP_HOME=/opt/rustup`
- **Python**: `PYENV_ROOT=/opt/pyenv`
- **Web**: `BUN_INSTALL=/opt/bun`

All language tools are installed in `/opt` for consistency across containers.

### Volume Mounts

Standard mount pattern:
```bash
docker run -v $(pwd):/workspace container:tag
```

### User Permissions

Containers support flexible user permissions:

```bash
# Run with your host user ID (recommended for development)
docker run -it --rm -u $(id -u):$(id -g) -v $(pwd):/workspace container:tag

# Run as default developer user (UID 1000)
docker run -it --rm -v $(pwd):/workspace container:tag

# Run as root (for system-level operations)
docker run -it --rm --user root -v $(pwd):/workspace container:tag
```

The containers are optimized to work with any user ID, making them perfect for:
- Local development with proper file ownership
- CI/CD pipelines with runner-specific users
- Multi-user development environments

## 🔌 Using with Dev Containers

These containers are designed to work seamlessly with VS Code Dev Containers and GitHub Codespaces. Create a `.devcontainer/devcontainer.json` in your project:

### Basic Configuration

```jsonc
{
  "name": "My Project",
  "image": "ghcr.io/lpportorino/jon-babylon-base:latest",
  // Or use a language-specific container:
  // "image": "ghcr.io/lpportorino/jon-babylon-rust:latest",

  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.cpptools",
        "llvm-vs-code-extensions.vscode-clangd"
      ]
    }
  }
}
```

### Persisting Configurations

To persist your Oh My Bash and NvChad configurations across container rebuilds, mount them to your host:

```jsonc
{
  "name": "My Project",
  "image": "ghcr.io/lpportorino/jon-babylon-base:latest",

  "mounts": [
    // Persist Oh My Bash configuration
    "source=${localWorkspaceFolder}/.devcontainer/oh-my-bash,target=/home/developer/.oh-my-bash,type=bind",
    "source=${localWorkspaceFolder}/.devcontainer/bashrc,target=/home/developer/.bashrc,type=bind",

    // Persist NvChad configuration and plugins
    "source=${localWorkspaceFolder}/.devcontainer/nvim,target=/home/developer/.config/nvim,type=bind",
    "source=${localWorkspaceFolder}/.devcontainer/nvim-data,target=/home/developer/.local/share/nvim,type=bind"
  ],

  // Initialize configs on first run
  "postCreateCommand": "test -d .devcontainer/oh-my-bash || cp -r ~/.oh-my-bash .devcontainer/ && test -d .devcontainer/nvim || cp -r ~/.config/nvim .devcontainer/"
}
```

### Adding Navi Cheat Sheets

Create custom navi cheat sheets for your project-specific commands:

```jsonc
{
  "name": "My Project",
  "image": "ghcr.io/lpportorino/jon-babylon-base:latest",

  "mounts": [
    // Add custom navi cheats
    "source=${localWorkspaceFolder}/.devcontainer/navi-cheats,target=/home/developer/.local/share/navi/cheats/custom,type=bind"
  ]
}
```

Create cheat sheets in `.devcontainer/navi-cheats/`:

```bash
# .devcontainer/navi-cheats/project.cheat
% myproject, build

# Build the project
make build

# Run tests
make test

# Deploy to staging
make deploy ENV=staging

$ ENV: echo -e "staging\nproduction"
```

### Using Dev Container Features

Extend containers with additional tools using [Dev Container Features](https://containers.dev/features):

```jsonc
{
  "name": "My Project",
  "image": "ghcr.io/lpportorino/jon-babylon-rust:latest",

  "features": {
    // Add GitHub CLI
    "ghcr.io/devcontainers/features/github-cli:1": {},

    // Add Docker-in-Docker
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},

    // Add AWS CLI
    "ghcr.io/devcontainers/features/aws-cli:1": {},

    // Add Terraform
    "ghcr.io/devcontainers/features/terraform:1": {
      "version": "latest"
    }
  }
}
```

**Search for more features at**: https://containers.dev/features

### Complete Example

```jsonc
{
  "name": "Full Stack Project",
  "image": "ghcr.io/lpportorino/jon-babylon-web:latest",

  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },

  "mounts": [
    // Persist shell configuration
    "source=${localWorkspaceFolder}/.devcontainer/bashrc,target=/home/developer/.bashrc,type=bind",

    // Persist NvChad config
    "source=${localWorkspaceFolder}/.devcontainer/nvim,target=/home/developer/.config/nvim,type=bind",

    // Add project-specific navi cheats
    "source=${localWorkspaceFolder}/.devcontainer/navi-cheats,target=/home/developer/.local/share/navi/cheats/custom,type=bind"
  ],

  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
      }
    }
  },

  "postCreateCommand": "npm install",

  "remoteUser": "developer"
}
```

## 🚢 Container Selection Guide

Choose containers based on your project needs:

- **JVM**: For Java, Kotlin, Clojure, Android, or any JVM-based development
- **Clang**: For C/C++ system programming, embedded development, or high-performance computing
- **Python**: For data science, machine learning, scripting, or compiled Python applications
- **Rust**: For systems programming, WebAssembly, or memory-safe applications
- **Go**: For cloud-native applications, microservices, or CLI tools
- **Web**: For frontend development, Node.js backends, or full-stack JavaScript/TypeScript projects

## 🏷️ Tags

All containers follow this tagging scheme:
- `latest` - Latest multi-arch build
- `latest-amd64` - Latest AMD64 build
- `latest-arm64` - Latest ARM64 build
- `{sha}` - Specific commit (multi-arch)
- `{sha}-amd64` - Specific commit AMD64
- `{sha}-arm64` - Specific commit ARM64

## 📄 License

This project (including Dockerfiles, scripts, and configuration) is licensed under the GNU General Public License v3.0 (GPL-3.0) - see the [LICENSE](LICENSE) file for details.

### ⚠️ Important License Notice

**The tools and software packages installed within the Docker image retain their original licenses.**
