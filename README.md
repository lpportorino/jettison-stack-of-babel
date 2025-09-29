# Jettison Stack of Babel 🗼

A universal polyglot Docker image (`jon-babylon`) containing all language toolchains and development tools for the Jettison project. Named after the Tower of Babel for its extreme multilingual capabilities.

## 🎯 Primary Target Platform

**Ubuntu 22.04 ARM64 on NVIDIA AGX Orin**

### Supported Hardware Configurations:
- **Orin NX**: 8-core ARM® Cortex®-A78AE v8.2 64-bit CPU (2MB L2 + 4MB L3)
- **Orin AGX**: 12-core ARM® Cortex®-A78AE v8.2 64-bit CPU (3MB L2 + 6MB L3)

> **Note**: The AMD64 variant is provided for local development and testing only. All optimizations target ARM64 architecture.

## 🎯 Purpose

Provides a consistent, reproducible development environment with all necessary compilers, interpreters, linters, formatters, and build tools for Jettison's diverse technology stack. Mount your host project into the container to build, lint, format, and analyze code without installing tools locally. The image is optimized for ARM64 execution on NVIDIA Orin platforms.

## 📦 Included Tools

### Programming Languages
- **Java** - OpenJDK 21 LTS
- **Kotlin** - Latest stable (2.1.x)
- **Clojure** - Latest stable (1.12.x) with Leiningen
- **Python** - 3.12+ via pyenv
- **Rust** - Latest stable (1.85.x) via rustup
- **JavaScript/TypeScript** - Node.js 22 LTS
- **C/C++** - LLVM/Clang 21

### Compilers & Transpilers
- **Nuitka** - Python to C++ compiler
- **TypeScript** - JavaScript with types
- **esbuild** - Fast JavaScript/TypeScript bundler
- **Bun** - All-in-one JavaScript runtime

### Build Tools
- **Maven** - Java/Kotlin build tool
- **Gradle** - Modern build automation
- **Leiningen** - Clojure project automation
- **Cargo** - Rust package manager and build tool
- **npm/yarn/pnpm** - JavaScript package managers

### Code Quality Tools

#### Linters
- **ESLint** - JavaScript/TypeScript linting
- **ktlint** - Kotlin code style checker
- **detekt** - Kotlin static analyzer
- **flake8** - Python style guide enforcement
- **ruff** - Fast Python linter
- **mypy** - Python static type checker
- **clippy** - Rust linter
- **clang-tidy** - C/C++ static analyzer

#### Formatters
- **Prettier** - Multi-language code formatter (JS/TS/JSON/CSS/MD)
- **black** - Python code formatter
- **rustfmt** - Rust code formatter
- **clang-format** - C/C++ code formatter

### Web Development
- **@lit/localize** - Internationalization for Lit
- **TypeScript** - JavaScript with types
- **esbuild** - Fast bundler
- **Bun** - All-in-one JavaScript runtime

## 🚀 Quick Start

### Pull the Image
```bash
docker pull ghcr.io/lpportorino/jon-babylon:latest
```

### Run Interactive Shell
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  bash
```

### Common Usage Patterns

#### Build Projects
```bash
# Java with Maven
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  mvn clean package

# Rust with Cargo
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  cargo build --release

# TypeScript with esbuild
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  esbuild src/index.ts --bundle --outfile=dist/app.js
```

#### Lint & Format Code
```bash
# ESLint for JavaScript/TypeScript
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  eslint src/ --fix

# Prettier for multiple file types
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  prettier --write "**/*.{js,ts,json,css,md}"

# Rust formatting and linting
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  cargo fmt && cargo clippy
```

#### Static Analysis
```bash
# Python type checking
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  mypy src/

# C++ analysis with clang-tidy
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  clang-tidy src/*.cpp
```

## 🏗️ Architecture Support

### Primary Target (Production)
- **Platform**: ARM64/aarch64
- **Hardware**: NVIDIA AGX Orin
- **Build Runner**: `ubuntu-22.04-arm` (GitHub Actions)
- **Optimization**: `-march=armv8.2-a -mtune=cortex-a78`

### Secondary Target (Development/Testing)
- **Platform**: x86_64/amd64
- **Hardware**: Development workstations
- **Build Runner**: `ubuntu-22.04` (GitHub Actions)
- **Purpose**: Local development and testing only

Both architectures are built in parallel using separate GitHub Actions workflows and pushed to GitHub Container Registry with architecture-specific tags.

## 🔧 Building Locally

### Quick Start (Universal Build Script)
```bash
# Automatic architecture detection and optimized build
./build-local.sh

# Build without cache
./build-local.sh --no-cache

# Quick build (skip tests)
./build-local.sh --quick

# Build and push to registry
./build-local.sh --push

# Just run tests on existing image
./build-local.sh --test-only
```

The `build-local.sh` script automatically:
- Detects your architecture (ARM64 or AMD64)
- Selects the appropriate Dockerfile
- Applies optimizations (Cortex-A78 for NVIDIA Orin)
- Uses Docker Buildx if available
- Runs basic validation tests
- Shows build summary and usage instructions

### Using Makefile
```bash
# Show available targets
make help

# Build for current architecture
make build

# Build optimized for NVIDIA Orin (ARM64)
make build-arm64

# Build for AMD64 (testing only)
make build-amd64

# Build both architectures
make build-multi

# Run tests
make test
```

### Manual Build
```bash
# Build for ARM64 with Orin optimizations
docker buildx build --platform linux/arm64 \
  --build-arg MARCH=armv8.2-a \
  --build-arg MTUNE=cortex-a78 \
  -t jon-babylon:arm64 -f Dockerfile.arm64 .

# Build for x86_64 (testing only)
docker build -t jon-babylon:x86_64 -f Dockerfile.x86_64 .
```

## 📋 Version Management

All tools are installed using official package repositories or installation scripts to ensure we get the latest stable versions without building from source.

### Check Installed Versions
```bash
docker run --rm ghcr.io/lpportorino/jon-babylon:latest \
  /scripts/check_versions.sh
```

## 🔄 CI/CD Pipeline

### Parallel Architecture Builds
The images are built in parallel on architecture-specific runners:

#### ARM64 Workflow (`build-arm64.yml`)
- **Runner**: `ubuntu-22.04-arm`
- **Target**: NVIDIA AGX Orin
- **Optimizations**: ARMv8.2-A with Cortex-A78 tuning
- **Tags**: `latest-arm64`, `<version>-arm64`

#### AMD64 Workflow (`build-amd64.yml`)
- **Runner**: `ubuntu-22.04`
- **Target**: Development/Testing
- **Optimizations**: Generic x86-64
- **Tags**: `latest-amd64`, `<version>-amd64`

### Trigger Conditions
- Push to `main` branch
- New release tags
- Daily at 00:00 UTC (tool updates)
- Manual workflow dispatch

### Build Process
1. **Parallel Builds**: ARM64 and AMD64 build simultaneously on different runners
2. **Shared Tests**: Both architectures run the same test suite (`tests/`)
3. **Version Validation**: Check all tool versions
4. **Integration Tests**: Build sample projects for each language
5. **Registry Push**: Push architecture-specific images
6. **Manifest Creation**: Create multi-arch manifest linking both images

## 📊 Image Details

### Base Image
- **OS**: Ubuntu 22.04 LTS
- **Primary Architecture**: ARM64 (optimized for NVIDIA Orin)
- **Secondary Architecture**: AMD64 (for testing)

### Image Metrics
- **Size**: ~2.5-3GB compressed
- **Build Time**: ~20-30 minutes per architecture
- **Registry**: `ghcr.io/lpportorino/jon-babylon`

### Image Tags
```bash
# Multi-arch manifest (pulls correct architecture automatically)
ghcr.io/lpportorino/jon-babylon:latest

# Architecture-specific tags
ghcr.io/lpportorino/jon-babylon:latest-arm64    # NVIDIA Orin optimized
ghcr.io/lpportorino/jon-babylon:latest-amd64    # Testing only

# Version tags
ghcr.io/lpportorino/jon-babylon:2024.01.15      # Date-based
ghcr.io/lpportorino/jon-babylon:2024.01.15-arm64
ghcr.io/lpportorino/jon-babylon:2024.01.15-amd64

# Git commit tags
ghcr.io/lpportorino/jon-babylon:<git-sha>
ghcr.io/lpportorino/jon-babylon:<git-sha>-arm64
ghcr.io/lpportorino/jon-babylon:<git-sha>-amd64
```

## 🧪 Testing Strategy

### Stage Testing
Each Docker build stage is tested independently:
```bash
# Test a specific stage
./docker/tests/test-stage.sh 05-python
```

### Tool Testing
Each tool is tested with a real project:
```bash
# Run all tests
./run_all_tests.sh

# Test specific language
./tests/java/run_test.sh
./tests/python/run_test.sh
./tests/rust/run_test.sh
```

### What We Test
1. **Build Tools**: Can compile/build projects (Maven, Cargo, npm, etc.)
2. **Linters**: Can analyze code (ESLint, clippy, mypy, etc.)
3. **Formatters**: Can format code (Prettier, rustfmt, clang-format, etc.)
4. **Package Managers**: Can install dependencies (pip, npm, cargo, etc.)
5. **Final Assembly**: All tools work in the complete image

## 🛠️ Development

### Project Structure
```
jettison-stack-of-babel/
├── docker/
│   ├── stages/          # Modular Docker stages (00-11)
│   ├── Dockerfile       # Main assembly file
│   └── tests/           # Stage testing scripts
├── tools/               # Installation scripts per tool
│   ├── java/
│   ├── python/
│   ├── rust/
│   └── ...
├── tests/               # Test projects with linters/formatters
│   ├── java/            # Maven + Gradle configs
│   ├── python/          # pip + mypy + black configs
│   ├── rust/            # Cargo + clippy + rustfmt
│   ├── web/             # TypeScript + ESLint + Prettier
│   └── ...
├── scripts/
│   ├── build-staged.sh  # Staged build script
│   └── check_versions.sh
├── .github/workflows/
│   └── staged-build.yml # CI/CD pipeline
└── Dockerfile.x86_64    # x86_64 specific build
```

### Adding New Tools

1. Update the appropriate Dockerfile
2. Add version check to `scripts/check_versions.sh`
3. Create a test project in `tests/`
4. Update this README
5. Submit a PR with tests passing

## 🔐 Security

- Base image updated weekly via automated builds
- Security scanning via Trivy on each build
- Dependabot enabled for dependency updates
- No credentials or secrets included in image

## 📝 License

This project is part of the Jettison ecosystem and follows its licensing terms.

## 🤝 Contributing

Contributions are welcome! Please:
1. Check the TODO.md for planned features
2. Test your changes locally first
3. Ensure all existing tests pass
4. Add tests for new functionality
5. Update documentation as needed

## 🔗 Related Projects

- [Jettison](https://github.com/lpportorino/jettison) - Main project repository
- [Jettison Documentation](https://github.com/lpportorino/jettison/docs) - Project documentation

## 📞 Support

For issues or questions:
- Open an issue in this repository
- Check existing issues for solutions
- Consult the Jettison documentation

---

**Note**: This image is optimized for the Jettison project's specific needs but can be used for any polyglot development requiring these tools.