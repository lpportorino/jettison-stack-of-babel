# Jettison Stack of Babel 🗼

A universal polyglot Docker image (`jon-babylon`) containing all language toolchains and development tools for the Jettison project. Named after the Tower of Babel for its extreme multilingual capabilities.

## 🎯 Purpose

Provides a consistent, reproducible development environment with all necessary compilers, interpreters, and build tools for Jettison's diverse technology stack, eliminating the need to install these tools directly on host systems.

## 📦 Included Tools

### Programming Languages
- **Java** - OpenJDK 21 LTS
- **Kotlin** - Latest stable (2.1.x)
- **Clojure** - Latest stable (1.12.x) with Leiningen
- **Python** - 3.12+ via pyenv
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

### Build a Project
```bash
# Java
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  javac Main.java && java Main

# Python with Nuitka
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  nuitka3 --standalone --onefile main.py

# TypeScript
docker run --rm -v $(pwd):/workspace -w /workspace \
  ghcr.io/lpportorino/jon-babylon:latest \
  tsc main.ts && node main.js
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

## 🧪 Testing

Run the test suite to validate all tools:
```bash
./scripts/test_local.sh
```

This will:
1. Build the image locally
2. Check all tool versions
3. Build sample projects for each language
4. Generate a test report

## 🛠️ Development

### Project Structure
```
jettison-stack-of-babel/
├── Dockerfile.arm64      # Production ARM64 image
├── Dockerfile.x86_64     # Development x86_64 image
├── scripts/
│   ├── build.sh          # Build script
│   ├── test_local.sh     # Local testing
│   ├── check_versions.sh # Version validation
│   └── run.sh           # Convenience wrapper
├── tests/               # Test projects for each language
│   ├── java/
│   ├── kotlin/
│   ├── clojure/
│   ├── python/
│   ├── typescript/
│   └── web/
├── .github/workflows/   # GitHub Actions CI/CD
│   ├── build-and-push.yml
│   └── test.yml
├── TODO.md             # Development roadmap
└── README.md           # This file
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