# Jettison Stack of Babel 🗼

A universal polyglot Docker image (`jon-babylon`) containing all language toolchains and development tools for the Jettison project. Named after the Tower of Babel for its extreme multilingual capabilities.

## 🎯 Purpose

Provides a consistent, reproducible development environment with all necessary compilers, interpreters, linters, formatters, and build tools for Jettison's diverse technology stack. Mount your host project into the container to build, lint, format, and analyze code without installing tools locally.

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

### Web Development
- **@lit/localize** - Internationalization for Lit
- **Prettier** - Code formatter
- **ESLint** - JavaScript linter

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

- **Primary**: ARM64/aarch64 (NVIDIA Orin, Raspberry Pi 4+)
- **Secondary**: x86_64/amd64 (Development workstations)

Images are automatically built for both architectures and published to GitHub Container Registry.

## 🔧 Building Locally

### For Current Architecture
```bash
./scripts/build.sh
```

### For Specific Architecture
```bash
# Build for ARM64 on x86_64 (requires Docker Buildx)
docker buildx build --platform linux/arm64 -t jon-babylon:arm64 -f Dockerfile.arm64 .

# Build for x86_64
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

The image is automatically built and published via GitHub Actions when:
- Code is pushed to the `main` branch
- A new release is tagged
- Daily at 00:00 UTC (to pick up tool updates)

### Workflow
1. Build multi-architecture images
2. Run version validation tests
3. Build test projects for each language
4. Push to GitHub Container Registry if all tests pass

## 📊 Image Details

- **Base**: Ubuntu 22.04 LTS
- **Size**: ~2.5-3GB compressed
- **Build Time**: ~20-30 minutes
- **Registry**: `ghcr.io/lpportorino/jon-babylon`

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