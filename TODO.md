# Jettison Stack of Babel - Development Roadmap 🗼

> **jon-babylon**: A universal polyglot Docker image containing all language toolchains for Jettison project development

## 🎯 Current Status

**Overall Progress: ~80% Complete** ███████████████████░░░░░

### ✅ Completed (Phases 1-3 + Partial 4)
- **Foundation**: All project structure, directories, and configuration files created
- **Tool Installation**: All language installation scripts implemented and tested
- **Docker Optimization**: Modular staged build system with 12 optimized layers
- **Comprehensive Testing**: Enhanced test scripts for Java, Python, Rust with full tool validation
- **Testing Coverage**: Build tools, linters, formatters, static analyzers all tested
- **CI/CD Foundation**: GitHub Actions workflow for staged builds configured

### 🚧 In Progress (Phases 4-5)
- **Stage Testing**: Test each Docker stage independently during build
- **Final Testing**: Comprehensive retest after full image assembly
- **CI/CD Enhancements**: Full automation in GitHub Actions
- **Documentation**: Complete remaining developer docs

### 📅 Remaining (Phase 6)
- **Documentation & Release**: Complete tool usage examples and release preparation
- **Multi-Architecture**: Full ARM64/x86_64 support with buildx (optional)
- **Registry Publishing**: Push to GitHub Container Registry

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Tools Inventory](#tools-inventory)
- [Phase 1: Foundation & Structure](#phase-1-foundation--structure)
- [Phase 2: Tool Installation Scripts](#phase-2-tool-installation-scripts)
- [Phase 3: Docker Optimization](#phase-3-docker-optimization)
- [Phase 4: Testing Framework](#phase-4-testing-framework)
- [Phase 5: CI/CD Pipeline](#phase-5-cicd-pipeline)
- [Phase 6: Documentation & Release](#phase-6-documentation--release)
- [References & Resources](#references--resources)

## Overview

### Primary Target Platform
**NVIDIA AGX Orin (ARM64)**
- Ubuntu 22.04 LTS on ARM64
- 8/12-core ARM® Cortex®-A78AE v8.2 64-bit CPU
- Optimization: `-march=armv8.2-a -mtune=cortex-a78`
- Build Runner: `ubuntu-22.04-arm` (GitHub Actions)

### Goals
- Build a **reproducible**, **optimized** Docker image for NVIDIA Orin
- Primary: **ARM64** optimized for Cortex-A78AE
- Secondary: **x86_64** for development/testing only
- Implement **parallel CI builds** on architecture-specific runners
- Ensure **all tools work on mounted host projects** (build/lint/format/analyze)
- Test **each stage independently** and **final assembled image**

### Success Metrics
- ✅ All tools install and validate successfully
- ✅ Test suite passes for all languages
- ✅ Image builds on both architectures
- ✅ GitHub Actions CI/CD pipeline functional
- ✅ Documentation complete and accurate

## Architecture

### Directory Structure
```
jettison-stack-of-babel/
├── docker/
│   ├── Dockerfile.base          # Base system + dependencies
│   ├── Dockerfile.languages     # Programming languages layer
│   ├── Dockerfile.tools         # Build tools layer
│   ├── Dockerfile.final         # Final assembly
│   └── docker-compose.yml       # Local development
├── tools/
│   ├── java/
│   │   ├── install/
│   │   │   ├── install.sh       # OpenJDK 21 installation
│   │   │   └── verify.sh        # Version verification
│   │   ├── test/
│   │   │   ├── HelloWorld.java
│   │   │   └── run_test.sh
│   │   └── validate/
│   │       └── validate.sh      # Full validation suite
│   ├── kotlin/                  # Similar structure
│   ├── clojure/                 # Similar structure
│   ├── python/                  # Similar structure
│   ├── rust/                    # Similar structure
│   ├── nodejs/                  # Similar structure
│   ├── typescript/              # Similar structure
│   ├── clang/                   # Similar structure
│   ├── build-tools/             # Maven, Gradle, etc.
│   ├── web-tools/               # Prettier, ESLint, etc.
│   └── package-managers/        # npm, yarn, pnpm, etc.
├── tests/
│   ├── java/                    # Java project with Maven/Gradle
│   ├── kotlin/                  # Kotlin project with Gradle
│   ├── clojure/                 # Clojure project with Leiningen
│   ├── python/                  # Python project with pip/Nuitka
│   ├── rust/                    # Rust project with Cargo
│   ├── nodejs/                  # Node.js project with npm/yarn/pnpm
│   ├── web/                     # Web project with TypeScript/Lit
│   ├── c/                       # C project with clang
│   └── cpp/                     # C++ project with clang++
├── scripts/
│   ├── build.sh                 # Main build script
│   ├── test.sh                  # Test runner
│   ├── validate.sh              # Validation suite
│   └── publish.sh               # Registry publishing
├── ci/
│   ├── workflows/
│   │   ├── build.yml            # Build pipeline
│   │   ├── test.yml             # Test pipeline
│   │   └── release.yml          # Release pipeline
│   └── scripts/                 # CI helper scripts
├── docs/
│   ├── ARCHITECTURE.md         # Technical design
│   ├── TOOLS.md                 # Tool inventory & versions
│   ├── TESTING.md               # Testing guide
│   └── TROUBLESHOOTING.md       # Common issues
└── README.md                    # User documentation
```

### Docker Layer Strategy
```dockerfile
# Layer 1: Base OS + System Dependencies (changes rarely)
FROM ubuntu:22.04 AS base

# Layer 2: APT repositories & certificates (changes occasionally)
FROM base AS repositories

# Layer 3: System languages (C/C++, Python) (changes monthly)
FROM repositories AS system-languages

# Layer 4: JVM ecosystem (Java, Kotlin, Clojure) (changes quarterly)
FROM system-languages AS jvm-languages

# Layer 5: Modern languages (Rust, Node.js) (changes monthly)
FROM jvm-languages AS modern-languages

# Layer 6: Build tools & package managers (changes weekly)
FROM modern-languages AS build-tools

# Layer 7: Development tools & utilities (changes frequently)
FROM build-tools AS dev-tools

# Layer 8: Final assembly & cleanup
FROM dev-tools AS final
```

## Tools Inventory

### Programming Languages & Runtimes

| Tool | Latest Version | Source | Installation Method | Size |
|------|----------------|--------|-------------------|------|
| **OpenJDK 21 LTS** | 21.0.5 | [Eclipse Temurin](https://adoptium.net/) | APT repository | ~200MB |
| **Kotlin** | 2.1.0 | [JetBrains](https://kotlinlang.org/) | SDKMAN | ~80MB |
| **Clojure** | 1.12.0 | [Clojure.org](https://clojure.org/) | Official script | ~15MB |
| **Python** | 3.13.1 | [Python.org](https://python.org/) | pyenv | ~150MB |
| **Rust** | 1.85.0 | [Rust-lang.org](https://rust-lang.org/) | rustup | ~650MB |
| **Node.js 22 LTS** | 22.13.0 | [NodeSource](https://github.com/nodesource/distributions) | APT repository | ~100MB |
| **TypeScript** | 5.8.0 | [TypeScript](https://www.typescriptlang.org/) | npm | ~70MB |
| **LLVM/Clang 21** | 21.0.0 | [LLVM.org](https://apt.llvm.org/) | APT repository | ~500MB |

### Compilers & Transpilers

| Tool | Version | Purpose | Installation |
|------|---------|---------|-------------|
| **Nuitka** | 2.5.9 | Python → C++ | pip |
| **esbuild** | 0.25.2 | JS/TS bundler | npm |
| **Bun** | 1.2.0 | JS runtime & bundler | Official script |

### Build Tools

| Tool | Version | Ecosystem | Installation |
|------|---------|-----------|-------------|
| **Maven** | 3.9.10 | Java | Binary download |
| **Gradle** | 8.12 | Java/Kotlin | Binary download |
| **Leiningen** | 2.11.4 | Clojure | Script download |
| **Cargo** | 1.85.0 | Rust | Included with Rust |

### Package Managers

| Tool | Version | Purpose | Installation |
|------|---------|---------|-------------|
| **npm** | 10.10.0 | Node.js packages | Included with Node |
| **yarn** | 4.6.0 | Node.js packages | npm/corepack |
| **pnpm** | 9.16.0 | Efficient npm alternative | npm/corepack |
| **pip** | 24.4 | Python packages | Included with Python |

### Development Tools

| Tool | Version | Purpose | Installation |
|------|---------|---------|-------------|
| **Prettier** | 3.4.2 | Code formatting | npm |
| **ESLint** | 9.18.0 | JavaScript linting | npm |
| **@lit/localize** | 0.14.0 | Web i18n | npm |

### Web Framework Dependencies (From Jettison)

| Package | Version | Purpose |
|---------|---------|---------|
| **lit** | 3.3.1 | Web Components framework |
| **@lit/localize** | 0.12.2 | Runtime localization |
| **@lit/localize-tools** | 0.8.0 | Build-time i18n tools |
| **chroma-js** | 3.1.2 | Color manipulation |
| **twind** | 0.16.19 | Tailwind-in-JS |
| **@bufbuild/protobuf** | 2.9.0 | Protocol Buffers |
| **signal-polyfill** | 0.2.2 | Signals API polyfill |
| **class-variance-authority** | 0.7.1 | CSS class variants |
| **clsx** | 2.1.1 | Class name utility |

## Phase 1: Foundation & Structure ✅ COMPLETED

### 1.1 Repository Setup ✅
- [x] Initialize git repository
- [x] Create directory structure
- [ ] Set up branch protection rules
- [ ] Configure repository settings

### 1.2 Project Structure ✅
- [x] Create `tools/` directory hierarchy
- [x] Create `docker/` for Dockerfiles
- [x] Create `tests/` for test suites
- [x] Create `scripts/` for automation
- [x] Create `docs/` directory (empty, templates pending)

### 1.3 Configuration Files
- [x] Create comprehensive `.gitignore`
- [x] Create `.dockerignore` for build optimization
- [ ] Create `.editorconfig` for consistency
- [ ] Create `docker-compose.yml` for local development

## Phase 2: Tool Installation Scripts ✅ COMPLETED

### 2.1 Base System Scripts ✅
- [x] System dependencies (integrated in staged Dockerfiles)
- [x] APT repositories setup (integrated in staged Dockerfiles)
- [x] SSL certificates (integrated in staged Dockerfiles)

### 2.2 Language Installation Scripts

#### Java Ecosystem
- [x] `tools/java/install/install.sh`
  ```bash
  # Eclipse Temurin OpenJDK 21
  wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public | \
    gpg --dearmor > /usr/share/keyrings/adoptium.gpg
  echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] \
    https://packages.adoptium.net/artifactory/deb jammy main" | \
    tee /etc/apt/sources.list.d/adoptium.list
  apt-get update && apt-get install -y temurin-21-jdk
  ```

#### Kotlin
- [x] `tools/kotlin/install/install.sh`
  ```bash
  # Via SDKMAN
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk install kotlin
  ```

#### Clojure
- [x] `tools/clojure/install/install.sh`
  ```bash
  # Official installer
  curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh
  chmod +x linux-install.sh
  ./linux-install.sh
  ```

#### Python
- [x] `tools/python/install/install.sh`
  ```bash
  # pyenv installation
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  pyenv install 3.13.1
  pyenv global 3.13.1
  ```

#### Rust
- [x] `tools/rust/install/install.sh`
  ```bash
  # rustup installation
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --default-toolchain stable --profile default
  ```

#### Node.js
- [x] `tools/nodejs/install/install.sh`
  ```bash
  # NodeSource repository
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt-get install -y nodejs
  corepack enable  # Enable package manager support
  ```

#### LLVM/Clang
- [x] `tools/clang/install/install.sh`
  ```bash
  # LLVM official script
  wget https://apt.llvm.org/llvm.sh
  chmod +x llvm.sh
  ./llvm.sh 21 all
  ```

### 2.3 Build Tools Installation
- [x] `tools/build-tools/maven/install.sh`
- [x] `tools/build-tools/gradle/install.sh`
- [x] `tools/build-tools/leiningen/install.sh` (included in clojure)

### 2.4 Package Managers & Web Tools
- [x] `tools/package-managers/install.sh` (yarn, pnpm)
- [x] `tools/web-tools/install.sh` (prettier, eslint, etc.)

## Phase 3: Docker Optimization ✅ COMPLETED

### 3.1 Multi-Stage Dockerfile ✅
- [x] Create `docker/stages/00-base.Dockerfile`
- [x] Create language stages (01-08 Dockerfiles)
- [x] Create tool stages (09-10 Dockerfiles)
- [x] Create `docker/stages/11-final.Dockerfile`
- [x] Create main `docker/Dockerfile` (assembles all stages)
- [x] Create `docker/Dockerfile.parallel` (parallel build version)

### 3.2 Build Optimization ✅
- [x] Implement proper layer caching
- [x] Minimize layer count (12 optimized stages)
- [x] Use `.dockerignore` effectively
- [x] Implement build argument support
- [x] Add health checks

### 3.3 Multi-Architecture Support ✅
- [x] Create `Dockerfile.x86_64` for x86_64 architecture
- [x] Create `Dockerfile.arm64` with Orin optimizations
- [x] Create Makefile with architecture-specific builds
- [x] Configure parallel CI workflows for each architecture
- [x] ARM64 optimizations for Cortex-A78 (`-march=armv8.2-a -mtune=cortex-a78`)

### 3.4 Size Optimization ⚠️
- [x] Remove unnecessary packages (apt-get clean in Dockerfiles)
- [x] Clean package manager caches (rm -rf /var/lib/apt/lists/*)
- [ ] Compress binary files where possible
- [x] Use `--no-install-recommends` for APT
- [ ] Strip debug symbols from binaries

## Phase 4: Testing Framework 🚧 IN PROGRESS

### 4.1 Unit Tests (Per Tool) ✅ ENHANCED
- [x] Java: Maven/Gradle full lifecycle, dependency resolution, JAR tools
- [x] Kotlin: kotlinc, ktlint, detekt, Gradle build
- [x] Clojure: REPL, Leiningen, clj-kondo
- [x] Python: pip, black, flake8, ruff, mypy, pytest, Nuitka, venv
- [x] Rust: cargo build/test/doc/tree/bench, rustfmt, clippy
- [x] Node.js: npm/yarn/pnpm, ESLint, Prettier
- [x] TypeScript: tsc, esbuild, type checking
- [x] Clang: clang-format, clang-tidy, compilation

### 4.2 Web Stack Tests (Based on Jettison Web Module) ✅
- [x] **Bun Runtime**: Test Bun installation and package management
- [x] **TypeScript Compilation**: Verify strict mode compilation with decorators
- [x] **esbuild Bundling**: Test ES module bundling with minification
- [x] **Lit Components**: Build Web Components with TypeScript decorators
- [x] **@lit/localize**: Test i18n/l10n with runtime mode
- [x] **ESLint**: Validate TypeScript and Lit component linting
- [x] **Prettier**: Format TypeScript, JavaScript, and JSON files
- [x] **Dependencies**: Test complex dependencies (chroma-js, twind, protobuf)

#### Web Test Project Structure
```
tests/web/
├── package.json            # Bun/npm dependencies
├── tsconfig.json          # TypeScript config (strict mode)
├── eslint.config.mjs      # ESLint configuration
├── .prettierrc.json       # Prettier configuration
├── lit-localize.json      # Localization config
├── index.html             # Test page
├── run_test.sh           # Test runner script
└── src/
    ├── app.ts            # Main entry point
    ├── components/       # Lit components
    │   ├── hello-world.ts
    │   └── localized-component.ts
    └── locales/          # Localization files
        └── locale-codes.ts

### 4.3 Tool Functionality Tests ✅
- [x] Maven/Gradle build Java/Kotlin projects with full dependency management
- [x] npm/yarn/pnpm manage JavaScript dependencies
- [x] TypeScript → esbuild → bundle pipeline
- [x] Linters work on mounted projects (ESLint, ktlint, detekt, flake8, ruff, clippy, clang-tidy)
- [x] Formatters work on mounted projects (Prettier, black, rustfmt, clang-format)
- [x] Static analyzers work (mypy, cargo check, detekt)

### 4.4 Stage Testing Strategy 🚧
- [ ] Test each Docker stage independently during build
- [ ] Verify tool availability at each stage
- [ ] Run minimal test suite per stage
- [ ] Final comprehensive test after assembly

### 4.5 Security Scanning
- [ ] Trivy vulnerability scanning
- [ ] Dependency checking
- [ ] License compliance
- [ ] SBOM generation

## Phase 5: CI/CD Pipeline 🚧 IN PROGRESS

### 5.1 GitHub Actions Setup ✅
- [x] `.github/workflows/staged-build.yml`
  ```yaml
  name: Build Multi-Arch Images
  on:
    push:
      branches: [main]
    schedule:
      - cron: '0 0 * * *'  # Daily builds
  ```

### 5.2 Build Pipeline ✅
- [x] Checkout code (in staged-build.yml)
- [x] Set up Docker buildx (in staged-build.yml)
- [x] Login to GitHub Container Registry (configured)
- [x] Parallel ARM64 build on `ubuntu-22.04-arm` runner
- [x] Parallel AMD64 build on `ubuntu-22.04` runner
- [x] Shared test suite for both architectures
- [x] Push architecture-specific images to registry
- [x] Create multi-arch manifest

### 5.3 Test Pipeline
- [ ] Run on pull requests
- [ ] Execute full test suite
- [ ] Generate test reports
- [ ] Post results as PR comments

### 5.4 Release Pipeline
- [ ] Tag-based releases
- [ ] Semantic versioning
- [ ] Generate release notes
- [ ] Update documentation

### 5.5 Scheduled Maintenance
- [ ] Daily vulnerability scans
- [ ] Weekly dependency updates
- [ ] Monthly performance benchmarks
- [ ] Quarterly architecture review

## Phase 6: Documentation & Release

### 6.1 User Documentation
- [x] Comprehensive README with usage patterns
- [x] Quick start guide
- [x] Tool version matrix
- [x] Usage examples for build/lint/format
- [ ] Troubleshooting guide

### 6.2 Developer Documentation
- [ ] Architecture overview
- [ ] Contributing guide
- [ ] Testing procedures
- [ ] Release process
- [ ] Maintenance checklist

### 6.3 API Documentation
- [ ] Script interfaces
- [ ] Environment variables
- [ ] Build arguments
- [ ] Volume mounts
- [ ] Network configuration

### 6.4 Release Preparation
- [ ] Version tagging strategy
- [ ] Changelog generation
- [ ] Migration guides
- [ ] Deprecation notices
- [ ] Security advisories

## References & Resources

### Official Documentation
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

### Tool-Specific Resources
- [OpenJDK Installation](https://adoptium.net/installation/)
- [Kotlin Releases](https://github.com/JetBrains/kotlin/releases)
- [Clojure Getting Started](https://clojure.org/guides/getting_started)
- [pyenv Installation](https://github.com/pyenv/pyenv#installation)
- [Rustup Documentation](https://rust-lang.github.io/rustup/)
- [Node.js Distribution](https://github.com/nodesource/distributions)
- [LLVM APT Packages](https://apt.llvm.org/)

### Security Resources
- [Trivy Scanner](https://github.com/aquasecurity/trivy)
- [Docker Security Best Practices](https://snyk.io/blog/10-docker-image-security-best-practices/)
- [OWASP Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

### Performance Resources
- [Docker Image Optimization](https://docs.docker.com/develop/dev-best-practices/#reduce-image-size)
- [Layer Caching](https://docs.docker.com/build/cache/)
- [Multi-arch Builds](https://docs.docker.com/buildx/working-with-buildx/)

## Metrics & KPIs

### Build Metrics
- **Target Build Time**: < 30 minutes
- **Target Image Size**: < 3GB compressed
- **Layer Count**: < 20 layers
- **Cache Hit Rate**: > 80%

### Quality Metrics
- **Test Coverage**: 100% of tools
- **Security Score**: A+ (no critical vulnerabilities)
- **Documentation Coverage**: 100% of features
- **Support Response Time**: < 24 hours

### Usage Metrics
- **Daily Pulls**: Track via GHCR
- **Issue Resolution Time**: < 48 hours
- **PR Merge Time**: < 72 hours
- **User Satisfaction**: > 4.5/5 stars

## Timeline

### Week 1-2: Foundation ✅
- [x] Complete Phase 1 (Structure & Setup)
- [x] Begin Phase 2 (Installation Scripts)

### Week 3-4: Implementation ✅
- [x] Complete Phase 2 (Installation Scripts)
- [x] Complete Phase 3 (Docker Optimization)

### Week 5-6: Testing 🚧 CURRENT
- [x] Partial Phase 4 (Unit & Web tests complete)
- [ ] Complete Phase 4 (Integration & performance tests pending)
- [x] Begin Phase 5 (CI/CD Pipeline started)

### Week 7-8: Automation
- Complete Phase 5 (CI/CD Pipeline)
- Complete Phase 6 (Documentation)

### Week 9-10: Release
- Final testing and optimization
- Public release preparation
- Documentation review
- Launch announcement

---

**Last Updated**: September 2025 (Enhanced Testing)
**Maintainers**: Jettison Team
**License**: See LICENSE file
**Contributing**: See CONTRIBUTING.md